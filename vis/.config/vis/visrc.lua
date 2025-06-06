-- ROGUH's vis configuration
-- ROGUH's vis configuration
-- ROGUH's vis configuration
-- ROGUH's vis configuration
-- ROGUH's vis configuration
-- ROGUH's vis configuration

-- TODO ranger file browser or alternative
-- TODO simple version of https://github.com/rhysd/committia.vim/tree/master/autoload ?
-- TODO rainbow indentation?
-- TODO org-mode hierarchy support? navigate to next level, create new level, etc
-- TODO autoreload on changes??? (IMPORTANT)


-- Load standard vis module, providing parts of the Lua API
require('vis')

vis.events.subscribe(vis.events.INIT, function(win)
    -- Semicolon is the same as colon
    vis:map(vis.modes.NORMAL, ';', ':')

    -- Alias shell redirection commands
    -- These won't work in VISUAL since they're taken by other mappings
    -- TODO force a mapping?
    vis:map(vis.modes.NORMAL | vis.modes.VISUAL_LINE, '|', ':|')
    vis:map(vis.modes.NORMAL | vis.modes.VISUAL_LINE, '<', ':<')
    vis:map(vis.modes.NORMAL | vis.modes.VISUAL_LINE, '>', ':>')

    vis:map(vis.modes.NORMAL, '`', ':lint')
    vis:map(vis.modes.NORMAL, '~', ':fix')

    vis:map(vis.modes.NORMAL, 'z=', function()
        vis:feedkeys('<C-w>e')
        vis:feedkeys('<C-w>w')
    end)

    vis:map(vis.modes.NORMAL, 'z=', function()
        vis:feedkeys('<C-w>e')
        vis:feedkeys('<C-w>w')
    end)

    -- Type current UTC time using Python
    vis:command_register("pt", function(argv, force, win, selection, range)
        -- This command used to be a hideous Python one-liner
        -- vis:feedkeys(':<python -c "import datetime; print(datetime.datetime.utcnow().isoformat(), end=\'\')"')
        vis:feedkeys(':<TZ=UTC date --iso-8601=seconds')
    end, "Insert 8601 UTC timestamp with seconds")

    -- The famous ctrl-P for finding files
    -- Process color codes with --ansi. This slows down fzf, but I can't seem to get rid of the color codes in the output from ag/somewhereelse
    vis:map(vis.modes.NORMAL, '<C-p>', ':fzf --ansi<Enter>')

    -- Paste from system clipboard with vis-clipboard
    -- vis:map(vis.modes.NORMAL, '<C-v>', '"+p')
    -- vis:map(vis.modes.INSERT, '<C-v>', '<Escape>"+pi')
    vis:map(vis.modes.NORMAL, '<C-v>', function() vis:feedkeys(':>vis-clipboard --paste<Enter>') end)
    vis:map(vis.modes.INSERT, '<Escape><C-v>', function() vis:feedkeys(':>vis-clipboard --paste<Enter>') end)

    -- Put selection content into system clipboard
    vis:map(vis.modes.VISUAL_LINE, '<C-c>', function() vis:feedkeys(':>vis-clipboard --copy<Enter>') end)
    -- TODO this doesn't work with multiple cursors, just gets last selection
    vis:map(vis.modes.VISUAL, '<C-c>', function() vis:feedkeys(':>vis-clipboard --copy<Enter>') end)
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    -- Per window configuration options.
    vis:command('set shell sh') -- a barebones shell that should have no extra config/outputs
    vis:command('set number')
    -- relativenumber + number = hybrid number mode with current line number shown, all others are relative
    -- TODO use absolute line numbers in insert mode, "smart hybrid mode"
    -- vis:command('set rnu') -- same as vis:command('set relativenumber')
    vis:command('set autoindent')
    vis:command('set layout v')
    vis:command('set cursorline on')
    -- TODO only ignore case if search string is all lowercase
    vis:command('set ignorecase on')

    -- vis:command('set show-newlines')
    vis:command('set show-tabs')
    vis:command('set show-eof')
									-- tabs example
                                    -- spaces example
--- lots of newlines







--- lots of newlines

    -- Python formatting settings
    vis:command('set colorcolumn 79')
    vis:command('set tabwidth 4')
    vis:command('set expandtab on')

    local lang = 'en_US'
    vis:command('set spelllang ' .. lang)
    vis:info('Spellchecking language is now ' .. lang .. '. F7 to activate; Ctrl-W W for sugggestions.')
end)

vis.events.subscribe(vis.events.INIT, function()
    -- Load plugins with require(), download if necessary
    lint = require_if_exists('https://github.com/rnpnr/vis-lint', 'vis-lint') or {}
    backup = require_if_exists('https://github.com/roguh/vis-backup', 'vis-backup', 'backup') or {}
    shebang = require_if_exists('https://github.com/e-zk/vis-shebang', 'vis-shebang') or {}
    -- Forked from 'https://gitlab.com/muhq/vis-spellcheck'
    -- This plugin will use enchant, enchant-2, aspell, or hunspell in that order
    spellcheck = require_if_exists('https://gitlab.com/muhq/vis-spellcheck', 'vis-spellcheck') or {}

    spellcheck.default_lang = "en_US"

    -- A global variable for configuring vis-shebang
    shebangs = {
        ["#!/bin/sh"] = "bash",
        ["#!/bin/bash"] = "bash",
        ["#!/usr/bin/env python3"] = "python",
        ["#!/usr/bin/env python"] = "python",
    }

    -- Configure backup plugin
    backup.time_format = "%H-%M-%S"
    -- This will create the directory
    backup.set_directory(os.getenv("HOME") .. "/tmp/vis-backups")
    backup.get_fname = backup.entire_path_with_double_percentage_signs_and_timestamp

	lint.linters["yaml"] = {"yamllint -"}
	lint.linters["python"] = {
	   -- "black --check -", "isort --check -",
	   "pylint --from-stdin visfile",
	   "mypy /dev/stdin",
	}

end)

function file_exists(name)
   local fileobj = io.open(name, "r")
   if fileobj ~= nil
   then io.close(fileobj) return true
   else return false
   end
end

-- Copied with love from
-- https://git.sr.ht/~mcepl/vis-fzf-open/tree/master/item/init.lua
fzf_config = {}
fzf_config.fzf_path = "fzf"
fzf_config.fzf_args = ""

-- Use ctrl-s or ctrl-v to open the chosen file in a (v)split window
vis:command_register("fzf", function(argv, force, win, selection, range)
    local command = string.gsub([[
            $fzf_path \
                --header="Enter:edit,^s:split,^v:vsplit" \
                --expect="ctrl-s,ctrl-v" \
                $fzf_args $args
        ]],
        '%$([%w_]+)', {
            fzf_path=fzf_config.fzf_path,
            fzf_args=fzf_config.fzf_args,
            args=table.concat(argv, " ")
        }
    )

    local file = io.popen(command)
    local output = {}
    for line in file:lines() do
        table.insert(output, line)
    end
    local success, msg, status = file:close()

    if status == 0 then
        local action = 'e'

        if     output[1] == 'ctrl-s' then action = 'split'
        elseif output[1] == 'ctrl-v' then action = 'vsplit'
        end

        vis:feedkeys(string.format(":%s '%s'<Enter>", action, output[2]))
    elseif status == 1 then
        vis:info(
            string.format(
                "fzf-open: No match. Command %s exited with return value %i.",
                command, status
            )
        )
    elseif status == 2 then
        vis:info(
            string.format(
                "fzf-open: Error. Command %s exited with return value %i.",
                command, status
            )
        )
    elseif status == 130 then
        vis:info(
            string.format(
                "fzf-open: Interrupted. Command %s exited with return value %i",
                command, status
            )
        )
    else
        vis:info(
            string.format(
                "fzf-open: Unknown exit status %i. command %s exited with return value %i",
                status, command, status
            )
        )
    end

    vis:feedkeys("<vis-redraw>")

    return true;
end, "Select file to open with fzf")

-- Use + and - to shift selection (:x)
-- Use , to reverse
vis:map(vis.modes.VISUAL, ',', function(keys)
        local ranges = {}
        local contents = {}
        for selection in vis.win:selections_iterator() do
                table.insert(ranges, selection.range)
                table.insert(contents, vis.win.file:content(selection.range))
        end
        for source = 1, #ranges do
                local target = #ranges - source + 1
                vis.win.file:delete(ranges[target])
                vis.win.file:insert(ranges[target].start, contents[source])
        end
        vis.win.selections = {}
        vis.mode = vis.modes.NORMAL
        vis:feedkeys("<vis-redraw>")
end, "reverse selections")

function run_command(command)
    return io.popen(command):read('*a'):gsub('\n', '')
end

-- Based on https://github.com/erf/vis-title/blob/master/init.luoa
function set_title(fname)
    -- ruh roh printf input sanitization
    local full_title = 'vis ' ..
      run_command('projectname.sh') ..
      ' ' .. (fname and fname:gsub("(%%)", "%%%%") or fname) ..
      ' ' .. run_command('echo $(hostname)')

    vis:command(string.format(":!printf '\\033]0;%s\\007'", full_title))
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    set_title(win.file.name or '[No Name]')
end)

vis.events.subscribe(vis.events.FILE_SAVE_POST, function(file, path)
    set_title(file.name)
end)

-- For loading plugins
function require_if_exists(repo, directory, initfile)
  initfile = initfile or 'init'
  local name = directory .. '/' .. initfile
  local location = os.getenv("HOME") .. "/.config/vis/"
  local plugin_location = location .. directory

  if os.rename(plugin_location, plugin_location) == nil then
    run_command('cd ' .. location .. ' && git clone ' .. repo .. ' ' .. plugin_location)
    vis:message('Installed plugin from repo: ' .. repo .. ' in ' .. location)
  end

  return require(name)
end

-- PURTT COLORS
purty_colors_now = function(a, b, c, d)
    local light_mode = false
    if light_mode then
        -- vis:command('set theme light-16')
        return null
    else
        -- vis:command('set theme solarized')
        return null
    end
end

vis.events.subscribe(vis.events.INIT, purty_colors_now)
vis.events.subscribe(vis.events.WIN_OPEN, purty_colors_now)

-- https://gitlab.com/muhq/vis-lspc ? Might slow vis down too much

-- Reminders:
-- :x/.../ c/.../        is   %s/.../.../ (g?)
-- It even leaves you multiple cursors at each replacement for further refinement!

-- :r                    is   :read
-- No, I didn't figure out how to alias it

-- :!command %           is   :<command $vis_filename
-- Why vis, why. TODO alias somehow? fork vis?

-- :sort is now :|sort
-- Or use my alias:    :| is |   in most modes

-- Move around windows with Ctrl-W hjkl, no arrow keys
-- TODO alias arrow keys for switching windows

-- > and < in VISUAL modify indentation

-- Ctrl-n C-n is TAB for autocomplete
