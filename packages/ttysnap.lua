local TTY = require "ttysnap"
require "util.flags"
require "util.io"
require "util.string"

local options = lp.options(...) {
  palette = '';
  term_size = '80x24';
  font = 'Cousine';
  font_size = 16;
  prefix = 'ttysnap/';
}

-- parse options that need parsing
options.palette = flags.mapOf(flags.number, flags.string)(nil, options.palette)
options.font_size = tonumber(options.font_size)

local tty

-- Extract screenshots from a ttyrec file.
-- Looks for options.prefix/<frame number>.png
-- If it finds it, emits a normal "image" tag.
-- If it doesn't find it, initializes TTY library if needed and then takes a
-- screenshot.
lp.defmacro('ttysnap', 1, function(frame)
  frame = tonumber(frame)
  name = '%s%08d.png' % {options.prefix, frame}
  if not io.exists(name) then
    if not tty then tty = TTY:init(options.file, options) end
    tty:seek(frame)
    tty:snap(name)
  end
  return '[img %s]' % name
end)
