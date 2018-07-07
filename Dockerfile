FROM ubuntu:xenial
LABEL maintainer="igore4ek061@gmail.com"

ARG NGX_VERSION='1.9.9'
ARG LUAJIT_VERSION='2.0.5'
ARG LUAJIT_MAJOR_VERSION='2.0'
ARG NGX_DEVEL_KIT_VERSION='0.3.0'
ARG LUA_NGINX_MODULE_VERSION='0.10.13'
ARG NGINX_INSTALL_PATH='/opt/nginx'

ENV TERM=xterm-256color
RUN apt-get update -qy && \
    apt-get install -qy software-properties-common make gcc libpcre3-dev zlib1g-dev wget

USER root
WORKDIR /opt/build 
RUN wget http://nginx.org/download/nginx-${NGX_VERSION}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz -O ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz -O lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz
 
# Extract
RUN tar xvf nginx-${NGX_VERSION}.tar.gz
RUN tar xvf LuaJIT-${LUAJIT_VERSION}.tar.gz
RUN tar xvf ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz
RUN tar xvf lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz
 
# Install luajit
RUN pwd
RUN cd LuaJIT-${LUAJIT_VERSION} && make install && cd ..
 
ENV NGX_DEVEL_KIT_PATH=/opt/build/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}
ENV LUA_NGINX_MODULE_PATH=/opt/build/lua-nginx-module-${LUA_NGINX_MODULE_VERSION}
ENV LD_LIBRARY_PATH=/usr/local/lib
 
# Compile And Install Nginx
RUN cd ./nginx-${NGX_VERSION} && \
    LUAJIT_LIB=/usr/local/lib/lua LUAJIT_INC=/usr/local/include/luajit-${LUAJIT_MAJOR_VERSION} \
    ./configure --prefix=${NGINX_INSTALL_PATH} --conf-path=${NGINX_INSTALL_PATH}/nginx.conf --pid-path=/var/run/nginx.pid \
    --sbin-path=/usr/sbin/nginx --lock-path=/var/run/nginx.lock \
    --with-ld-opt='-Wl,-rpath,/usr/local/lib/lua' \
    --add-module=${NGX_DEVEL_KIT_PATH} \
    --add-module=${LUA_NGINX_MODULE_PATH} \
    && make -j2 && make install

COPY nginx.conf /opt/nginx
COPY index.html /opt/nginx/html

#Clean
RUN rm -rf /opt/build

#Open port
EXPOSE 80
#Entry
CMD ["nginx","-g","daemon off;"]
