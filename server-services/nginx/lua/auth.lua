local cjson = require "cjson"
local jwt = require "resty.jwt"
local ngx = ngx

local function parse_form_body(body)
    local data = {}
    for k, v in string.gmatch(body, "([^&=]+)=([^&]*)") do
        data[ngx.unescape_uri(k)] = ngx.unescape_uri(v)
    end
    return data
end

local function generate_token(username)
    local jwt_secret = ngx.shared.jwt_secrets:get("secret")
    if not jwt_secret then
        ngx.log(ngx.ERR, "JWT secret not found in shared dict")
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.say(cjson.encode({ message = "Internal server error" }))
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    local token, err = jwt:sign(
        jwt_secret,
        {
            header = { typ = "JWT", alg = "HS256" },
            payload = { username = username, exp = ngx.time() + 3600 } -- Token valid for 1 hour
        }
    )
    if not token then
        ngx.log(ngx.ERR, "JWT signing error: ", err)
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.say(cjson.encode({ message = "Internal server error" }))
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    return token
end

ngx.req.read_body()
local body = ngx.req.get_body_data()

-- Log the raw request body for debugging purposes
ngx.log(ngx.ERR, "Request Body: ", body)

if not body or body == "" then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode({ message = "No request body" }))
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local data
local content_type = ngx.req.get_headers()["Content-Type"]
if content_type and string.find(content_type, "application/json") then
    local err
    data, err = cjson.decode(body)
    if not data then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.header.content_type = "application/json"
        ngx.say(cjson.encode({ message = "Invalid JSON: " .. (err or "unknown error") }))
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
else
    data = parse_form_body(body)
end

local valid_users = {
    user1 = "password1",
    user2 = "password2",
    testuser = "testpassword"
}

if valid_users[data.username] and valid_users[data.username] == data.password then
    local token = generate_token(data.username)
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode({ token = token }))
    ngx.exit(ngx.HTTP_OK)
else
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode({ message = "Invalid credentials" }))
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
