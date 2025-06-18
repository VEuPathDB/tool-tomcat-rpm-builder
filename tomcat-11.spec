%define debug_package %{nil}

%define dist_version 11.0.8
%define major_version 11

%define tc_name apache-tomcat-%{dist_version}

%define package_name tomcat-%{major_version}
%define package_version %{dist_version}
%define packager Ryan Doherty <rdoherty@upenn.edu>

%undefine _disable_source_fetch

Summary: Apache Tomcat Server
Name: %{package_name}
Version: %{package_version}
Release: 1%{?dist}
License: Apache 2.0
Group: Networking/Daemons
URL: https://tomcat.apache.org
Packager: %{packager}

Requires: java-21-openjdk

Source0: https://archive.apache.org/dist/tomcat/tomcat-%{major_version}/v%{dist_version}/bin/apache-tomcat-%{dist_version}.tar.gz

#BuildRoot: %{_tmppath}/%{tc_name}

%description
Tomcat is the servlet container that is used in the official Reference
Implementation for the Java Servlet and JavaServer Pages technologies.
The Java Servlet and JavaServer Pages specifications are developed by
Oracle under the Java Community Process.

This package is tailored for the VEuPathDB project.

%prep
%setup -q -n apache-tomcat-%{dist_version}
#%setup -q -D -T -a 1 -n %{tc_name}

%build
cd bin
tar zxf commons-daemon-native.tar.gz
cd commons-daemon*/unix
./configure --with-java=/usr/lib/jvm/java
make

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local
pwd
cp -a . $RPM_BUILD_ROOT/usr/local/apache-tomcat-%{major_version}
pwd
cp bin/commons-daemon-*-native-src/unix/jsvc $RPM_BUILD_ROOT/usr/local/apache-tomcat-%{major_version}/bin

%clean
#rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/usr/local/apache-tomcat-%{major_version}

%files -n default-tomcat-%{major_version}

%doc

