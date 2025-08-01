# Todo

![](demo-todo.gif)

A poorly programmed todo list manager. 

The todos are stored in the variable `TODO_FILE` inside the script, the default
value for which is `~/todo.txt`. You can add syntax highlighting (with `bat`)
and text editor integration if you like. [Pickdate] is used as the date picker
for due dates, although you can opt not to use it and the script will still
run.

## Installation

There is no installation just copy the contents of the `todo.sh` script into
your own system. 

## Why I did this

I want to learn bash scripting and programming in general so I did this
project. This project is inspired by other CLI todo managers like
[taskwarrior][2] and [todo.txt][3].

## Usage

The contents of the `TODO_FILE` must have the headings as found in the
`todo.txt` file in this repo. The *status* column is either `o` or `x` which
signifies incomplete and complete respectively. The due column is of the format
"MM-YY". The *priority* column takes in the values A, B, C; (more if you want)
this is for manipulation of the sort i.e., the todo with the A priority is at
the top. The *category* column takes in a lowercase alphabet and is supposed to
be the shorthand of the category that is associated with the todo. (r for
research)

> todo.sh [option] \<argument\>

**Options:**

> `-a, --add `

Add a todo. The todo message and the due date can be specified.

> `-aa, --add-all`

Similar to -a but the priority and the category of the todo can be speicifed.

> `-l, --list <category|none>`

Lists the added todos, the script automatically sorts the .txt file
alphabetically. only displays the todo id, status, due-date, and message. A
category can be specified to only list all todos in that category

> `-la, --list-all <category|none>`

Similar to -l, but lists the todo priority and category

> `-e, --edit <id|none>`

Edit a specified todo. A blank message deletes the description.

> `-ee, --editor, --editor-edit`

Opens the `TODO_FILE` in the `EDITOR` environment variable.

> `<id>`

Changes the status of the todo from 'o' to 'x' and vice-versa

> `-d, -x, --delete <id|none>`

Deletes the specified todo.

> `-h, --help`

Prints a help message.

[1]: https://github.com/maraloon/pickdate
[2]: https://github.com/GothenburgBitFactory/taskwarrior
[3]: https://github.com/todotxt/todo.txt-cli
