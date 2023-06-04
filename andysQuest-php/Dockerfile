FROM php:8.1.5-apache-bullseye

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends\
        libfreetype6-dev \
        ca-certificates \
        libjpeg62-turbo-dev \
        libssh2-1-dev \
        libssh2-1 \
        git \
        unzip \
        xvfb \
        libfontconfig \
        wkhtmltopdf \
        xorg \
        build-essential \
        libssl-dev \
        libxrender-dev \
        mc \
        freetds-bin \
        freetds-dev \
        freetds-common \
        libxml2-dev \
        libtidy-dev \
        zip \
        && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/ \
        && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/ \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install mysqli \
        && docker-php-ext-install exif \
        && docker-php-ext-install opcache \
        && docker-php-ext-install soap \
        && docker-php-ext-install tidy \
        && pecl install redis \
        && docker-php-ext-enable redis \
        && a2enmod rewrite \
        && a2enmod expires \ 
        && a2enmod headers \
        && rm -rf /etc/localtime \
        && ln -s /usr/share/zoneinfo/Europe/Bucharest  /etc/localtime \
        && apt-get install -y libssh2-1-dev libssh2-1 \
        && pecl install ssh2-1.3.1 \
        && docker-php-ext-enable ssh2 
   

RUN ln -s /dev/stdout /var/log/apache2/access_log 

RUN mkdir -p /etc/apache2/conf.d/
COPY ./usr/local/etc/php/php.ini /usr/local/etc/php/php.ini
COPY ./etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./etc/apache2/mods-enabled/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

RUN curl -L -o wkhtmltox_0.12.5-1.stretch_amd64.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
	&& dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb \
	&& rm -f wkhtmltox_0.12.5-1.stretch_amd64.deb \  
	&& cp /usr/local/bin/wkhtmltopdf /usr/bin/ \
	&& ln -s /storage/uploads /uploads \
  && ln -s /storage/downloads/docs /docs

ENV ACCEPT_EULA=Y

# Install prerequisites required for tools and extensions installed later on.
RUN apt-get update \
    && apt-get install -y apt-transport-https gnupg2 libpng-dev libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

# Install prerequisites for the sqlsrv and pdo_sqlsrv PHP extensions.
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y msodbcsql17 mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Retrieve the script used to install PHP extensions from the source container.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

# Install required PHP extensions and all their prerequisites available via apt.
RUN chmod uga+x /usr/bin/install-php-extensions \
    && sync \
    && install-php-extensions bcmath ds exif gd intl opcache pcntl pdo_sqlsrv redis sqlsrv zip


COPY ./entrypoints /entrypoints
RUN chmod +x /entrypoints/*

