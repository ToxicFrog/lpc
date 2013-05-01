-- Let's Play post generator
-- This program is PUBLIC DOMAIN, free to use, modify, and distribute for any
-- purpose whatsoever, by anyone, forever

--------------------
-- INITIALIZATION --
--------------------

-- package loader setup
package.path = "./?.lua;"..package.path

-- general utility functions
require "lib.misc"

-- load configuration settings
lp = { chapters = {} }
require "config"

-- load typesetting
require "lib.formatting"
require "lib.output"


-----------------------------
-- LOCAL SUPPORT FUNCTIONS --
-----------------------------

local function read_args(...)
    local outputs = {}
    local chapters = {}
    local argv = { ... }
    local i=1
    while argv[i] and not tonumber(argv[i])
    do
        table.insert(outputs, argv[i])
        i = i + 1
    end
    return outputs, {unpack(argv, i)}
end

local function load_chapter(chapter)
    local function setupenv(f)
        setfenv(f, formatting)
    end

    local dir = "%03d/" % chapter
    local f,e = loadfile(dir.."post.lua")
    
    if not f then
        return f,e
    end
    
    lp.chapter = {
        index = chapter;
        dir = dir;
        text = {};
    }
    lp.chapters[chapter] = lp.chapter

    setupenv(f)
    formatting.lfsensitive(true)
    f()
    formatting.lfsensitive(false)
    lp.chapter.text = table.concat(lp.chapter.text)
    
    return true
end

local function load_chapters(chapters)
    -- if we're actually given a list, load all the chapters in the list
    if #chapters > 0 then
        for _,c in ipairs(chapters) do
            local r,e = load_chapter(tonumber(c))
            if not r then
                eprintf("Warning: can't load chapter %d: %s\n", chapter, e)
            end
        end
    else
        -- otherwise, load everything
        for i=0,math.huge do
            if not load_chapter(i) then break end
        end
    end
end


-----------------
-- ENTRY POINT --
-----------------

local function main(...)
    local formats,chapters = read_args(...)

    if #formats == 0 then
        print("Usage: lp <formats> [chapters]")
        print("  No formats specified, exiting.")
        return 1
    end
    
    load_chapters(chapters)
    
    for _,format in pairs(formats) do
        for _,chapter in pairs(lp.chapters) do
            output.gen(chapter, format)
        end
    end
end

do return main(...) end

