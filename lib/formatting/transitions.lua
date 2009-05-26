-- when ending dialog and returning to screenshots, insert an extra linebreak
function dialog_to_ss()
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

