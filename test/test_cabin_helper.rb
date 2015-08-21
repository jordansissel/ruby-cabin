$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest-patch"
require "cabin"

module RSpec
  class Confi
    def include(*)
    end
    def before(*)
    end
    def after(*)
    end
  end

  def self.configure
    yield Confi.new
  end
end

require "rspec/cabin_helper"
require "minitest/autorun" if __FILE__ == $0

describe "RSpec helper for Cabin" do

  class RSpecContext
    include CabinHelper
  end

  before do
    @context = RSpecContext.new
    @receiver = RSpecContext::LoggingReceiver.new
    @matcher = RSpecContext::ReceiveLogMessage.new(@receiver, "Foo", {})
  end

  test "context should have #receive_log_message" do
    assert(@context.respond_to?(:receive_log_message))
  end

  test "context#receive_log_message should return a matcher" do
    assert_equal(@context.receive_log_message("foo").class, @matcher.class)
  end

  test "context should have #log_receiver" do
    assert(@context.respond_to?(:log_receiver))
  end

  test "context#log_receiver should return a LoggingReceiver instance" do
    assert_equal(@context.log_receiver.class, @receiver.class)
  end

  test "context should have #new_subscribed_cabin_channel" do
    assert(@context.respond_to?(:new_subscribed_cabin_channel))
  end

  test "context#new_subscribed_cabin_channel should return a Cabin Channel instance" do
    assert_equal(@context.new_subscribed_cabin_channel(:info, @receiver).class.name, "Cabin::Channel")
  end

  describe RSpecContext::LoggingReceiver do
    before do
      @subject = RSpecContext::LoggingReceiver.new
    end

    test "the #cache method returns an array" do
      assert_equal(@subject.cache, [])
    end

    test "the #<< method appends to the cache" do
      @subject << {foo: 1}
      assert_equal(@subject.cache, [{foo: 1}])
    end

    test "the #reset method clears the cache" do
      @subject << {foo: 1}
      @subject.reset
      assert_equal(@subject.cache, [])
    end

    test "the #filter method should find one cache entry when present" do
      1.upto(8) { |i| @subject << {foo: i} }
      @block = lambda {|h| h[:foo] == 5}

      assert_equal(@subject.filter(&@block) , {foo: 5})
    end

    test "the #filter method should not find a cache entry when not present" do
      1.upto(8) { |i| @subject << {foo: i} }
      @block = lambda {|h| h[:foo] == 9}

      assert_equal(@subject.filter(&@block) , nil)
    end
  end

  describe "RSpecContext::ReceiveLogMessage (a matcher) complies with RSpec3 Matcher Protocol" do
    before do
      @subject_proc = lambda do |msg, hash|
        RSpecContext::ReceiveLogMessage.new(RSpecContext::LoggingReceiver.new, msg, hash)
      end
    end

    test "the #failure_message method should return a string" do
      subject = @subject_proc.call('foo', {})
      assert(subject.failure_message.is_a?(String))
    end

    test "the #failure_message_when_negated method should return a string" do
      subject = @subject_proc.call('foo', {})
      assert(subject.failure_message_when_negated.is_a?(String))
    end

    test "the #supports_block_expectations? method should return true" do
      subject = @subject_proc.call('foo', {})
      assert(subject.supports_block_expectations?)
    end

    test "the #diffable? method should return false" do
      subject = @subject_proc.call('foo', {})
      refute(subject.diffable?)
    end

    # and now No. 1, the larch... the larch
    describe "the matches? method" do
      # NOTE: this matcher is weird, it does not verify the return value (actual)
      # it verifies that a logging side effect occured as a result of sending
      # the subject a message e.g. plugin.register()

      describe "for a simple filter" do
        before do
          @matcher = @context.receive_log_message('foo')
        end
        # ----------------------------------------------------------------------------
        # in rspec it block when doing...
        # expect { some_action_that_creates_log_entries() }.to receive_log_message('foo')
        test "given a proc with some log entry of interest" do
          # simulate some kind of logging
          lmda = lambda { @context.log_receiver << {message: 'foo', bar: 'baz'} }
          assert(@matcher.matches?(lmda))
        end
        # ----------------------------------------------------------------------------
        # in rspec it block when doing...
        # expect { some_action_that_creates_log_entries() }.not_to receive_log_message('foo')
        test "given a proc with some log entry of no interest" do
          # simulate some kind of logging
          lmda = lambda { @context.log_receiver << {message: 'quux', bar: 'baz'} }
          refute(@matcher.matches?(lmda))
        end
        # ----------------------------------------------------------------------------
        # in rspec it block when doing...
        # some_action_that_creates_log_entries()
        # expect(log_receiver).to receive_log_message('foo')
        test "given the receiver itself when a log entry of interest is added" do
          # simulate some kind of logging
          @context.log_receiver << {message: 'foo', bar: 'baz'}
          assert(@matcher.matches?(@context.log_receiver))
        end
        # ----------------------------------------------------------------------------
        # in rspec it block when doing...
        # some_action_that_creates_log_entries()
        # expect(log_receiver).not_to receive_log_message('foo')
        test "given the receiver itself when a log entry of no interest is added" do
          # simulate some kind of logging
          @context.log_receiver << {message: 'quux', bar: 'baz'}
          refute(@matcher.matches?(@context.log_receiver))
        end

        describe "for a complex filter" do
          describe "when the query is simple" do
            before do
              @matcher = @context.receive_log_message('foo', key: :quux, match: 42)
            end

            test "given the receiver itself when a log entry of interest is added" do
              @context.log_receiver << {message: 'foo', quux: 42}
              assert(@matcher.matches?(@context.log_receiver))
            end
          end

          describe "when the query is uses a regular expression" do
            before do
              @matcher = @context.receive_log_message('foo', key: :quux, match: %r|larch|)
            end

            test "given the receiver itself when a log entry of interest is added" do
              Foo = Class.new { def inspect() "larch"; end }
              @context.log_receiver << {message: 'foo', quux: Foo.new}
              assert(@matcher.matches?(@context.log_receiver))
            end
          end
        end
      end
    end
  end
end



