.PHONY: test
test:
	ruby test/test_logging.rb

gem:
	gem build cabin.gemspec

publish: GEM=$(shell ls -t *.gem | head -1)
publish: gem
	gem push $(GEM)
