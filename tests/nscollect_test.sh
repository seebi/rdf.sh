#!/usr/bin/env bash

testNsCollect() {
    rm -f prefixes.ttl
    assertEquals "8 prefixes from 1 file(s) collected in prefixes.ttl (0 before)" "$(../rdf nscollect)"
    assertEquals "8 prefixes from 1 file(s) collected in prefixes.ttl (8 before)" "$(../rdf nscollect)"
    rm -f prefixes.ttl
}

testNsDist() {
    rm -f prefixes.ttl test.ttl
    touch test.ttl
    assertEquals "8 prefixes from 2 file(s) collected in prefixes.ttl (0 before)" "$(../rdf nscollect)"
    assertEquals "test.ttl: +8 prefix declarations" "$(../rdf nsdist test.ttl)"
    assertEquals "test.ttl: +0 prefix declarations" "$(../rdf nsdist test.ttl)"
    rm -f prefixes.ttl test.ttl
}
