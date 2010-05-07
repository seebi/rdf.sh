#!/bin/bash
# @(#) A multi-tool shell script for doing Semantic Web jobs on the command line.

this=`basename $0`
command="$1"

if [ "$command" == "" ]
then
    echo "Syntax:" $this "<command>"
    echo "(command is one of: get head rdfhead ns diff count desc list)"
    exit 1
fi

# takes an input string and checks if it is a valid qname
_isQName ()
{
    qname=$1
    if [ "$qname" == "" ]
    then
        echo "isQName error: need an parameter"
        exit 1
    fi

    LocalPart=`echo $qname | cut -d ":" -f 2`
    if [ "$qname" == "$LocalPart" ]
    then
        echo "false"
        return
    else
        Prefix=`echo $qname | cut -d ":" -f 1`

        # this is ugly ... here we distinguish between uris and qnames
        case "$Prefix" in
            "http" | "https" )
                echo "false"
                return
            ;;
        esac

        if [ "$qname" != "$Prefix:$LocalPart" ]
        then
        echo "false"
        return
        else
            echo "true"
            return
        fi
    fi
}

# takes a qname and outputs the prefix
_getPrefix ()
{
    qname=$1
    if [ "$qname" == "" ]
    then
        echo "getPrefix error: need an qname parameter"
        exit 1
    fi

    LocalPart=`echo $qname | cut -d ":" -f 2`
    if [ "$qname" == "$LocalPart" ]
    then
        echo "getPrefix error: $qname is not a valid qname"
        exit 1
    else
        Prefix=`echo $qname | cut -d ":" -f 1`
        if [ "$qname" != "$Prefix:$LocalPart" ]
        then
        echo "getPrefix error: $qname is not a valid qname"
        exit 1
        else
            echo $Prefix
        fi
    fi
}

# takes a qname and outputs the LocalName
_getLocalName ()
{
    qname=$1
    if [ "$qname" == "" ]
    then
        echo "getLocalName error: need an qname parameter"
        exit 1
    fi

    LocalPart=`echo $qname | cut -d ":" -f 2`
    if [ "$qname" == "$LocalPart" ]
    then
        echo "getLocalName error: $qname is not a valid qname"
        exit 1
    else
        Prefix=`echo $qname | cut -d ":" -f 1`
        if [ "$qname" != "$Prefix:$LocalPart" ]
        then
        echo "getLocalName error: $qname is not a valid qname"
        exit 1
        else
            echo $LocalPart
        fi
    fi
}

# takes an input qname or URI and outputs the expanded full URI (if it is a qname)
_expandQName ()
{
    input=$1
    isQName=`_isQName $input`
    if [ "$isQName" == "true" ]
    then
        prefix=`_getPrefix $input`
        localName=`_getLocalName $input`
        namespace=`$this ns $prefix`
        echo $namespace$localName
    else
        echo $input
    fi
}


case "$command" in

"info" | "desc")
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(outputs an N3 description of the given resource)"
        exit 1
    fi
    uri=`_expandQName $uri`
    tmpfile=`tempfile -p rdfsh`
    $this get $uri >$tmpfile
    roqet -q -e "CONSTRUCT {<$uri> ?p ?o} WHERE {<$uri> ?p ?o}" -D $tmpfile | cwm --n3=q
    rm $tmpfile
;;

"list" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(list resources which start with the given URI)"
        exit 1
    fi
    uri=`_expandQName $uri`
    tmpfile=`tempfile -p rdfsh`
    $this get $uri >$tmpfile
    roqet -q -e "SELECT DISTINCT ?s WHERE {?s ?p ?o. FILTER isURI(?s) } " -D $tmpfile 2>/dev/null | cut -d "<" -f 2 | cut -d ">" -f 1 | grep $uri
    rm $tmpfile
;;

"get" | "ld" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(wgets rdf in xml to stdout)"
        exit 1
    fi
    uri=`_expandQName $uri`
    wget -q -O - --header="Accept: application/rdf+xml" $uri
;;

"header" | "head" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(curls only the http header)"
        exit 1
    fi
    uri=`_expandQName $uri`
    curl -I -X HEAD $uri
;;

"rdfheader" | "rdfhead" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(curls only the http header but accepts only rdf)"
        exit 1
    fi
    uri=`_expandQName $uri`
    curl -I -X HEAD -H "Accept: application/rdf+xml" $uri
;;

"ns" | "namespace" )
    prefix="$2"
    suffix="$3"
    if [ "$prefix" == "" ]
    then
        echo "Syntax:" $this "$command <prefix> <suffix>"
        echo "(catch the namespace from prefix.cc)"
        echo " suffix can be n3, rdfa, sparql, ...)"
        exit 1
    fi
    if [ "$suffix" == "" ]
    then
        wget -O - -q http://prefix.cc/$prefix.file.n3 | cut -d "<" -f 2 | cut -d ">" -f 1
    else
        wget -O - -q http://prefix.cc/$prefix.file.$suffix
    fi
;;

"meld" | "diff" )
	source1="$2"
	source2="$3"
    if [ "$source2" == "" ]
    then
        echo "Syntax:" $this "$command <rdf-file-1> <rdf-file-2>"
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
        echo "Syntax:" $this "$command <file>"
        echo "(count triples using rapper)"
        exit 1
    fi
    rapper -c $file
;;

#"validate" | "v" )
#    file="$2"
#    if [ "$file" == "" ]
#    then
#        echo "Syntax:" $this "$command <file>"
#        echo "(validates rdf/xml using http://www.w3.org/RDF/Validator/ARPServlet)"
#        exit 1
#    fi
#    wget --post-file=post.rdf http://www.w3.org/RDF/Validator/ARPServlet -q -O - | html2text
#;;

* )
    echo "Unknown command!"
esac

