#!/bin/sh

export TITLE='Cat Writes'

export CONTENT='
<p>Meow mew <a href="blog">blog</a> meow.</p>
<p>にゃん</p>'

# Homepage
< site.html.template \
  envsubst \
  > index.html

cd blog

posts=''

without_date() {
  cut -d'-' -f1,2,3 --complement
}

drop_ext() {
  rev | cut -d'.' -f1 --complement | rev
}

kebab_to_space() {
  sed 's/-/ /g'
}

# Posts, sorted for latest at the top.
for post in *.html.part; do
  dest="$(echo "$post" | drop_ext)"
  export TITLE="$(echo "$dest" | without_date | drop_ext | kebab_to_space )"
  export CONTENT="$(cat "$post")"
  < ../site.html.template \
    envsubst \
    > "$dest"
  posts="$posts\n$post"
done

export TITLE='Cat Writes a Blog'
export CONTENT="$(echo "$posts" | sort -r | awk 'NF { print("<p>"$1"</p>") }')"
  < ../site.html.template \
    envsubst \
    > index.html
