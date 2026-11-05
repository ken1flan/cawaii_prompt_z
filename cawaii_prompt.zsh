# cawaii_prompt.zsh
# Source this file from ~/.zshrc:
#   source /path/to/cawaii_prompt.zsh

autoload -Uz add-zsh-hook

typeset -g CAWAII_PROMPT_STATUS_OK='%F{green}(≧∇≦)b OK%f'
typeset -g CAWAII_PROMPT_STATUS_WARN='%F{yellow}（;´▽｀A%f'
typeset -g CAWAII_PROMPT_STATUS_NG='%F{red}く(""0"")＞なんてこった!!%f'
typeset -g CAWAII_PROMPT_STATUS_BUG='%F{cyan}m(_ _)m promptのバグです%f'

cawaii_prompt_last_command_status() {
  local exit_code=$1
  (( exit_code == 0 )) || print -r -- "$CAWAII_PROMPT_STATUS_NG"
}

cawaii_prompt_git_status() {
  local -a statuses
  local git_state

  statuses=( ${(f)"$(command git status --porcelain 2>/dev/null | cut -c1-2 | tr -d ' ' | sort -u)"} )
  (( ${#statuses} == 0 )) && { print -r -- "$CAWAII_PROMPT_STATUS_OK"; return; }

  for git_state in $statuses; do
    [[ $git_state == *U* ]] && { print -r -- "$CAWAII_PROMPT_STATUS_NG"; return; }
  done
  for git_state in $statuses; do
    [[ $git_state == *[RMAD?]* ]] && { print -r -- "$CAWAII_PROMPT_STATUS_WARN"; return; }
  done
  print -r -- "$CAWAII_PROMPT_STATUS_BUG"
}

cawaii_prompt_precmd() {
  local last_command_status=$?
  local branch

  if ! command git rev-parse --is-inside-work-tree &>/dev/null; then
    if [[ -n ${CAWAII_PROMPT_OLD_PROMPT_SET-} ]]; then
      PROMPT=$CAWAII_PROMPT_OLD_PROMPT
      unset CAWAII_PROMPT_OLD_PROMPT CAWAII_PROMPT_OLD_PROMPT_SET
    fi
    return
  fi

  if [[ -z ${CAWAII_PROMPT_OLD_PROMPT_SET-} ]]; then
    typeset -g CAWAII_PROMPT_OLD_PROMPT=$PROMPT
    typeset -g CAWAII_PROMPT_OLD_PROMPT_SET=1
  fi

  branch=$(command git branch --show-current 2>/dev/null)
  [[ -n $branch ]] || branch='HEAD'
  PROMPT="$(cawaii_prompt_last_command_status "$last_command_status")%F{yellow}%~%f[%F{magenta}${branch}%f$(cawaii_prompt_git_status)]
%D{%H:%M} $ "
}

add-zsh-hook -d precmd cawaii_prompt_precmd 2>/dev/null
add-zsh-hook precmd cawaii_prompt_precmd
