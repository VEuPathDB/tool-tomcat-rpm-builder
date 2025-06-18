%define debug_package %{nil}

%define dist_version 10.1.42
%define major_version 10

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

Source0: https://archive.apache.org/dist/tomcat/tomcat-%{major_version}/v%{dist_version}/bin/%{tc_name}.tar.gz

BuildRoot: %{_tmppath}/%{tc_name}

%description
Tomcat is the servlet container that is used in the official Reference
Implementation for the Java Servlet and JavaServer Pages technologies.
The Java Servlet and JavaServer Pages specifications are developed by
Oracle under the Java Community Process.

This package is tailored for the VEuPathDB project.

%package -n default-tomcat-%{major_version}
Summary: Metapackage to make Apache Tomcat %major_version default
Requires: %{name}
Conflicts: default-tomcat-9 default-tomcat-10

%description -n default-tomcat-%{major_version}
This metapackage installs tomcat-%major_version as the default version using
/etc/alternatives

%prep
%setup -q -n %{tc_name}
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
cp -a . $RPM_BUILD_ROOT/usr/local/%{tc_name}
pwd
cp bin/commons-daemon-*-native-src/unix/jsvc $RPM_BUILD_ROOT/usr/local/%{tc_name}/bin

%post -n default-tomcat-%{major_version}
%{_sbindir}/alternatives --install /usr/local/apache-tomcat tomcat \
    /usr/local/%{tc_name} 1

%postun -n default-tomcat-%{major_version}
%{_sbindir}/alternatives --remove tomcat /usr/local/%{tc_name}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/usr/local/%{tc_name}

%files -n default-tomcat-%{major_version}

%doc

