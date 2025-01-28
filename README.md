# ITHM
**ITHM** stands for **IntelliJ's Terminal History Manager** and was created as workaround for the lack of native 
support for terminal history management per project in JetBrains IDE, which often leads to loss or mixing after 
every major update.
More information can be found here:
https://youtrack.jetbrains.com/issue/IDEA-118659/project-specific-terminal-history

I'm using it in PHPStorm/Ubuntu/Bash on a daily basis and haven't tested it with any other IDEs yet, but since it 
depends on the global IntelliJ flow, it should work in any JetBrains IDE.

## Install

#### METHOD 1
copy `ithm.sh` to the home directory

in `~/.bashrc` add the following line
``` 
source ./ithm.sh
```
#### METHOD 2
copy and paste contents of ithm.sh file in `~/.bashrc`

## Configuration

> History config
> by default, ITHM sets up history options like that:
```
shopt -s histappend

PROMPT_COMMAND="history -n; history -a; history -w; $PROMPT_COMMAND"
```
> If you want to disable it, set the ITHM_DISABLE_HISTORY_SETUP environment variable to 1 in terminal settings.

To start working, ITHM needs one environment variable ITHM_PROJECT_ROOT set to the project root.
To set it up, follow these steps:

> file -> settings -> tools -> terminal -> environment variables -> 
> click list icon on input or click input and shift + enter -> click + icon(add) 

> ITHM_PROJECT_ROOT = `$PROJECT_DIR$` - special IntelliJ's variable pointing to project root

> after setting env you need to restart IDE or only new terminals will start with enabled ITHM.

Since IntelliJ made changes to the naming of history files, using this script has sometimes been 'hard,' especially when running multiple instances simultaneously. 
Now, the history file name in IntelliJ can be a 'randomly' generated number instead of being sequentially generated. 
Additionally, the history file is no longer permanently linked to the console tab. 
Instead, each console initialization generates a new file name. 
I tested several options to address the problem and settled on a solution that feels best, though it’s not perfect.

I added a shared file sequence generation mechanism, which allows history files to be loaded in a more predictable way. 
Additionally, to address accidental tab closures, there is now a mechanism to save the ID of the last closed tab, so it will be restored upon reopening.
To 'permanently' close a tab (without saving its ID), you must call ithm_not_restore in the desired console. 
You can also override the sequence using ithm_set_seq [NUMBER].
To use this script in the old way, relying on IntelliJ's history file name generation, define the environment variable `ITHM_USE_INTELLIJ_HISTFILE_NAME=1`.

## OTHER CONFIG ENVS
#### ITHM_GLOBAL_HISTORY_FILE
allows defining global history file(one you use outside the IDE) to use in functions like `ithm_import`/`ithm_export` which lets you merge history files
> **default:** ITHM_GLOBAL_HISTORY_FILE:=$HISTFILE
#### ITHM_DIRECTORY_BROWSER
sets the command to open directories
> **default**: xdg-open
#### ITHM_FILE_EDITOR=nano
sets the command to edit files
> **default**: nano
#### ITHM_FILE_READER
sets the command to read files
> **default**: less
#### ITHM_HISTORY_FILE_PATH
The path where history files should be stored. For example, you can use it to set config per IDE.
> **default**:  ITHM_PROJECT_ROOT/.idea/terminal/history/


### ITHM_INITAL_USE_GLOBAL_HISTORY
setting to 1 causes the terminal to start with the global history. Don't set if you want to have an empty history in new terminal.
> **default**: disabled
#### ITHM_BACKUP_ON_CLOSE
setting to 1 enables backup creation when the terminal is closed
> **default**: disabled
#### ITHM_APPEND_SESSION_HISTORY_TO_GLOABL_ON_CLOSE
setting to 1 enables appending current IDE session history to global file defined in `ITHM_GLOBAL_HISTORY_FILE`  when the terminal is closed
> **default**: disabled
#### ITHM_APPEND_SESSION_HISTORY_TO_FILE_ON_CLOSE
setting to file path enables appending current IDE session history to this file when the terminal is closed
> **default**: disabled
#### ITHM_SAVE_HISTORY_ON_CLOSE_AND_RESET_HISTFILE
setting to 1 enables saving history and restoring `HISTFILE` to value from `ITHM_GLOBAL_HISTORY_FILE`
> **default**: disabled
> 
#### ITHM_USE_INTELLIJ_HISTFILE_NAME
setting to 1 makes the script rely on IntelliJ's history file name generation.
> **default**: disabled

## IN TERMINAL FUNCTIONS
#### ithm_current
shows current history file name
#### ithm_directory
shows current director path where history files are stored
#### ithm_list
shows all available history files in current project
#### ithm_use $CURRENT_PROJECT_HISTORY_FILE_NAME
allows you to use other history file chosen from available files in current project. Content of source file is copied to target file and source is deleted.
Useful when accidentally close terminal and want to restore previous history.
#### ithm_clone $CURRENT_PROJECT_HISTORY_FILE_NAME
like `ithm_use` allows to use other history file contents from current project but after copy source file is not deleted. 
useful when you want init terminal with history from other terminal.
#### ithm_import $FILE=global/intellij/file_path
like `ithm_clone` but allow any file contents to be appended not only from current project. 
You can use "global" keyword to append global history or "intellij" to append native history file. Keyword "intellij" is especially useful when you start using ITHM in project with existing terminal history. 
#### ithm_export $FILE=global/file_path
allow to append current terminal history to any file. You can use "global" keyword to append to global history file.
#### ithm_read $CURRENT_PROJECT_HISTORY_FILE_NAME(optional)=intellij/file_path
allow to read current project history file contents using reader command set in `ITHM_FILE_READER`. Not setting arg = use current file.
You can use "intellij" keyword to read native history file.
#### ithm_edit $CURRENT_PROJECT_HISTORY_FILE_NAME(optional)
allow to edit current project history file using editor command set in `ITHM_FILE_EDITOR`. Not setting arg = use current file.
#### ithm_reload
clear current history and reload current history file.
#### ithm_backup $CURRENT_PROJECT_HISTORY_FILE_NAME(optional)
creates backup for current project history file. Not setting arg = use current file.
#### ithm_backup_list $CURRENT_PROJECT_HISTORY_FILE_NAME(optional)
lists all backups for current project history file. Not setting arg = use current file.
#### ithm_backup_read $CURRENT_PROJECT_HISTORY_FILE_NAME(optional)
`ithm_read` but for backup files. Not setting arg = use current file.
#### ithm_backup_restore $CURRENT_PROJECT_HISTORY_FILE_NAME $BACKUP_FILE
restore current project history file from chosen backup file.
#### ithm_open $DEST=intellij(optional)
opens directory where current history file is stored using command set in `ITHM_DIRECTORY_BROWSER`.
You can use "intellij" keyword to open directory where native history files are stored.
#### ithm_set_seq $NUMBER
overrides the current sequence state with the given number, useful if you want to reset your console tabs.
#### ithm_not_restore
stops the restore mechanism, allowing the current console to be 'permanently' closed.
