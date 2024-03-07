#!/bin/sh

RS=""

site_root="$(dirname "$0")"
site_template="$site_root/site.html.template"

cd "$site_root" || exit 1

# Clean before we start

find "$site_root" -type f -name '*.html' -delete
find "$site_root" -type f -name 'page-list*' -delete

# Generate pages

{
  find . -type f -name '*.html.part' >tmp
  while IFS= read -r content
  do
    path="$(dirname "$content")"
    TITLE="$(basename "$content" | cut -d '.' -f 1)"
    date="$(expr "$TITLE" : '\([[:digit:]]*-[[:digit:]]*-[[:digit:]]*\)')"

    if [ -n "$date" ]
    then
      TITLE="$date $(echo "$TITLE" | cut -d '-' -f 4- | sed 's/-/ /g')"
    else
      TITLE="$(echo "$TITLE" | sed 's/-/ /g')"
    fi

    filename="$(basename "$content" .part | tr '[:upper:]' '[:lower:]')"
    case "$filename" in
      *.*.*) dest="$(echo "$filename" | cut -d '.' -f 2-)" ;;
      *.*)   chunk="$(basename "$filename" .html)"
             mkdir -p "$path/$chunk"
             dest="$chunk/index.html" ;;
    esac

    CONTENT="$(cat "$content")"

    export TITLE
    export CONTENT
    envsubst \
      <"$site_template" \
      >"$path/$dest"

    echo "$(echo "$dest" | sed 's/index.html$//')$RS$TITLE" >> "$path/page-list"
  done <tmp
  rm tmp
}

# Generate page lists

{
  find . -type f -name page-list >tmp
  while IFS= read -r list
  do
    path="$(dirname "$list")"
    dest=index.html

    if [ -f "$path/$dest" ]
    then
      dest=page-list.html
    fi

    TITLE='Page List'
    CONTENT="<ul>$(sort -r "$list" | awk -F "$RS" 'NF { print("<li><a href=\""$1"\">"$2"</a></li>") }')</ul>"

    export TITLE
    export CONTENT
    envsubst \
      <"$site_template" \
      >"$path/$dest"

    rm "$list"
  done <tmp
  rm tmp
}
