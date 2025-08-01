local todo = require("todo")
todo.setup()
vim.keymap.set("n", "<leader>t", function() todo.open_float() end)
