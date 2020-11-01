# Job

## 特点

- 一次性执行任务，类似Linux中的job

- **应用场景：** 如离线数据处理，视频解码等业务
  
## 示例

用job控制器类型创建资源，执行算圆周率的命令，保持后2000位，创建过程等同于在计算。当遇到异常时Never状态会重启，所以要设定次数

    ``` yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
    name: pi
    spec:
    template:
        spec:
        containers:
        - name: pi
            image: perl
            # 命令是计算π的值
            command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
        restartPolicy: Never
    backoffLimit: 4
    ```
![job](images/job.png)

