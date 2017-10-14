#!/usr/bin/env bash

testSomeValidNamespaces()   {
    assertEquals "http://www.w3.org/1999/02/22-rdf-syntax-ns#" "$(../rdf ns rdf)"
    assertEquals "http://www.w3.org/2000/01/rdf-schema#"       "$(../rdf ns rdfs)"
    assertEquals "http://www.w3.org/2002/07/owl#"              "$(../rdf ns owl)"
    assertEquals "http://purl.org/dc/elements/1.1/"            "$(../rdf ns dc)"
    assertEquals "http://purl.org/dc/terms/"                   "$(../rdf ns dct)"
}

