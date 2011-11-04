# Logging kind of sucks.

I want:

## Context and Structured Data

Logging with printf makes it hard to read later. Why write code that's easy to maintain, but not write logs that are the same? Structured data means you don't need crazy regular expression skills to make sense of logs.

## Output logs to multiple targets

Why not log to a file, a database, and a websocket at the same time? What if you could log to any output logstash supported right from your application?

## Log levels

What did the application programmer think of the importance and meaning of a log message?

Is the usual list of fatal, error, warning, info, and debug sufficient?

## Easy shared logging configuration through an application

It should be easy for your entire application (and all libraries you use) to use the same logging configuration.

## API that encourages tracking metrics, latencies, etc

Your applications and libraries would be vastly easier to debug, scale, and maintain if they exposed metrics about ongoing behaviors. Keep a count of HTTP hits by response code, count errors, time latencies, etc.

# What is out there?

log4j has the context bits (see
[MDC](http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/MDC.html)
and
[NDC](http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/NDC.html)).

Ruby's Logger has almost none of this. Same with Python's standard 'logging' module. Node doesn't really have any logging tools. Java has many, including log4j mentioned above, and misses much of the above.

# Broaden Your Views

Many logging tools are myopic - they only see one use for logs. Loggers are for
debugging and troubleshooting. Some are for logging usage for billing and
accounting. Some logs are for recording transactions for rollback or replay.

Ultimately all of these things are, roughly, a timestamp and some data. Debug
logs will have messages and context. Billing logs will have customer info and
usage metrics. Transaction logs will include operations performed.

For troubleshooting-style logs it makes sense to use a "level" concept where
some logs have a higher degree of importance or different meaning. In billing
logs, what is "info" vs "error" ? Would you even have such a thing?

We can do better than requiring three different kinds of log libraries and
tools for each of these three problems.

# Why experiment with this?

Logging plain-text strings is just plain shit. You need to be a regexp ninja
to make any kind of aggregated sense out of anything more than a single log
event.

* How many customers signed up yesterday?
* What is the average SQL query latency in the past hour?
* How many unique users are visiting the site?
* What's in my logs that matters to my goals? (Business or otherwise?)

Lots of this data finds its way into your logs (rather than your
metrics/graphing systems).

How about we skip the level 70 Regular Expression skill requirement? Log
structured data, yo. Pretty sure every language can parse JSON. Don't like
JSON? That's fine, JSON is just a serialization- a data representation - there
are plenty of choices...

... but I digress. Your applications have context at the time of logging. Most
of the time you try to embed it in some silly printf or string-interpolated 
meatball, right? Stop that.

Instead of code like this:

    logger.error("#{hostname} #{program}[#{pid}]: error: PAM: authentication error for illegal user #{user} from #{client}")

and output like this:

    Sep 25 13:44:37 fbsd1 sshd[4374]: error: PAM: authentication error for illegal user amelia from e210255180014.ec-userreverse.dion.ne.jp

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
