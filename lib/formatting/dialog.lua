-- dialog with portraits
-- this installs a generic handler so that requests for a format starting
-- with a capital letter will assume that to be a name, and look for a face
-- in <chapter>/faces/<name>

lp.faceext = lp.faceext or lp.ssext

-- this handles the actual formatting
local function dialog(name, text)
    local face = ".img{%03d/faces/%s%s}" % lp.chapter.index % name % lp.faceext
    emit ("%s %s\n" % face % text)
end

-- this will be called if a format is requested that doesn't have a function
-- registered for it
function formatting:__index(key)
    -- doesn't start with a capital letter? We know nothing.
    if not key:match "^[A-Z]"
    then
        return nil
    end
    
    -- otherwise, return a callable that collects what they're actually
    -- saying and passes it to dialog
    -- but also supports .topic notation
    local rv = {}
    function rv:__call(text)
        return dialog(key, text)
    end
    function rv:__index(topic)
        return function(text)
            return dialog(key, ".i{["..topic.."]} "..text)
        end
    end
    return setmetatable(rv,rv)
end

