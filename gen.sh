#!/bin/sh

export TITLE='A Cat Writes'

export CONTENT='
<p>Meow mew <a href="blog">blog</a> meow.</p>
<p>にゃん</p>'

< site.html.template \
  envsubst \
  > index.html
