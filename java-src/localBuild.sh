#!/bin/bash

rm -rf artifacts/*
mvn package || exit 1
cd artifacts
unzip cbjgroups-1.0.0.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: CBJgroups Java Services
Bundle-SymbolicName: org.pixl8.cbjgroups
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm cbjgroups-1.0.0.jar
zip -rq cbjgroups-1.0.0.jar *

cp cbjgroups-1.0.0.jar ../../lib/
