# rdf.sh

A multi-tool shell script for doing Semantic Web jobs on the command line.

## usage / features

### overview

rdf.sh currently provides these subcommands:

* count -- count triples using rapper
* desc  -- outputs a turtle description of the given resource
* diff  -- diff of two RDF files
* get   -- curls rdf in xml to stdout (tries accept header)
* head  -- curls only the http header but accepts only rdf
* headn -- curls only the http header
* list  -- list resources which start with the given URI
* ns    -- curls the namespace from prefix.cc
* nscollect  -- collects prefix declarations of a list of ttl/n3 files
* nsdist     -- distributes prefix declarations from one file to a list of other ttl/n3 files
* split -- split an RDF file into pieces of max X triple and -optional- run a command on each part

### namespace lookup (`ns`)

rdf.sh allows you to quickly lookup namespaces from [prefix.cc](http://prefix.cc):

    $ rdf ns foaf
    http://xmlns.com/foaf/0.1/

rdf.sh can also output prefix.cc syntax templates: 

    $ rdf ns skos sparql
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

    SELECT *
    WHERE {
      ?s ?p ?o .
    }

    $ rdf ns ping n3    
    @prefix ping: <http://purl.org/net/pingback/> .

**Note:** As a result of this subcommand, all other rdf command can
get qnames as parameters (e.g. `foaf:Person` or `skos:Concept`) which
results in a namespace lookup ahead of the used command.

### resource description (`desc`)

Describe a resource by querying for statements where the resource is the
subject. This is extremly useful to fastly check schema details.

    $ rdf desc foaf:Person
    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

    <http://xmlns.com/foaf/0.1/Person> a <http://www.w3.org/2000/01/rdf-schema#Class>, <http://www.w3.org/2002/07/owl#Class> ;
    <http://www.w3.org/2000/01/rdf-schema#comment> "A person." ;
    <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <http://xmlns.com/foaf/0.1/> ;
    <http://www.w3.org/2000/01/rdf-schema#label> "Person" ;
    <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/swap/pim/contact#Person>, <http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing>, <http://xmlns.com/foaf/0.1/Agent> ;
    <http://www.w3.org/2002/07/owl#disjointWith> <http://xmlns.com/foaf/0.1/Organization>, <http://xmlns.com/foaf/0.1/Project> ;
    <http://www.w3.org/2003/06/sw-vocab-status/ns#term_status> "stable" .

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

## installation

rdf.sh is a single bash shell script so installation is trivial ... :-)
Just copy or link it to you path, e.g. with

    $ sudo ln -s /path/to/rdf.sh /usr/local/bin/rdf

### dependencies

Required tools currently are:

  * [roqet](http://librdf.org/rasqal/roqet.html) (from rasqal-utils)
  * [rapper](http://librdf.org/raptor/rapper.html) (from raptor-utils or raptor2-utils)
  * [curl](http://curl.haxx.se/)

Suggested tools are:

  * [zsh](http://zsh.sourceforge.net/) (without the autocompletion, it is not the same)

### files

  * `changelog.md` - version changelog
  * `_rdf` - zsh autocompletion file
  * `rdf.sh` - the script
  * `README.md` - this file
