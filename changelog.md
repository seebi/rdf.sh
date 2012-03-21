# rdf.sh changlog
## 0.4
 * improve output of desc with prefixes wrong cache and config
 * fix rapper call for diff command
 * fix a wrong sed call
 * fix some darwin related bugs

## 0.3
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

## 0.2
 * add: plain mode for ns command (for scripting)
 * add: zsh completion now with history of used resources
 * mod: no wget dependency anymore (always curl used instead)
 * mod: no cwm dependeny anymore (always rapper used instead)
 * mod: command head is now headn (for normal)
 * mod: command rdfhead is now head (as an rdf tool, this should be the default)
 * fix: curl calls with --fail to avoid getting error pages
 * fix: uniq with sort -u now
 * misc: moved home to github: https://github.com/seebi/rdf.sh

## 0.1
 * first version
 * available commands: get head rdfhead ns diff count desc list split
