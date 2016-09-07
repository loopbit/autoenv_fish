#!/usr/bin/env bash

set AUTOENV_AUTH_FILE ~/.autoenv_authorized
if [ -z "$AUTOENV_ENV_FILENAME" ]
    set AUTOENV_ENV_FILENAME ".env"
end

function autoenv_init
  set defIFS $IFS
  set IFS (echo -en "\n\b")

  set target $argv[1]
  set home (dirname $HOME)
  set current_dir $PWD

  while [ $PWD != "/" -a $PWD != "$home" ]
    set file "$PWD/$AUTOENV_ENV_FILENAME"
    if [ -e $file ]
      set files $files $file
    end
    builtin cd .. >/dev/null 2>&1
  end
  builtin cd $current_dir

  set numerator (count $files)
  if [ $numerator -gt 0 ]
    for x in (seq $numerator)
      set envfile $files[$x]
      autoenv_check_authz_and_run "$envfile"
    end
  end

  set IFS $defIFS
end

function autoenv_run
  set file "(realpath "$argv[1]")"
  autoenv_check_authz_and_run "$file"
end

function autoenv_env
  builtin echo "autoenv:" "$argv[1]"
end

function autoenv_printf
  builtin printf "autoenv: "
  builtin printf "$argv[1]"
end

function autoenv_indent
  cat -e $argv[1] | sed 's/.*/autoenv:     &/'
end

function autoenv_hashline
  # typeset envfile hash
  set envfile $argv[1]
  set hash (shasum "$envfile" | cut -d' ' -f 1)
  echo "$envfile:$hash"
end

function autoenv_check_authz
  # typeset envfile hash
  set envfile $argv[1]
  set hash (autoenv_hashline "$envfile")
  touch $AUTOENV_AUTH_FILE
  grep -Gq "$hash" $AUTOENV_AUTH_FILE
end

function autoenv_check_authz_and_run
  # typeset envfile
  set envfile $argv[1]
  if autoenv_check_authz "$envfile"
    autoenv_source "$envfile"
    return 0
  end
  if [ -z $MC_SID ] #make sure mc is not running
    autoenv_env
    autoenv_env "WARNING:"
    autoenv_env "This is the first time you are about to source $envfile":
    autoenv_env
    autoenv_env "    --- (begin contents) ---------------------------------------"
    autoenv_indent "$envfile"
    autoenv_env "    --- (end contents) -----------------------------------------"
    autoenv_env
    autoenv_printf "Are you sure you want to allow this? (y/N) "
    read answer
    if [ $answer = "y" -o $answer = "Y" ]
      autoenv_authorize_env "$envfile"
      autoenv_source "$envfile"
    end
  end
end

function autoenv_deauthorize_env
  #typeset envfile
  set envfile $argv[1]
  cp "$AUTOENV_AUTH_FILE" "$AUTOENV_AUTH_FILE.tmp"
  grep -Gv "$envfile:" "$AUTOENV_AUTH_FILE.tmp" > $AUTOENV_AUTH_FILE
end

function autoenv_authorize_env
  #typeset envfile
  set envfile $argv[1]
  autoenv_deauthorize_env "$envfile"
  autoenv_hashline "$envfile" >> $AUTOENV_AUTH_FILE
end

function autoenv_source
  #TODO: Why are global vars not being passed to sourced script?
  set -g AUTOENV_CUR_FILE $argv[1]
  set -g AUTOENV_CUR_DIR (dirname $argv[1])
  source "$argv[1]"
  #set -e AUTOENV_CUR_FILE
  #set -e AUTOENV_CUR_DIR
end

function autoenv_cd
  if builtin cd "$argv"
    autoenv_init
    return 0
  else
    return $status
  end
end

function enable_autoenv
    function cd
        autoenv_cd "$argv"
    end

    cd .
end

# probe to see if we have access to a shasum command, otherwise disable autoenv
if which gsha1sum 2>/dev/null >&2
    function autoenv_shasum
        gsha1sum "$argv"
    end
    enable_autoenv
else if which sha1sum 2>/dev/null >&2
    function autoenv_shasum
        sha1sum "$argv"
    end
    enable_autoenv
else if which shasum 2>/dev/null >&2
    function autoenv_shasum
        shasum "$argv"
    end
    enable_autoenv
else
    echo "Autoenv cannot locate a compatible shasum binary; not enabling"
end
