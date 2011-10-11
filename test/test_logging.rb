$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest-patch"
require "cabin"
require "stringio"
require "minitest/autorun" if __FILE__ == $0

describe Cabin::Channel do
  class Receiver
    attr_accessor :data

    public
    def initialize
      @data = []
    end

    public
    def <<(data)
      @data << data
    end
  end # class Receiver

  before do
    @logger = Cabin::Channel.new
    @target = Receiver.new
    @logger.subscribe(@target)
  end

  test "simple string publishing" do
    @logger.publish("Hello world")
    assert_equal(1, @target.data.length)
    assert_equal("Hello world", @target.data[0][:message])
  end

  test "simple context data" do
    @logger[:foo] = "bar"
    @logger.publish("Hello world")
    assert_equal(1, @target.data.length)
    assert_equal("Hello world", @target.data[0][:message])
    assert_equal("bar", @target.data[0][:foo])
  end

  test "time something" do
    timer = @logger.time("some sample")
    timer.stop

    event = @target.data[0]
    assert_equal("some sample", event[:message])
    assert(event[:duration].is_a?(Numeric))
  end

  test "double subscription" do
    @logger.subscribe(@target)
    @logger.publish("Hello world")
    assert_equal(2, @target.data.length)
    assert_equal("Hello world", @target.data[0][:message])
    assert_equal("Hello world", @target.data[1][:message])
  end 

  test "context values" do
    context = @logger.context
    context["foo"] = "hello"
    @logger.publish("testing")
    assert_equal(1, @target.data.length)
    assert_equal("hello", @target.data[0]["foo"])
    assert_equal("testing", @target.data[0][:message])
  end

  test "context values clear properly" do
    context = @logger.context
    context["foo"] = "hello"
    context.clear
    @logger.publish("testing")
    assert_equal(1, @target.data.length)
    assert(!@target.data[0].has_key?("foo"))
    assert_equal("testing", @target.data[0][:message])
  end

  %w(fatal error warn info debug).each do |level|
    level = level.to_sym
    test "standard use case, '#{level}' logging when enabled" do
      @logger.level = level
      @logger.send(level, "Hello world")
      event = @target.data[0]
      assert_equal("Hello world", event[:message])
      assert_equal(level, event[:level])
    end
  end

  %w(error warn info debug).each do |level|
    level = level.to_sym
    test "standard use case, '#{level}' logging when wrong level" do
      @logger.level = :fatal
      # Should not log since log level is :fatal and we are above that.
      @logger.send(level, "Hello world")
      assert_equal(0, @target.data.length)
    end
  end
end
