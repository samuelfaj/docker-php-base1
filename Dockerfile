# Use a base image with PHP 7.4 and Apache on Alpine
FROM php:7.4-alpine3.15

# Install Apache
RUN apk --no-cache add apache2

USER root

# Set the working directory
WORKDIR /var/www/localhost/htdocs/

# Set timezone
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/New_York /etc/localtime && \
    echo "America/New_York" > /etc/timezone && \
    apk del tzdata

# Install necessary libraries and tools
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    libjpeg-turbo \
    libwebp \
    libxpm \
    freetype \
    postgresql-dev \
    supervisor \
    imagemagick \
    imagemagick-dev \
    nodejs \
    npm \ 
    zlib \ 
    zlib-dev \ 
    libzip \
    libzip-dev \
    libpng \ 
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \ 
    libxpm \       
    libxpm-dev   

RUN apk add --no-cache \ 
    oniguruma \
    oniguruma-dev \
    libxml2 \ 
    libxml2-dev \ 
    autoconf \ 
    php7-apache2

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
    docker-php-ext-install gd zip pdo pdo_mysql pdo_pgsql mysqli bcmath mbstring ctype fileinfo json mbstring pdo tokenizer xml

RUN apk add --no-cache gcc g++ make

RUN pecl install redis imagick 
RUN docker-php-ext-enable redis imagick
RUN echo "LoadModule php7_module modules/libphp7.so" >> /etc/apache2/httpd.conf
RUN echo '<FilesMatch \.php$>' >> /etc/apache2/conf.d/php7.conf \
    && echo '    SetHandler application/x-httpd-php' >> /etc/apache2/conf.d/php7.conf \
    && echo '</FilesMatch>' >> /etc/apache2/conf.d/php7.conf \
    && sed -i 's/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /etc/apache2/httpd.conf \
    && sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php/' /etc/apache2/httpd.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP to display errors
RUN echo 'error_reporting = E_ALL' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'display_errors = On' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'display_startup_errors = On' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/custom.ini

# Give proper permissions to the storage and bootstrap/cache folders
RUN chown -R apache:apache /var/www/localhost/htdocs

# Copy your application files to the container
COPY . /var/www/localhost/htdocs/

# Install PHP dependencies using Composer
RUN composer install --no-interaction --no-progress --optimize-autoloader

RUN npm i -g pm2
RUN apk --no-cache add certbot 

RUN apk add \
    php7 \
    php7-session \
    php7-fpm \
    php7-pdo \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-openssl \
    php7-json \
    php7-phar \
    php7-mbstring \
    php7-tokenizer \
    php7-xml \
    php7-ctype \
    php7-zip \
    php7-gd \
    php7-curl \
    php7-dom \
    php7-intl \
    php7-dba \
    php7-sqlite3 \
    php7-pear \
    php7-phpdbg \
    php7-litespeed \
    php7-gmp \
    php7-phalcon \
    php7-pdo_mysql \
    php7-sodium \
    php7-pcntl \
    php7-common \
    php7-xsl \
    php7-mysqlnd \
    php7-enchant \
    php7-pspell \
    php7-snmp \
    php7-doc \
    php7-tideways_xhprof \
    php7-fileinfo \
    php7-dev \
    php7-xmlrpc \
    php7-xmlreader \
    php7-pdo_sqlite \
    php7-exif \
    php7-opcache \
    php7-ldap \
    php7-posix \
    php7-gd \
    php7-gettext \
    php7-iconv \
    php7-sysvshm \
    php7-curl \
    php7-shmop \
    php7-odbc \
    php7-phar \
    php7-pdo_pgsql \
    php7-imap \
    php7-pdo_dblib \
    php7-pdo_odbc \
    php7-zip \
    php7-apache2 \
    php7-cgi \
    php7-ctype \
    php7-bcmath \
    php7-calendar \
    php7-tidy \
    php7-dom \
    php7-sockets \
    php7-brotli \
    php7-dbg \
    php7-soap \
    php7-sysvmsg \
    php7-ffi \
    php7-embed \
    php7-ftp \
    php7-sysvsem \
    php7-pdo \
    php7-bz2 \
    php7-mysqli \
    php7-simplexml \
    php7-xmlwriter

# Expose the port for Apache
EXPOSE $PORT

# Start Apache in the foreground
CMD ["apache2-foreground"]
