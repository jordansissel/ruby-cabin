# encoding: utf-8
require "bundler/gem_tasks"

ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(ROOT, 'lib')
Dir.glob('lib/**').each { |d| $LOAD_PATH.unshift(File.join(ROOT, d)) }

require 'rake/testtask'

EXCLUDED_TEST = FileList['test/cabin/*zeromq.rb']

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/cabin/test_*.rb'] - EXCLUDED_TEST
end
