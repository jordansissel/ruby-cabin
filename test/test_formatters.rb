$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest-patch"
require "cabin"
require "stringio"
require "minitest/autorun" if __FILE__ == $0

describe Cabin::Channel do

  class StringIOReceiver < StringIO
    def is_a?(klazz)
      return true  if klazz == IO
      return false if klazz == Logger
      super.is_a?(klazz)
    end
  end

  describe "parsing json" do

    before do
      @logger = Cabin::Channel.new
      @target = StringIOReceiver.new
      @logger.subscribe(@target)
      @logger.formatter(Cabin::Formatter::JSON.new)
    end

    test "output data as JSON format" do
      @logger.info("Hello world")
      raised_exception = false
      begin
        JSON.parse(@target.string)
      rescue
        raised_exception = true
      end
      assert_equal(false, raised_exception)
    end
  end

  describe "parsing csv" do

    before do
      @logger = Cabin::Channel.new
      @target = StringIOReceiver.new
      @logger.subscribe(@target)
      @logger.formatter(Cabin::Formatter::CSV.new)
    end

    test "output data as JSON format" do
      @logger.info("Hello world")
      raised_exception = false
      begin
        CSV.parse(@target.string)
      rescue
        raised_exception = true
      end
      assert_equal(false, raised_exception)
    end
  end

  describe "output data using the default format, Ruby.inspect method" do

    before do
      @logger = Cabin::Channel.new
      @target = StringIOReceiver.new
      @logger.subscribe(@target)
    end

    test "simple string publishing" do
      @logger.info("Hello world")
      raised_exception = false
      begin
        JSON.parse(@target.string)
      rescue
        raised_exception = true
      end
      assert_equal(true, raised_exception)
    end

  end
end
