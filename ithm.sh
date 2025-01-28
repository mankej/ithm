#INTELLIJ TERMINAL HISTORY MANAGER
if [ -n "$__INTELLIJ_COMMAND_HISTFILE__" ] && [ -n "$ITHM_PROJECT_ROOT" ]; then

    if [ -z "$ITHM_DISABLE_HISTORY_SETUP" ]; then
        shopt -s histappend

        PROMPT_COMMAND="history -n; history -a; history -w; $PROMPT_COMMAND"
    fi
    ITHM_UNIQ_STARTUP_ID=${GIO_LAUNCHED_DESKTOP_FILE_PID}
    ITHM_HISTORY_FILE_PATH=${ITHM_HISTORY_FILE_PATH:=$ITHM_PROJECT_ROOT/.idea/terminal/history/}
    ITHM_ID_FILE=$ITHM_HISTORY_FILE_PATH/ithm_startup
    ITHM_CLOSED_ID_FILE=$ITHM_HISTORY_FILE_PATH/ithm_closed
    touch $ITHM_ID_FILE
    touch $ITHM_CLOSED_ID_FILE
    ITHM_RESTORE_CLOSED=true
    ITHM_STARTUP_DATA=$(< $ITHM_ID_FILE)
    ITHM_LAST_CLOSED_ID=$(head -n 1 $ITHM_CLOSED_ID_FILE)
    ITHM_LOAD_ID=1;
    if [ -n "$ITHM_STARTUP_DATA" ]; then
    ITHM_LAST_UNIQ_STARTUP_ID=$(echo $ITHM_STARTUP_DATA | cut -d ':' -f 1)
    if [ "$ITHM_UNIQ_STARTUP_ID" = "$ITHM_LAST_UNIQ_STARTUP_ID" ]; then
      if [ -n "$ITHM_LAST_CLOSED_ID" ]; then
        ITHM_LOAD_ID=$ITHM_LAST_CLOSED_ID
      else
        ITHM_LOAD_ID=$(echo $ITHM_STARTUP_DATA | cut -d ':' -f 2)
        ITHM_LOAD_ID=$((ITHM_LOAD_ID+1))
      fi
    fi
    fi
    if [ -z "$ITHM_LAST_CLOSED_ID" ]; then
    echo "$ITHM_UNIQ_STARTUP_ID:$ITHM_LOAD_ID" > $ITHM_ID_FILE
    else
    sed -i '1d' $ITHM_CLOSED_ID_FILE
    fi
    trap "__ithm_catch_closed_id" EXIT
    ITHM_HISTORY_FILE_NAME="history$ITHM_LOAD_ID"
    if [ -n "$ITHM_USE_INTELLIJ_HISTFILE_NAME" ]; then
        ITHM_HISTORY_FILE_NAME=$(echo $__INTELLIJ_COMMAND_HISTFILE__ | grep -Eoh "([^/]+?)$" | rev | cut -d '-' -f 1 | rev)
    fi
    PROMPT_COMMAND="echo -n [$ITHM_HISTORY_FILE_NAME]; $PROMPT_COMMAND"
    INTELLIJ_ORIGINAL_PATH=$__INTELLIJ_COMMAND_HISTFILE__
    unset __INTELLIJ_COMMAND_HISTFILE__
    ITHM_GLOBAL_HISTORY_FILE=${ITHM_GLOBAL_HISTORY_FILE:=$HISTFILE}
    ITHM_DIRECTORY_BROWSER=${ITHM_DIRECTORY_BROWSER:=xdg-open}
    ITHM_FILE_EDITOR=${ITHM_FILE_EDITOR:=nano}
    ITHM_FILE_READER=${ITHM_FILE_READER:=less}
    ITHM_HISTORY_FILE="$ITHM_HISTORY_FILE_PATH$ITHM_HISTORY_FILE_NAME"
    alias ithm_current='echo $ITHM_HISTORY_FILE_NAME'
    alias ithm_directory='echo $ITHM_HISTORY_FILE_PATH'
    alias ithm_list="find $ITHM_HISTORY_FILE_PATH -maxdepth 1 -type f -and -not -name '$ITHM_HISTORY_FILE_NAME' -printf '%f\n'"
    if [ -n "$ITHM_BACKUP_ON_CLOSE" ]; then
        trap "ihm_backup" EXIT
    fi
    if [ -n "$ITHM_APPEND_SESSION_HISTORY_TO_GLOABL_ON_CLOSE" ]; then
        trap "$(builtin printf 'history -a %q' "$ITHM_GLOBAL_HISTORY_FILE")" EXIT
    fi
    if [ -n "$ITHM_APPEND_SESSION_HISTORY_TO_FILE_ON_CLOSE" ]; then
        trap "$(builtin printf 'history -a %q' "$ITHM_APPEND_SESSION_HISTORY_TO_FILE_ON_CLOSE")" EXIT
    fi
    if [ -n "$ITHM_SAVE_HISTORY_ON_CLOSE_AND_RESET_HISTFILE" ]; then
        trap "$(builtin printf 'history -w %q; HISTFILE=%q' "$ITHM_HISTORY_FILE_NAME" "$ITHM_GLOBAL_HISTORY_FILE")" EXIT
    fi
    ithm_set_seq(){
        echo "$ITHM_UNIQ_STARTUP_ID:$1" > $ITHM_ID_FILE
    }
    ithm_not_restore(){
        ITHM_RESTORE_CLOSED=false
    }
    __ithm_catch_closed_id(){
        if [ "$ITHM_RESTORE_CLOSED" = true ]; then
          echo "$ITHM_LOAD_ID" >> $ITHM_CLOSED_ID_FILE
        fi
    }
    ithm_clone() {
        if [ -n "$1" ] && [ -f "$ITHM_HISTORY_FILE_PATH$1" ] && [ "$1" != "$ITHM_HISTORY_FILE_NAME" ]; then
            while true; do
                read -p "clone $1 to $ITHM_HISTORY_FILE_NAME?" yn
                case $yn in
                y)
                    history -c
                    history -r "$ITHM_HISTORY_FILE_PATH$1"
                    history -w
                    echo "done"
                    break
                    ;;
                n)
                    break
                    ;;
                *)
                    echo "Answer 'y' or 'n'"
                    ;;
                esac
            done
        fi
    }
    ithm_import() {
        local ACTION=$1
        local FILE=$ITHM_HISTORY_FILE_PATH$1
        if [ "$ACTION" = "global" ]; then
            ACTION=$ITHM_GLOBAL_HISTORY_FILE
            FILE=$ITHM_GLOBAL_HISTORY_FILE
        fi
        if [ "$ACTION" = "intellij" ]; then
            ACTION=$INTELLIJ_ORIGINAL_PATH
            FILE=$INTELLIJ_ORIGINAL_PATH
        fi

        if [ -n "$1" ] && [ -f "$FILE" ] && [ "$1" != "$ITHM_HISTORY_FILE_NAME" ]; then
            while true; do
                read -p "append $ACTION to $ITHM_HISTORY_FILE_NAME?" yn
                case $yn in
                y)
                    history -n $FILE
                    history -w
                    echo "done"
                    break
                    ;;
                n)
                    break
                    ;;
                *)
                    echo "Answer 'y' or 'n'"
                    ;;
                esac
            done
        fi
    }
    ithm_export() {
        local ACTION=$1
        local FILE=$ITHM_HISTORY_FILE_PATH$1
        if [ "$ACTION" = "global" ]; then
            ACTION=$ITHM_GLOBAL_HISTORY_FILE
            FILE=$ITHM_GLOBAL_HISTORY_FILE
        fi

        if [ -n "$1" ] && [ -f "$FILE" ] && [ "$1" != "$ITHM_HISTORY_FILE_NAME" ]; then
            while true; do
                read -p "append $ITHM_HISTORY_FILE_NAME to $ACTION?" yn
                case $yn in
                y)
                    history -n $FILE
                    echo "done"
                    break
                    ;;
                n)
                    break
                    ;;
                *)
                    echo "Answer 'y' or 'n'"
                    ;;
                esac
            done
        fi
    }
    ithm_use() {
        if [ -n "$1" ] && [ -f "$ITHM_HISTORY_FILE_PATH$1" ] && [ "$1" != "$ITHM_HISTORY_FILE_NAME" ]; then
            while true; do
                read -p "copy $1 to $ITHM_HISTORY_FILE_NAME and remove?" yn
                case $yn in
                y)
                    history -c
                    history -r "$ITHM_HISTORY_FILE_PATH$1"
                    history -w
                    rm "$ITHM_HISTORY_FILE_PATH$1"
                    echo "done"
                    break
                    ;;
                n)
                    break
                    ;;
                *)
                    echo "Answer 'y' or 'n'"
                    ;;

                esac
            done
        fi
    }
    ithm_read() {
        if [ -z "$1" ]; then
            $ITHM_FILE_READER "$ITHM_HISTORY_FILE"
        fi
        if [ "$1" = "intellij" ]; then
            $ITHM_FILE_READER "$INTELLIJ_ORIGINAL_PATH"
        fi
        if [ -n "$1" ] && [ -f "$ITHM_HISTORY_FILE_PATH$1" ]; then
            $ITHM_FILE_READER "$ITHM_HISTORY_FILE_PATH$1"
        fi
    }
    ithm_edit() {
        if [ -z "$1" ]; then
            $ITHM_FILE_EDITOR "$ITHM_HISTORY_FILE"
            ithm_reload
        fi
        if [ -n "$1" ] && [ -f "$ITHM_HISTORY_FILE_PATH$1" ]; then
            $ITHM_FILE_EDITOR "$ITHM_HISTORY_FILE_PATH$1"
        fi
    }
    ithm_reload() {
        history -c
        history -r "$ITHM_HISTORY_FILE"
    }
    ithm_backup() {
        local FILE=$1
        if [ -z "$FILE" ]; then
            FILE="$ITHM_HISTORY_FILE_NAME"
        fi
        if [ -n "$FILE" ] && [ -f "$ITHM_HISTORY_FILE_PATH$FILE" ]; then
            local BACKUP_FOLDER="$ITHM_HISTORY_FILE_PATH${FILE}_backup/"
            local BACKUP_PATH="$BACKUP_FOLDER$(date +%Y%m%d%H%M%S)"
            [ -d "$BACKUP_FOLDER" ] || mkdir -p "$BACKUP_FOLDER"
            cp $ITHM_HISTORY_FILE_PATH$FILE $BACKUP_PATH
            echo "BACKUP CREATED: $BACKUP_PATH"
        fi
    }
    ithm_backup_list() {
        local FILE=$1
        if [ -z "$FILE" ]; then
            FILE="$ITHM_HISTORY_FILE_NAME"
        fi
        local BACKUP_FOLDER="$ITHM_HISTORY_FILE_PATH${FILE}_backup/"
        if [ -n "$FILE" ] && [ -d "$BACKUP_FOLDER" ]; then
            find $BACKUP_FOLDER -maxdepth 1 -type f -printf '%f\n' | sort -r
        fi
    }
    ithm_backup_read() {
        local FILE=$1
        local BACKUP_FILE=$2
        if [ -z "$FILE" ]; then
            FILE="$ITHM_HISTORY_FILE_NAME"
        fi
        local BACKUP_PATH="$ITHM_HISTORY_FILE_PATH${FILE}_backup/$BACKUP_FILE"
        if [ -f "$BACKUP_PATH" ]; then
            $ITHM_FILE_READER $BACKUP_PATH
        fi
    }
    ithm_backup_restore() {
        local FILE=$1
        local BACKUP_FILE=$2
        local BACKUP_PATH="$ITHM_HISTORY_FILE_PATH${FILE}_backup/$BACKUP_FILE"
        if [ -f "$BACKUP_PATH" ]; then
            cp $BACKUP_PATH "$ITHM_HISTORY_FILE_PATH${FILE}.$BACKUP_FILE"
        fi
    }
    ithm_open() {
        if [ -z "$1" ]; then
            nohup $ITHM_DIRECTORY_BROWSER "$ITHM_HISTORY_FILE_PATH" >/dev/null 2>&1
        fi
        if [ "$1" = "intellij" ]; then
            nohup $ITHM_DIRECTORY_BROWSER "$(echo $INTELLIJ_ORIGINAL_PATH | grep -Eoh "(^.*/)")" >/dev/null 2>&1
        fi
    }
    echo "CONSOLE $ITHM_HISTORY_FILE_NAME STARTED ITHM READY $([ ! -f "$ITHM_HISTORY_FILE" ] || echo "- history recovered")"
    HISTFILE="$ITHM_HISTORY_FILE"
    if [ -z "$ITHM_INITAL_USE_GLOBAL_HISTORY" ] && [ ! -f "$ITHM_HISTORY_FILE" ]; then
        CLEAN_HISTORY=1
    fi
    [ -d "$ITHM_HISTORY_FILE" ] || mkdir -p $ITHM_HISTORY_FILE_PATH
    [ -f "$ITHM_HISTORY_FILE" ] || touch $ITHM_HISTORY_FILE
    if [ -n "$CLEAN_HISTORY" ]; then
        history -c
        history -w
    fi
fi
