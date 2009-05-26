--
local lp = lp
local styles = {}

package.loaded["lp.styles"] = styles

module "lp.styles"

-- the title at the start of the post, in bold
-- 12: The Update Of Doom
function title(title)
    return ".b{%d: %s}\n\n" % lp.chapter % lp.title
end

-- screenshots
function ss(n, ...)
    if not n then return "" end
    
    return (".img{%03d/ss/%04d}\n" % lp.chapter % n)..styles.ss(...)
end

-- narration. Newline-seperated.
function narrate(text)
    return "\n.i{%s}\n" % text
end

-- FAQ. Invoked as 'faq "question" "answer"'
-- Produces the question in bold, newline, then the answer and two newlines.
function faq(Q)
    return function(A)
        return ".b{%s}\n%s\n\n" % Q % A
    end
end

-- general LP commentary. Text in italics.
function text(text)
    return "\n.i{%s}\n\n" % text
end

-- an image inserted raw into the LP
-- note that the path is relative to the LP root
function img(path)
    return ".img{%s}" % path
end

-- a link to elsewhere
function url(path, text)
    return ".url{%s %s}" % path:gsub(' ', '%%20'), text
end

-- a linebreak
function br()
    return "\n"
end

function dialogue(name, text)
    return "%s %s\n" % img(lp.chapter.."/faces/"..name) % text
end

-- general indexer
-- functions starting with a capital letter are assumed to be dialogue
function styles:__index(name)
    if not name:match("^[A-Z]") then
        return nil
    end
    
    
    return function(text)
        last = "dialogue"
        emit("%s %s\n", img(lp.chapter .."/faces/"..name), text)
    end
end

-- TRANSITION FUNCTIONS --

-- when ending dialog and returning to screenshots, insert an extra linebreak
function dialogue_ss()
    return br()
end

local last = ""

setmetatable(styles, styles)

return setmetatable({}, {
    __index = function(this, key)
        local f = styles[key]
        local transition = styles[last.."_"..key]
        return function(...)
            if transition then transition() end
            last = key
            return f(...)
        end
    end;
})

