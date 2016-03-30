# ncareol/osm-tiles

<!--About-->

`ncareol/osm-tiles` is a **Docker** image that provides a full stack for working w/ **OpenStreetMap** data. It can be used to:

- Initialize **PostgreSQL** database w/ **PostGIS** extensions: `initdb`
- Import **OpenStreetMap** data into **PostgreSQL** database: `import`
- Optionally pre-generate tiles: `render`
- Serve pre-generated (if available) and dynamically generated tiles from **Apache**, **renderd** and **mapnik** via an **OpenLayers** interface: `startservices`
- Serve exclusively pre-generated tiles from **Apache** via an **OpenLayers** interface: `startweb`

## Background

This image is adapted from [`homme/openstreetmap-tiles-docker`](https://hub.docker.com/r/homme/openstreetmap-tiles-docker/), which is based on the [Switch2OSM instructions](http://switch2osm.org/serving-tiles/manually-building-a-tile-server-12-04/).

`ncareol/osm-tiles` runs **Ubuntu** 14.04 (Trusty) and is based on [ncareol/baseimage](https://hub.docker.com/r/ncareol/baseimage), which is an adaptation of [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker). It includes:

- **PostgreSQL** `9.3`
- **PostGIS** extensions
- **Apache** `2.2`
- [**osm2pgsql**](http://wiki.openstreetmap.org/wiki/Osm2pgsql)
- [**mapnik**](http://mapnik.org/)
- [**mod_tile**](http://wiki.openstreetmap.org/wiki/Mod_tile), an **Apache** module that also provides scripts for rendering tiles

Source code is available on **GitHub**: <https://github.com/ncareol/osm-tiles-docker>

**Docker** image is available on **Docker Hub**: <https://hub.docker.com/r/ncareol/osm-tiles>

## Usage

Prerequisites, configuration and a demonstration of the complete workflow are available on the [wiki](https://github.com/ncareol/osm-tiles-docker/wiki).

Command reference is available in [`help.txt`](https://github.com/ncareol/osm-tiles-docker/blob/master/help.txt) or by running the image:

```sh
$ docker run ncareol/osm-tiles
```

## Issues

Issues can be reported on **GitHub**: <https://github.com/ncareol/osm-tiles-docker/issues>

## License

[**GPLv3**](https://github.com/ncareol/osm-tiles-docker/blob/master/LICENSE)
