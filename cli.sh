#!/bin/sh
#
# Copyright (C) 2016 Powershop New Zealand Ltd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Simple cli interface to a rails hangman instance running somewhere

set -e

usage() {
  cat << EOF
Usage: cli.sh

Connect to a remote hangman server like this:
  cli.sh

Environment variables affect how the script runs:
  DICTFILE - dictionary file containing words - default /usr/share/dict/words
  URL      - url of the remote server - default http://localhost:3000

Options mirror the environment variables above:
  --dict-file - same as DICTFILE
  --url       - same as URL

Examples
  URL=http://10.43.0.13:3000 ./cli.sh
  ./cli.sh --url http://10.43.0.13:3000 --dict-file /tmp/words

Requirements:
posix compliant sh
awk
sed
curl
python - first choice for pretty printing json
perl-JSON - fallback if python cannot be used to pretty print json
yajl - fallback  if neither python or perl-JSON are available to pretty-print json (json_reformat)

Exit codes:
0 - Won
1 - Invalid arguments
2 - Missing dependencies
3 - Lost

EOF
}

# shellcheck disable=SC2159
while [ 0 ]; do
  if [ "x$1" = "x-h" ] || [ "x$1" = "x-help" ] || [ "x$1" = "x--help" ]; then
    usage | less -F -X
    exit 0
  elif [ "x$1" = "x--dict-file" ]; then
    shift

    if [ "x$1" = "x" ]; then
      echo >&2 "--dict-file requires an argument."
      exit 1
    fi

    DICTFILE="$1"

    if [ ! -e "$DICTFILE" ] ; then
      echo >&2 "File $DICTFILE does not exist"
      exit 1
    fi

    shift
  elif [ "x$1" = "x--url" ]; then
    shift

    if [ "x$1" = "x" ]; then
      echo >&2 "--url requires an argument."
      exit 1
    fi

    URL="$1"

    shift
  elif [ "x$1" = "x" ]; then
    break
  else
    echo >&2 "Unknown token $1"
    exit 1
  fi
done

jsonpp=""
if echo "{}" | python -c 'import sys, json;' > /dev/null 2>&1 ; then
  jsonpp='python -c "import sys, json; data = sys.stdin.read(); print json.dumps(json.loads(data), sort_keys=True, indent=4, separators=('\'','\'', '\'': '\''))"'
elif echo "{}" | perl -0007 -MJSON -ne 'from_json($_, {allow_nonref => 1})' > /dev/null 2>&1 ; then
  jsonpp='perl -0007 -MJSON -ne '\''print to_json(from_json($_, {allow_nonref => 1}), {pretty => 1})."\n"'\'''
elif command -v json_reformat > /dev/null 2>&1 ; then
  jsonpp="json_reformat"
else
  echo >&2 "This script requires yajl, python, or perl-JSON (to pretty-print json) to run."
  exit 2
fi

CLRED=$(printf '\033[31m')
CLGREEN=$(printf '\033[32m')
CLBLUE=$(printf '\033[34m')
CLMAGENTA=$(printf '\033[35m')
CLRESET=$(printf '\033[0m')

DICTFILE=${DICTFILE:-/usr/share/dict/words}

if [ ! -e "$DICTFILE" ] ; then
  echo >&2 "File $DICTFILE does not exist"
  exit 1
fi

URL=${URL:-http://localhost:3000}

max="$(wc -l < "$DICTFILE")"
num="$(awk -v min=1 -v max="$max" 'BEGIN{ srand(); print int(min + rand() * (max - min + 1)) }')"
word="$(sed "$(printf "%s" "$num")q;d" "$DICTFILE")"

gameurl="$(curl -f -v -H "Accept: application/json" "$URL/games" --data game[lives]=7 --data game[word]="$word" -o /dev/null 2>&1 | tr -d '\r' | grep ocation | cut -d' ' -f3)"
game_id="$(echo "$gameurl" | sed 's#.*/\([[:digit:]][[:digit:]]*\)#\1#')"

error=""
# shellcheck disable=SC2159
while [ 0 ] ; do

  printf "\033[2J\033[1;1H"

  data="$(curl -s -H "Accept: application/json" "$gameurl" | tr -d '\r' | eval $jsonpp | sed 's/ : /: /')"
  lives="$(echo "$data" | grep "lives_remaining" | sed -e 's/^[ \t]*//' -e 's/,//g' | cut -d' ' -f2)"
  gstatus="$(echo "$data" | grep "status" | sed -e 's/^[ \t]*//' -e 's/,//g' | cut -d' ' -f2)"

  # python and perl-JSON will format a blank array like this
  if echo "$data" | grep '"guesses": \[\]' > /dev/null 2>&1 ; then
    letters=""
  else
    letters="$(echo "$data" | sed '1,/guesses/d' | sed '/]/,$d' | grep -v '^$' | sed -e 's/^[ \t]*//' -e 's/,//g' -e 's/"//g')"
  fi

  guessed_letters="[ $(printf "%s" "$letters" | tr '\n' ' ') ]"

  if [ "$gstatus" -eq 2 ] ; then
    echo "$CLRED""Game over!$CLRESET"
    echo "Word was $CLBLUE$word$CLRESET"
    echo ""
    echo "Used Letters"
    echo "$guessed_letters"
    exit 3
  fi

  if [ "$gstatus" -eq 3 ] ; then
    echo "$CLGREEN""You won!$CLRESET"
    echo "Word was $CLBLUE$word$CLRESET"
    echo ""
    echo "Used Letters"
    echo "$guessed_letters"
    exit 0
  fi

  if [ "$gstatus" -ne 0 ] && [ "$gstatus" -ne 1 ] ; then
    echo "Unknown game status $gstatus"
    exit 4
  fi

  if [ "x$error" != "x" ] ; then
    echo "$CLMAGENTA$error$CLRESET"
  fi

  echo "You have $CLBLUE$lives$CLRESET lives left"

  echo "$word" | sed -e 's/\(.\)/\1\
/g' | while read -r letter ; do
    upletter="$(echo "$letter" | tr '[:lower:]' '[:upper:]')"
    if echo "$letters" | grep "$upletter" > /dev/null 2>&1 ; then
      printf "%s" "$letter "
    else
      printf "_ "
    fi
  done

  echo ""
  echo ""

  echo "Used Letters"
  echo "$guessed_letters"
  echo ""

  printf "Enter a letter: "
  read -r letter
  echo

  if [ "x$letter" = "x" ] ; then
    error="Letter was empty"
    continue
  fi

  if [ "$(printf "%s" "$letter" | wc -m)" -ne 1 ] ; then
    error="Please enter a single letter"
    continue
  fi

  response="$(curl -v -H "Accept: application/json" "$URL/guesses" --data "game_id=$game_id" --data "guess[letter]=$letter" 2> /dev/null | tr -d '\r')"

  if echo "$response" | grep "HTTP/1.1 201 Created" > /dev/null 2>&1 ; then
    continue
  fi

  error="$(echo "$response" | tail -n 1)"

done

