.PHONY: test
test:
	ruby test/all.rb

.PHONY: testloop
testloop:
	# TODO(sissel): use inotifywait?
	while true; do $(MAKE) test; sleep 1 ;done

.PHONY: gem
gem:
	gem build cabin.gemspec

.PHONY: publish
publish: GEM=$(shell ls -t *.gem | head -1)
publish: gem
	gem push $(GEM)
