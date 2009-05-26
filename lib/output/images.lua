-- run the image mapper on the chapter
-- runs through all the .img{} sequences in the chapter text and replaces them
-- with the version returned by the image mapper

return function(chapter, options)
    local name = options.mapper or lp.images
    local mapper,args = name:match("(%S+)%s*(.*)")
    local mapperf = srequire("lib.images."..mapper)
    
    if not mapperf then
        die("images: can't open image mapper named '%s'\nMake sure that lib/images/%s.lua exists\n",
            mapper,
            mapper)
    end
    
    local function mapimage(text)
        text = text:sub(6,-2) -- strip off the .img{ }
        return ".img{"..mapperf(text, args).."}"
    end
    
    chapter.text = chapter.text:gsub(".img%b{}", mapimage)
end

