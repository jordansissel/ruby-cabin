$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest-patch'
require 'cabin'
require 'stringio'
require 'minitest/autorun' if __FILE__ == $0

describe Cabin::Channel do
  class Receiver
    attr_accessor :data

    public
    def initialize
      @data = []
    end

    def <<(data)
      @data << data
    end
  end # class Receiver

  before do
    @logger = Cabin::Channel.new
    @target = Receiver.new
    @logger.subscribe(@target)

    @info_reader,  @info_writer  = IO.pipe
    @error_reader, @error_writer = IO.pipe
  end

  after do
    @logger.unsubscribe(@target.object_id)
    [ @info_reader, @info_writer,
      @error_reader, @error_writer ].each do |io|
      io.close unless io.closed?
    end
  end

  test 'Piping one IO' do
    @info_writer.puts 'Hello world'
    @info_writer.close

    @logger.pipe(@info_reader => :info)
    assert_equal(1, @target.data.length)
    assert_equal('Hello world', @target.data[0][:message])
  end

  test 'Piping multiple IOs' do
    @info_writer.puts 'Hello world'
    @info_writer.close

    @error_writer.puts 'Goodbye world'
    @error_writer.close

    @logger.pipe(@info_reader => :info, @error_reader => :error)

    assert_equal(3, @target.data.first.keys.length)

    @target.data.map {|out| out.delete(:timestamp) }
    expected_responses = [
      {
        :message => 'Hello world',
        :level => :info
      },
      {
        :message => 'Goodbye world',
        :level => :error
      }
    ]
    assert_includes(expected_responses, @target.data.shift)
    assert_includes(expected_responses, @target.data.shift)
    assert_equal([], @target.data)
  end

  test 'Piping with a block' do
    @info_writer.puts 'Hello world'
    @info_writer.close

    @error_writer.puts 'Goodbye world'
    @error_writer.close

    info  = StringIO.new
    error = StringIO.new

    @logger.pipe(@info_reader => :info, @error_reader => :error) do |message, level|
      info  << message if level == :info
      error << message if level == :error
    end

    assert_equal('Hello world',   info.string)
    assert_equal('Goodbye world', error.string)
  end
end

