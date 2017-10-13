#!/usr/bin/env bash

testDesc() {
    export RDFSH_HIGHLIGHTING_SUPPRESS=true
    ../rdf desc foaf:Person > test.ttl
    diff test.ttl foafPerson.ttl || fail "test.ttl and foafPerson.ttl are not same described."
    rm test.ttl

}

