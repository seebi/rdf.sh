#!/usr/bin/env bash

testSomeLists()   {
    assertEquals "http://xmlns.com/foaf/0.1/primaryTopic" "$(../rdf list foaf:prim)"
    assertEquals "32" "$(../rdf list skos: | wc -l)"
    assertEquals "" "$(../rdf list foaf:aaa)"
    assertEquals "http://sebastian.tramp.name" "$(../rdf list http://sebastian.tramp.name)"
}

