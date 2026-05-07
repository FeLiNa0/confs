-- Copyright 2025 Matěj Cepl (@mcepl everywhere). See LICENSE.
-- Copyright 2012 joten
-- Org agenda LPeg lexer.

local lexer = lexer
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local lex = lexer.new(...)

-- Embedded code block highlighting.
local src_end = '\n' * lexer.starts_line(P('#+END_SRC'))
lex:embed(lexer.load('python'),     lexer.starts_line(P('#+BEGIN_SRC python')     * lexer.nonnewline^0 * '\n'), src_end)
lex:embed(lexer.load('bash'),       lexer.starts_line(P('#+BEGIN_SRC bash')       * lexer.nonnewline^0 * '\n'), src_end)
lex:embed(lexer.load('javascript'), lexer.starts_line(P('#+BEGIN_SRC javascript') * lexer.nonnewline^0 * '\n'), src_end)

-- Headings: leading n-1 stars are 'org_ghost' (invisible on dark bg),
-- last star+space gets per-level rainbow color.
local function h(n)
    local tag = string.format('%s.h%s', lexer.HEADING, n)
    if n == 1 then
        return lex:tag(tag, lexer.starts_line(P('* ')))
    end
    return lex:tag('org_ghost', lexer.starts_line(P(string.rep('*', n - 1)))) *
           lex:tag(tag, P('* '))
end
lex:add_rule('header', h(6) + h(5) + h(4) + h(3) + h(2) + h(1))

-- Task states.
lex:add_rule('todo',    lex:tag(lexer.KEYWORD,  lex:word_match('todo')))
lex:add_rule('done',    lex:tag('org_done',     lex:word_match('done')))
lex:add_rule('waiting', lex:tag(lexer.CONSTANT, lex:word_match('waiting')))

-- Priority [#A], [#B], [#C].
lex:add_rule('priority', lex:tag(lexer.NUMBER, P('[#') * R('AZ') * P(']')))

-- Tags :tag:tag:.
lex:add_rule('tags', lex:tag(lexer.CLASS,
    (':' * (R('az', 'AZ', '09') + S('_@#%'))^1)^1 * ':'))

-- Checkboxes.
lex:add_rule('checkbox_done',    lex:tag('org_done',     P('- [') * S('xX') * P(']')))
lex:add_rule('checkbox_partial', lex:tag(lexer.CONSTANT, P('- [-]')))
lex:add_rule('checkbox_todo',    lex:tag(lexer.KEYWORD,  P('- [ ]')))

-- Planning keywords.
lex:add_rule('planning', lex:tag(lexer.LABEL,
    P('SCHEDULED:') + P('DEADLINE:') + P('CLOSED:')))

-- Metadata directives #+KEYWORD:.
lex:add_rule('meta', lex:tag(lexer.PREPROCESSOR,
    lexer.starts_line(P('#+') * (R('az', 'AZ', '09') + P('_'))^1 * P(':'))))

-- Block delimiters #+BEGIN_*/#+END_* (comment rule must stay above this
-- so the range pattern consumes #+BEGIN_COMMENT blocks before block_delim sees them).
local line_comment  = lexer.starts_line(lexer.to_eol('# '))
local block_comment = lexer.range(lexer.starts_line('#+BEGIN_COMMENT'),
    lexer.starts_line('#+END_COMMENT'))
lex:add_rule('comment', lex:tag(lexer.COMMENT, block_comment + line_comment))

lex:add_rule('block_delim', lex:tag(lexer.PREPROCESSOR,
    lexer.starts_line(lexer.to_eol(P('#+BEGIN_') + P('#+END_')))))

-- Inline formatting.
local function inline(marker)
    return P(marker) * (lexer.nonnewline - P(marker))^1 * P(marker)
end
lex:add_rule('bold',      lex:tag('bold',         inline('*')))
lex:add_rule('italic',    lex:tag('italic',        inline('/')))
lex:add_rule('underline', lex:tag('underline',     inline('_')))
lex:add_rule('strike',    lex:tag('strikethrough', inline('+')))
lex:add_rule('code',      lex:tag('code',          inline('~')))
lex:add_rule('verbatim',  lex:tag(lexer.TYPE,      inline('=')))

-- Links [[url][desc]] or [[url]].
lex:add_rule('link', lex:tag(lexer.LINK,
    '[[' * (lexer.nonnewline - S(' ]'))^1 * ']' *
    ('[' * (lexer.nonnewline - P(']'))^1 * ']')^-1 * ']'))

-- Strings "quoted".
lex:add_rule('string', lex:tag(lexer.STRING, lexer.range('"')))

-- DateTime (org-agenda view).
local DD = lexer.digit * lexer.digit
lex:add_rule('current_date', lex:tag(lexer.LABEL,
    lexer.starts_line(lex:word_match('weekday')) * lexer.space^1 * DD * '. ' *
        lex:word_match('month') * lexer.space^1 * DD * DD * '|'))
lex:add_rule('time',     lex:tag(lexer.NUMBER, DD * ':' * DD))
lex:add_rule('week',     lex:tag('underline',
    lexer.starts_line('KW ' * DD * lexer.space^25) +
    lexer.starts_line('Wk ' * DD * lexer.space^25)))

-- Word lists.
lex:set_word_list('todo',    {'TODO', 'NEXT', 'DELEGATED'})
lex:set_word_list('done',    {'DONE', 'INVALID', 'WONTFIX', 'CANCELLED'})
lex:set_word_list('waiting', {'WAITING', 'HOLD'})

lex:set_word_list('wday', {
    'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So',
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    'Po', 'Út', 'St', 'Čt', 'Pá',
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom',
    'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
})

lex:set_word_list('weekday', {
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag',
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    'Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota', 'Neděle',
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
})

lex:set_word_list('month', {
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    'January', 'February', 'March', 'May', 'June', 'July', 'October', 'December',
    'Leden', 'Únor', 'Březen', 'Duben', 'Květen',
    'Červen', 'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosince',
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    'Janvier', 'Février', 'Avril', 'Juin', 'Juillet', 'Août',
    'Septembre', 'Octobre', 'Novembre', 'Décembre',
})

lexer.property['scintillua.comment'] = '#'

return lex
