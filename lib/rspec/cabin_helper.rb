module CabinHelper
  class LoggingReceiver
    def filter(&block)
      cache.detect(&block)
    end

    def cache
      @cache ||= []
    end

    def <<(hash)
      cache.push(hash)
    end

    def reset
      cache.clear
    end
  end

  class ReceiveLogMessage
    def initialize(receiver, message, query)
      @receiver = receiver
      @message = message
      @query = query
      @compound = false
      prepare_query
    end

    def matches?(actual)
      if actual.is_a?(LoggingReceiver)
        actual.filter(&method(:filter_block))
      elsif actual.is_a?(Proc)
        actual.call
        @receiver.filter(&method(:filter_block))
      else
        @receiver.filter(&method(:filter_block))
      end
    end

    def failure_message
      "expected a matching log entry"
    end

    def failure_message_when_negated
      "matching log entry was not expected"
    end

    def supports_block_expectations?
      true
    end

    def diffable?
      false
    end

    private

    def prepare_query
      return if !query_valid?
      @compound = true
      @operator = :==
      @transform = ->(v){v}
      @key = @query[:key].to_sym
      @rhs = @query[:match]
      if @rhs.is_a?(Regexp)
        @operator = :=~
        @transform = ->(v){v.inspect}
      end
    end

    def filter_block(h)
      if @compound
        inter = @transform.call(h[@key])
        result = !!(inter.send(@operator, @rhs))
        h[:message].to_s == @message && result
      else
        !!(h[:message].to_s == @message)
      end
    end

    def query_valid?
      @query.is_a?(Hash) &&
        !@query.size.zero? &&
        @query.has_key?(:key) &&
        @query.has_key?(:match)
    end
  end

  def new_subscribed_cabin_channel(level, subscriber)
    ::Cabin::Channel.new.tap do |obj|
      obj.level = level
      obj.subscribe(subscriber)
    end
  end

  def receive_log_message(message, query = {})
    ReceiveLogMessage.new(log_receiver, message, query)
  end

  def log_receiver
    @log_receiver ||= LoggingReceiver.new
  end
end


RSpec.configure do |c|
  c.include CabinHelper
  c.before(:example) do
    log_receiver.reset
    allow(::Cabin::Channel).to receive(:get).and_return(new_subscribed_cabin_channel(:debug, log_receiver))
  end
  c.after(:example) { RSpec::Mocks.space.proxy_for(::Cabin::Channel).reset }
end
