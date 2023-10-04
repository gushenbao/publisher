#!/bin/sh

src=$(tar cjf - src/ | base64 -w 0)
log=$(echo $DRONE_COMMIT_MESSAGE | base64 -w 0)
version=${DRONE_TAG}

uuid=$(awk -F ":" '/uuid/ {print $2}' pkginfo)
name=$(awk -F ":" '/name/ {print $2}' pkginfo)
description=$(awk -F ":" '/description/ {print $2}' pkginfo)
author=$(awk -F ":" '/author/ {print $2}' pkginfo)
archived=$(awk -F ":" '/archived/ {print $2}' pkginfo)

uuid=$(echo $uuid | xargs)
name=$(echo $name | xargs)
description=$(echo $description | xargs)
author=$(echo $author | xargs)
archived=$(echo $archived | xargs)

postdata=$(cat <<-JSON
{
    "uuid": "###__UUID__###",
    "name": "###__NAME__###",
    "description": "###__DESCRIPTION__###",
    "author": "###__AUTHOR__###",
    "archived": ###__ARCHIVED__###,
    "version": "###__VERSION__###",
    "log": "###__LOG__###",
    "content": "###__SRC__###"
}
JSON
)

postdata=$(echo $postdata | sed -e "s/###__NAME__###/$name/g")
postdata=$(echo $postdata | sed -e "s/###__UUID__###/$uuid/g")
postdata=$(echo $postdata | sed -e "s/###__DESCRIPTION__###/$description/g")
postdata=$(echo $postdata | sed -e "s/###__AUTHOR__###/$author/g")
postdata=$(echo $postdata | sed -e "s/###__ARCHIVED__###/$archived/g")
postdata=$(echo $postdata | sed -e "s/###__VERSION__###/$version/g")
postdata=$(echo $postdata | sed -e "s~###__LOG__###~$log~g")
postdata=$(echo $postdata | sed -e "s~###__SRC__###~$src~g")

postfile=$(mktemp)
echo $postfile
echo $postdata > "$postfile"

wget --header="Accept: application/json" --header="Content-Type: application/json" --post-file=$postfile -O - http://localhost:9900/plugin/$uuid

rm -f $postfile
