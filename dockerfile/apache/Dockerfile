# Use the official Ubuntu base image
FROM ubuntu:jammy

# Set environment variables
ENV TZ=Asia/Kolkata \
    DEBIAN_FRONTEND=noninteractive 

# Define PHP and Node.js versions
ENV PHP_VERSION=8.2 \
    NODE_VERSION=20

# Update package lists and install initial packages
RUN apt-get update && \
    apt-get install -y \
    tzdata \
    software-properties-common \
    ca-certificates \
    git \
    wget \
    curl \
    unzip \
    nano \
    zip \
    supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add PPA repositories for Apache2 and PHP
RUN add-apt-repository ppa:ondrej/apache2 && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

# Install Apache2
RUN apt-get install -y apache2

# Install PHP and necessary extensions
RUN apt-get install -y \
    php${PHP_VERSION} \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-memcached 

# Update PHP configuration for all configurations
RUN for config in fpm cli apache2; do \
        sed -i -e 's/^file_uploads = .*/file_uploads = On/' \
               -e 's/^allow_url_fopen = .*/allow_url_fopen = On/' \
               -e 's/^short_open_tag = .*/short_open_tag = On/' \
               -e 's/^memory_limit = .*/memory_limit = 256M/' \
               -e 's/^;cgi.fix_pathinfo=1.*/cgi.fix_pathinfo = 0/' \
               -e 's/^upload_max_filesize = .*/upload_max_filesize = 100M/' \
               -e 's/^post_max_size = .*/post_max_size = 100M/' \
               -e 's/^max_execution_time = .*/max_execution_time = 360/' \
            /etc/php/${PHP_VERSION}/$config/php.ini; \
    done

# Download and install ionCube Loader
RUN extension_dir=$(php -i | grep ^extension_dir | awk '{print $3}') && \
    curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube_loaders.tar.gz && \
    tar -xzf ioncube_loaders.tar.gz && \
    mv ioncube/ioncube_loader_lin_${PHP_VERSION}.so "$extension_dir" && \
    for config in apache2 cli fpm; do \
        sed -i "2 a zend_extension=${extension_dir}/ioncube_loader_lin_${PHP_VERSION}.so" /etc/php/${PHP_VERSION}/$config/php.ini; \
    done && \
    rm -rf ioncube_loaders.tar.gz ioncube

# Install wkhtmltopdf
RUN apt-get update && \
    apt-get install -y wkhtmltopdf

# Add Composer installation
RUN curl -fsSL https://getcomposer.org/installer -o composer-setup.php && \
    HASH=$(curl -fsSL https://composer.github.io/installer.sig) && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Set the working directory
WORKDIR /var/www/html

# Copy the start-services script into the container
COPY start-services.sh /usr/local/bin/start-services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-services.sh

# Enable necessary Apache modules and configurations
RUN a2enmod proxy_fcgi setenvif rewrite headers && \
    a2enconf php${PHP_VERSION}-fpm

RUN service php${PHP_VERSION}-fpm restart && \
    service apache2 restart

# Expose ports 80 and 443
EXPOSE 80
EXPOSE 443

# Start both Apache2 and PHP-FPM using the shell script
CMD ["/usr/local/bin/start-services.sh"]