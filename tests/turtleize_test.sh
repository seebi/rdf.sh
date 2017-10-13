#!/usr/bin/env bash

testSameTurtleizeResult() {
    export RDFSH_HIGHLIGHTING_SUPPRESS=true
    ../rdf turtleize foafPerson.nt >test.ttl
    diff test.ttl foafPerson.ttl || fail "test.ttl and foafPerson.ttl are not same turtleized."
    rm test.ttl
}
