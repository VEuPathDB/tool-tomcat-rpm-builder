#!/bin/bash

projectDir=$(dirname $(realpath $0))
cd $projectDir

rpmDir=rpmbuild

minSupportedVersion=9 # <- This will change over time

if [ "$#" != "1" ] && [ "$#" != "2" ]; then
  echo "USAGE: buildTomcatRPM.sh [-y] <fullVersion>"
  exit 1
fi

fullVersion=$1
confirmOverwrite="true"

if [ "$1" == "-y" ]; then
  confirmOverwrite="false"
  fullVersion=$2
  if [ "$fullVersion" == "" ]; then
    echo "USAGE: buildTomcatRPM.sh [-y] <fullVersion>"
    exit 1
  fi
fi

majorVersion=$(echo "$fullVersion" | sed -e 's/\([0-9]*\).*/\1/')

if [ "$majorVersion" == "" ] || [ "$majorVersion" == "$fullVersion" ]; then
  echo "Error: fullVersion argument must be of the form x.y.z"
  exit 1
fi

echo "Will create RPM for Tomcat $majorVersion, specifically $fullVersion"

if [ -e "$rpmDir" ]; then
  echo "Existing $rpmDir/ directory (with any previously built RPMs) will be overwritten."
  if [ "$confirmOverwrite" == "true" ]; then
    read -p "Continue (y/n)? " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
  fi
fi

echo "Creating $rpmDir and subdirs"
rm -rf $rpmDir
mkdir $rpmDir && $(cd $rpmDir; mkdir BUILD RPMS SOURCES SPECS SRPMS)

echo "Generating spec file for $fullVersion"
sed "s/__TOMCAT_VERSION__/$fullVersion/g" ./tomcat.spec.tmpl | sed "s/__TOMCAT_MAJOR_VERSION__/$majorVersion/g" > $rpmDir/SPECS/tomcat-$fullVersion.spec

echo "Downloading Tomcat $fullVersion"
if [ "$majorVersion" -lt "minSupportedVersion" ]; then
  echo "WARNING: This version of Tomcat is EOL and no longer supported!"
  downloadUrl=https://archive.apache.org/dist/tomcat/tomcat-$majorVersion/v$fullVersion/bin/apache-tomcat-$fullVersion.tar.gz
else
  downloadUrl=https://dlcdn.apache.org/tomcat/tomcat-$majorVersion/v$fullVersion/bin/apache-tomcat-$fullVersion.tar.gz
fi
$(cd $rpmDir/SOURCES && wget $downloadUrl)

echo "Building Source RPM"
rpmbuild --define "_topdir `pwd`/rpmbuild" -bs ./rpmbuild/SPECS/tomcat-$fullVersion.spec

echo "Building Binary RPM"
rpmbuild --define "_topdir `pwd`/rpmbuild" -bb ./rpmbuild/SPECS/tomcat-$fullVersion.spec

echo "Done"
