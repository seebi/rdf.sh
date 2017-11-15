#!/usr/bin/env bash

testDataPlatformImportExportAndDiff()   {
    local graph="https://github.com/seebi/rdf.sh"
    local store="https://cmem-showcase.eccenca.com/dataplatform/proxy/default/graph"
    local authUrl="https://cmem-showcase.eccenca.com/dataplatform/oauth/token"
    local input="foafPerson.ttl"
    local output="testDataPlatform.ttl"
    rm -f "$output"
    assertNotNull "DP_USER not given" "${DP_USER}"
    assertNotNull "DP_PASSWORD not given" "${DP_PASSWORD}"
    assertNotNull "DP_CLIENTNAME not given" "${DP_CLIENTNAME}"
    assertNotNull "DP_CLIENTPASS not given" "${DP_CLIENTPASS}"
    RDFSH_TOKEN=$(curl -s -S -X POST -u "${DP_CLIENTNAME:-}":"${DP_CLIENTPASS:-}" "$authUrl" -d "password=${DP_PASSWORD:-}&username=${DP_USER:-}&grant_type=password" | jq -r '.access_token')
    export RDFSH_TOKEN
    assertNotNull "TOKEN not extracted" "${RDFSH_TOKEN}"
    assertEquals '200 OK' "$(../rdf gsp-delete "$graph" "$store")"
    assertEquals "200 OK" "$(../rdf gsp-put "$graph" "$input" "$store")"
     ../rdf gsp-get "$graph" "$store" >"$output"
    assertEquals "" "$(../rdf diff "$output" "$input")"
    assertEquals "200 OK" "$(../rdf gsp-delete "$graph" "$store")"
    rm -f "$output"
    unset RDFSH_TOKEN
}

testDydraImportExportAndDiff()   {
    local graph="https://github.com/seebi/rdf.sh"
    local store="http://dydra.com/seebi/rdf-sh/service"
    local input="foafPerson.ttl"
    local output="testDydra.ttl"
    rm -f "$output"
    assertNotNull "DYDRA_USER not given" "${DYDRA_USER}"
    assertNotNull "DYDRA_PASSWORD not given" "${DYDRA_PASSWORD}"
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

