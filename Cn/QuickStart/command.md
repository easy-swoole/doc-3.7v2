# 基本管理命令


## 服务管理

`EasySwoole` 框架主命令。

可执行 `php easyswoole.php server` 来查看具体操作,执行结果如下：
```shell
Easyswoole server
Usage:
  easyswoole.php server ACTION [--opts ...]
Actions:
  start    start-up
  stop     stop it
  reload   reload worker process
  restart  restart EasySwoole server
  status   view EasySwoole status
Options:
  -d         start as a daemon
  -force     stop by force
  -mode=dev  run mode,dev is default mode

```

**服务启动**

> php easyswoole.php server start

**守护进程方式启动**

> php easyswoole.php server start -d

**指定配置文件启动服务**

默认为 `dev`，即 `-mode` 参数默认为 `dev`，即默认以项目根目录的 `dev.php` 作为框架运行的配置文件。

指定以项目根目录的 `produce.php` 作为框架运行的配置文件，请运行如下命令：

`-d` 可选参数：守护进程

> php easyswoole.php server start -mode=produce

**停止服务**

> php easyswoole.php server stop

**强制停止服务**

> php easyswoole.php server stop -force

**热重启**

仅会重启 `worker` 进程

> php easyswoole.php server reload

**服务状态**

> php easyswoole.php server status

## 进程管理

`EasySwoole` 内置对于 `Process` 的命令行操作，方便开发者友好地去管理 `Process`。

可执行 `php easyswoole.php process` 来查看具体操作,执行结果如下。
```shell
Process manager
Usage:
  easyswoole.php process ACTION [--opts ...]
Actions:
  kill  kill process
  show  show all process information
Options:
  --pid=PID           kill the specified pid
  --group=GROUP_NAME  kill the specified process group
  -f                  force kill process
```

**显示所有进程**

> php easyswoole.php process show


**杀死指定进程(PID)**

> php easyswoole.php process kill --pid=PID

**杀死指定进程组(GROUP)**

> php easyswoole.php process kill --group=GROUP_NAME

**强制杀死进程**

需要带上 `-f` 参数，例如：

> php easyswoole.php process kill --pid=PID -f


## Crontab 管理

`EasySwoole` 内置对于 `Crontab` 的命令行操作，方便开发者友好地去管理 `Crontab`。

可执行 `php easyswoole.php crontab` 来查看具体操作,执行结果如下。
```shell
Crontab manager
Usage:
  easyswoole.php crontab ACTION [--opts ...]
Actions:
  show    show all crontab
  stop    stops the specified crontab
  resume  restores the specified crontab
  run     run the specified crontab once immediately
  reset   rewrite scheduled task rules
Options:
  --taskName=TASK_NAME  the task name to be operated on
  --taskRule=TASK_RULE  the task crontab rule

```

**查看所有注册的 Crontab**

> php easyswoole.php crontab show

**停止指定的 Crontab**

> php easyswoole.php crontab stop --taskName=TASK_NAME

**恢复指定的 Crontab**

> php easyswoole.php crontab resume --taskName=TASK_NAME

**立即跑一次指定的 Crontab**

> php easyswoole.php crontab run --taskName=TASK_NAME


**重置定时规则 Crontab**

> php easyswoole.php crontab reset --taskName=TASK_NAME --taskRule=TASK_RULE
