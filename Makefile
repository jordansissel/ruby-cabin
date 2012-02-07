VERSION=$(shell awk -F\" '/version = / { print $$2 }' cabin.gemspec)
GEM=cabin-$(VERSION).gem
DIRS=lib/ test/

.PHONY: test
test:
	sh notify-failure.sh ruby test/all.rb

.PHONY: testloop
testloop:
	while true; do \
		$(MAKE) test; \
		$(MAKE) wait-for-changes; \
	done

.PHONY: serve-coverage
serve-coverage:
	cd coverage; python -mSimpleHTTPServer

.PHONY: wait-for-changes
wait-for-changes:
	-inotifywait --exclude '\.swp' -e modify $$(find $(DIRS) -name '*.rb'; find $(DIRS) -type d)

.PHONY: gem package
gem package: $(GEM)
$(GEM):
	gem build cabin.gemspec

.PHONY: install
install: $(GEM)
	gem install $(GEM)

.PHONY: publish
publish: gem
	gem push $(GEM)
