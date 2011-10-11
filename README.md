# Logging kind of sucks.

I want:

* allow easy context attaching (see structured logging)
* log structured data
* should allow writing to N outputs
* log levels
* logger singleton-ish-factory-thin similar to log4j's getLogger(object)
* recording metrics
* track latencies/etc

# Why?

Logging plain-text strings is just plain shit. You need to be a regexp ninja
to make any kind of aggregated sense out of anything more than a single log
event.

* How many customers signed up yesterday?
* What is the average SQL query latency in the past hour?
* How many unique users are visiting the site?

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
