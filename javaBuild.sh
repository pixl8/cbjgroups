#!/bin/bash


cd java-src
rm -rf artifacts/*

mvn package || exit 1
cp target/cbjgroups-1.0.0-jar-with-dependencies.jar artifacts/cbjgroups.jar
cd artifacts
unzip cbjgroups.jar
echo "Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: CBJgroups Java Services
Bundle-SymbolicName: org.pixl8.cbjgroups
Bundle-Version: 1.0.0
" > META-INF/MANIFEST.MF
rm cbjgroups.jar
zip -rq cbjgroups.jar *

cp cbjgroups.jar ../../lib/
