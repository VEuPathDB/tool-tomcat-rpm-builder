#!/bin/bash

# Minimum version still supported by Apache; this will not effect the
#   ability to create an RPM but a warning will be printed.
minSupportedVersion=9 # <- This will change over time

currentDir=$(pwd)
sourceDir=$(dirname $(realpath $0))
cd $sourceDir

if [ "$#" != "1" ] && [ "$#" != "2" ]; then
  echo "USAGE: buildTomcatRPM.sh <fullVersion>"
  exit 1
fi

fullVersion=$1
majorVersion=$(echo "$fullVersion" | sed -e 's/\([0-9]*\).*/\1/')

if [ "$majorVersion" == "" ] || [ "$majorVersion" == "$fullVersion" ]; then
  echo "Error: fullVersion argument must be of the form x.y.z"
  exit 1
fi

rpmDir=/tmp/rpmbuild-$(openssl rand -hex 12)

echo "Will create RPM for Tomcat $majorVersion, specifically $fullVersion"
echo "Work dir: $rpmDir"

echo "Creating $rpmDir and subdirs"
rm -rf $rpmDir
mkdir $rpmDir && $(cd $rpmDir; mkdir BUILD RPMS SOURCES SPECS SRPMS)

echo "Generating spec file for $fullVersion"
sed "s/__TOMCAT_VERSION__/$fullVersion/g" ./tomcat.spec.tmpl | sed "s/__TOMCAT_MAJOR_VERSION__/$majorVersion/g" > $rpmDir/SPECS/tomcat-$fullVersion.spec

echo "Downloading Tomcat $fullVersion"
if [ "$majorVersion" -lt "$minSupportedVersion" ]; then
  echo "WARNING: This version of Tomcat is EOL and no longer supported!"
  downloadUrl=https://archive.apache.org/dist/tomcat/tomcat-$majorVersion/v$fullVersion/bin/apache-tomcat-$fullVersion.tar.gz
else
  downloadUrl=https://dlcdn.apache.org/tomcat/tomcat-$majorVersion/v$fullVersion/bin/apache-tomcat-$fullVersion.tar.gz
fi
$(cd $rpmDir/SOURCES && wget $downloadUrl)

echo "Building Source and Binary RPMs"
rpmbuild --define "_topdir $rpmDir" -ba $rpmDir/SPECS/tomcat-$fullVersion.spec
cp $rpmDir/SRPMS/tomcat-$majorVersion-$fullVersion-1.src.rpm $currentDir
cp $rpmDir/RPMS/*/tomcat-$majorVersion-$fullVersion-1.x86_64.rpm $currentDir

echo "Done"
