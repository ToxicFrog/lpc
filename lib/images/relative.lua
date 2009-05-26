return function(path)
    local pattern = '^'..lp.chapter.dir:gsub('%W', '%%%0')
    
    if path:match(pattern) then
        return path:gsub(pattern, '')
    end
    
    return lp.chapter.dir:gsub('[^/]+', '..')..path
end

