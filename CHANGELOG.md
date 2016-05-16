# rdf.sh changlog

## Roadmap

* use conditional get and cache of downloaded files
* document password retrieval for webid keystore
* add a distinct option instead of new commands

## 0.7.0 (May 2016)

* new command: turtleize - outputs an RDF file in turtle, using as much as possible prefix declarations 
* new command: distinctcount - count only distinct triples
* new command: distinctdiff - show only diff between distinct triples
* fix for current roqet version which does not support ntriples output anymore
* fix issue with md5 command on debian
* fix error with some namespaces which have ? in it
* fix namespace detection for local names with special chars (e.g. vs:term_status)
* fix zsh completion (allow *.ttl files as RDF files)
* Remove dependency to uniq command

## 0.6 (May 2013)

* new command: color - get a color value for a resource URI :)
* new commands: delete, put and edit (linked data platform commands)
* add support for local configuration options
* add support for WebID requests
* add a brew recipe
* add debian package build directory
* fix issue with macosx ancient sed command (zsh completion)
* fix different auto-completion issues

## 0.5 (Oct 2012)

* introduce support for working with other RDF representations
* allow adoption of accept header via environment `RDFSH_ACCEPT_HEADER`
* fix man page issues on darwin
* support syntax highlighting via pygmentize with the turtle lexer
* introduce the `RDFSH_HIGHLIGHTING_SUPPRESS` environment variable

## 0.4.1 (Apr 2012)

* improve documentation in `README.md`
* fix bug when prefix cache does not exists
* fix bug when `roqet` (or any other tool) is not available

## 0.4 (Mar 2012)

* improve output of desc with prefixes wrong cache and config
* fix rapper call for diff command
* fix a wrong sed call
* fix some darwin related bugs

## 0.3 (Sep 2011)

* new command: help - outputs the manpage
* new command: nscollect - collects prefix declarations of a file list
* new command: nsdist - distributes prefix declarations to a file list
* new command: ping - sends a semantic pingback request (source -> target)
* new command: pingall - sends a semantic pingback request to all targets of a source
* use proper XDG config and caching directories
* add cache for namespace fetching (ns command)
* introduce a local user-generated priority lookup table for the ns command
* improve history creation
* add a second parameter format to the desc subcommand (default: turtle)
* refactoring towards maintainability
* new help screen with docu one-liners
* Darwin workarounds

## 0.2 (Aug 2011)

* add: plain mode for ns command (for scripting)
* add: zsh completion now with history of used resources
* mod: no wget dependency anymore (always curl used instead)
* mod: no cwm dependeny anymore (always rapper used instead)
* mod: command head is now headn (for normal)
* mod: command rdfhead is now head (as an rdf tool, this should be the default)
* fix: curl calls with --fail to avoid getting error pages
* fix: uniq with sort -u now
* misc: moved home to github: https://github.com/seebi/rdf.sh

## 0.1 (Aug 2011)

* first version
* available commands: get head rdfhead ns diff count desc list split

