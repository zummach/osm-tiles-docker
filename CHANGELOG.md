# CHANGELOG

## Background

[`ncareol/osm-tiles`](https://hub.docker.com/r/ncareol/osm-tiles/)

Based on <https://hub.docker.com/r/homme/openstreetmap-tiles-docker/>

Source: <https://github.com/ncareol/osm-tiles-docker>

## Tags

- `ncareol/osm-tiles:0.1.6`
  - update to reflect correct and updated git repository URL
  - based on [`v0.1.6`](https://github.com/ncareol/osm-tiles-docker/releases/tag/v0.1.6)
- `ncareol/osm-tiles:0.1.5`
  - base image: use my build of `baseimage`, `ncareol/baseimage:0.9.18`, which disables `cron`
  - based on [`4315636`](https://github.com/ncareol/osm-tiles-docker/commit/4315636)
- `ncareol/osm-tiles:0.1.4`
  - base image: update to latest `phusion/baseimage`: `0.9.18`
  - locked `osm2pgsql` to version `0.88.1` to avoid breaking changes from `master`
  - based on [`f7eff9e`](https://github.com/ncareol/osm-tiles-docker/commit/f7eff9e)
- `ncareol/osm-tiles:0.1.3`
  - `apache2`: add `down` file so that `runit` doesn't start `apache2` on boot;
  - based on [`db3e04b`](https://github.com/ncareol/osm-tiles-docker/commit/db3e04b)
- `ncareol/osm-tiles:0.1.2`
  - `postgresql` config: set work_mem to `512MB`;
  - based on [`8143db6 `](https://github.com/ncareol/osm-tiles-docker/commit/8143db6)
- `ncareol/osm-tiles:0.1.1`
  - `run.sh`, remove debugging output
  - based on [`f29f1f3`](https://github.com/ncareol/osm-tiles-docker/commit/f29f1f3)
- `ncareol/osm-tiles:0.1.0`
  - `run.sh`, remove `_wait()` and `tty` logic, just always sleep 2 seconds;
  - based on [`938e088`](https://github.com/ncareol/osm-tiles-docker/commit/938e088)
- `ncareol/osm-tiles:0.0.10`
  - `run.sh`, restore `createuser()` and `createdb()` functions
  - based on [`ed7fee9`](https://github.com/ncareol/osm-tiles-docker/commit/ed7fee9)
- `ncareol/osm-tiles:0.0.9`
  - `run.sh`, preface `import` and `startservices` w/ `startdb`
  - based on [`c809984`](https://github.com/ncareol/osm-tiles-docker/commit/c809984)
- `ncareol/osm-tiles:0.0.8`
  - `run.sh`, move `createuser()` and `createdb()` into `initdb()`
  - based on [`a9ccfeb`](https://github.com/ncareol/osm-tiles-docker/commit/a9ccfeb)
- `ncareol/osm-tiles:0.0.7`
  - `run.sh`, `render()`: add more control via environment variables
    - see `help` for more details
  - based on [`6ff3c9c`](https://github.com/ncareol/osm-tiles-docker/commit/6ff3c9c)
- `ncareol/osm-tiles:0.0.6`
  - `index.html`: Serve simple OpenLayers example as Apache root document
  - based on [`4794816`](https://github.com/ncareol/osm-tiles-docker/commit/4794816)
- `ncareol/osm-tiles:0.0.5`
  - `run.sh`, `import()`: allow specification of path to import file via `OSM_IMPORT_FILE` environment variable;
  - `run.sh`: add `render()` function, to render tiles;
  - built from [`ncareol/osm-tiles-docker/commit/5d66fe5`](https://github.com/ncareol/osm-tiles-docker/commit/5d66fe5)
- `ncareol/osm-tiles:0.0.4`
  - concatenate installations from source and remove sources;
  - built from [`ncareol/osm-tiles-docker/commit/f17931d`](https://github.com/ncareol/osm-tiles-docker/commit/f17931d)
- `ncareol/osm-tiles:0.0.3`
  - update to use latest version of `phusion/baseimage`: `0.9.17`
  - built from [`ncareol/osm-tiles-docker/commit/1d0b8e3`](https://github.com/ncareol/osm-tiles-docker/commit/1d0b8e3)
- `ncareol/osm-tiles:0.0.2` is built from [`ncareol/osm-tiles-docker/commit/69d116a`](https://github.com/ncareol/osm-tiles-docker/commit/69d116a84d4567929b40965384541d4c53a99a2a)
- `ncareol/osm-tiles:0.0.1` is built from [`ncareol/osm-tiles-docker/commit/a81fc7b`](https://github.com/ncareol/osm-tiles-docker/commit/a81fc7b1b8d8e45e2ed2ac8c43f56a62ab5d79e0)
