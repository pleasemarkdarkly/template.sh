#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
#
# set -e
version="0.0.1"
this_script=`basename "$0"`
project="bash template"
#
#--------------------------------------------------------------------------------------------------

# http://www.skybert.net/bash/debugging-bash-scripts-on-the-command-line/
export PS4='# ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]}() - [${SHLVL},${BASH_SUBSHELL},$?] '

session=$(date +"%Y%m%d_%H%M_%S")
start=`date +%s`

UNAME=$(command -v uname)

prereqs=(
  git
)

backup_project () {
  log_warning "function: backup_project"
  mkdir -p ~/backup_projects
  sudo /bin/tar -czvf "~/backup_projects/${SESS}.`whoami`.${HOSTNAME}.${project}-${version}.tar.gz" ${pwd}
}

function pushover_install () {
  log_warning "function: pushover_install"
  if [[ ! -e "./pushover" ]]; then
    wget https://gist.github.com/pleasemarkdarkly/05cf0e99c39d176f15603d4a3870c67c/raw -O ./pushover
    chmod +x ./pushover
    cp -v ./pushover /usr/local/bin
    ./pushover "bootstrap installed successfully"
  fi
}

function verify_bash_debugger () {
 echo "function: verify_bash_debugger"
 if [[ ! -e ./bashdb ]]; then
   wget http://pretty.pleasemarkdarkly.com:8080/VUAvT/bashdb
 elif [[ ! -e ./header.sh ]]; then
   wget http://pretty.pleasemarkdarkly.com:8080/EbcOe/header.sh
 elif [[ ! -e ./functions.sh ]]; then
   wget http://pretty.pleasemarkdarkly.com:8080/15m20A/functions.sh
 else
   echo "use: bashdb $0 for step debugging"
 fi
}

function verify_log4bash () {
 echo "function: verify_log4bash"
 if [[ ! -e ./log4bash.sh ]]; then
  echo "update remote link to github"
  wget https://transfersh.pleasemarkdarkly.com/DPL6R/log4bash.sh
   cp -v log4bash.sh /bootstrap/log4bash.sh
 fi

 source ./log4bash.sh

 log "example log outputs"
 log "log output";
 log_info "log_info output";
 log_success "log_success output";
 log_warning "log_warning output";
 # log_error "log_error: error";
 # log_error "script: $template starting";
 log "end example log outputs"
 echo
}

function os_detect_install_prereqs () {
 log "function: os_detect_install_prereqs"
 case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
   linux*)
     log_info 'linux\n'
     if [ command -v bash 2>/dev/null ]; then
        log_info "prerequisites bash found"
     else
        log_info "installing prerequisites"
        install_apps
     fi
     ;;
   darwin*)
     log_info 'darwin\n'
     if [ command -v bash 2>/dev/null ]; then
        log_info "prerequisites rclone, wget found"
     else
        log_info "installing prerequisites"
        install_apps
     fi
     ;;
   msys*|cygwin*|mingw*)
     # or possible 'bash on windows'
     log_warning 'windows\n'
     return
     ;;
   nt|win*)
     log_warning 'windows\n'
     return
     ;;
   *)
     ;;
 esac
}

function install_apps () {
  log_warning "function: install_apps"
  for app in "${prereqs[@]}"
  do
    log_info "function: installing - $app"
    case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
      linux*)
        apt install -y $app
        apt --fix-broken install
        apt-get update -y; apt autoremove
        ;;
      darwin*)
        brew install $app & brew upgrade $app
        ;;
      *)
        ;;
    esac
  done
}

function main () {
  log_info "$project.$this.$version $session"

  # os_detect_install_prereqs

  cleanup
}

function cleanup () {
  log_warning "function: cleanup"
  find . -maxdepth 1 -mmin +2 -type f ./*.log -exec rm {} \;
}

verify_log4bash
verify_bash_debugger

main "[@]" | tee "./$session.log"

