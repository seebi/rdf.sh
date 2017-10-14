#!/usr/bin/env bash

testDesc() {
    export RDFSH_HIGHLIGHTING_SUPPRESS=true
    ../rdf ns rdfs
    ../rdf ns rdf
    ../rdf ns owl
    ../rdf ns foaf
    ../rdf ns contact
    ../rdf ns wgs84
    ../rdf ns schema
    ../rdf ns vs
    ../rdf desc foaf:Person > test.ttl
    diff test.ttl foafPerson.ttl || fail "test.ttl and foafPerson.ttl are not same described."
    rm test.ttl

}

