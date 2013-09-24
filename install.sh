#!/bin/sh

installs='
755 slider          /etc/slider
755 slider.initd    /etc/init.d/slider
644 iface.hotplugd  /etc/hotplug.d/iface/88-slider
644 button.hotplugd /etc/hotplug.d/button/21-slider
'

execcmd()
{
  execcmd_before "$@"
  if [ -z "$DRYRUN" -o "$DRYRUN" = 0 ]; then
    "$@"
    execcmd_after $?
  fi
}

execcmdsh()
{
  execcmd_before "$@"
  if [ -z "$DRYRUN" -o "$DRYRUN" = 0 ]; then
    eval "$@"
    execcmd_after $?
  fi
}

execcmd_before()
{
  printf '#\033[1;33m %s  \033[m\n' "$*"
}

execcmd_after()
{
  [ "$1" = 0 ] && return 0
  printf '#\033[1;31m $? = '"$1"' \033[m\n'
  return "$1"
}



# Change current working dir.

execcmd_before cd "$(dirname "$0")"
cd "$(dirname "$0")"
execcmd pwd


# To run or not.

[ "$1" = go ] && export DRYRUN=0 || export DRYRUN=1


# Copy files.

execcmd mkdir -pm 755 /etc/init.d

echo "$installs" | while read mod from to check; do
  if [ -n "$from" ]; then
    if [ "$check" = check ]; then
      [ -f "$to" ] && continue
    fi

    execcmd cp -fP "$from" "$to"
    execcmd chmod "$mod" "$to"
  fi
done


# And we are done.

if [ "$1" = go ]; then
  execcmd_before Done.

else
  echo
  echo 'Dry-run done.'
  echo 'Please check the commands above.'
  echo "If everything is OK, run '$0 go' to make changes."

fi

