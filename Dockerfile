FROM docker.vivait.co.uk/docker-test-runner
MAINTAINER Viva IT Limited <enquiry@vivait.co.uk>

# Create the structure
WORKDIR /project

COPY github-oauth.token github-oauth.token
RUN /composer_oauth github-oauth.token

# Copy the role requirements and run them
COPY ansible/install-dependencies.sh ansible/install-dependencies.sh
COPY ansible/requirements.yml ansible/requirements.yml
RUN /ansible_dependencies

# Copy any files used in provisioning & provision
COPY ansible ansible
COPY app/config/parameters.yml.dist app/config/parameters.yml.dist
RUN /apt_cacher apt-cache.vivait.co.uk; /ansible_setup && /graceful_shutdown

# Copy any composer files and pre-download them
COPY vendor vendor
COPY composer.json composer.lock ./
RUN /composer_setup

# Try and provision, so we can atleast cache
COPY ./ ./

USER root
RUN /ansible_update && /graceful_shutdown

RUN chown -R www-data:www-data ./
