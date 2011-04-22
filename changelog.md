# rdf.sh changlog

## 0.2
 * add: plain mode for ns command (for scripting)
 * add: zsh completion now with history of used resources
 * mod: no wget dependency anymore (always curl used instead)
 * mod: no cwm dependeny anymore (always rapper used instead)
 * mod: command head is now headn (for normal)
 * mod: command rdfhead is now head (as an rdf tool, this should be the default)
 * fix: curl calls with --fail to avoid getting error pages
 * fix: uniq with sort -u now

## 0.1
 * first version
 * available commands: get head rdfhead ns diff count desc list split
