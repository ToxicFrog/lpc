-- this is a very simple program. It just processes its input looking for
-- bbcode [img] and [timg] tags, and uploads the images to lpix. It outputs
-- the same text except with the image tags rewritten to point at the uploaded
-- images. [timg] tags are translated to lpix thumbnails.

package.path = package.path..";lib/?.lua;lib/luasocket/?.lua"
package.cpath = package.cpath..";lib/?.so;lib/?.dll;lib/luasocket/?.so;lib/luasocket/?.dll"

require "util"

local lpix = require "lpix"

local function upload(type, file)
    if file:match("^http://") then return end
    
    local result,err = lpix.upload(file)
    if not result then
        io.eprintf("Error uploading: %s\n", err)
    end
    
    if type == "img" then
        return "[img]%s[/img]" % result.imageurl
    else
        return "[img]%s[/img]" % result.thumburl
    end
end

local text = io.read("*a")

text = text:gsub("%[(t?img)%](.-)%[/t?img%]", upload)

io.write(text)
