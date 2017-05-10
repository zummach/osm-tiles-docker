## -*- docker-image-name: "zavpyj/osm-tiles" -*-

##
# The OpenStreetMap Tile Server
#
# This creates an image containing the OpenStreetMap tile server stack as
# described at
# <https://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/>.
#

FROM phusion/baseimage:0.9.19
MAINTAINER Xavier Guille <xguille@hotmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set the locale. This affects the encoding of the Postgresql template
# databases.
ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Update cache and install dependencies
RUN apt-get update -y && apt-get install -y \
    apache2 \
    apache2-dev \
    autoconf \
    build-essential \
    bzip2 \
    cmake \
    g++ \
    gdal-bin \
    git-core \
    libagg-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-python-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libbz2-dev \
    libcairo-dev \
    libcairomm-1.0-dev \
    libexpat1-dev \
    libfreetype6-dev \
    libgdal-dev \
    libgdal1-dev \
    libgeos-dev \
    libgeos++-dev \
    libicu-dev \
    liblua5.2-dev \
    libmapnik-dev \
    libpng12-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-c0-dev \
    libtiff5-dev \
    libtool \
    libxml2-dev \
    lua5.2 \
    make \
    mapnik-utils \
    munin \
    munin-node \
    postgresql-9.5-postgis-2.2 \
    postgresql-contrib \
    postgresql-server-dev-9.5 \
    protobuf-c-compiler \
    python-mapnik \
    python-software-properties \
    software-properties-common \
    subversion \
    sudo \
    tar \
    ttf-unifont \
    unzip \
    wget \
    zlib1g-dev

# Install osm2pgsql
ENV OSM2PGSQL_VERSION 0.92.0
RUN git clone --depth 1 --branch ${OSM2PGSQL_VERSION} https://github.com/openstreetmap/osm2pgsql.git /tmp/osm2pgsql && \
    cd /tmp/osm2pgsql && \
    mkdir build && cd build && cmake .. && \
    make && make install && \
    cd /tmp && rm -rf /tmp/osm2pgsql

# TODO: mapnik 3.x

# Install the Mapnik library
RUN cd /tmp && git clone https://github.com/mapnik/mapnik && \
    cd /tmp/mapnik && \
    git checkout 2.2.x && \
    python scons/scons.py configure INPUT_PLUGINS=all OPTIMIZATION=3 SYSTEM_FONTS=/usr/share/fonts/truetype/ && \
    python scons/scons.py && \
    python scons/scons.py install && \
    ldconfig && \
    cd /tmp && rm -rf /tmp/mapnik

# Verify that Mapnik has been installed correctly
RUN python -c 'import mapnik'

# Install mod_tile and renderd
#master is not a good point to rely on, but no tag exists on mod_tile Github's project since v0.4 (2011) !
#So we rely on the last commit of the master branch at the time of this Dockerfile
ENV MOD_TILE_VERSION e25bfdba1c1f2103c69529f1a30b22a14ce311f1
ENV MOD_TILE_PARALLEL_BUILD 4
RUN cd /tmp && git clone https://github.com/openstreetmap/mod_tile.git && \
    cd /tmp/mod_tile && \
    git reset --hard $MOD_TILE_VERSION && \
    ./autogen.sh && \
    ./configure && \
    make -j $MOD_TILE_PARALLEL_BUILD && \
    make install && \
    make install-mod_tile && \
    ldconfig && \
    cd /tmp && rm -rf /tmp/mod_tile

# Install the Mapnik stylesheet
RUN cd /usr/local/src && svn co http://svn.openstreetmap.org/applications/rendering/mapnik mapnik-style

# Install the coastline data
RUN cd /usr/local/src/mapnik-style && ./get-coastlines.sh /usr/local/share

# Configure mapnik style-sheets
RUN cd /usr/local/src/mapnik-style/inc && cp fontset-settings.xml.inc.template fontset-settings.xml.inc
COPY ./build/datasource-settings.sed /tmp/
RUN cd /usr/local/src/mapnik-style/inc && sed --file /tmp/datasource-settings.sed  datasource-settings.xml.inc.template > datasource-settings.xml.inc
COPY ./build/settings.sed /tmp/
RUN cd /usr/local/src/mapnik-style/inc && sed --file /tmp/settings.sed  settings.xml.inc.template > settings.xml.inc

# Configure renderd
COPY ./build/renderd.conf.sed /tmp/
RUN cd /usr/local/etc && sed --file /tmp/renderd.conf.sed --in-place renderd.conf

# Create the files required for the mod_tile system to run
RUN mkdir /var/run/renderd && chown www-data: /var/run/renderd
RUN mkdir /var/lib/mod_tile && chown www-data /var/lib/mod_tile

# Replace default apache index page with Leaflet demo
COPY ./build/index.html /var/www/html/

# Configure mod_tile
COPY ./build/mod_tile.load /etc/apache2/mods-available/
COPY ./build/mod_tile.conf /etc/apache2/mods-available/
RUN a2enmod mod_tile

# Ensure the webserver user can connect to the gis database
RUN sed -i -e 's/local   all             all                                     peer/local gis www-data peer/' /etc/postgresql/9.5/main/pg_hba.conf

# Tune postgresql
COPY ./build/postgresql.conf.sed /tmp/
RUN sed --file /tmp/postgresql.conf.sed --in-place /etc/postgresql/9.5/main/postgresql.conf

# Define the application logging logic
COPY ./build/syslog-ng.conf /etc/syslog-ng/conf.d/local.conf
RUN rm -rf /var/log/postgresql

# Create a `postgresql` `runit` service
COPY ./build/sv/postgresql /etc/sv/postgresql/
RUN update-service --add /etc/sv/postgresql

# Create an `apache2` `runit` service
COPY ./build/sv/apache2 /etc/sv/apache2/
RUN update-service --add /etc/sv/apache2

# Create a `renderd` `runit` service
COPY ./build/sv/renderd /etc/sv/renderd/
RUN update-service --add /etc/sv/renderd

# Expose the webserver and database ports
EXPOSE 80 5432

# Set the osm2pgsql import cache size in MB. Used in `run import`.
ENV OSM_IMPORT_CACHE 40

# Add the README
COPY ./README.md /usr/local/share/doc/

# Add the help file
COPY ./build/help.txt /usr/local/share/doc/run/

RUN rm -Rf /var/lib/postgresql/9.5/main

# Correct the Error: could not open temporary statistics file "/var/run/postgresql/9.5-main.pg_stat_tmp/global.tmp": No such file or directory
RUN mkdir -p /var/run/postgresql/9.5-main.pg_stat_tmp
RUN chown postgres:postgres /var/run/postgresql/9.5-main.pg_stat_tmp -R

# Add the entrypoint
COPY ./build/run.sh /usr/local/sbin/run
RUN chmod +x /usr/local/sbin/run /etc/sv/renderd/run /etc/sv/apache2/run /etc/sv/postgresql/check /etc/sv/postgresql/run
ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run"]

# Default to showing the usage text
CMD ["help"]

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
