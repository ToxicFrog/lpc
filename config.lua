---------------------
-- GLOBAL SETTINGS --
---------------------

-- the name of the Let's Play. Not currently used by anything, but might be
-- useful in the future.
lp.name = "Let's Play Example Game"

---------------------
-- SOURCE SETTINGS --
---------------------

-- what formatting styles are loaded. These are provided by the formatting/*.lua
-- files; each one loads the file with that name
lp.formatting = {
    "standard";     -- basic formatting, links, titles and text
    "images";       -- ss and img
    "dialog";       -- dialog transcription with character portraits
    "local";        -- lp-specific stuff
}

-- file extension for screenshots
-- yes, this framework requires that all screenshots use the same file extension
lp.ssext = ".png"

-- file extension for faces (for the dialog module)
-- if unset, defaults to the screenshot extension
lp.faceext = ".png"


---------------------------------
-- IMAGE URL & UPLOAD SETTINGS --
---------------------------------

-- how to determine the final URL to images
-- default: don't change image URLs at all
--
lp.images = "identity"

-- change to relative links, using the post.lua as a basis - so "001/ss/0000.png"
-- becomes "ss/0000.png", and "common/cover.png" becomes "../common/cover.png"
-- this is useful for generating HTML versions with relative links
--
--lp.images = "relative"

-- prefix with a static path or URL
-- useful if you're using your own image host and all paths/names will be
-- preserved, so that
--      001/ss/0000.png
-- becomes
--      http://example.com/letsplay/examplegame/001/ss/0000.png
-- Note that this won't automatically upload the images for you; use the
-- "images" output format to get a list of images you need to upload, suitable
-- for passing to rsync, your favorite FTP client, or the like
--
--lp.images = "prefix http://hostname/path/to/LP"

-- upload the image to waffleimages and insert the URL given by WI
-- it won't upload images more than once, so the first time it'll upload
-- everything and on subsequent runs it will only upload new or changed images
-- note that it detects changes in a very crude way - it checks the file length
--
-- lp.images = "waffleimages"

---------------------
-- OUTPUT SETTINGS --
---------------------

-- what formats to output in by default. These are provided by the output/*.lua
-- files, and as formatting, each one loads the corresponding file
lp.output = {
    "html";
    "bbcode";
}

---------------------
-- UPLOAD SETTINGS --
---------------------

-- FIXME - does anything need to go here?

