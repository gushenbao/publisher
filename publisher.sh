#!/bin/sh

src=$(tar cjf - src/ | base64 -w 0)
uuid=$(awk -F ":" '/uuid/ {print $2}' pkginfo)
name=$(awk -F ":" '/name/ {print $2}' pkginfo)
description=$(awk -F ":" '/description/ {print $2}' pkginfo)
author=$(awk -F ":" '/name/ {print $2}' pkginfo)

uuid=$(echo $uuid | xargs)
name=$(echo $name | xargs)
description=$(echo $description | xargs)
author=$(echo $author | xargs)

postdata=$(cat <<-JSON
{
    "name": "###__NAME__###",
    "uuid": "###__UUID__###",
    "description": "###__DESCRIPTION__###",
    "author": "###__AUTHOR__###",
    "version": "###__VERSION__###",
    "src": "###__SRC__###"
}
JSON
)

postdata=$(echo $postdata | sed -e "s/###__NAME__###/$name/g")
postdata=$(echo $postdata | sed -e "s/###__UUID__###/$uuid/g")
postdata=$(echo $postdata | sed -e "s/###__DESCRIPTION__###/$description/g")
postdata=$(echo $postdata | sed -e "s/###__AUTHOR__###/$author/g")
postdata=$(echo $postdata | sed -e "s~###__SRC__###~$src~g")

echo $src
echo $postdata
