FROM alpine:latest

ENV NGINX_VERSION=1.29.0
ENV NJS_VERSION=0.9.1
RUN apk add --no-cache ca-certificates curl bash tree tzdata pcre2 geoip gd libxml2 libxslt && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN GPG_KEYS=D6786CE303D9A9022998DC6CC8464D549AF75C0A && \
    CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_dav_module \
        --add-module=/usr/src/nginx-dav-ext-module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --add-dynamic-module=/usr/src/njs/nginx \
    " && \
    set -x && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        libxml2-dev \
        gd-dev \
        curl-dev \
        geoip-dev \
        libedit-dev \
        bash \
        alpine-sdk \
        gnupg \
        quickjs-dev \
        git \
        findutils && \
    addgroup -g 101 -S nginx && \
    adduser -S -D -h /var/cache/nginx -s /sbin/nologin -G nginx -u 101 nginx && \
    curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz && \
    curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $GPG_KEYS && \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz && \
    rm -rf "$GNUPGHOME" nginx.tar.gz.asc && \
    mkdir -p /usr/src && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    git clone https://github.com/nginx/njs.git -b $NJS_VERSION --depth=1 /usr/src/njs && \
    git clone https://github.com/mid1221213/nginx-dav-ext-module.git -b v4.0.1 --depth=1 /usr/src/nginx-dav-ext-module && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure $CONFIG && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    rm -rf /etc/nginx/html/ && \
    mkdir /etc/nginx/conf.d/ && \
    mkdir -p /usr/share/nginx/html && \
    install -m644 html/index.html /usr/share/nginx/html/ && \
    install -m644 html/50x.html /usr/share/nginx/html/ && \
    install -m755 objs/nginx /usr/sbin/nginx && \
    install -m755 objs/ngx_http_xslt_filter_module.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module.so && \
    install -m755 objs/ngx_http_image_filter_module.so /usr/lib/nginx/modules/ngx_http_image_filter_module.so && \
    install -m755 objs/ngx_http_geoip_module.so /usr/lib/nginx/modules/ngx_http_geoip_module.so && \
    install -m755 objs/ngx_stream_geoip_module.so /usr/lib/nginx/modules/ngx_stream_geoip_module.so && \
    install -m755 objs/ngx_http_js_module.so /usr/lib/nginx/modules/ngx_http_js_module.so && \
    install -m755 objs/ngx_stream_js_module.so /usr/lib/nginx/modules/ngx_stream_js_module.so && \
    ln -s ../../usr/lib/nginx/modules /etc/nginx/modules && \
    strip /usr/sbin/nginx* && \
    strip /usr/lib/nginx/modules/*.so && \
    rm -rf /usr/src/nginx-$NGINX_VERSION && \
    rm -rf /usr/src/njs && \
    rm -rf /usr/src/nginx-dav-ext-module && \
    apk add --no-cache --virtual .gettext gettext && \
    mv /usr/bin/envsubst /tmp/ && \
    apk del .build-deps && \
    apk del .gettext && \
    mv /tmp/envsubst /usr/local/bin/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
COPY build/docker-entrypoint.sh /docker-entrypoint.sh
COPY build/nginx.conf /etc/nginx/nginx.conf
STOPSIGNAL SIGQUIT
EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
