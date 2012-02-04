$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest-patch"
require "cabin"
require "cabin/metrics"
require "minitest/autorun" if __FILE__ == $0

describe Cabin::Metrics do
  before do
    @metrics = Cabin::Metrics.new
  end

  test "gauge" do
    gauge = @metrics.gauge(self) { 3 }
    assert_equal(3, gauge.get)
    # metrics.first == [identifier, Gauge]
    assert_equal(3, @metrics.first.last.get)
  end

  test "counter" do
    counter = @metrics.counter(self)
    0.upto(30) do |i|
      assert_equal(i, counter.get)
      counter.incr
    end
    31.downto(0) do |i|
      assert_equal(i, counter.get)
      counter.decr
    end
  end
end # describe Cabin::Channel do
