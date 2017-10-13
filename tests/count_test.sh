#!/usr/bin/env bash

testCountLocalFile() {
    assertEquals "12" "$(../rdf count foafPerson.nt)"
}

testCountRemoteResource() {
    assertEquals "58" "$(../rdf count https://sebastian.tramp.name)"
}

