#!/bin/sh

export TITLE='Cat Writes'
export CONTENT='
<p>Meow mew <a href="blog">blog</a> meow.</p>
<p>にゃん</p>'
export ROOT='.'
export BLOG='blog'

# Homepage
< site.html.template \
  envsubst \
  > index.html

cd blog || exit 1
export ROOT='..'
export BLOG='./'

posts=''

without_date() {
  cut -d'-' -f 4-
}

get_date() {
  cut -d'-' -f 1,2,3
}

kebab_to_space() {
  sed 's/-/ /g'
}

# Posts, sorted for latest at the top.
for post in *.html.part; do
  dest="$(basename "$post" .part)"
  date="$(echo "$post" | get_date)"

  TITLE="$(basename "$dest" .html | without_date | kebab_to_space)"
  export TITLE
  CONTENT="$(cat "$post")"
  export CONTENT

  < ../site.html.template \
    envsubst \
    > "$dest"

  posts="$posts\n$dest $date $TITLE"
done

export TITLE='Cat Writes a Blog'
CONTENT="$(echo "$posts" | sort -r | awk 'NF { print("<p><a href=\""$1"\">"$2,$3"</a></p>") }')"
export CONTENT

< ../site.html.template \
  envsubst \
  > index.html
