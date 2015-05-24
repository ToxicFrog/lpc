local options = lp.options(...) {
  prefix = ''
}

lp.defmacro('img', 1, function(path)
  return '[image %s%s]' % { options.prefix, path }
end)

lp.defmacro('timg', 1, function(path)
  return '[thumbnail %s%s]' % { options.prefix, path }
end)
