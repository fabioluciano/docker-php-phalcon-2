FROM centos:latest

MAINTAINER Fábio Luciano <fabioluciano@php.net>

# Install dependencies
RUN yum install -y httpd mod_ssl openssl pcre-devel gcc make initscripts git \
    php-devel php-pear php-pdo php-cli php-cli php-common php-fpm php-ldap \
    php-mbstring php-mysql php-pgsql php-soap php-xml\
  && yum clean all

WORKDIR /tmp

# Install Phalcon
RUN git clone https://github.com/phalcon/cphalcon && \
  cd cphalcon/build/ && \
  ./install && \
  cd /tmp && \
  /bin/rm -rf /tmp/cphalcon/ && \
  echo "extension=phalcon.so" > /etc/php.d/phalcon.ini


# Install OCI8
COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/

RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm \
  /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm \
  /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm && \
  yum clean all && \
  printf "\n" | pecl install oci8-2.0.11 && \
  echo "extension=oci8.so" > /etc/php.d/oci8.ini

RUN rm -rf ./*

EXPOSE 80 443

VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
