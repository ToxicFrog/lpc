-- turns :foo: into \emote{foo}
-- also supports :) :( :D ;)

local smilies = {
    [":)"] = [[\emote{smile}]];
    [":("] = [[\emote{frown}]];
    [":D"] = [[\emote{biggrin}]];
}

function PRE(text)
    return text:gsub(":[()D]", smilies)
    :gsub(";)", "\\emote{wink}")
    :gsub(":([^:]+):", "\\emote{%1}")
end
