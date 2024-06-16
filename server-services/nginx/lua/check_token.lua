local jwt = require "resty.jwt"

local jwt_secret = ngx.shared.jwt_secrets:get("secret")
if not jwt_secret then
    ngx.log(ngx.ERR, "JWT secret not set")
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local token = ngx.var.cookie_token or ngx.req.get_headers()["Authorization"]
if not token then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

if token:sub(1, 7) == "Bearer " then
    token = token:sub(8)
end

local jwt_obj = jwt:verify(jwt_secret, token)
if not jwt_obj.verified then
    ngx.log(ngx.ERR, "JWT verification failed: " .. jwt_obj.reason)
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
