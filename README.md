# rdf.sh

A multi-tool shell script for doing Semantic Web jobs on the command line.

# contents

* [usage / features](#usage-features)
  * [overview](#overview)
  * [namespace lookup](#nslookup)
  * [resource description](#description)
  * [syntax highlighting](#highlighting)
  * [resource listings](#listings)
  * [resource inspection / debugging](#inspection)
  * [prefix distribution for data projects](#prefixes)
  * [spinning the semantic web: semantic pingback](#pingback)
  * [autocompletion and resource history](#autocompletion)
* [installation (manually, debian/ubuntu/, brew based)](#installation)


<a name="usage-features"></a>
## usage / features

<a name="overview"></a>
### overview

rdf.sh currently provides these subcommands:

* count -- count triples using rapper
* desc -- outputs description of the given resource in a given format (default: turtle)
* diff -- diff of two RDF files
* get -- curls rdf in xml to stdout (tries accept header)
* head -- curls only the http header but accepts only rdf
* headn -- curls only the http header
* help -- outputs the manpage of rdf.sh
* list -- list resources which start with the given URI
* ns -- curls the namespace from prefix.cc
* nscollect -- collects prefix declarations of a list of ttl/n3 files
* nsdist -- distributes prefix declarations from one file to a list of other ttl/n3 files
* ping -- sends a semantic pingback request from a source to a target or to all possible targets
* pingall -- sends a semantic pingback request to all targets of a source resource
* split -- split an RDF file into pieces of max X triple and -optional- run a command on each part

<a name="nslookup"></a>
### namespace lookup (`ns`)

rdf.sh allows you to quickly lookup namespaces from [prefix.cc](http://prefix.cc) as well as locally defined prefixes:

    $ rdf ns foaf
    http://xmlns.com/foaf/0.1/

These namespace lookups are cached (typically
`$HOME/.cache/rdf.sh/prefix.cache`) in order to avoid unneeded network
traffic. As a result of this subcommand, all other rdf command can get
qnames as parameters (e.g. `foaf:Person` or `skos:Concept`).

To define you own lookup table, just add a line

    prefix|namespace

to `$HOME/.config/rdf.sh/prefix.local`. rdf.sh will use it as a priority
lookup table which overwrites cache and prefix.cc lookup.

rdf.sh can also output prefix.cc syntax templates (uncached): 

    $ rdf ns skos sparql
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

    SELECT *
    WHERE {
      ?s ?p ?o .
    }

    $ rdf ns ping n3    
    @prefix ping: <http://purl.org/net/pingback/> .


<a name="description"></a>
### resource description (`desc`)

Describe a resource by querying for statements where the resource is the
subject. This is extremly useful to fastly check schema details.

    $ rdf desc foaf:Person
    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix owl: <http://www.w3.org/2002/07/owl#> .
    @prefix foaf: <http://xmlns.com/foaf/0.1/> .
    @prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .
    @prefix contact: <http://www.w3.org/2000/10/swap/pim/contact#> .
    
    foaf:Person
        a rdfs:Class, owl:Class ;
        rdfs:comment "A person." ;
        rdfs:isDefinedBy <http://xmlns.com/foaf/0.1/> ;
        rdfs:label "Person" ;
        rdfs:subClassOf contact:Person, geo:SpatialThing, foaf:Agent ;
        owl:disjointWith foaf:Organization, foaf:Project ;
        <http://www.w3.org/2003/06/sw-vocab-status/ns#term_status> "stable" .

In addition to the textual representation, you can calculate a color for visual
resource representation with the `color` command:

    ∴ rdf color http://sebastian.tramp.name
    #2024e9

Refer to the [cold webpage](http://cold.aksw.org) for more information :-)

<a name="highlighting"></a>
### syntax highlighting

rdf.sh supports the highlighted output of turtle with
[pygmentize](http://pygments.org/) and a proper
[turtle lexer](https://github.com/gniezen/n3pygments). If everything is
available (`pygmentize -l turtle` does not throw an error), then it will look
like this.

<img src="https://raw.github.com/seebi/rdf.sh/master/Screenshot.png" />

If you do not want syntax highlighting for some reason, you can disable it by
setting the shell environment variable `RDFSH_HIGHLIGHTING_SUPPRESS` to `true`
e.g with

    export RDFSH_HIGHLIGHTING_SUPPRESS=true

before you start `rdf.sh`.

<a name="listings"></a>
### resource listings (`list`)

To get a quick overview of an unknown RDF schema, rdf.sh provides the
`list` command which outputs a distinct list of subject resources of the
fetched URI:

    $ rdf list geo:
    http://www.w3.org/2003/01/geo/wgs84_pos#
    http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing
    http://www.w3.org/2003/01/geo/wgs84_pos#Point
    http://www.w3.org/2003/01/geo/wgs84_pos#lat
    http://www.w3.org/2003/01/geo/wgs84_pos#location
    http://www.w3.org/2003/01/geo/wgs84_pos#long
    http://www.w3.org/2003/01/geo/wgs84_pos#alt
    http://www.w3.org/2003/01/geo/wgs84_pos#lat_long

You can also provide a starting sequence to constrain the output

    $ rdf list skos:C   
    http://www.w3.org/2004/02/skos/core#Concept
    http://www.w3.org/2004/02/skos/core#ConceptScheme
    http://www.w3.org/2004/02/skos/core#Collection
    http://www.w3.org/2004/02/skos/core#changeNote
    http://www.w3.org/2004/02/skos/core#closeMatch

**Note:** Here the `$GREP_OPTIONS` environment applies to the list. In
my case, I have a `--ignore-case` in it, so e.g. `skos:changeNote` is
listed as well.

This feature only works with schema documents which are available by
fetching the namespace URI (optionally with linked data headers to be
redirected to an RDF document). Nevertheless, you can use this command
also on non schema resources as FOAF profiles and WebIDs:

    $ rdf list http://haschek.eye48.com/
    http://haschek.eye48.com/haschek.rdf
    http://haschek.eye48.com/
    http://haschek.eye48.com/gelabb/

<a name="inspection"></a>
### resource inspection (`get`, `count`, `head` and `headn`)

Fetch a resource via linked data and print it to stdout:

    $ rdf get http://sebastian.tramp.name >me.rdf

Count all statements of a resource (using rapper):
 
    $ rdf count http://sebastian.tramp.name
    rapper: Parsing URI http://sebastian.tramp.name with parser guess
    rapper: Parsing returned 58 triples

Inspect the header of a resource. Use `head` for header request with
content negotiation suitable for linked data and `headn` for a normal
header request as sent by browsers.

    $ rdf head http://sebastian.tramp.name
    HTTP/1.1 302 Found
    [...]
    Location: http://sebastian.tramp.name/index.rdf
    [...]

<a name="prefixes"></a>
### prefix distribution for data projects (`nscollect` and `nsdist`)

Often I need to create a lot of n3/ttl files as a data project which consists
of schema and instance resources. These projects are split over several files
for a better handling and share a set if used namespaces.

When introducing a new namespace to such projects, I need to add the `@prefix`
line to each of the ttl files of this project.

`rdf.sh` has two subcommands which handle this procedure:

* `rdf nscollect` collects all prefixes from existing n3/ttl files in the
  current directory and collect them in the file `prefixes.n3`
* `rdf nsdist *.n3` firstly removes all `@prefix` lines from the target files
  and then add `prefixes.n3` on top of them.

<a name="pingback"></a>
### spinning the semantic web: semantic pingback

With its `ping`/`pingall` commands, `rdf.sh` is a [Semantic
Pingback](http://www.w3.org/wiki/Pingback) client with the following
features:

* Send a single pingback request from a source to a target resource
  * Example: `rdf ping http://sebastian.tramp.name http://aksw.org/SebastianTramp`
* Send a pingback request to all target resources of a source
  * Example: `rdf pingall http://sebastian.tramp.name`
* `rdf.sh` will do the following tests before sending a pingback request:
  * Is the source resource related to the target resource?
  * Is there a pingback server attached to the target resource?

<a name="autocompletion"></a>
### autocompletion and resource history

`rdf.sh` can be used with a 
[zsh](http://en.wikipedia.org/wiki/Zsh)
[command-line completion](http://en.wikipedia.org/wiki/Command-line_completion)
function.
This boosts the usability of  this tool to a new level!
The completion features support for the base commands as well as for
auto-completion of resources.
These resources are taken from the resource history.
The resource history is written to `$HOME/.cache/rdf.sh/resource.history`.

When loaded, the completion function could be used in this way:

    rdf de<tab> tramp<tab>

This could result in the following commandline:

    rdf desc http://sebastian.tramp.name

Notes:

* The substring matching feature of the zsh [completion system](http://linux.die.net/man/1/zshcompsys) should be turned on.
  * e.g. with `zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'`
* This assumes that at least one resource exists in the history which matches `.*tramp.*`

<a name="installation"></a>
## installation

### manually

rdf.sh is a single bash shell script so installation is trivial ... :-)
Just copy or link it to you path, e.g. with

    $ sudo ln -s /path/to/rdf.sh /usr/local/bin/rdf

### debian / ubuntu

You can download a debian package from the [download
section](https://github.com/seebi/rdf.sh/downloads) and install it as root with
the following commands:

    $ sudo dpkg -i /path/to/your/rdf.sh_X.Y_all.deb
    $ sudo apt-get -f install

The `dpkg` run will probably fail due to missing dependencies but the `apt-get`
run will install all dependencies as well as `rdf`.

Currently, `zsh` is a hard dependency since the zsh completion "needs" it.

### brew based

You can install 'rdf.sh' by using the provided recipe:

    brew install https://raw.github.com/seebi/rdf.sh/master/brew/rdf.sh.rb

Currently, only the manpage and the script will be installed (if you know, how
to provide zsh functions in brew, please write a mail).

<a name="dependencies"></a>
### dependencies

Required tools currently are:

* [roqet](http://librdf.org/rasqal/roqet.html) (from rasqal-utils)
* [rapper](http://librdf.org/raptor/rapper.html) (from raptor-utils or raptor2-utils)
* [curl](http://curl.haxx.se/)

Suggested tools are:

 * [zsh](http://zsh.sourceforge.net/) (without the autocompletion, it is not the same)

<a name="files"></a>
### files

These files are available in the repository:

* `README.md` - this file
* `_rdf` - zsh autocompletion file
* `changelog.md` - version changelog
* `doap.ttl` - doap description of rdf.sh
* `rdf.1` - rdf.sh man page
* `rdf.sh` - the script
* `Screenshot.png` - a screeny of rdf.sh in action

These files are used by the tools:

* `$HOME/.cache/rdf.sh/resource.history` - history of all processed resources
* `$HOME/.cache/rdf.sh/prefix.cache` - a cache of all fetched namespaces
* `$HOME/.config/rdf.sh/prefix.local` - locally defined prefix / namespaces

