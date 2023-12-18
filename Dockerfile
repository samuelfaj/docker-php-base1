# Use a base image with PHP 7.4 and Apache on Alpine
FROM php:7.4-alpine

# Install Apache
RUN apk --no-cache add apache2 \
    && mkdir -p /run/apache2 \
    && chown -R apache:apache /run/apache2

USER root

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
    autoconf

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
    docker-php-ext-install gd zip pdo pdo_mysql pdo_pgsql mysqli bcmath mbstring ctype fileinfo json mbstring pdo tokenizer xml

RUN apk add --no-cache gcc g++ make

RUN pecl install redis imagick 
RUN docker-php-ext-enable redis imagick

# Enable mod_rewrite for Apache
RUN apk add --no-cache apache2-utils && \
    sed -i 's/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /etc/apache2/httpd.conf

# Set the working directory and Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
WORKDIR /var/www/html

# Update Apache document root in the configuration
RUN sed -ri -e "s|/var/www/localhost/htdocs|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/httpd.conf && \
    if [ -d /etc/apache2/conf.d/ ]; then \
        sed -ri -e "s|/var/www/localhost/htdocs|${APACHE_DOCUMENT_ROOT}|g" /etc/apache2/conf.d/*.conf; \
    fi

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html

# Configure PHP to display errors
RUN echo 'error_reporting = E_ALL' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'display_errors = On' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'display_startup_errors = On' >> /usr/local/etc/php/conf.d/custom.ini && \
    echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/custom.ini
    
# Set the Apache port based on the PORT environment variable
ENV PORT 8080
RUN sed -i "s/^Listen 80/Listen ${PORT}/" /etc/apache2/httpd.conf

# Give proper permissions to the storage and bootstrap/cache folders
RUN chown -R root:www-data /var/www/html
RUN chmod -R 777 /var/www/html                    # @TODO JUST TESTING - WE NEED TO CHANGE IT

# Copy your application files to the container
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html/

# Install PHP dependencies using Composer
RUN composer install --no-interaction --no-progress --optimize-autoloader

# Add auto_prepend_file to php.ini
ENV WORKSPACE /var/www/html

# Expose the port for Apache
EXPOSE $PORT

# Start Apache in the foreground
CMD ["apache2-foreground"]
