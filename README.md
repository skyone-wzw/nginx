# Nginx Build

Build Nginx from source with custom modules.

This is a Docker image that builds Nginx from source with custom modules. The image is based on the official Nginx image and adds the ability to build Nginx from source with custom modules.

Modules:

* http_dav_module
* http_xslt_module (dynamic)
* http_image_filter_module (dynamic)
* http_geoip_module (dynamic)
* njs (dynamic)

Docker image tag name:

* latest: Latest version of Nginx and njs
* vx.y.z: Specific version of Nginx
* vx.y.z-vx.y.z: Specific version of Nginx and njs

Current latest nginx version: v1.29.3

Current latest njs version: v0.9.4

```shell
docker pull ghcr.io/skyone-wzw/nginx:v1.29.3-v0.9.4
```

Minimal example:

```bash
curl https://raw.githubusercontent.com/skyone-wzw/nginx/master/docker-compose.yml -o docker-compose.yml
docker-compose up
```
