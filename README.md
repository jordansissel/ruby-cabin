# Logging kind of sucks.

I want:

## Context and Structured Data

because logging with printf makes it hard to read later.

Why write code that's easy to maintain but not write logs that are the same?
Structured data means you don't need crazy regular expression skills to make
sense of logs.

## Output logs to multiple targets

Why not log to a file, a database, and a websocket at the same time? What if
you could log to any output logstash supported right from your application?

## Log levels

What did the application programmer think of the importance and meaning of a
log message?

Is the usual list of fatal, error, warning, info, and debug sufficient?

## Easy shared logging configuration through an application

It should be easy for your entire application (and all libraries you use) to
use the same logging configuration.

## API that encourages tracking metrics, latencies, etc

Your applications and libraries would be vastly easier to debug, scale, and
maintain if they exposed metrics about ongoing behaviors. Keep a count of HTTP
hits by response code, count errors, time latencies, etc.

## Separation of Data and View

Using printf or similar logging methods is bad because you are merging your
data with your view of that data.

I want to be able to log in a structured way and have the log output know how
that should be formatted. Maybe for humans, maybe for computers (as JSON), maybe
as some other format. Mabye you want to log to a csv file because that's easy
to load into Excel for analysis, but you don't want to change all your
applications log methods?

# What is out there?

log4j has the context bits (see
[MDC](http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/MDC.html)
and
[NDC](http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/NDC.html)).

Ruby's Logger has almost none of this. Same with Python's standard 'logging' module. Node doesn't really have any logging tools. Java has many, including log4j mentioned above, and misses much of the above.

# Zoom out for a moment

Many logging tools are fixated on only purpose. Some logging tools are for
debugging and troubleshooting. Some are for logging usage for billing and
accounting. Some logs are for recording transactions for rollback or replay.

Ultimately all of these things are, roughly, a timestamp and some data. Debug
logs will have messages and context. Billing logs will have customer info and
usage metrics. Transaction logs will include operations performed.

For troubleshooting-style logs, it can make sense to use a "level" concept
where some logs have a higher degree of importance or different meaning. In
billing logs, what is "info" vs "fatal," and would you even have such a thing?

We can do better than requiring three different kinds of log libraries and
tools for each of these three problems.

# Why experiment with this?

Logging plain-text strings is just plain shit. You need to be a regexp ninja
to make any kind of aggregated sense out of anything more than a single log
event.

* How many customers signed up yesterday?
* Have any recent database queries failed?
* What is the average SQL query latency in the past hour?
* How many unique users are visiting the site?
* What's in my logs that matters to my goals? (Business or otherwise?)

Lots of this data finds its way into your logs (rather than your
metrics/graphing systems).

How about we skip the level 70 Regular Expression skill requirement? Log
structured data, yo. Pretty sure every language can parse JSON. Don't like
JSON? That's fine, JSON is just a serialization - a data representation - there
are plenty of choices...

... but I digress. Your applications have context at the time of logging. Most
of the time you try to embed it in some silly printf or string-interpolated
meatball, right? Stop that.

Instead of code like this:

    logger.error("#{hostname} #{program}[#{pid}]: error: PAM: authentication error for illegal user #{user} from #{client}")

and output like this:

    Sep 25 13:44:37 fbsd1 sshd[4374]: error: PAM: authentication error for illegal user amelia from e210255180014.ec-userreverse.dion.ne.jp

and a regex to parse it like this:

    /haha, just kidding I'm not writing a regex to parse that crap./

How about this:

    logger.error("PAM: authentication error for illegal user", {
      :hostname => "fbsd1",
      :program => "sshd",
      :pid => 4374,
      :user => "amelia",
      :client => "e210255180014.ec-userreverse.dion.ne.jp"
    })

And output in any structured data format, like json:

    {
      "timestamp": "2011-09-25T13:44:37.034Z",
      "message": "PAM: authentication error for illegal user",
      "hostname": "fbsd1",
      "program": "sshd",
      "pid": 4374,
      "user": "amelia",
      "client": "e210255180014.ec-userreverse.dion.ne.jp"
    }

Log structured stuff and you can trivially do some nice analytics and searching on your logs.

# Latency matters.

Want to time something and log it?

    n = 30
    logger[:input] = n
    logger.time("fibonacci duration") do
      fib(30)
    end

Output in JSON format:

    {
      "timestamp":"2011-10-11T02:17:12.447487-0700",
      "input":30,
      "message":"fibonacci duration",
      "duration":1.903017632
    }

# Metrics like counters?

    metrics = Cabin::Channel.new
    logger = Cabin::Channel.new

    # Pretend you can subscribe rrdtool, graphite, or statsd to the 'metrics'
    # channel. Pretend the 'logger' channel has been subscribed to something
    # that writes to stdout or disk.

    begin
      logger.time("Handling request") do
        handle_request
      end
      metrics[:hits] += 1
    rescue => e
      metrics[:errors] += 1
      logger.error("An error occurred", :exception => e, :backtrace => e.backtrace)
    end

## RSpec Helper

Defines a matcher, a subscriber to collect structured log entries and utility methods to use in your specs.

To use this helper, add this line to any spec file

    require 'cabin/rspec/cabin_helper'

# Helper

when you require the helper it will automatically stub Cabin::Channel.get to return a Channel subscribed to a special subscriber in a before(:example) block and unstub it in an after(:example) block

The following methods are available in Rspec ```it``` blocks

| method              | description                                            |
|---------------------| -------------------------------------------------------|
| receive_log_message | the matcher method, invoked by RSpec                   |
| log_receiver        | returns the reference to the collection of log entries |


# Matcher

The matcher is invoked thus
```ruby
  receive_log_message(message_txt, query_hash)
```
NOTE: query_hash is optional

Each log entry is a Ruby Hash with some keys e.g. timestamp, message, error, method, file, line, level (and more)

Log Entry example
```ruby
{:timestamp=>"2015-08-20T09:28:04.260000+0100", :message=>"config LogStash::Outputs::Riemann/@port = 5555", :level=>:debug, :file=>"logstash/config/mixin.rb", :line=>"112", :method=>"config_init"}
```

NOTE: You can match on only the message OR the message and one other key/value.

Please add an Github Issue if you really need the message_txt to be a Regexp or you must match on multiple other key/value pairs.

| arg          | description                                 |
|--------------| --------------------------------------------|
| messsage_txt | a String to match on the message key        |
| query_hash   | a Hash with keys ```key``` and ```match```  |

query_hash examples:
```ruby
  {:key => :line, :match => '112' }
  {:key => :level, :match => :info }
```

| key   | can be a String or Symbol |
| match | can be a String or Regexp |

Use the Regexp for ```match``` if the value returned by ```key``` cannot be matched using ```==```

Usually in your code logging is a side effect, so in your test add expect(log_receiver).to receive_log_message... after you run the method that might log something. However you can also use the expect { some_method }.to receive_log_message... block syntax.

Examples:
```ruby
# no query, only message text
expect(log_receiver).to receive_log_message("config LogStash::Outputs::Riemann/@port = 5555")

# query with match as a String
expect(log_receiver).not_to receive_log_message("Unhandled exception", key: :method, match: "send_to_riemann")

# query with match as a Regexp
expect { output.receive(event) }.not_to receive_log_message("Unhandled exception", key: :error, match: %r|undefined method .compact. for ..Java..JavaUtil..ArrayList|)
```

To reduce the risk of false positives, use
```ruby
  puts log_receiver.cache.inspect
```
to see what entries are being logged while tuning the matcher args.  Especially if you are trying to verify that a log entry is *not* being created

