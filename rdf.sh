#!/bin/bash
# @(#) A multi-tool shell script for doing Semantic Web jobs on the command line.

this=`basename $0`
command="$1"

commandlist="get head rdfhead ns diff count desc list"
commandinfo["desc"]="outputs an N3 description of the given resource"

docu_desc () { echo "outputs an N3 description of the given resource";}
docu_list () { echo "list resources which start with the given URI"; }
docu_get () { echo "wgets rdf in xml to stdout (tries accept header)"; }
docu_head () { echo "curls only the http header"; }
docu_rdfhead () { echo "curls only the http header but accepts only rdf"; }
docu_ns () { echo "catch the namespace from prefix.cc"; }
docu_diff () { echo "diff of two RDF files"; }
docu_count () { echo "count triples using rapper"; }

if [ "$command" == "" ]
then
    echo "Syntax:" $this "<command>"
    echo "(command is one of: $commandlist)"
    exit 1
fi

if [ "$command" == "zshcomp" ]
then
    #echo "$commandlist"
    echo "("
    for cmd in $commandlist
    do
        echo $cmd:\"`docu_$cmd`\"
    done
    echo ")"
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
            "http" | "https" | "mailto" | "ldap" | "urn" )
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

"desc")
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_desc`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    tmpfile=`mktemp -q ./rdfsh-XXXX`
    $this get $uri >$tmpfile
    roqet -q -e "CONSTRUCT {<$uri> ?p ?o} WHERE {<$uri> ?p ?o}" -D $tmpfile | cwm --n3=q
    rm $tmpfile
;;

"list" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_list`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    tmpfile=`mktemp -q ./rdfsh-XXXX`
    $this get $uri >$tmpfile
    roqet -q -e "SELECT DISTINCT ?s WHERE {?s ?p ?o. FILTER isURI(?s) } " -D $tmpfile 2>/dev/null | cut -d "<" -f 2 | cut -d ">" -f 1 | grep $uri
    rm $tmpfile
;;

"get")
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_get`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    wget -q -O - --header="Accept: application/rdf+xml" $uri
;;

"head" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_head`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    curl -I -X HEAD $uri
;;

"rdfhead" )
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_rdfhead`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    curl -I -X HEAD -H "Accept: application/rdf+xml" $uri
;;

"ns" )
    prefix="$2"
    suffix="$3"
    if [ "$prefix" == "" ]
    then
        echo "Syntax:" $this "$command <prefix> <suffix>"
        echo "(`docu_ns`)"
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

"diff" )
	source1="$2"
	source2="$3"
    if [ "$source2" == "" ]
    then
        echo "Syntax:" $this "$command <rdf-file-1> <rdf-file-2>"
        echo "(`docu_diff`)"
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
        echo "(`docu_count`)"
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

