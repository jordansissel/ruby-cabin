VERSION=$(shell awk -F\" '/version = / { print $$2 }' cabin.gemspec)
GEM=cabin-$(VERSION).gem
DIRS=lib/ test/

.PHONY: test
test:
	sh notify-failure.sh ruby -Ilib -Itest test/all.rb

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
$(GEM): $(shell git ls-files | grep '\.rb$$')
	gem build cabin.gemspec

.PHONY: bump-version
bump-version: NEXTVERSION=$(shell echo "$(VERSION)" | awk -F. '{OFS="."; print $$1,$$2,$$3+1}')
bump-version:
	sed -i -e 's/.*spec.version =.*/  spec.version = "$(NEXTVERSION)"/' cabin.gemspec

.PHONY: install
install: $(GEM)
	gem install --local $(GEM)

.PHONY: publish
publish: gem
	gem push $(GEM)

.PHONY: clean
clean:
	-rm $(GEM)
