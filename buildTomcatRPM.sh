#!/bin/bash

currentDir=$(pwd)

if [ "$#" != "1" ] && [ "$#" != "2" ]; then
  echo "USAGE: buildTomcatRPM.sh <majorVersion>"
  exit 1
fi

majorVersion=$1

rpmDir=/tmp/rpmbuild-$(openssl rand -hex 12)

echo "Will create RPM for Tomcat $majorVersion"
echo "Work dir: $rpmDir"

echo "Creating $rpmDir and subdirs"
rm -rf $rpmDir
mkdir $rpmDir && $(cd $rpmDir; mkdir BUILD RPMS SOURCES SPECS SRPMS)

echo "Building Source and Binary RPMs"
rpmbuild --define "_topdir $rpmDir" -ba tomcat-$majorVersion.spec
cp $rpmDir/SRPMS/tomcat-*.src.rpm $currentDir
cp $rpmDir/RPMS/*/tomcat-*.rpm $currentDir

echo "Done"
