#!/bin/bash

if [[ $TRAVIS_TAG == v* ]] ; then
	GIT_BRANCH=$TRAVIS_TAG
	BRANCH_FOLDER=${GIT_BRANCH//origin\//}
	BRANCH_FOLDER="${BRANCH_FOLDER##*/}"
	ZIP_FILE=$BRANCH_FOLDER.zip
	BUILD_DIR=build/
	PADDED_BUILD_NUMBER=`printf %05d $TRAVIS_BUILD_NUMBER`
	VERSION_NUMBER="${GIT_BRANCH//v}+$PADDED_BUILD_NUMBER"

	echo "Building JGroups Coldbox Integration"
	echo "===================================="
	echo "GIT Branch      : $GIT_BRANCH"
	echo "Version number  : $VERSION_NUMBER"
	echo

	cd ./java-src
	echo "Packaging java source with Maven..."
	mvn clean && mvn package || exit 1
	cd ../
	mkdir -p ./lib
	cp ./java-src/artifacts/*.jar ./lib/
	echo "Done packaging java source."

	rm -rf $BUILD_DIR
	mkdir -p $BUILD_DIR


	echo "Copying files to $BUILD_DIR..."
	rsync -a ./ --exclude=".*" --exclude="$BUILD_DIR" --exclude="*.sh" --exclude="/java-src" --exclude="*.log" "$BUILD_DIR" || exit 1
	echo "Done."

	cd $BUILD_DIR
	echo "Inserting version number..."
	sed -i "s/VERSION_NUMBER/$VERSION_NUMBER/" box.json
	sed -i "s/DOWNLOAD_LOCATION/$ZIP_FILE/" box.json
	echo "Done."

	echo "Zipping up..."
	zip -rq $ZIP_FILE * -x jmimemagic.log || exit 1
	mv $ZIP_FILE ../
	cd ../
	find ./*.zip -exec aws s3 cp {} s3://pixl8-public-packages/cbjgroups/ --acl public-read \; || exit 1

    cd $BUILD_DIR;
    CWD="`pwd`";

    box forgebox login username="$FORGEBOXUSER" password="$FORGEBOXPASS";
    box publish directory="$CWD";
else
	echo "Not publishing. This is not a tagged release.";
fi

cd ../

echo "Build complete :)"
