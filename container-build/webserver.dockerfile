# php-mssql
# PHP runtime with pdo_sqlsrv to connect to SQL Server
FROM ubuntu:16.04

WORKDIR /var/www/html

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-utils \
    apt-transport-https \
    debconf-utils \
    locales \
    curl \
    gcc \
    build-essential \
    g++-5 \
    apache2

# adding custom MS repository
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN bash -c "curl -s https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list"

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y unixodbc-dev msodbcsql mssql-tools
RUN apt-get install -y \
    unixodbc-dev \
    gcc \
    g++ \
    make \
    autoconf \
    libc-dev \
    pkg-config


# php libraries
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -yqq \
    php-pear \
    php7.3-dev \
    php7.3-cli \
    php7.3-fpm \
    php7.3-json \
    php7.3-mysql \
    php7.3-pdo \
    php7.3-zip \
    php7.3-gd \
    php7.3-mbstring \
    php7.3-curl \
    php7.3-xml \
    php7.3-bcmath \
    php7.3-json \
    php7.3-intl \
    php7.3-common \
    php7.3-soap \
    libapache2-mod-php7.3 \
    && rm -rf /var/lib/apt/lists/*

# add extension info to ini files
# RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
# RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

# install SQL Server PHP connector module 
RUN pecl install sqlsrv pdo_sqlsrv

RUN a2enmod php7.3 rewrite vhost_alias

# add sqlsrv extension info to apache2/php.ini
RUN echo "extension=sqlsrv.so" >> /etc/php/7.3/apache2/php.ini
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.3/apache2/php.ini

# copy 30-pdo_sqlsrv.ini to some locations for loading
RUN bash -c "echo extension=sqlsrv.so > /etc/php/7.3/cli/conf.d/sqlsrv.ini"
RUN bash -c "echo extension=sqlsrv.so > /etc/php/7.3/apache2/conf.d/sqlsrv.ini"
RUN bash -c "echo extension=pdo_sqlsrv.so > /etc/php/7.3/cli/conf.d/pdo_sqlsrv.ini"
RUN bash -c "echo extension=pdo_sqlsrv.so > /etc/php/7.3/apache2/conf.d/pdo_sqlsrv.ini"

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# Change current user to www
# USER www

RUN ln -s /opt/mssql-tools/bin/sqlcmd /usr/bin/sqlcmd

CMD ["chown", "-Rf", "www-data", "/var/www/html"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]