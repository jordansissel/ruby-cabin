$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest-patch"
require "logging"
require "stringio"
require "minitest/autorun" if __FILE__ == $0

describe Logging::Channel do
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
    @logger = Logging::Channel.new
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
