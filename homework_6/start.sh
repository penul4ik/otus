#1/bin/bash
yum -y update
cat <<EOT >> /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOT
yum-config-manager --enable nginx-mainline
yum install -y nginx rpmlint
systemctl enable --now nginx
rpmdev-setuptree
cat <<EOT >> ./hello.sh
#!/bin/sh
echo "Hello world"
EOT
mkdir ./hello-0.0.1
mv ./hello.sh ./hello-0.0.1
tar --create --file hello-0.0.1.tar.gz hello-0.0.1
mv ./hello-0.0.1.tar.gz /root/rpmbuild/SOURCES
mkdir /usr/share/nginx/html/repo
rpmdev-newspec hello
cat <<EOT >> /root/rpmbuild/SPECS/hello.spec 
Name:           hello
Version:        0.0.1
Release:        1%{?dist}
Summary:        A simple hello world script
BuildArch:      noarch

License:        GPL
Source0:        %{name}-%{version}.tar.gz

Requires:       bash

%description
A demo RPM build for otus

%prep
%setup -q

%install
rm -rf \$RPM_BUILD_ROOT
mkdir -p \$RPM_BUILD_ROOT/%{_bindir}
cp %{name}.sh \$RPM_BUILD_ROOT/%{_bindir}

%clean
rm -rf \$RPM_BUILD_ROOT

%files
%{_bindir}/%{name}.sh

%changelog
* Sun Nov 19 2023 Maksim Konovalenko <maksimpenul@gmail.com> - 0.0.1
- First version being packaged
EOT
rpmlint /root/rpmbuild/SPECS/hello.spec
rpmbuild -ba /root/rpmbuild/SPECS/hello.spec
cp /root/rpmbuild/RPMS/noarch/hello-0.0.1-1.el7.noarch.rpm /usr/share/nginx/html/repo/
wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
createrepo /usr/share/nginx/html/repo/
rm -rf /etc/nginx/conf.d/default.conf
cat <<EOT >> /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}

EOT
nginx -t
nginx -s reload
curl -a http://localhost/repo/