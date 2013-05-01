function PRE(text)
    return text:gsub("\n(%u%w*):%s+([^\n]+)", "\n\\mugshot{%1} %2")
end

function mugshot(name)
    return [[\img{mugshots/%s.png}]] % name
end
