.PHONY: test
test:
	ruby test/test_logging.rb

gem:
	gem build cabin.gemspec
