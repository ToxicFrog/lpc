-- dump the raw IR for debugging purposes

local function ir(chapter, options)
    print("[ir] dumping intermediate representation to %s" % options.o)
    return chapter.text
end

return output.makefn(ir, "post.ir")


