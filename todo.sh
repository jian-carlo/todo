#!/usr/bin/env bash

TODO_FILE="$HOME/todo.txt"
(head -n 1 "$TODO_FILE" && tail -n +2 "$TODO_FILE" | sort) > "$TODO_FILE.tmp" && mv "$TODO_FILE.tmp" "$TODO_FILE"

MODE=""
ARG=$1

batify() {
    bat --plain --theme todo --language todo
}

case $ARG in
    "-a" | "--add" ) MODE="add" ;;
    "-aa" | "--add-all" ) MODE="add-all" ;;
    "-l" | "" | "--list" ) MODE="list" ;;
    "-la" | "--list-all" | "-al") MODE="list-all" ;;
    "-e" | "--edit" ) MODE="edit" ;;
    "-ee" | "--editor" | "--editor-edit" ) MODE="editor-edit" ;;
    [0-9]* ) MODE="complete" ;;
    "-d" | "-x" | "--delete" ) MODE="delete" ;;
    "-h" | "--help" ) MODE="help" ;;
    * )
        echo "argument is not supported see --help or -h";
        MODE=""
        echo "exit code 1"
        exit 1 ;;
esac

if [[ "$MODE" == "add" ]]
then
    echo
    # this just reads the ENTRY and the DUE
    # and appends it to the todofile

    read -p "    todo: " ENTRY
    if cmd="$(command -v pickdate)" && [ -x "$cmd" ]; then
        tput smcup
        DUE=$(pickdate -f yyyy-mm-dd | awk -F '-' '{print $2 "-" $3}')
        tput rmcup
        echo "     due: $DUE"
        echo
    else
        read -p "     due: " DUE
    fi
    PRIORITY="_"
    CATEGORY="_"
    echo "o    $DUE  $PRIORITY    $CATEGORY    $ENTRY" >> $TODO_FILE

elif [[ "$MODE" == "add-all" ]]
then
    echo
    # this reads ENTRY, DUE, PRIORITY, and CATEGORY
    # and appends it to the todofile

    read -p "    todo: " ENTRY
    if cmd="$(command -v pickdate)" && [ -x "$cmd" ]; then
        tput smcup
        DUE=$(pickdate -f yyyy-mm-dd | awk -F '-' '{print $2 "-" $3}')
        tput rmcup
        echo "     due: $DUE"
    else
        read -p "     due: " DUE
    fi
    read -p "priority: " PRIORITY
    read -p "category: " CATEGORY
    echo "o    $DUE  $PRIORITY    $CATEGORY    $ENTRY" >> $TODO_FILE

    echo
elif [[ "$MODE" == "list" ]]
then
    echo

    LISTOPT=$2

    IDS=()
    MAX=$(( $(awk 'END{print NR}' $TODO_FILE) - 1 ))
    index=0
    while [[ "$index" -le "$MAX" ]]; do
        if [[ index -eq 0 ]]; then
            IDS+=("ID") 
        else
            IDS+=("$index") 
        fi
        ((index++))
    done

    LIST=$(awk -v ids="$(printf "%s\n" "${IDS[@]}")" '
    BEGIN {
        n = split(ids, id, "\n")
        }
    NR <= n {
        printf "%-3s %s\n", id[NR], $0
    }' $TODO_FILE)

    case $LISTOPT in
        "-d" | "--date" )
            if cmd="$(command -v pickdate)" && [ -x "$cmd" ]; then
                tput smcup
                DUE=$(pickdate -f yyyy-mm-dd | awk -F '-' '{print $2 "-" $3}')
                tput rmcup
            else
                read -p "     due: " DUE
            fi
            echo "your todos for $DUE"
            echo
            FILTERED=$(echo -n "ID  " && head -n 1 "$TODO_FILE" &&
                echo "$LIST" | awk -v due="$DUE" '$3 == due')
            ;;
        [a-z] )
            echo "your todos for category $LISTOPT"
            echo
            FILTERED=$(echo -n "ID  " && head -n 1 "$TODO_FILE" &&
            echo "$LIST" | awk -v cat="$LISTOPT" '$5 == cat')
            ;;
        "" ) 
            FILTERED=$(echo "$LIST")
            ;;
        * )
            echo "error: argument not supported"
            exit 1 ;;
    esac

    ENTRY=$(echo "$FILTERED" | awk '{$1=$2=$3=$4=$5="";printf "%-s\n", $0}')
    TRIMMED=()
    for item in "${ENTRY[@]}"; do
        trimmed=$(echo "$item" | awk '{$1=$1; print}')
        TRIMMED+=("$trimmed")
    done

    F3FIELDS=$(awk -v filtered="$(printf "%s\n" "${FILTERED[@]}")" '
    BEGIN {
        m = split(filtered, fil, "\n")
        for (i = 1; i <= m; i++) {
            split(fil[i], fields)
            printf "%-3s %-4s %-6s\n", fields[1], fields[2], fields[3]
        }
    }')

    TO_PRINT="$(awk -v trimmed="$(printf "%s\n" "${TRIMMED[@]}")" \
        -v f3fields="$(printf "%s\n" "${F3FIELDS[@]}")" '
    BEGIN {
        split(trimmed, s1, "\n")
        split(f3fields, s2, "\n")
        for (i=1; i<=length(s1); i++) {
            printf "%-6s %s\n", s2[i], s1[i]
        }
    }')"
    echo "$TO_PRINT" | bat --plain --language todo-short --theme todo  || echo "$TO_PRINT"
    # echo "$FILTERED" | awk  '{print $1,$2,$3}'

    echo
elif [[ "$MODE" == "list-all" ]]; 
then
    # this should take all the ids on the $TODO_FILE and
    # prepend them into the echoed output of the file

    # if category is specified, list only todos in that
    # category
    echo

    LISTOPT=$2

    IDS=()
    MAX=$(( $(awk 'END{print NR}' $TODO_FILE) - 1 ))
    index=0
    while [[ "$index" -le "$MAX" ]]; do
        if [[ index -eq 0 ]]; then
            IDS+=("ID") 
        else
            IDS+=("$index") 
        fi
        ((index++))
    done

    LIST=$(awk -v ids="$(printf "%s\n" "${IDS[@]}")" '
    BEGIN {
        n = split(ids, id, "\n")
        }
    NR <= n {
        printf "%-3s %s\n", id[NR], $0
    }' $TODO_FILE)

    case $LISTOPT in
        "-d" | "--date" )
            if cmd="$(command -v pickdate)" && [ -x "$cmd" ]; then
                tput smcup
                DUE=$(pickdate -f yyyy-mm-dd | awk -F '-' '{print $2 "-" $3}')
                tput rmcup
            else
                read -p "     due: " DUE
            fi
            echo "your todos for $DUE"
            echo
            echo -n "ID  " && head -n 1 "$TODO_FILE" | bat --plain --language todo --theme todo 
            FILTERED="$(echo "$LIST" | awk -v due="$DUE" '$3 == due')"
            ;;
        [a-z] )
            echo "your todos for category $LISTOPT"
            echo
            echo -n "ID  " && head -n 1 "$TODO_FILE" | bat --plain --language todo --theme todo 
            FILTERED="$(echo "$LIST" | awk -v cat="$LISTOPT" '$5 == cat')"
            ;;
        "" ) 
            FILTERED="$(echo "$LIST")"
            ;;
        * )
            echo "error: argument not supported"
            exit 1 ;;

    esac
    echo "$FILTERED" | bat --plain --language todo --theme todo || echo "$FILTERED"
    echo
elif [[ "$MODE" == "edit" ]]; then
    echo
    # this reads the ID of the entry to be edited and
    # replaces it with new values,
    # a blank value becomes "_"

    if [[ "$#" -eq 1  ]]; then
        read -p "      id: " ID
        echo
    elif [[ "$#" -eq 2 ]]; then
        ID=$2
    elif [[ "$#" -ge 2 ]]; then
        ID=$2
        echo "warn: only second ID will be recognized"
    fi

    if [[ "$ID" =~ ^[0-9]+$ ]]; then
        ENTRY=$(awk -v id=$(( "$ID" + 1 )) 'NR == id { print $0 }' $TODO_FILE)
        awk 'NR == 1 {print $0}' $TODO_FILE
        echo "$ENTRY"
        echo
        mapfile -d " " COLUMNS <<< $ENTRY
         
        read -p "  x|o  STA: " STATUS
        read -p "MM-DD  DUE: " DUE
        read -p "A|B|C  PRI: " PRIORITY
        read -p "       CAT: " CATEGORY
        read -p "        DO: " TODO
        echo

        if [[ -z "$STATUS" ]]; then STATUS="_"
        fi
        if [[ -z "$DUE" ]]; then DUE="_    "
        fi
        if [[ -z "$PRIORITY" ]]; then PRIORITY="_"
        fi
        if [[ -z "$CATEGORY" ]]; then CATEGORY="_"
        fi
        if [[ -z "$TODO" ]]; then TODO="_"
        fi
        
        awk 'NR == 1 {print $0}' $TODO_FILE
        EDITED=$(echo "$STATUS    $DUE  $PRIORITY    $CATEGORY    $TODO")
        sed -i 's,'"$ENTRY"','"$EDITED"',g' $TODO_FILE

        echo "$EDITED   >>> to id #$ID"
    else
        echo "error: id is not a number"
        exit 1
    fi

    echo
elif [[ "$MODE" == "editor-edit" ]]; then
    # this opens $TODO_FILE with $EDITOR
    
    if [[ -z "$EDITOR" ]]; then
        nvim $TODO_FILE
    elif ! [[ -z "$EDITOR" ]]; then
        $EDITOR $TODO_FILE
    else
        "set \$EDITOR variable"
        exit 1
    fi
elif [[ "$MODE" == "complete" ]]; then
    echo

    ID=$(( "$1" + 1 ))

    CUR_STA=$(awk -v id="$ID" 'NR == id { print $1 }' $TODO_FILE)

    if [[ "$CUR_STA" == "o" ]]; then
        sed -i "${ID}s/^o/x/" $TODO_FILE
        printf "task $(( $ID - 1 )) completed\n"
    elif [[ "$CUR_STA" == "x" ]]; then
        sed -i "${ID}s/^x/o/" $TODO_FILE
        printf "task $(( $ID - 1 )) uncompleted\n"
    fi

    echo
elif [[ "$MODE" == "delete" ]]; then
    echo

    if [[ "$#" -eq 1  ]]; then
        read -p "      id: " ID
        echo
    elif [[ "$#" -eq 2 ]]; then
        ID=$(( "$2" + 1 ))
    elif [[ "$#" -ge 2 ]]; then
        ID=$(( "$2" + 1 ))
        echo "warn: only second ID will be recognized"
    fi

    if [[ "$ID" =~ ^[0-9]+$ ]]; then
        sed -i "${ID}d" $TODO_FILE
        printf "task "$2" deleted\n"
    else
        echo "error: ID must be a number"
        exit 1
    fi

    echo
elif [[ "$MODE" == "help" ]]; then
    echo

    echo "Usage:" 
    echo "   todo.sh [option] <argument>"
    echo 
    echo "Description:"
    echo "   This is a CLI todo list script"
    echo "   The data are stored in a .txt file specified by the"
    echo "   \$TODO_FILE variable." 
    echo 
    echo "Options:"
    echo "   -a, --add"
    echo "      Add a todo. The todo message and the due date"
    echo "      can be specified."
    echo
    echo "   -aa, --add-all"
    echo "      Similar to -a but the priority and the category"
    echo "      of the todo can be speicifed."
    echo
    echo "   -l, --list <category|none>"
    echo "      Lists the added todos, the script automatically"
    echo "      sorts the .txt file alphabetically. only displays"
    echo "      the todo id, status, due-date, and message. A"
    echo "      category can be specified to only list all todos"
    echo "      in that category"
    echo
    echo "   -la, --list-all <category|none>"
    echo "      Similar to -l, but lists the todo priority and"
    echo "      category"
    echo
    echo "   -e, --edit <id|none>"
    echo "      Edit a specified todo. A blank message deletes"
    echo "      the description."
    echo
    echo "   -ee, --editor, --editor-edit"
    echo "      Opens the \$TODO_FILE in the \$EDITOR environment"
    echo "      variable."
    echo
    echo "   <id>"
    echo "      Changes the status of the todo from 'o' to 'x' and"
    echo "      vice-versa"
    echo
    echo "   -d, -x, --delete <id|none>"
    echo "      Deletes the specified todo."
    echo
    echo "   -h, --help"
    echo "      Prints this help message."

    echo
fi
