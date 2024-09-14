FROM php:8.3-fpm as base

#Set workdir
WORKDIR /app

#Install libraries
RUN apt-get update && apt-get install -y unzip libicu-dev libzip-dev libpq-dev zlib1g-dev git \
	&& apt purge -y --auto-remove

#Install extensions
RUN docker-php-ext-install intl pdo pdo_mysql pdo_pgsql zip \
	&& pecl install apcu \
	&& docker-php-ext-enable zip \
	&& docker-php-ext-enable opcache

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Change text color
ENV TERM xterm-256color
RUN echo "PS1-'\e[92m\u\e[0m@\e[94\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc

FROM base as DEV

# Set permissions
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN cp -T /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN sed -i 's/user = www-data/user = ${USERNAME}/g' /usr/local/etc/php-fpm.d/www.conf \
	&& sed -i 's/group = www-data/user = ${USERNAME}/g' /usr/local//etc/php-fpm.d/www.conf

USER $USERNAME


