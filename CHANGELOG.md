# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

TODO: add at least one Added, Changed, Deprecated, Removed, Fixed or Security section

## [0.8.0] 2017-10-14

### Added

* all downloaded files are now cached by default
* allow to override the standard ntriples fetch command with alternatives such as any23's rover CLI
* new commend: gsp-delete - delete a graph via SPARQL 1.1 Graph Store HTTP Protocol
* new command: gsp-get -- get a graph via SPARQL 1.1 Graph Store HTTP Protocol
* new command: gsp-put - delete and re-create a graph via SPARQL 1.1 Graph Store HTTP Protocol
* docker image description
* some shunit2 tests
* integration with travis ci service

### Changed

* switch change log format to [Keep a Changelog](http://keepachangelog.com/) 
* the split command just outputs the file pieces now (in order to use xargs or parallel directly)
* the distinctcount command is now the count command, the non-distinct version was removed
* the distinctdiff command is now the diff command, the non-distinct version was removed

### Fixed

* most of the shellcheck issues

### Removed

* the distinctcount command is now the count command, the non-distinct version was removed
* the distinctdiff command is now the diff command, the non-distinct version was removed
* all semantic pingback related commands (nobody need this)

## [0.7.0] - May 2016

### Added

* new command: turtleize - outputs an RDF file in turtle, using as much as possible prefix declarations 
* new command: distinctcount - count only distinct triples
* new command: distinctdiff - show only diff between distinct triples

### Changed

* Remove dependency to uniq command

### Fixed

* fix for current roqet version which does not support ntriples output anymore
* issue with md5 command on debian
* error with some namespaces which have ? in it
* namespace detection for local names with special chars (e.g. vs:term_status)
* zsh completion (allow *.ttl files as RDF files)

## [0.6] - May 2013

### Added

* new command: color - get a color value for a resource URI :)
* new commands: delete, put and edit (linked data platform commands)
* add support for local configuration options
* add support for WebID requests
* add a brew recipe
* add debian package build directory

### Fixed

* issue with macosx ancient sed command (zsh completion)
* different auto-completion issues

## [0.5] - Oct 2012

### Added

* introduce support for working with other RDF representations
* allow adoption of accept header via environment `RDFSH_ACCEPT_HEADER`
* support syntax highlighting via pygmentize with the turtle lexer
* introduce the `RDFSH_HIGHLIGHTING_SUPPRESS` environment variable

### Fixed

* fix man page issues on darwin

## [0.4.1] - Apr 2012

### Changed

* improve documentation in `README.md`

### Fixed

* bug when prefix cache does not exists
* bug when `roqet` (or any other tool) is not available

## [0.4] - Mar 2012

### Changed

* improve output of desc with prefixes wrong cache and config

### Fixed

* rapper call for diff command
* wrong sed call
* some darwin related bugs

## [0.3] - Sep 2011

### Added

* new command: help - outputs the manpage
* new command: nscollect - collects prefix declarations of a file list
* new command: nsdist - distributes prefix declarations to a file list
* new command: ping - sends a semantic pingback request (source -> target)
* new command: pingall - sends a semantic pingback request to all targets of a source
* use proper XDG config and caching directories
* add cache for namespace fetching (ns command)
* introduce a local user-generated priority lookup table for the ns command

### Changed

* improve history creation
* add a second parameter format to the desc subcommand (default: turtle)
* refactoring towards maintainability
* new help screen with docu one-liners
* Darwin workarounds

## [0.2] - Aug 2011

### Added

* plain mode for ns command (for scripting)
* zsh completion now with history of used resources

### Changed

* no wget dependency anymore (always curl used instead)
* no cwm dependeny anymore (always rapper used instead)
* command head is now headn (for normal)
* command rdfhead is now head (as an rdf tool, this should be the default)
* moved home to github: https://github.com/seebi/rdf.sh

### Fixed

* curl calls with --fail to avoid getting error pages
* uniq with sort -u now

## [0.1] - Aug 2011

### Added

* first version
* available commands: get head rdfhead ns diff count desc list split

