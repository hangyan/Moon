# Makefile
MICROBLOG_TEMPLATE := _templates/microblog
POST_DATE := $(shell date +%Y-%m-%d)
POST_TIME := $(shell date +%Y-%m-%d\ %T\ %z)
POST_TITLE := $(shell openssl rand 100000 | shasum | cut -c1-8)
POST_FILE := _microblog/$(POST_DATE)-$(POST_TITLE).md
.PHONY: new-microblog
new-microblog:
	@cat $(MICROBLOG_TEMPLATE) | \
	sed "s/%CURRENT_DATE%/$(POST_TIME)/g" | \
	sed "s/%POST_TITLE%/$(POST_TITLE)/g" > ${POST_FILE} && \
	code ${POST_FILE}
