FROM openresty/openresty:alpine

# Install dependencies
RUN apk add --no-cache openssl curl git make gcc libc-dev

# Install LuaRocks
RUN curl -R -O http://luarocks.github.io/luarocks/releases/luarocks-3.5.0.tar.gz && \
    tar zxpf luarocks-3.5.0.tar.gz && \
    cd luarocks-3.5.0 && \
    ./configure && \
    make build && \
    make install && \
    cd .. && \
    rm -rf luarocks-3.5.0 luarocks-3.5.0.tar.gz

# Install lua-resty-jwt
RUN luarocks install lua-resty-jwt || \
    (git clone https://github.com/SkyLothar/lua-resty-jwt.git && \
    cd lua-resty-jwt && \
    luarocks make && \
    cd .. && \
    rm -rf lua-resty-jwt)

# Copy Nginx configuration
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Create self-signed fallback certificates
RUN mkdir -p /etc/nginx/certs && \
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=CA/L=San Francisco/O=Example Company/CN=example.com" \
    -keyout /etc/nginx/certs/localhost.key \
    -out /etc/nginx/certs/localhost.crt

# Copy Lua scripts
COPY lua /
COPY lua/auth.lua /etc/nginx/lua/auth.lua
COPY lua/check_token.lua /etc/nginx/lua/check_token.lua

# Copy other necessary files
COPY mime.types /etc/nginx/mime.types
COPY proxy_params.conf /etc/nginx/proxy_params.conf
COPY nginx-html /usr/share/nginx/html
COPY tokens.txt /etc/nginx/tokens.txt

