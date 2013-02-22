#!/bin/bash

FAQ=$(dirname $0)
SCRIPTNAME=$(basename $0)
FTPSITE=$(grep machine ~/.netrc| cut -f 2)
JW=/usr/bin/jw

do_help()
{
    echo "Usage: ${SCRIPTNAME}" >&2
    echo "Build SGML into HTML and optionally FTP to my ISP at ${FTPSITE}." >&2
    echo "Options:" >&2
    echo "  -b = build" >&2
    echo "  -f = ftp to site set in .netrc" >&2
    echo "  -h = this help" >&2
    echo "Return codes:" >&2
    echo "  0 = build completed successfully" >&2
    echo "  1 = build failed, see previous messages" >&2
    echo "Copyright 2010 Frank Jung. All rights reserved." >&2
}

do_check()
{
    # check dependencies
    if [[ ! -x ${JW} ]]; then
        echo "ERROR: /usr/bin/jw not installed" >&2
        echo "" >&2
        do_help
        exit 1
    fi
}

do_build() 
{
    do_check
    rm -rf $FAQ/index/*
    rm -rf $FAQ/index.junk
    ${JW} -f docbook -b html -o index index.sgml
    chmod 755 $FAQ/index/
    chmod 644 $FAQ/index/*
}

do_ftp()
{
    ftp -pv <<FTPFAQ
        open $FTPSITE
        ascii
        verbose
        prompt
        reset
        tick
        lcd $FAQ/index
        dir .
        delete index.html
        put index.html
        mdelete x*.html
        mput x*.html
        dir .
        bye
FTPFAQ
}

#
# MAINLINE
#

# check for action to perform, show help if none 
if [[ $# -eq 0 ]]; then
    do_help
    exit 0
fi

# at least one parameter
while getopts "fbh" opt;
do
    case "$opt" in
        b)  do_build ;;
        f)  do_ftp ;;
        h)  do_help ;;
        *)  do_help
            exit 1 ;;
    esac
done

exit 0
