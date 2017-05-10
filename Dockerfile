## -*- docker-image-name: "zavpyj/osm-tiles" -*-

##
# The OpenStreetMap Tile Server
#
# This creates an image containing the OpenStreetMap tile server stack as
# described at
# <https://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/>.
#

FROM ncareol/baseimage:0.9.18
MAINTAINER Xavier Guille <xguille@hotmail.com>

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
    libtiff4-dev \
    libtool \
    libxml2-dev \
    mapnik-utils \
    munin \
    munin-node \
    postgresql-9.3-postgis-2.1 \
    postgresql-contrib \
    postgresql-server-dev-9.3 \
    protobuf-c-compiler \
    python-mapnik \
    python-software-properties \
    software-properties-common \
    subversion \
    tar \
    ttf-unifont \
    unzip \
    wget

# Install osm2pgsql
RUN cd /tmp && git clone https://github.com/openstreetmap/osm2pgsql.git && \
    cd /tmp/osm2pgsql && \
    git checkout 0.88.1 && \
    ./autogen.sh && \
    ./configure && \
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
RUN cd /tmp && git clone https://github.com/openstreetmap/mod_tile.git && \
    cd /tmp/mod_tile && \
    ./autogen.sh && \
    ./configure && \
    make && \
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
ADD datasource-settings.sed /tmp/
RUN cd /usr/local/src/mapnik-style/inc && sed --file /tmp/datasource-settings.sed  datasource-settings.xml.inc.template > datasource-settings.xml.inc
ADD settings.sed /tmp/
RUN cd /usr/local/src/mapnik-style/inc && sed --file /tmp/settings.sed  settings.xml.inc.template > settings.xml.inc

# Configure renderd
ADD renderd.conf.sed /tmp/
RUN cd /usr/local/etc && sed --file /tmp/renderd.conf.sed --in-place renderd.conf

# Create the files required for the mod_tile system to run
RUN mkdir /var/run/renderd && chown www-data: /var/run/renderd
RUN mkdir /var/lib/mod_tile && chown www-data /var/lib/mod_tile

# Replace default apache index page with Leaflet demo
ADD index.html /var/www/html/index.html

# Configure mod_tile
ADD mod_tile.load /etc/apache2/mods-available/
ADD mod_tile.conf /etc/apache2/mods-available/
RUN a2enmod mod_tile

# Ensure the webserver user can connect to the gis database
RUN sed -i -e 's/local   all             all                                     peer/local gis www-data peer/' /etc/postgresql/9.3/main/pg_hba.conf

# Tune postgresql
ADD postgresql.conf.sed /tmp/
RUN sed --file /tmp/postgresql.conf.sed --in-place /etc/postgresql/9.3/main/postgresql.conf

# Define the application logging logic
ADD syslog-ng.conf /etc/syslog-ng/conf.d/local.conf
RUN rm -rf /var/log/postgresql

# Create a `postgresql` `runit` service
ADD postgresql /etc/sv/postgresql
RUN update-service --add /etc/sv/postgresql

# Create an `apache2` `runit` service
ADD apache2 /etc/sv/apache2
RUN update-service --add /etc/sv/apache2

# Create a `renderd` `runit` service
ADD renderd /etc/sv/renderd
RUN update-service --add /etc/sv/renderd

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose the webserver and database ports
EXPOSE 80 5432

# We need the volume for importing data from
VOLUME ["/data"]

# Set the osm2pgsql import cache size in MB. Used in `run import`.
ENV OSM_IMPORT_CACHE 40

# Add the README
ADD README.md /usr/local/share/doc/

# Add the help file
RUN mkdir -p /usr/local/share/doc/run
ADD help.txt /usr/local/share/doc/run/help.txt

RUN rm -Rf /var/lib/postgresql/9.3/main

# Add the entrypoint
ADD run.sh /usr/local/sbin/run
ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run"]

# Default to showing the usage text
CMD ["help"]
