# zsh-autoenv script to add binstubs to PATH

local BIN_PATH="${0:a:h}/bin"
local NEW_PATH=":${PATH}:"
NEW_PATH=${NEW_PATH//":$BIN_PATH:"/:}
NEW_PATH=${NEW_PATH/#:/$BIN_PATH:}

export PATH=${NEW_PATH/%:/}
export rvm_silence_path_mismatch_check_flag=1
