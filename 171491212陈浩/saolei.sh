#!/bin/bash
score=0
a="1 10 -10 -1"
b="-1 0 1"
c="0 1"
d="-1 0 1 -2 -3"
e="1 2 20 21 10 0 -10 -20 -23 -2 -1"
f="1 2 3 35 30 20 22 10 0 -10 -20 -25 -30 -35 -3 -2 -1"
g="1 4 6 9 10 15 20 25 30 -30 -24 -11 -10 -9 -8 -7"
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m" 

declare -a room

usage()
{
cat <<_EOF_
  
_EOF_
}
time_to_quit()
{
  printf '\n\n%s\n\n' "选择退出"
  exit 1
}
plough()
{
  r=0
  printf "\e[2J\e[H"
  printf '%s' "     a   b   c   d   e   f   g   h   i   j"
  printf '\n   %s\n' "-----------------------------------------"
  for row in $(seq 0 9); do
    printf '%d  ' "$row" 
    for col in $(seq 0 9); do
       ((r+=1))
       is_null_field $r
       printf '%s \e[33m%s\e[0m ' "|" "${room[$r]}"
    done
    printf '%s\n' "|" 
    printf '   %s\n' "-----------------------------------------"
  done
  printf '\n\n'
}
get_free_fields()
{
  free_fields=0
  for n in $(seq 1 ${#room[@]}); do
    if [[ "${room[$n]}" = "." ]]; then
      ((free_fields+=1))
    fi
  done
}
is_free_field()
{
  local f=$1
  local val=$2
  not_allowed=0
  if [[ "${room[$f]}" = "." ]]; then
    room[$f]=$val
    score=$((score+val))
  else
    not_allowed=1
  fi
}
is_null_field()
{
  local e=$1  
    if [[ -z "${room[$e]}" ]];then
      room[$r]="."
    fi
}
get_mines()
{
  m=$(shuf -e a b c d e f g X -n 1)
  if [[ "$m" != "X" ]]; then
    for limit in ${!m}; do
      field=$(shuf -i 0-5 -n 1)
      index=$((i+limit))
      is_free_field $index $field
    done
  elif [[ "$m" = "X" ]]; then
    g=0
    room[$i]=X
    for j in {42..49}; do
      out="游戏结束"
      k=${out:$g:1}
      room[$j]=${k^^}
      ((g+=1)) 
    done
  fi
}
get_coordinates()
{
  colm=${opt:0:1}
  ro=${opt:1:1}
  case $colm in
    a ) o=1;;
    b ) o=2;;
    c ) o=3;;
    d ) o=4;;
    e ) o=5;;
    f ) o=6;;
    g ) o=7;;
    h ) o=8;;
    i ) o=9;;
    j ) o=10;;
  esac
  i=$(((ro*10)+o))
  is_free_field $i $(shuf -i 0-5 -n 1)
  if [[ $not_allowed -eq 1 ]] || [[ ! "$colm" =~ [a-j] ]]; then
    printf "$RED \n%s: %s\n$NC" "警告" "不允许"
  else
    get_mines
    plough
    get_free_fields
    if [[ "$m" = "X" ]]; then
      printf "\n\n\t $RED%s: $NC %s %d\n" "游戏结束" "得分" "$score"
      exit 0
    elif [[ $free_fields -eq 0 ]]; then
      printf "\n\n\t $GREEN%s: %s $NC %d\n\n" "你赢了" "得分" "$score
      exit 0
    fi
  fi
}
# main
trap time_to_quit INT
printf "\e[2J\e[H"
usage
read -p "输入 Enter 继续"
plough
while true; do
  read -p "输入坐标： " opt
  get_coordinates
done