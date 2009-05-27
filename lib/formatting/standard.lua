-- standard formatting rules: basic HTML, title, text

-- the title at the start of the post. Renders is as bold followed by two newlines.
function formatting.title(title)
    emit (".b{%d: %s}", lp.chapter.index, title)
end

-- FAQ. Invoked as 'faq ("question", "answer")'
-- Produces the question in bold, newline, then the answer and two newlines.
function formatting.faq(Q, A)

    emit (".b{%s}\n%s" % Q % A)
end

-- general LP commentary. Text in italics.
function formatting.text(text)
    emit (".i{%s}" % text)
end

-- a link to elsewhere
function formatting.url(path, text)
    emit (".url{%s %s}" % path:gsub(' ', '%%20'), text)
end

-- a linebreak
function formatting.br()
    emit "\n"
end

-- completely unmodified text
function formatting.raw(text)
    emit (text)
end

-- bold, italic, underline, superscript, subscript, preformatted, fixedwidth
for _,format in ipairs { "b", "i", "u", "super", "sub", "pre", "tt" }
do
    formatting[format] = function(text)
        emit (".%s{%s}" % format % text)
    end
end

