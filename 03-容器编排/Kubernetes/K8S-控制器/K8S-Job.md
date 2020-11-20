# Job

## 特点

- 一次性执行任务，类似Linux中的job

- **应用场景：** 如离线数据处理，视频解码等业务

Kubernetes支持以下几种Job：

- 非并行Job：通常创建一个Pod直至其成功结束
- 固定结束次数的Job：设置.spec.completions，创建多个Pod，直到.spec.completions个Pod成功结束
- 带有工作队列的并行Job：设置.spec.Parallelism但不设置.spec.completions，当所有Pod结束并且至少一个成功时，Job就认为是成功

根据.spec.completions和.spec.Parallelism的设置，可以将Job划分为以下几种pattern：

![job-type](./_images/job-type.png)

## Job Controller

Job Controller负责根据Job Spec创建Pod，并持续监控Pod的状态，直至其成功结束。如果失败，则根据restartPolicy（只支持OnFailure和Never，不支持Always）决定是否创建新的Pod再次重试任务。
  
## 创建Job

**Job Spec格式：**

- spec.template格式同Pod
- RestartPolicy仅支持Never或OnFailure
- 单个Pod时，默认Pod成功运行后Job即结束
- .spec.completions标志Job结束需要成功运行的Pod个数，默认为1
- .spec.parallelism标志并行运行的Pod的个数，默认为1
- spec.activeDeadlineSeconds标志失败Pod的重试最大时间，超过这个时间不会继续重试

**示例：**

- 用job控制器类型创建资源，执行算圆周率的命令，保持后2000位，创建过程等同于在计算。当遇到异常时Never状态会重启，所以要设定次数

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

    ![job](_images/job.png)

- 固定结束次数的Job示例

    ``` yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
    name: busybox
    spec:
    completions: 3
    template:
        metadata:
        name: busybox
        spec:
        containers:
        - name: busybox
            image: busybox
            command: ["echo", "hello"]
        restartPolicy: Never
    ```
