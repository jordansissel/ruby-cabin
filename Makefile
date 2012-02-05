DIRS=lib/ test/

.PHONY: test
test:
	sh notify-failure.sh ruby test/all.rb

.PHONY: testloop
testloop:
	while true; do \
		$(MAKE) wait-for-changes test; \
	done

.PHONY: serve-coverage
serve-coverage:
	cd coverage; python -mSimpleHTTPServer

.PHONY: wait-for-changes
wait-for-changes:
	-inotifywait --exclude '\.swp' -e modify $$(find $(DIRS) -name '*.rb'; find $(DIRS) -type d)

.PHONY: gem
gem:
	gem build cabin.gemspec

.PHONY: publish
publish: GEM=$(shell ls -t *.gem | head -1)
publish: gem
	gem push $(GEM)
