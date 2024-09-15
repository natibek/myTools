#! /usr/bin/env bash
# Script for increasing and decreasing the resolution of the embedded display

if [ "$#" -ne 1 ]; then
  exit 1
fi

eDP_resolutions=()
eDP_monitor=$(xrandr | awk '/connected/ && /eDP/ {print $1}')
IFS=$'\n'
eDP_section=false
idx=-1
for data in $(xrandr)
do 
  first_val=$(echo "$data" | awk -F' ' '{print $1}')
  if $eDP_section; then
    if [[ "$first_val" =~ ^[0-9]{3,4}x[0-9]{3,4}$ ]]; then
      eDP_resolutions+=("$first_val")
      ((idx++))

      if [[ "$data" == *"*"* ]]; then
        cur_res="$first_val"
        cur_res_idx=$idx
      fi
      
    else 
      break
    fi
  elif [ "$first_val" = "$eDP_monitor" ]; then
    eDP_section=true
  fi
done

case "$1" in 
  "-list")
    echo "${eDP_resolutions[@]}"
    ;;
  "-current")
    echo "$cur_res"
    ;;
  "-increase")
    new_idx=$((cur_res_idx - 1))
    if (( new_idx > 0 )); then
      xrandr --output "$eDP_monitor" --mode "${eDP_resolutions["$new_idx"]}"
    fi
    ;;
  "-decrease")
    new_idx=$((cur_res_idx + 1))
    if (( new_idx < "${#eDP_resolutions[@]}" )); then
      xrandr --output "$eDP_monitor" --mode "${eDP_resolutions["$new_idx"]}"
    fi
    ;;
esac
