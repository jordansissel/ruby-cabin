require "cabin/namespace"
require "cabin/metrics/gauge"
require "cabin/metrics/meter"
require "cabin/metrics/counter"

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
# Reading what Coda Hale's "Metrics" stuff has, here's my summary:
#   gauges (callback to return a number)
#   counters (.inc and .dec methods)
#   meters (.mark to track each 'hit')
#     Also exposes 1, 5, 15 minute moving averages
#   histograms: (.update(value) to record a new value)
#     like meter, but takes values more than simply '1'
#     as a result, exposes percentiles, median, etc.
#   timers
#     combination of meter + histogram
#     meter for invocations, histogram for duration
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
  
  # Create a new gauge
  #
  # Gauge reads can block your program if you aren't using threads,
  # so be aware of writing slow-to-execute Gauge callbacks.
  public
  def gauge(identifier, &block)
    @metrics[identifier] = Cabin::Metrics::Gauge.new(&block)
  end # def gauge

  public
  def counter(identifier)
    @metrics[identifier] = Cabin::Metrics::Counter.new
  end # def counter

  public
  def meter(identifier)
    @metrics[identifier] = Cabin::Metrics::Meter.new
  end # def meter

  #public
  #def histogram(identifier)
    #@metrics[identifier] = Cabin::Metrics::Histogram.new
  #end # def histogram
  
  # iterate over each metric. yields identifer, metric
  def each(&block)
    # delegate to the @metrics hash until we need something fancier
    @metrics.each(&block)
  end # def each
end # class Cabin::Metrics
