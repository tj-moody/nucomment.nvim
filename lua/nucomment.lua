local M = {}

local default_config = {
    floating_comments = false,
    normal_mapping = "<leader>c",
    visual_mapping = "<leader>c",
    single_line_mapping = "<leader>cc"
}

local function comment_line(line_nr, min_indent)
    local commentstring = vim.bo.commentstring:sub(1, -3)
    local indent = vim.fn.indent(line_nr)
    local line = vim.fn.getline(line_nr) ---@cast line string
    local stripped_line = line:gsub("^%s*", "")

    local num_leading_spaces = min_indent
    if indent > commentstring:len() and M.config.floating_comments then
        num_leading_spaces = min_indent - commentstring:len()
    end
    local leading_spaces = (' '):rep(num_leading_spaces)

    local num_trailing_spaces = 0
    if indent ~= min_indent then
        if M.config.floating_comments then
            num_trailing_spaces = indent - num_leading_spaces - commentstring:len()
        else
            num_trailing_spaces = indent - min_indent
        end
    end
    local trailing_spaces = (' '):rep(num_trailing_spaces)

    vim.fn.setline(line_nr,
        leading_spaces
        .. commentstring
        .. trailing_spaces
        .. stripped_line
    )
end

local function uncomment_line(line_nr)
    local commentstring = vim.bo.commentstring:sub(1, -3)
    local indent = vim.fn.indent(line_nr) ---@cast indent integer
    local line = vim.fn.getline(line_nr) ---@cast line string
    local stripped_line = line:gsub("^%s*", "")

    local num_leading_spaces = indent + commentstring:len()
    if indent == 0 or not M.config.floating_comments then num_leading_spaces = indent end

    vim.fn.setline(line_nr,
        (' '):rep(num_leading_spaces)
        .. stripped_line:sub(commentstring:len() + 1, -1)
    )
end

local function comment_toggle_lines()
    vim.go.operatorfunc = "v:lua.callback"
    return "g@"
end


_G.callback = function()
    local commentstring = vim.bo.commentstring:sub(1, -3)
    local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "[")) ---@diagnostic disable-line
    local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "]")) ---@diagnostic disable-line

    local min_indent = vim.fn.indent(start_line)
    local block_commented = true
    for line_nr = start_line, end_line do
        local indent = vim.fn.indent(line_nr)
        if indent < min_indent then
            min_indent = indent
        end

        local stripped_line = vim.fn.getline(line_nr):gsub("^%s*", "") ---@diagnostic disable-line
        if stripped_line:sub(1, commentstring:len()) ~= commentstring then
            block_commented = false
        end
    end

    if block_commented then
        for line_nr = start_line, end_line do uncomment_line(line_nr) end
    else
        for line_nr = start_line, end_line do comment_line(line_nr, min_indent) end
    end
end

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    vim.keymap.set('n', '<Plug>comment_toggle', comment_toggle_lines, { expr = true, desc = 'Comment toggle' })
    vim.keymap.set('n', '<leader>c', '<Plug>comment_toggle', {})
    vim.keymap.set('x', '<leader>c', '<Esc>`<<Plug>comment_toggle`>gv', {})
    vim.keymap.set('n', '<leader>cc', '<Plug>comment_toggle l', {})
end

M.toggle_floating_comments = function()
    M.config.floating_comments = not M.config.floating_comments
end

return M
