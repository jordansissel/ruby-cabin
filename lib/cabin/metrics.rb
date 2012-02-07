require "cabin/namespace"
require "cabin/metrics/gauge"
require "cabin/metrics/meter"
require "cabin/metrics/counter"
require "cabin/metrics/timer"
require "cabin/metrics/histogram"

# What type of metrics do we want?
#
# What metrics should come by default?
# Per-call/transaction/request metrics like:
#   - hit (count++ type metrics)
#   - latencies/timings
#
# Per app or generally long-lifetime metrics like:
#   - "uptime"
#   - cpu usage
#   - memory usage
#   - count of active/in-flight actions/requests/calls/transactions
#   - peer metrics (number of cluster members, etc)
# ------------------------------------------------------------------
# https://github.com/codahale/metrics/tree/master/metrics-core/src/main/java/com/yammer/metrics/core
# Reading what Coda Hale's "Metrics" stuff has, here's my summary:
#
#   gauges (callback to return a number)
#   counters (.inc and .dec methods)
#   meters (.mark to track each 'hit')
#     Also exposes 1, 5, 15 minute moving averages
#   histograms: (.update(value) to record a new value)
#     like meter, but takes values more than simply '1'
#     as a result, exposes percentiles, median, etc.
#   timers
#     a time-observing interface on top of histogram.
#
# With the exception of gauges, all the other metrics are all active/pushed.
# Gauges take callbacks, so their values are pulled, not pushed. The active
# metrics can be represented as events since they the update occurs at the
# time of the change.
#
# These active/push metrics can therefore be considered events.
#
# All metrics (active/passive) can be queried for 'current state', too,
# making this suitable for serving to interested parties like monitoring
# and management tools.
class Cabin::Metrics
  include Enumerable

  public
  def initialize
    @metrics = {}
  end # def initialize
  
  private
  def create(instance, name, metric_object)
    #p :newmetric => [name, instance]
    #p [instance, instance.class, instance.class.class]
    return @metrics[[instance, name]] = metric_object
  end # def create

  public
  def counter(instance, name=nil)
    return create(instance, name, Cabin::Metrics::Counter.new)
  end # def counter

  public
  def meter(instance, name=nil)
    return create(instance, name, Cabin::Metrics::Meter.new)
  end # def meter

  public
  def histogram(instance, name=nil)
    return create(instance, name, Cabin::Metrics::Histogram.new)
  end # def histogram

  public
  def timer(instance, name=nil)
    return create(instance, name, Cabin::Metrics::Timer.new)
  end # def timer
  
  # iterate over each metric. yields identifer, metric
  def each(&block)
    # delegate to the @metrics hash until we need something fancier
    @metrics.each(&block)
  end # def each
end # class Cabin::Metrics
