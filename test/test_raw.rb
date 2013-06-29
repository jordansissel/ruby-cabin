$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest-patch'
require 'cabin'
require 'minitest/autorun' if __FILE__ == $0

describe Cabin::Channel do
  before do
    @logger          = Cabin::Channel.new
    @reader, @writer = IO.pipe
    @target          = Cabin::Outputs::Raw.new(@writer)
    @logger.subscribe(@target)
  end

  test "simple string publishing" do
    @logger.publish('Hello world')
    assert_equal("Hello world\n", @reader.readline)
  end

  test "ignores rich data" do
    @logger[:foo] = 'bar'
    @logger.publish('Hello world')
    assert_equal("Hello world\n", @reader.readline)
  end
end

