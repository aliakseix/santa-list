#!/bin/bash
# needs two parameters: full name and email
img=""
if (($# > 2)) && [[ -n "${3-}" ]]; then
  img="<img src='${3}' alt='student ${1}' />"
fi

echo "<p>${img}Student going by the name <b>${1}</b> and reacheable on <i>${2}</i></p>"
