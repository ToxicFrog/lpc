-- dump the raw IR for debugging purposes

local function ir(chapter, options)
    return chapter.text
end

return output.makefn(ir, "post.ir")


