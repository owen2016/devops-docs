# NPM

https://stackoverflow.com/questions/18130164/nodejs-vs-node-on-ubuntu-12-04
安装
    Node 8.12.0
    Npm 6.4.1


１）https://blog.csdn.net/u014361775/article/details/78865582

    sudo apt-get install nodejs
    sudo apt install nodejs-legacy
    sudo apt install npm

    全局安装n管理器(用于管理nodejs版本)
        sudo npm install n -g

２）https://www.cnblogs.com/zhuchenglin/p/7498307.html（升级）

    前提：安装了"全局安装n管理器(用于管理nodejs版本)"

    1.查看nodejs 版本
        sudo n ls

        使用版本号安装
            sudo n 8.12.0

    2.查看npm 版本
        npm -v

        使用版本号安装,升级npm为最新/指定版本
            sudo npm install npm@latest -g
            或
            sudo npm install npm@6.4.1 -g

３）https://www.cnblogs.com/youcong/p/10326243.html（卸载）

    #apt-get 卸载
    sudo apt-get remove --purge npm
    sudo apt-get remove --purge nodejs
    sudo apt-get remove --purge nodejs-legacy
    sudo apt-get autoremove

    #手动删除 npm 相关目录
    rm -r /usr/local/bin/npm
    rm -r /usr/local/lib/node-moudels
    find / -name npm
    rm -r /tmp/npm* 


备注：
    n是一个Node工具包，它提供了几个升级命令参数：

    n 显示已安装的Node版本
    n latest 安装最新版本Node
    n stable 安装最新稳定版Node
    n lts 安装最新长期维护版(lts)Node
    n version 根据提供的版本号安装Node


***建议安装顺序***：
    １．先安装npm
    ２．升级npm到指定版本
    ３．用"全局安装n管理器(用于管理nodejs版本)"安装指定版本node


    sudo apt install npm
    sudo apt install nodejs-legacy
    sudo npm install n -g
    sudo npm install npm@6.4.1 -g
    sudo n 8.12.0

    删除nodejs
        sudo apt-get remove nodejs

错误提示：
    １）：包npm和node版本不兼容，不是安装错误
        eddychen@eddychen-VirtualBox:~/vwork-frontend$ npm -v
        /usr/local/lib/node_modules/npm/bin/npm-cli.js:85
              let notifier = require('update-notifier')({pkg})
              ^^^

        SyntaxError: Block-scoped declarations (let, const, function, class) not yet supported outside strict mode
            at exports.runInThisContext (vm.js:53:16)
            at Module._compile (module.js:374:25)
            at Object.Module._extensions..js (module.js:417:10)
            at Module.load (module.js:344:32)
            at Function.Module._load (module.js:301:12)
            at Function.Module.runMain (module.js:442:10)
            at startup (node.js:136:18)
            at node.js:966:3

    2）：执行npm -v报错（https://www.cnblogs.com/jwentest/p/8259770.html）
        /usr/bin/env: 'node': No such file or directory

        原因：
            推测！！因为npm执行的时候默认是使用/usr/bin/node去执行的，但我本地是没有/usr/bin/node的，所以需要创建一个
            所以需要创建一个软连接将自己的node的执行文件指到/usr/bin/node上，于是修改如下：

        解决：
            ln -s /usr/bin/nodejs /usr/bin/node