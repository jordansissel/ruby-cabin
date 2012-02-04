require "cabin/namespace"

class Cabin::Metrics::Gauge
  # A new Gauge. The block given will be called every time the metric is read.
  public
  def initialize(&block)
    @block = block
  end # def initialize

  # Get the value of this metric.
  public
  def get
    @block.call
  end # def get
end # class Cabin::Metrics::Gauge
