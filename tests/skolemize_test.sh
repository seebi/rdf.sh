#!/usr/bin/env bash

testSkolemizeLocalFile() {
    sourceFile="skolemize-source.ttl"
    targetFile="skolemize-target.ttl"
    ../rdf skolemize "$sourceFile" >"$targetFile"
    assertEquals "$(../rdf count ${sourceFile})" "$(../rdf count ${targetFile})"
    rm -f "$targetFile"
}
