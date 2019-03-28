# Makefile
MICROBLOG_TEMPLATE := _templates/microblog
BLOG_TEMPLATE := _templates/blog

POST_DATE := $(shell date +%Y-%m-%d)
POST_TIME := $(shell date +%Y-%m-%d\ %T\ %z)

POST_TITLE := $(shell openssl rand 100000 | shasum | cut -c1-8)
BLOG_TITLE := $(title)


POST_FILE := _microblog/$(POST_DATE)-$(POST_TITLE).md
BLOG_FILE := _posts/$(POST_DATE)-$(BLOG_TITLE).md

.PHONY: mb
mb:
	@cat $(MICROBLOG_TEMPLATE) | \
	sed "s/%CURRENT_DATE%/$(POST_TIME)/g" | \
	sed "s/%POST_TITLE%/$(POST_TITLE)/g" > ${POST_FILE} && \
	code ${POST_FILE}
blog:
	@cat $(BLOG_TEMPLATE) | \
	sed "s/%CURRENT_DATE%/$(POST_TIME)/g" > ${BLOG_FILE}
