#!/bin/bash
# @(#) A multi-tool shell script for doing Semantic Web jobs on the command line.

# application metadata
name="rdf.sh"
version="0.3-dev"
home="https://github.com/seebi/rdf.sh"

# basic application environment
this=`basename $0`
thisexec=$0
command="$1"
curlcommand="curl --fail -A ${name}/${version} -s -L"

###
# private functions
###

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
        namespace=`$thisexec ns $prefix`
        echo $namespace$localName
    else
        echo $input
    fi
}

_getNamespaceFromPrefix ()
{
    prefix=$1
    if [ "$prefix" == "" ]
    then
        echo "getNamespaceFromPrefix error: need a prefix parameter"
        exit 1
    fi
    namespace=`_getPrefixFromCache $prefix`
    if [ "$namespace" == "" ]
    then
        # no cache-hit, request it from prefix.cc
        namespace=`$curlcommand http://prefix.cc/$prefix.file.n3 | cut -d "<" -f 2 | cut -d ">" -f 1`
        if [ "$namespace" != "" ]
        then
            _addPrefixToCache $prefix "$namespace"
        fi
    fi
    # output cache hit or curl output (maybe empty)
    echo $namespace
}

# give a prefix and get a namespace or ""
# this function search in the cache as well the locally configured prefixes
_getPrefixFromCache ()
{
    prefix=$1
    if [ "$prefix" == "" ]
    then
        echo "getPrefixFromCache error: need a prefix parameter"
        exit 1
    fi
    namespace=`cat $prefixlocal $prefixcache | grep "^$prefix|" | head -1 | cut -d "|" -f 2`
    echo $namespace
}

# give a prefix + namespace and get a new cache entry
_addPrefixToCache ()
{
    prefix=$1
    if [ "$prefix" == "" ]
    then
        echo "addPrefixToCache error: need a prefix parameter"
        exit 1
    fi
    namespace=$2
    if [ "$namespace" == "" ]
    then
        echo "addPrefixToCache error: need a namespace parameter"
        exit 1
    fi
    touch $prefixcache
    existingNamespace=`_getPrefixFromCache $prefix`
    if [ "$existingNamespace" == "" ]
    then
        echo "$prefix|$namespace" >>$prefixcache
    fi
}

# add a resource to the .resource_history file
_addToHistory ()
{
    resource=$1
    if [ "$resource" == "" ]
    then
        echo "addToHistory error: need an resource parameter"
        exit 1
    fi

    historyfile=$2
    if [ "$historyfile" == "" ]
    then
        echo "addToHistory error: need an historyfile as second parameter "
        exit 1
    fi
    touch $historyfile

    if [ "$noHistory" == "" ]
    then
        count=`grep $resource $historyfile | wc -l`
        if [ "$count" != 0 ]
        then
            # f resource exists, remove it
            sed -i "s|$resource||g" $historyfile
            sed -i '/^$/d' $historyfile
        fi
        # add (or re-add) the resource at the end
        echo $resource >>$historyfile
    fi
}

# creates a tempfile and returns the filename
_getTempFile ()
{
    tmpfile=`mktemp -q ./rdfsh-XXXX.tmp`
    echo $tmpfile
}

# get all related resources
_getRelatedResources ()
{
    resource=$1
    if [ "$resource" == "" ]
    then
        echo "getRelatedResources error: need an resource parameter"
        exit 1
    fi
    uri=`_expandQName $resource`

    tmpfile=`_getTempFile`
    $thisexec get $uri >$tmpfile
    roqet -q -e "SELECT DISTINCT ?o {<$uri> ?property ?o. FILTER(isUri(?o))}" -D $tmpfile 2>/dev/null | cut -d "<" -f 2 | cut -d ">" -f 1 | grep "^http"
    rm $tmpfile
}

# returns the announced pingback URL or an empty string
_isPingbackEnabled ()
{
    resource=$1
    if [ "$resource" == "" ]
    then
        echo "isPingbackEnabled error: need an resource parameter"
        exit 1
    fi
    uri=`_expandQName $resource`

    pingbackServer=`$thisexec head $uri | grep X-Pingback: | cut -d " " -f 2`
    #$thisexec head $uri | grep X-Pingback: | cut -d " " -f 2
    if [ "$pingbackServer" == "" ]
    then
        tmpfile=`_getTempFile`
        $thisexec get $uri >$tmpfile
        pingbackServer=`roqet -q -e "SELECT ?o {<$uri> <http://purl.org/net/pingback/to> ?o}" -D $tmpfile 2>/dev/null | head -1 | cut -d "<" -f 2 | cut -d ">" -f 1`
        rm $tmpfile
    fi

    # output server
    if [ "$pingbackServer" != "" ]
    then
        echo $pingbackServer
    fi
}

# send a pingback to server $1 which connects the source $2 with the target $3
_sendPingback ()
{
    pbserver=$1
    if [ "$pbserver" == "" ]
    then
        echo "sendPingback error: need a pingback server URL as first parameter"
        exit 1
    fi
    pbsource=$2
    if [ "$pbsource" == "" ]
    then
        echo "sendPingback error: need a pingback source URL as second parameter"
        exit 1
    fi
    pbtarget=$3
    if [ "$pbtarget" == "" ]
    then
        echo "sendPingback error: need a pingback target URL as third parameter"
        exit 1
    fi

    result=`$curlcommand $pbserver --data "source=$pbsource&target=$pbtarget"`
    echo "server response: $result"
}

###
# the "command" functions:
# the are executed by using the first parameter and get all parameters as options
###

docu_desc () { echo "outputs description of the given resource in a given format (default: turtle)";}
do_desc ()
{
    uri="$2"
    output="$3"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart> <format>"
        echo "(`docu_desc`)"
        exit 1
    fi
    if [ "$output" == "" ]
    then
        output="turtle"
    fi
    uri=`_expandQName $uri`
    tmpfile=`_getTempFile`
    $thisexec get $uri >$tmpfile
    roqet -q -e "CONSTRUCT {<$uri> ?p ?o} WHERE {<$uri> ?p ?o}" -D $tmpfile -r $output
    rm $tmpfile
    _addToHistory $uri $historyfile

}

docu_list () { echo "list resources which start with the given URI"; }
do_list ()
{
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_list`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    tmpfile=`_getTempFile`
    # turn history off for this internal call (dirty URIs)
    export noHistory="true"
    $thisexec get $uri >$tmpfile
    roqet -q -e "SELECT DISTINCT ?s WHERE {?s ?p ?o. FILTER isURI(?s) } " -D $tmpfile 2>/dev/null | cut -d "<" -f 2 | cut -d ">" -f 1 | grep $uri
    rm $tmpfile
}

docu_get () { echo "curls rdf in xml to stdout (tries accept header)"; }
do_get ()
{
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_get`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    $curlcommand -H "Accept: application/rdf+xml" $uri
    _addToHistory $uri $historyfile
}

docu_headn () { echo "curls only the http header"; }
do_headn ()
{
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_head`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    $curlcommand -I -X HEAD $uri
    _addToHistory $uri $historyfile
}

docu_head () { echo "curls only the http header but accepts only rdf"; }
do_head ()
{
    uri="$2"
    if [ "$uri" == "" ]
    then
        echo "Syntax:" $this "$command <URI | Prefix:LocalPart>"
        echo "(`docu_rdfhead`)"
        exit 1
    fi
    uri=`_expandQName $uri`
    $curlcommand -I -X HEAD -H "Accept: application/rdf+xml" $uri
    _addToHistory $uri $historyfile
}

docu_ns () { echo "curls the namespace from prefix.cc"; }
do_ns ()
{
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
        # this is a standard request as "rdf ns foaf"
        namespace=`_getNamespaceFromPrefix $prefix`
        echo $namespace
    else
        if [ "$suffix" == "plain" ]
        then
            # this is for vim integration, plain = without newline
            namespace=`_getNamespaceFromPrefix $prefix`
            echo -n $namespace
        else
            # if a real suffix is given, we always fetch from prefix.cc
            $curlcommand http://prefix.cc/$prefix.file.$suffix
        fi
    fi
}

docu_diff () { echo "diff of two RDF files"; }
do_diff ()
{
    source1="$2"
    source2="$3"
    difftool="$4"

    if [ "$difftool" != "" ]
    then
        RDFSHDIFF=$difftool
    fi

    if [ "$RDFSHDIFF" == "" ]
    then
        for difftool in "diff" "meld"
        do
            which $difftool >/dev/null
            if [ "$?" == "0" ]
            then
                RDFSHDIFF=$difftool
            fi
        done
    fi

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
    $RDFSHDIFF $dest1 $dest2
    rm $dest1 $dest2
}

docu_count () { echo "count triples using rapper"; }
do_count ()
{
    file="$2"
    if [ "$file" == "" ]
    then
        echo "Syntax:" $this "$command <file>"
        echo "(`docu_count`)"
        exit 1
    fi
    rapper -i guess --count $file
}

docu_split () { echo "split an RDF file into pieces of max X triple and -optional- run a command on each part"; }
do_split ()
{
    file="$2"
    size="$3"
    todo="$4"
    if [ "$file" == "" ]
    then
        echo "Syntax:" $this "$command <file> <size-X> <command>"
        echo "(`docu_split`)"
        exit 1
    fi
    if [ "$size" == "" ]
    then
        size="25000"
    fi

    tmpdir=`mktemp -d`
    rapper -i guess -q $file | split -a 5 -l $size - $tmpdir/
    echo "Input splitted into `ls -1 $tmpdir | wc -l` pieces of max. $size triples."

    if [ "$todo" != "" ]
    then
        echo "Now executing '$todo' for every part (using %PART% as a placeholder):"
        for piece in `ls -1 $tmpdir`
        do
            cd $tmpdir
            realtodo=`echo $todo | sed "s/%PART%/$piece/" `
            echo $realtodo
            $realtodo
        done
    fi

    echo "The pieces are in $tmpdir ... "
}

docu_nscollect() { echo "collects prefix declarations of a list of ttl/n3 files";}
do_nscollect()
{
    prefixfile="$2"

    if [ "$prefixfile" == "" ]
    then
        prefixfile="prefixes.n3"
    fi

    if [ -f "$prefixfile" ]
    then
        countBefore=`cat $prefixfile| wc -l`
    else
        countBefore=0
    fi

    files=`ls -1 *.n3 *.ttl 2>/dev/null | grep -v $prefixfile`
    cat $files | grep "@prefix " | sort -u >$prefixfile
    count=`cat $prefixfile| wc -l`
    echo "$count prefixes collected in $prefixfile ($countBefore before)"
    #for n3file in $files
    #do
    #done
}

docu_nsdist () { echo "distributes prefix declarations from one file to a list of other ttl/n3 files";}
do_nsdist ()
{
    prefixfile="prefixes.n3"
    if [ ! -f "$prefixfile" ]
    then
        echo "Syntax:" $this "$command <targetfiles>"
        echo "(`docu_nsdist`)"
        echo "I try to use $prefixfile as source but it is empty."
        exit 1
    fi

    if [ "$2" == "" ]
    then
        files=`ls -1 *.n3 *.ttl 2>/dev/null | grep -v $prefixfile`
    else
        files=$@
    fi

    count=`cat $prefixfile| wc -l`
    tmpfile=`mktemp -q ./rdfsh-XXXX`
    for target in $files
    do
        if [ -f "$target" ]
        then
            before=`cat $target | grep "@prefix "  | wc -l`

            cat $target | grep -v "@prefix " >$tmpfile
            cat $prefixfile >$target
            cat $tmpfile >>$target

            after=`cat $target | grep "@prefix "  | wc -l`
            let result=$after-$before
            if [ "$result" -ge "0" ]
            then
                echo "$target: +$result prefix declarations"
            else
                echo "$target: $result prefix declarations"
            fi
        fi
    done
    rm $tmpfile
}

docu_ping () { echo "sends a semantic pingback request from a source to a target or to all possible targets"; }
do_ping ()
{
    pingsource="$2"
    pingtargets="$3"

    # check for ping source
    if [ "$pingsource" == "" ]
    then
        echo "Syntax:" $this "$command <pingsource> <pingtarget>"
        echo "(`docu_ping`)"
        exit 1
    fi
    pingsource=`_expandQName $pingsource`

    # check for ping target
    if [ "$pingtargets" != "" ]
    then
        # target is given as parameter, so check
        pingtargets=`_getRelatedResources $pingsource | grep "^$pingtargets$"`
        if [ "$pingtargets" == "" ]
        then
            echo "Error: No link found."
            exit 1
        fi
    else
        # target not given as paremeter, so search for
        pingtargets=`_getRelatedResources $pingsource`
        if [ "$pingtargets" == "" ]
        then
            echo "Error: No targets available at all."
            exit 1
        fi
    fi

    count=`echo $pingtargets | wc -w`
    if [ "$count" -ge 2 ]
    then
        echo "Please provide one of these ping target resources as a second parameter:"
        for target in $pingtargets
        do
            echo "- $target"
        done
        exit 1
    fi

    # look for a pingback server responsable for the target
    pingserver=`_isPingbackEnabled $pingtargets`
    if [ "$pingserver" == "" ]
    then
        echo "Error: No pingback server found for $pingtargets"
        exit 1
    fi

    # finally, do the ping
    _sendPingback $pingserver $pingsource $pingtargets
}

docu_help () { echo "outputs the manpage of $this"; }
do_help ()
{
    realfile=`readlink $thisexec`
    if [ "$realfile" == "" ]
    then
        # assume useage over "xxx/yyy/rdf.sh/rdf.sh help"
        execdir=`dirname $thisexec`
        manpage="$execdir/rdf.1"
    else
        # assume rdf.sh started as link and manpage is in same dir with script
        execdir=`dirname $thisexec`
        scriptdir=`dirname $realfile`
        manpage="$execdir/$scriptdir/rdf.1"
    fi
    # try central manpage first, then try the guessed one
    man rdf 2>/dev/null || man -l $manpage
}

###
# execute the command NOW :-)
###

# rdf.sh uses proper XDG config and cache directories now
if [ "$XDG_CONFIG_HOME" == "" ]
then
    XDG_CONFIG_HOME="$HOME/.config"
fi
if [ "$XDG_CACHE_HOME" == "" ]
then
    XDG_CACHE_HOME="$HOME/.cache"
fi
confdir="$XDG_CONFIG_HOME/rdf.sh"
cachedir="$XDG_CACHE_HOME/rdf.sh"
mkdir -p $confdir
mkdir -p $cachedir
historyfile="$cachedir/resource.history"
prefixcache="$cachedir/prefix.cache"
prefixlocal="$confdir/prefix.local"
touch $prefixlocal

# taken from http://stackoverflow.com/questions/2630812/
commandlist=`typeset -f | grep "do_.*()" | cut -d "_" -f 2 | cut -d " " -f 1 | sort`

# if no command is given, present a basic help screen
if [ "$command" == "" ]
then
    echo "$this is a a multi-tool shell script for doing Semantic Web jobs on the command line."
    echo "Version:  $version"
    echo "Homepage: $home"
    echo ""
    echo "Syntax: $this <command>"
    echo ""
    echo "Available commands are:"
    for cmd in $commandlist
    do
        echo "  $cmd:" `docu_$cmd`
    done
    exit 1
fi

# for generating the autocompletion suggestions automatically
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

# now start the sub - command
# taken from http://stackoverflow.com/questions/1007538/
if type do_$command >/dev/null 2>&1
then
    do_$command $*
else
    echo "$this: '$command' is not a rdf command. See '$this help'."
    exit 1
fi

