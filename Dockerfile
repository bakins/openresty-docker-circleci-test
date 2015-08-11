#based on https://github.com/ficusio/openresty

FROM alpine:3.2

ENV OPENRESTY_VERSION 1.7.10.2
ENV OPENRESTY_PREFIX /opt/openresty
ENV NGINX_PREFIX /opt/openresty/nginx
ENV VAR_PREFIX /var/openresty

RUN apk update && \
    apk add make gcc musl-dev \
    pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev \
    curl perl git pcre libgcc openssl libssl1.0 bash

RUN curl -L -o /usr/local/bin/envplate https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux

RUN  mkdir -p /root/ngx_openresty && \
    cd /root/ngx_openresty && \
    git clone https://github.com/zebrafishlabs/nginx-statsd.git && \
    curl -sSL http://openresty.org/download/ngx_openresty-${OPENRESTY_VERSION}.tar.gz | tar -xvz

RUN cd /root/ngx_openresty/ngx_openresty-${OPENRESTY_VERSION} \
 && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
 && ./configure \
    --prefix=$OPENRESTY_PREFIX \
    --http-client-body-temp-path=$VAR_PREFIX/client_body_temp \
    --http-proxy-temp-path=$VAR_PREFIX/proxy_temp \
    --http-log-path=$VAR_PREFIX/access.log \
    --error-log-path=$VAR_PREFIX/error.log \
    --pid-path=$VAR_PREFIX/nginx.pid \
    --lock-path=$VAR_PREFIX/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_memcached_module \
    --add-module=/root/ngx_openresty/nginx-statsd \
    -j${NPROC} \
 && make -j${NPROC} \
 && make install


RUN rm -rf /root/ngx_openresty && \
  apk del \
  make gcc musl-dev pcre-dev openssl-dev zlib-dev ncurses-dev \
  readline-dev curl perl git && \
  apk add ca-certificates && \
  rm -rf /var/cache/apk/*



# CMD ["/opt/openresty/nginx/sbin/nginx", "-g", "daemon off; error_log /dev/stderr info;"]

# nginx is at /opt/openresty/nginx/sbin/nginx
