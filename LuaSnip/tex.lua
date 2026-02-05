local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- Simple fraction: ff -> \frac{}{}
    s({trig = "ff", snippetType = "autosnippet"}, {
        t("\\frac{"), i(1), t("}{"), i(2), t("}"),
    }),

    -- Equation block: eq -> \begin{equation} 
    s({trig = "eq"}, {
        t({"\\begin{equation}", " "}), i(1),
        t({"", "\\end{equation}"}),
    }),

    -- Itemize block: item -> \begin{itemize}
    s({strig = "item"}, {
        t({"\\begin{itemize}", " \\item "}), i(1),
        t({"", "\\end{itemize}"}),
    }),

    -- Bold text: tbb -> \textbf{}
    s({trig = "tbb", snippetType = "autosnippet"}, {
        t("\\textbf{"), i(1), t("}"),
    }),

    -- Italic text: tii -> \textit{}
    s({trig = "tii", snippetType = "autosnippet"}, {
        t("\\textit{"), i(1), t("}"),
    }),
}

