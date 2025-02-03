# rdf.sh

A multi-tool shell script for doing Semantic Web jobs on the command line.

[![Build Status](https://api.travis-ci.com/seebi/rdf.sh.svg?branch=develop)](https://app.travis-ci.com/seebi/rdf.sh)

## contents

* [installation (manually, debian/ubuntu/, brew, docker)](#installation)
* [configuration](#configuration)
* [usage / features](#usage-features)
  * [overview](#overview)
  * [namespace lookup](#nslookup)
  * [resource description](#description)
  * [SPARQL graph store protocol](#gsp)
  * [linked data platform client](#ldp)
  * [WebID requests](#webid)
  * [syntax highlighting](#highlighting)
  * [resource listings](#listings)
  * [resource inspection / debugging](#inspection)
  * [materialize / skolemize bnodes](#skolemize)
  * [re-format RDF files in turtle](#turtleize)
  * [prefix distribution for data projects](#prefixes)
  * [autocompletion and resource history](#autocompletion)

<a name="installation"></a>
## installation

### manually

rdf.sh is a single bash shell script so installation is trivial ... :-)
Just copy or link it to you path, e.g. with

```shell
sudo ln -s /path/to/rdf.sh /usr/local/bin/rdf
```

### debian / ubuntu

You can download a debian package from the [release
section](https://github.com/seebi/rdf.sh/releases) and install it as root with
the following commands:

```shell
sudo dpkg -i /path/to/your/rdf.sh_X.Y_all.deb
sudo apt-get -f install
```

The `dpkg` run will probably fail due to missing dependencies but the `apt-get`
run will install all dependencies as well as `rdf`.

Currently, `zsh` is a hard dependency since the zsh completion "needs" it.

### brew based

You can install `rdf.sh` by using the provided recipe:

```shell
brew install https://raw.githubusercontent.com/seebi/rdf.sh/develop/brew/rdf.sh.rb
```

This will install the latest stable version.
In case you want to install the latest develop version, use this command:

```shell
brew install --HEAD https://raw.githubusercontent.com/seebi/rdf.sh/develop/brew/rdf.sh.rb
```

### docker based

You can install `rdf.sh` by using the provided docker image:

```shell
docker pull seebi/rdf.sh
```

After that, you can e.g. run this command:

```shell
docker run -i -t --rm seebi/rdf.sh desc foaf:Person
```

<a name="dependencies"></a>
### dependencies

Required tools currently are:

* [roqet](https://librdf.org/rasqal/roqet.html) (from rasqal-utils)
* [rapper](https://librdf.org/raptor/rapper.html) (from raptor-utils or raptor2-utils)
* [curl](https://curl.se/)

Suggested tools are:

* [zsh](https://zsh.sourceforge.io/) (without the autocompletion, it is not the same)

<a name="files"></a>
### files

These files are available in the repository:

* `README.md` - this file
* `_rdf` - zsh autocompletion file
* `CHANGELOG.md` - version change log
* `doap.ttl` - doap description of rdf.sh
* `rdf.1` - rdf.sh man page
* `rdf.sh` - the script
* `Screenshot.png` - a screeny of rdf.sh in action
* `example.rc` - an example config file which can be copied

These files are used by rdf.sh:

* `$HOME/.cache/rdf.sh/resource.history` - history of all processed resources
* `$HOME/.cache/rdf.sh/prefix.cache` - a cache of all fetched namespaces
* `$HOME/.config/rdf.sh/prefix.local` - locally defined prefix / namespaces
* `$HOME/.config/rdf.sh/rc` - config file

rdf.sh follows the
[XDG Base Directory Specification](
https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
in order to allow different cache and config directories.

<a name="usage-features"></a>
## usage / features

<a name="overview"></a>
### overview

rdf.sh currently provides these subcommands:

* color: get a html color for a resource URI
* count: count distinct triples
* delete: deletes an existing linked data resource via LDP
* desc: outputs description of the given resource in a given format (default: turtle)
* diff: diff of triples from two RDF files
* edit: edit the content of an existing linked data resource via LDP (GET + PUT)
* get: fetches an URL as RDF to stdout (tries accept header)
* get-ntriples: curls rdf and transforms to ntriples
* gsp-delete: delete a graph via SPARQL 1.1 Graph Store HTTP Protocol
* gsp-get: get a graph via SPARQL 1.1 Graph Store HTTP Protocol
* gsp-put: delete and re-create a graph via SPARQL 1.1 Graph Store HTTP Protocol
* head: curls only the http header but accepts only rdf
* headn: curls only the http header
* help: outputs the manpage of rdf
* list: list resources which start with the given URI
* ns: curls the namespace from prefix.cc
* nscollect: collects prefix declarations of a list of ttl/n3 files
* nsdist: distributes prefix declarations from one file
  to a list of other ttl/n3 files
* nssort: sorts the prefix declarations in files
* put: replaces an existing linked data resource via LDP
* split: split an RDF file into pieces of max X triple and output the file names
* turtleize: outputs an RDF file in turtle,
  using as much as possible prefix declarations

<a name="nslookup"></a>
### namespace lookup (`ns`)

rdf.sh allows you to quickly lookup namespaces from [prefix.cc](https://prefix.cc)
as well as locally defined prefixes:

```shell
$ rdf ns foaf
http://xmlns.com/foaf/0.1/
```

These namespace lookups are cached (typically
`$HOME/.cache/rdf.sh/prefix.cache`) in order to avoid unneeded network
traffic. As a result of this subcommand, all other rdf command can get
qnames as parameters (e.g. `foaf:Person` or `skos:Concept`).

To define you own lookup table, just add a line

```
prefix|namespace
```

to `$HOME/.config/rdf.sh/prefix.local`. rdf.sh will use it as a priority
lookup table which overwrites cache and prefix.cc lookup.

rdf.sh can also output prefix.cc syntax templates (uncached):

```shell
$ rdf ns skos sparql
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT *
WHERE {
  ?s ?p ?o .
}

$ rdf ns dct n3
@prefix dct: <http://purl.org/dc/terms/>.
```

<a name="description"></a>
### resource description (`desc`)

Describe a resource by querying for statements where the resource is the
subject. This is extremly useful to fastly check schema details.

```shell
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
```

In addition to the textual representation, you can calculate a color for visual
resource representation with the `color` command:

```shell
$ rdf color http://sebastian.tramp.name
#2024e9
```

Refer to the [cold webpage (archived)](
https://web.archive.org/web/20210301164303/http://cold.aksw.org/index.php)
for more information. :-)

<a name="gsp"></a>
### SPARQL graph store protocol client

The [SPARQL 1.1 Graph Store HTTP Protocol](https://www.w3.org/TR/sparql11-http-rdf-update/)
describes the use of HTTP operations
for the purpose of managing a collection of RDF graphs.
rdf.sh supports the following commands in order to manipulate graphs:

```manpage
Syntax: rdf gsp-get <graph URI | Prefix:LocalPart> <store URL | Prefix:LocalPart (optional)>
(get a graph via SPARQL 1.1 Graph Store HTTP Protocol)
```

```manpage
Syntax: rdf gsp-put <graph URI | Prefix:LocalPart> <path/to/your/file.rdf> <store URL | Prefix:LocalPart (optional)>
(delete and re-create a graph via SPARQL 1.1 Graph Store HTTP Protocol)
```

```manpage
Syntax: rdf gsp-delete <graph URI | Prefix:LocalPart> <store URL | Prefix:LocalPart (optional)>
(delete a graph via SPARQL 1.1 Graph Store HTTP Protocol)
```

If the store URL **is not given**,
the [Direct Graph Identification](
https://www.w3.org/TR/sparql11-http-rdf-update/#direct-graph-identification)
is assumed,
which means the store URL is taken as the graph URL.
If the store URL **is given**, [Indirect Graph Identification](
https://www.w3.org/TR/sparql11-http-rdf-update/#indirect-graph-identification)
is used.

<a name="ldp"></a>
### linked data platform client

The [Linked Data Platform](https://www.w3.org/TR/ldp/) describe a read-write
Linked Data architecture, based on HTTP access to web resources that describe
their state using the RDF data model. rdf.sh supports
[DELETE](https://www.w3.org/TR/ldp/#http-delete),
[PUT](https://www.w3.org/TR/ldp/#http-put) and edit (GET, followed by an edit
command, followed by a PUT request)
of Linked Data Platform Resources (LDPRs).

```
Syntax: rdf put <URI | Prefix:LocalPart> <path/to/your/file.rdf>
(replaces an existing linked data resource via LDP)
```

```
Syntax: rdf delete <URI | Prefix:LocalPart>
(deletes an existing linked data resource via LDP)
```

```
Syntax: rdf edit <URI | Prefix:LocalPart>
(edit the content of an existing linked data resource via LDP (GET + PUT))
```

The edit command uses the `EDITOR` variable to start the editor of your choice
with a prepared turtle file.
You can change the content of that file (add or remove triple) and you can use
any prefix you've already declared via config or which is cached.
Used prefix declarations are added automatically afterwards and the file is the
PUTted to the server.

<a name="webid"></a>
### WebID requests

In order to request ressources with your WebID client certificate, you need to
setup the rdf.sh `rc` file (see configuration section).
Curl allows for using client certs with the
[-E parameter](https://curl.se/docs/manpage.html#-E), which needs a
[pem](https://en.wikipedia.org/wiki/X.509#Certificate_filename_extensions) file
with your private key AND the certificate.

To use your proper created WebID pem file, just add this to your rc file:

```bash
RDFSH_CURLOPTIONS_ADDITONS="-E $HOME/path/to/your/webid.pem"
```

<a name="highlighting"></a>
### syntax highlighting

rdf.sh supports the highlighted output of turtle with
[pygmentize](https://pygments.org/) and a proper
[turtle lexer](https://github.com/gniezen/n3pygments). If everything is
available (`pygmentize -l turtle` does not throw an error), then it will look
like this.

![](Screenshot.png)

If you do not want syntax highlighting for some reason, you can disable it by
setting the shell environment variable `RDFSH_HIGHLIGHTING_SUPPRESS` to `true`
e.g with

```bash
export RDFSH_HIGHLIGHTING_SUPPRESS=true
```

before you start `rdf.sh`.

<a name="listings"></a>
### resource listings (`list`)

To get a quick overview of an unknown RDF schema, rdf.sh provides the
`list` command which outputs a distinct list of subject resources of the
fetched URI:

```shell
$ rdf list geo:
http://www.w3.org/2003/01/geo/wgs84_pos#
http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing
http://www.w3.org/2003/01/geo/wgs84_pos#Point
http://www.w3.org/2003/01/geo/wgs84_pos#lat
http://www.w3.org/2003/01/geo/wgs84_pos#location
http://www.w3.org/2003/01/geo/wgs84_pos#long
http://www.w3.org/2003/01/geo/wgs84_pos#alt
http://www.w3.org/2003/01/geo/wgs84_pos#lat_long
```

You can also provide a starting sequence to constrain the output

```shell
$ rdf list skos:C
http://www.w3.org/2004/02/skos/core#Concept
http://www.w3.org/2004/02/skos/core#ConceptScheme
http://www.w3.org/2004/02/skos/core#Collection
http://www.w3.org/2004/02/skos/core#changeNote
http://www.w3.org/2004/02/skos/core#closeMatch
```

**Note:** Here the `$GREP_OPTIONS` environment applies to the list. In
my case, I have a `--ignore-case` in it, so e.g. `skos:changeNote` is
listed as well.

This feature only works with schema documents which are available by
fetching the namespace URI (optionally with linked data headers to be
redirected to an RDF document).

<a name="inspection"></a>
### resource inspection (`get`, `count`, `head` and `headn`)

Fetch a resource via linked data and print it to stdout:

```shell
rdf get http://sebastian.tramp.name >me.rdf
```

Count all statements of a resource:

```shell
$ rdf count http://sebastian.tramp.name
58
```

Inspect the header of a resource. Use `head` for header request with
content negotiation suitable for linked data and `headn` for a normal
header request as sent by browsers.

```shell
$ rdf head http://sebastian.tramp.name
HTTP/1.1 302 Found
[...]
Location: http://sebastian.tramp.name/index.rdf
[...]
```

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

<a name="skolemize"></a>
### Materialize / skolemize bnodes (`skolemize`)

Blank nodes can be painful,
so this command materializes all blank nodes as full IRIs.
The first parameter is the RDF file,
while the second parameter is an optional namespace for the UUID minted IRIs
(default is `urn:uuid:`).

<a name="turtleize"></a>
### re-format RDF files in turtle (`turtleize`)

Working with RDF files often requires to convert and reformat different files.
With `rdf turtleize`, its easy to get RDF files in turtle plus they are nicely
formatted because all needed prefix declarations are added.

turtleize uses rapper and tries to detect all namespaces which are cached in
your `prefix.cache` file, as well as which a defined in the `prefix.local` file.

To turtleize your current buffer in vim for example,
you can do a `:%! rdf turtleize %`.

<a name="autocompletion"></a>
### autocompletion and resource history

`rdf.sh` can be used with a
[zsh](https://en.wikipedia.org/wiki/Zsh)
[command-line completion](https://en.wikipedia.org/wiki/Command-line_completion)
function.
This boosts the usability of  this tool to a new level!
The completion features support for the base commands as well as for
auto-completion of resources.
These resources are taken from the resource history.
The resource history is written to `$HOME/.cache/rdf.sh/resource.history`.

When loaded, the completion function could be used in this way:

```shell
rdf de<tab> tramp<tab>
```

This could result in the following commandline:

```shell
rdf desc http://sebastian.tramp.name
```

Notes:

* The substring matching feature of the zsh [completion system](
  https://linux.die.net/man/1/zshcompsys) should be turned on.
  * e.g. with `zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'`
* This assumes that at least one resource exists in the history which matches `.*tramp.*`

<a name="configuration"></a>
## configuration

rdf.sh imports `$HOME/.config/rdf.sh/rc` at the beginning of each execution so
this is the place to setup personal configuration options such as

* WebID support
* syntax highlighting suppression
* setup of preferred accept headers
* setup of alternate ntriples fetch program such as any23's rover
  (see [this feature request](https://github.com/seebi/rdf.sh/issues/8)
  for background infos)

Please have a look at the [example rc file](example.rc).
