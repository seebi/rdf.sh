#!/bin/bash
# @(#) A multi-tool shell script for doing Semantic Web jobs on the command line.

command="$1"

if [ "$command" == "" ]
then
    echo "Syntax:" `basename $0` "<command>"
    echo "(command is one of: get head ns diff count)"
    exit 1
fi

case "$command" in

"get" | "ld" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" `basename $0` "$command <URI>"
        echo "(wgets rdf in xml to stdout)"
        exit 1
    fi
    wget -q -O - --header="Accept: application/rdf+xml" $uri
;;

"header" | "head" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" `basename $0` "$command <URI>"
        echo "(curls only the http header)"
        exit 1
    fi
    curl -I -X HEAD $uri
;;

"ns" | "namespace" )
    prefix="$2"
    if [ "$prefix" == "" ]
    then
        echo "Syntax:" `basename $0` "$command <prefix>"
        echo "(catch the namespace from prefix.cc)"
        exit 1
    fi
    wget -O - -q http://prefix.cc/$prefix.file.n3
;;

"meld" | "diff" )
	source1="$2"
	source2="$3"
    if [ "$source2" == "" ]
    then
        echo "Syntax:" `basename $0` "$command <rdf-file-1> <rdf-file-2>"
        echo "(diff of two RDF files)"
        exit 1
    fi
    dest1="/tmp/$RANDOM-`basename $source1`"
    dest2="/tmp/$RANDOM-`basename $source2`"
    rapper $source1 | sort >$dest1
    rapper $source2 | sort >$dest2
    meld $dest1 $dest2
;;

"count" )
    file="$2"
    if [ "$file" == "" ]
    then
        echo "Syntax:" `basename $0` "$command <file>"
        echo "(count triples using rapper)"
        exit 1
    fi
    rapper -c $file
;;


* )
    echo "Unknown command!"
esac

