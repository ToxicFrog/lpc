function POST(text)
    if file then
        LOG("Writing post to %s", file) 
        local fd = assert(io.open(file, "w"))
        fd:write(text)
        fd:close()
    else
        LOG("Writing post to stdout")
        io.write(text)
    end
end
