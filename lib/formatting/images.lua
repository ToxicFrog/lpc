-- image-related formats
-- screenshots, raw images

-- an image inserted raw into the LP
-- images starting with http:// are assumed to be absolute links; otherwise
-- they are assumed to be relative to the LP (_not_ the chapter) directory
function formatting.img(path)
    emit (".img{%s}" % path)
end

-- screenshots; expects the images to be in <chapter>/ss/<image>
-- so, for example, ss(2) in chapter 3 would emit
-- .img{003/ss/0002}
-- you can pass multiple numbers and it will concat them, eg, ss(1,2,3)
function formatting.ss(...)
    local argv = {...}
    for i,n in ipairs (argv)
    do
        argv[i] = (".img{%03d/ss/%04d%s}" % lp.chapter.index % n % lp.ssext)
    end
    emit(table.concat(argv, "\n"))
end


