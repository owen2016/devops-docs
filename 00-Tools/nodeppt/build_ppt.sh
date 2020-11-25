#!/bin/bash

function read_dir() {   
    for file in $(ls $1); do
        if [ -d $1"/"$file ]; then
            read_dir $1"/"$file
        else
            newfile=$1"/"$file
            if [ "${newfile#*.}" = "md" ]; then
                echo "### COMMING IN: $1 ###"
                echo "nodeppt build $newfile -d "$1/dist" "
                mkdir -p "$1/dist"
                nodeppt build $newfile -d "$1/dist"
            else
                echo "Skiping non-md file:$1"/"$file" #在此处处理文件即可
            fi
        fi
    done
}

read_dir Share/nodeppt

