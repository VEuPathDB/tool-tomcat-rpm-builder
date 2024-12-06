# tool-tomcat-rpm-builder
Tooling to easily build new Tomcat RPMs as new versions are released.

## Dependencies

This project is meant to be used in conjuction with Rocky 9.x Linux and RHEL-named packages.

Specifically, it sets a package dependency of 'java-21-openjdk`.  Previous RPM generation tools used `jdk` with a minimum version, but since the Java version is integrated into the package name, this is more difficult using the new Java package naming convention.

## Artifacts

Several "latest" Tomcat RPMs have been created and published to this repo's release artifacts.
