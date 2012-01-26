require "rubygems"
require "cabin"
require "cabin/mixins/CAPSLOCK"
require "logger"

# instance method
class Derp
  def logger
    logger = Cabin::Channel.new
    logger.extend(Cabin::Mixins::CAPSLOCK)
    rubylog = Logger.new('/tmp/sensu.log')
    logger.subscribe(rubylog)
    logger
  end
end

# usage
config = Derp.new
logger = config.logger
logger.level = :debug

logger.info("Hello")
logger.warn("World")


