require "util.string"
require "util.io"

local http = require "socket.http"
local ltn12 = require "ltn12"

local post = {}

post.boundary = "##80b5a56f_9d39_4f33_82e3_ffe9058cac9f##"

function post.new()
    return setmetatable({}, {__index = post})
end

function post:append(data, ...)
    if data then
        self[#self+1] = data
        return self:append(...)
    end
end

function post:field(key, value)
    self:append(
        '--'..self.boundary,
        'Content-Disposition: form-data; name="%s"' % key,
        '',
        value
    )
end

function post:file(key, filename)
    self:append(
        '--'..self.boundary,
        'Content-Disposition: form-data; name="%s"; filename="%s"' % { key, filename },
        'Content-Type: application/octet-stream',
        '',
        io.readfile(filename)
    )
end

function post:post(url, progress)
    self:append('--'..self.boundary..'--', '')
    local body = table.concat(self, '\r\n')
    local head = {
        ["content-type"] = "multipart/form-data; boundary=%s" % self.boundary;
        ["content-length"] = tostring(#body);
        ["accept"] = "text/xml";
    }

    local response = {}
    local source = ltn12.source.string(body);

    if progress then
        local _source = source
        local sent = 0
        function source()
            local data = _source()
            sent = sent + #(data or '')
            progress(sent/#body)
            return data
        end
    end

    local r,e = http.request {
        method = "POST";
        url = url;
        headers = head;
        source = source;
        sink = ltn12.sink.table(response);
    }

    if not r then
        return nil,tostring(e)
    end

    return table.concat(response)
end

return post
