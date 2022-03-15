#!/bin/bash
shell=""
groups=""
user=""
home=""
exec 3>&1
dialog --separate-widget $'\n' --ok-label "Ok" \
          --backtitle "Linux User Managment" \
          --title "new" \
          --form "creating new " \
15 80 0 \
        "field1: "              1 1 "$user"             1 25 40 0 \
        "field2:"               2 1 "$shell"            2 25 40 0 \
        "field3:"               3 1 "$groups"           3 25 40 0 \
        "field4:"               4 1 "$home"             4 25 40 0 \

# aggiungi dimensione quota

2>&1 1>&3 | {
  read -r user
  read -r shell
  read -r groups
  read -r home

  echo $user
  echo $shell
  echo $groups
  echo $home

  #continue script here
}
exec 3>&-
