# Use the official Ubuntu base image
FROM ubuntu:jammy
ENV TZ=Asia/Kolkata DEBIAN_FRONTEND=noninteractive

# Install Supervisor and update the package index

RUN apt update && apt -y install unzip wget git nano supervisor apt-utils ca-certificates curl gnupg lsb-release software-properties-common &&  rm -r /var/lib/apt/lists/*
RUN add-apt-repository ppa:ondrej/php
RUN apt install -y php8.2 libapache2-mod-php8.2 php8.2-mysql php8.2-cli php8.2-common php8.2-fpm php8.2-soap php8.2-gd php8.2-opcache  php8.2-mbstring php8.2-zip php8.2-bcmath php8.2-intl php8.2-xml php8.2-curl php8.2-imap php8.2-ldap php8.2-gmp php8.2-redis libapache2-mod-php8.2 php8.2-memcached  &&  rm -r /var/lib/apt/lists/*
RUN apt-get clean
WORKDIR /var/www/html
COPY faveo-worker.conf /etc/supervisor/conf.d/faveo-worker.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]