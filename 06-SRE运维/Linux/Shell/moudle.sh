#!/bin/bash
delete() {
       rm -rf $de
}

copy() {
     cp -rf $sdir  $tdir
}

backup() {
       tar zcvf $tar_name  $tar_dir &>/dev/null
}

quit() {
       exit
}
