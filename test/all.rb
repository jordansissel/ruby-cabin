$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "minitest/autorun"
require "simplecov"

SimpleCov.start

dir = File.dirname(File.expand_path(__FILE__))
Dir.glob(File.join(dir, "**", "test_*.rb")).each do |path|
  puts "Loading tests from #{path}"
  require path
end
