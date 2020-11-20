#！/usr/bin/env bash
echo "WorkDir:$PWD"
PIDS=$(ps -ef | grep docsify | grep -v grep | awk '{print $2}')
if [ "$PIDS" != "" ]; then
    echo "docsify is runing!"
else
    echo "starting docsify!"
    nohup docsify serve . --port 3333 >/dev/null 2>&1 &
fi
