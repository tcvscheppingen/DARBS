-- Steel: neutral greys with one steel-blue accent, the DARBS palette.
-- The same colors are in dwm, st, dmenu, slock, dunst and the Helix theme.
vim.cmd.highlight("clear")

if vim.fn.exists("syntax_on") == 1 then
	vim.cmd.syntax("reset")
end

vim.o.background = "dark"
vim.g.colors_name = "steel"

local c = {
	bg_dark = "#111111",
	bg = "#151515",
	bg1 = "#1f1f1f",
	bg2 = "#2a2a2a",
	bg3 = "#3a3a3a",
	grey = "#5a5a5a",
	comment = "#6c6c6c",
	fg_dim = "#8a8a8a",
	fg = "#c6c6c6",
	fg_bright = "#e8e8e8",

	accent = "#3d7ab8",
	red = "#c25d5d",
	green = "#6fa392",
	yellow = "#c4a35e",
	blue = "#5b8fc7",
	bright_blue = "#74a5da",
	magenta = "#8f7fc2",
	cyan = "#5ea7b5",
}
local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Editor UI
hi("Normal", { fg = c.fg, bg = c.bg })
hi("NormalFloat", { fg = c.fg, bg = c.bg1 })
hi("NormalNC", { fg = c.fg, bg = c.bg })
hi("SignColumn", { fg = c.fg, bg = c.bg })
hi("EndOfBuffer", { fg = c.bg, bg = c.bg })
hi("Cursor", { fg = c.bg, bg = c.fg })
hi("CursorLine", { bg = c.bg1 })
hi("CursorColumn", { bg = c.bg1 })
hi("ColorColumn", { bg = c.bg1 })
hi("Visual", { bg = "#263547" })
hi("VisualNOS", { bg = "#263547" })
hi("Search", { fg = c.fg_bright, bg = "#2f5577" })
hi("IncSearch", { fg = c.fg_bright, bg = c.accent, bold = true })
hi("CurSearch", { fg = c.fg_bright, bg = c.accent, bold = true })
hi("Substitute", { fg = c.fg_bright, bg = c.accent })
hi("MatchParen", { bg = c.bg3, bold = true })
hi("NonText", { fg = c.bg3 })
hi("Whitespace", { fg = c.bg3 })

-- Line numbers and folds
hi("LineNr", { fg = c.grey, bg = c.bg })
hi("CursorLineNr", { fg = c.bright_blue, bg = c.bg1, bold = true })
hi("FoldColumn", { fg = c.grey, bg = c.bg })
hi("Folded", { fg = c.fg_dim, bg = c.bg1, italic = true })

-- Window separators and borders
hi("WinSeparator", { fg = c.bg3, bg = c.bg })
hi("VertSplit", { fg = c.bg3, bg = c.bg })
hi("FloatBorder", { fg = c.bg3, bg = c.bg1 })
hi("FloatTitle", { fg = c.bright_blue, bg = c.bg1, bold = true })

-- Statusline and tabline
hi("StatusLine", { fg = c.fg, bg = c.bg2 })
hi("StatusLineNC", { fg = c.fg_dim, bg = c.bg1 })
hi("TabLine", { fg = c.fg_dim, bg = c.bg1 })
hi("TabLineFill", { fg = c.fg_dim, bg = c.bg1 })
hi("TabLineSel", { fg = c.fg_bright, bg = c.accent, bold = true })

-- Menus and prompts
hi("Pmenu", { fg = c.fg, bg = c.bg1 })
hi("PmenuSel", { fg = c.fg_bright, bg = c.accent, bold = true })
hi("PmenuSbar", { bg = c.bg2 })
hi("PmenuThumb", { bg = c.grey })
hi("WildMenu", { fg = c.fg_bright, bg = c.accent })
hi("Question", { fg = c.bright_blue })
hi("MoreMsg", { fg = c.bright_blue })
hi("ModeMsg", { fg = c.bright_blue })
hi("ErrorMsg", { fg = c.red, bold = true })
hi("WarningMsg", { fg = c.yellow })
hi("Title", { fg = c.fg_bright, bold = true })
hi("Directory", { fg = c.blue, bold = true })

-- Diagnostics
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.blue })
hi("DiagnosticHint", { fg = c.cyan })

hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan })

-- Diff
hi("DiffAdd", { fg = c.green, bg = "#1c2d28" })
hi("DiffChange", { fg = c.blue, bg = "#1c2533" })
hi("DiffDelete", { fg = c.red, bg = "#2d1c1c" })
hi("DiffText", { fg = c.fg_bright, bg = "#2f4a66" })

-- Spelling
hi("SpellBad", { undercurl = true, sp = c.red })
hi("SpellCap", { undercurl = true, sp = c.blue })
hi("SpellLocal", { undercurl = true, sp = c.cyan })
hi("SpellRare", { undercurl = true, sp = c.magenta })

-- Core syntax: blue keywords, cyan types, mint strings, violet constants.
-- Red and gold are kept for errors and warnings.
hi("Comment", { fg = c.comment, italic = true })

hi("Constant", { fg = c.magenta })
hi("String", { fg = c.green })
hi("Character", { fg = c.green })
hi("Number", { fg = c.magenta })
hi("Boolean", { fg = c.magenta })
hi("Float", { fg = c.magenta })

hi("Identifier", { fg = c.fg })
hi("Variable", { fg = c.fg })
hi("Function", { fg = c.fg_bright })

hi("Statement", { fg = c.blue })
hi("Conditional", { fg = c.blue })
hi("Repeat", { fg = c.blue })
hi("Label", { fg = c.blue })
hi("Operator", { fg = c.fg_dim })
hi("Keyword", { fg = c.blue })
hi("Exception", { fg = c.blue })

hi("PreProc", { fg = c.bright_blue })
hi("Include", { fg = c.bright_blue })
hi("Define", { fg = c.bright_blue })
hi("Macro", { fg = c.bright_blue })

hi("Type", { fg = c.cyan })
hi("StorageClass", { fg = c.blue })
hi("Structure", { fg = c.cyan })
hi("Typedef", { fg = c.cyan })

hi("Special", { fg = c.cyan })
hi("Delimiter", { fg = c.fg_dim })
hi("SpecialComment", { fg = c.comment, italic = true })

hi("Error", { fg = c.fg_bright, bg = "#8a3434", bold = true })
hi("Todo", { fg = c.fg_bright, bg = c.accent, bold = true })

-- Tree-sitter captures
hi("@comment",               { link = "Comment" })
hi("@string",                { link = "String" })
hi("@string.escape",         { fg = c.cyan })
hi("@character",             { link = "Character" })

hi("@number",                { link = "Number" })
hi("@float",                 { link = "Float" })
hi("@boolean",               { link = "Boolean" })
hi("@constant",              { link = "Constant" })
hi("@constant.builtin",      { fg = c.magenta })

hi("@variable",              { fg = c.fg })
hi("@variable.builtin",      { fg = c.magenta })
hi("@variable.parameter",    { fg = c.fg })

hi("@function",              { fg = c.fg_bright })
hi("@function.call",         { fg = c.fg_bright })
hi("@function.builtin",      { fg = c.cyan })
hi("@method",                { fg = c.fg_bright })
hi("@method.call",           { fg = c.fg_bright })

hi("@keyword",               { fg = c.blue })
hi("@keyword.function",      { fg = c.blue })
hi("@keyword.return",        { fg = c.blue, bold = true })
hi("@keyword.operator",      { fg = c.blue })

hi("@type",                  { fg = c.cyan })
hi("@type.builtin",          { fg = c.cyan })
hi("@attribute",             { fg = c.bright_blue })
hi("@property",              { fg = c.fg })

hi("@operator",              { fg = c.fg_dim })
hi("@punctuation.delimiter", { fg = c.fg_dim })
hi("@punctuation.bracket",   { fg = c.fg_dim })

hi("@tag",                   { fg = c.blue })
hi("@tag.attribute",         { fg = c.cyan })
hi("@markup.heading",        { fg = c.fg_bright, bold = true })
hi("@markup.link",           { fg = c.bright_blue, underline = true })
