#!/bin/bash

cd `dirname $0`

box install

exitcode=0

box stop name="cbjgroupstests"
box start directory="./tests/" serverConfigFile="./tests/server-cbjgroupstests.json"
box testbox run verbose=true || exitcode=1
box stop name="cbjgroupstests"

exit $exitcode


