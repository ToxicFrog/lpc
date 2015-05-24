local vstruct = require "vstruct"
require "util.logging"

local TTY = {}

function TTY:init(ttyrec, options)
  local tty = setmetatable({}, {__index = TTY})
  tty.file = ttyrec
  tty.fd = assert(io.open(ttyrec, 'rb'))

  -- constants
  local s,us = vstruct.readvals('u4 u4', tty.fd)
  tty.start = s + (us/1e6)      -- starting time of recording
  tty.eof = tty.fd:seek('end')  -- end of file offset
  tty.options = options

  -- state
  tty.frame = -1            -- current frame displayed in terminal
  tty.time = 0      -- current time
  tty.where = 0             -- read pointer offset

  -- start child process
  -- there's some ugly hacks here
  -- first, we create a fifo named /tmp/<current time>, which is totes insecure
  tty.fifoname = "/tmp/%d" % os.time()
  log.debug('Creating fifo %s', tty.fifoname)
  os.execute("mkfifo '%s'" % tty.fifoname)

  -- then we open an xterm in the background
  local cmd = "xterm -T ttysnap -ah -geometry %s -fa %s -fs %d -bg black +sb -e cat '%s' &" % {
    options.term_size,
    options.font,
    options.font_size,
    tty.fifoname,
  }
  log.debug('Creating XTterm with command line: %s', cmd)
  assert(os.execute(cmd))

  -- and finally we open the fifo to it so we can send it stuff.
  tty.xterm = assert(io.open(tty.fifoname, 'w'))

  -- initialize custom colourmap
  for id,colour in pairs(options.palette) do
    log.debug('Overriding colourmap entry: %d = %s', id, colour)
    tty.xterm:write('\x1B]4;%d;%s\x07' % {id, colour})
  end

  -- display first frame
  tty.fd:seek('set')
  tty:seek(0)
  return tty
end

function TTY:close()
  self.xterm:close()
  os.remove(self.fifoname)
end

function TTY:rewind()
  -- rewind to start
  self.frame = -1
  self.fd:seek('set')
  self.time = 0
  self.where = 0
  self.xterm:write('\x1B[2J') -- CSI 2 J; Erase Display: All
end

function TTY:step()
  -- write one frame
  local frame = vstruct.read('s:u4 us:u4 data:c4', self.fd)
  self.xterm:write(frame.data)
  self.frame = self.frame + 1
  self.time = (frame.s + frame.us/1e6) - self.start
  self.where = self.fd:seek()
end

function TTY:seek(to_frame)
  to_frame = math.max(to_frame, 0)
  if self.frame > to_frame then
    self:rewind()
  end

  while self.frame < to_frame and self.where < self.eof do
    self:step()
  end

  self.xterm:flush()
end

function TTY:seektime(to_time)
  to_time = math.max(to_time, 0)
  if self.time > to_time then
    self:rewind()
  end

  while self.time < to_time and self.where < self.eof do
    self:step()
  end

  self.xterm:flush()
end

function TTY:snap(name)
  return os.execute('import -window ttysnap "png:%s"' % name) and name
end

return TTY
