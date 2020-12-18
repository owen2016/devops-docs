#!/bin/bash
# source ./moudle.sh    #调用 moudle.sh 脚本中的函数
while true 
do
cat <<EOF
*******************************
    The following is optional
*******************************
        1) Copy
        2) Delete
        3) Backup
        4) Exit
*******************************
EOF

read -p "please enter your chioce:" option
case $option in
   1)
      read -p "Please input the file you want to copy:" sdir
      read -p "Please input the directory you want to copy:" tdir
      copy
     ;;
   2)
      read -p "Please input your target file:" de
      delete
     ;;
   3)
      read -p  "Please input the backupfile name:" tar_name
      read -p  "Please input the file you want to backup:" tar_dir
      backup                  /注意上面这些变量都要和引用函数脚本的变量一致。
     ;;
   4)
      quit;break
     ;;
   *)
      echo "option is inviald."
   esac