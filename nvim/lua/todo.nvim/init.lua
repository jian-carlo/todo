local M = {}
local todo_file = vim.fn.expand("$HOME/todo.txt")

local function filetype_setup()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "todo.txt",
        callback = function()
            vim.bo.filetype = "todotxt"
        end,
    })
end

local function sort_todo_file()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("keepjumps keepmarks silent! %" .. "sort")
    vim.api.nvim_win_set_cursor(0, cursor_pos)
end

function M.autosort()
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = todo_file,
        callback = sort_todo_file,
        group = vim.api.nvim_create_augroup("TodoAutosort", { clear = true }),
    })
end

function M.open_float()
    local buf = vim.fn.bufadd(todo_file)
    vim.fn.bufload(buf)

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.5)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2 - 1,
        style = "minimal",
        border = "rounded",
        title = "TODO",
        title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    vim.bo[buf].filetype = "todotxt"
    vim.wo[win].number = false
    vim.wo[win].wrap = false
    vim.wo[win].signcolumn = "yes"

    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

function M.toggle_status()
    if vim.bo.filetype ~= "todotxt" then return end

    local line = vim.api.nvim_get_current_line()
    local status = line:match("^([ox])")

    if status then
        local new_status = (status == "o") and "x" or "o"
        local new_line = line:gsub("^[ox]", new_status, 1)

        vim.api.nvim_set_current_line(new_line)
    else
        print("status (o/x) found on this line")
    end
end

function M.setup()
    filetype_setup()
    M.autosort()

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "todotxt",
        callback = function()
            vim.keymap.set("n", "<c-x>", M.toggle_status, { buffer = true })
        end,
        group = vim.api.nvim_create_augroup("TodoTxtKeymaps", { clear = true }),
    })
end

return M
