#!/usr/bin/env bash

testDydraImportExportAndDiff()   {
    local graph="https://github.com/seebi/rdf.sh"
    local store="http://dydra.com/seebi/rdf-sh/service"
    local input="foafPerson.ttl"
    local output="testDydra.ttl"
    rm -f "$output"
    if [ "${DYDRA_USER:-}" != "" ]; then
        export RDFSH_USER="${DYDRA_USER}"
    fi
    if [ "${DYDRA_PASSWORD:-}" != "" ]; then
        export RDFSH_PASSWORD="${DYDRA_PASSWORD}"
    fi
    assertEquals "404 Not Found" "$(../rdf gsp-delete "$graph" "$store")"
    assertEquals "200 OK" "$(../rdf gsp-put "$graph" "$input" "$store")"
    ../rdf gsp-get "$graph" "$store" >"$output"
    assertEquals "" "$(../rdf diff "$output" "$input")"
    assertEquals "200 OK" "$(../rdf gsp-delete "$graph" "$store")"
    rm -f "$output"
}

