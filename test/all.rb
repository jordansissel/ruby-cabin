$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest/autorun"
require "simplecov"

SimpleCov.start

dir = File.dirname(File.expand_path(__FILE__))
Dir.glob(File.join(dir, "**", "test_*.rb")).each do |path|
  puts "Loading tests from #{path}"
  if path =~ /test_zeromq/
    puts "Skipping zeromq tests because they force ruby to exit if libzmq is not found"
    next
  end
  require path
end
