
# 配置文件
`EasySwoole` 框架提供了非常灵活自由的全局配置功能，配置文件采用 `PHP` 返回数组方式定义，对于一些简单的应用，无需修改任何配置，对于复杂的要求，还可以自行扩展自己独立的配置文件和进行动态配置。  
框架安装完成后系统默认的全局配置文件是项目根目录下的 `produce.php` 、 `dev.php` 文件，`3.7.x` 版本(最新版)支持在启动 `EasySwoole` 框架时以指定的配置文件( `dev.php` / `produce.php`)运行，详细启动命令请看 [基本管理命令章节](/QuickStart/command.html)。

配置文件内容如下:
```php
<?php

use EasySwoole\Log\LoggerInterface;

return [
    'SERVER_NAME' => "EasySwoole",
    'MAIN_SERVER' => [
        'LISTEN_ADDRESS' => '0.0.0.0',
        'PORT' => 9501,//监听端口
        'SERVER_TYPE' => EASYSWOOLE_WEB_SERVER, //可选为 EASYSWOOLE_SERVER  EASYSWOOLE_WEB_SERVER EASYSWOOLE_WEB_SOCKET_SERVER
        'SOCK_TYPE' => SWOOLE_TCP,
        'RUN_MODEL' => SWOOLE_PROCESS,
        //setting配置项可以看 https://wiki.swoole.com/zh-cn/#/server/setting
        'SETTING' => [
            'worker_num' => 8,//默认进程数
            'reload_async' => true,
            'max_wait_time' => 3,
            'enable_deadlock_check'=>false,
        ],
        'TASK' => [
            'workerNum' => 4,//异步任务进程数，注意，easyswoole的异步任务是自己实现的，和swoole的异步进程注意区分
            'maxRunningNum' => 128,
            'timeout' => 15
        ]
    ],
    "LOG" => [
        'dir' => null,
        'level' => LoggerInterface::LOG_LEVEL_DEBUG,
        'handler' => null,
        'logConsole' => true,
        'displayConsole' => true,
        'ignoreCategory' => []
    ],
    //临时目录
    'TEMP_DIR' => null
];

```

上述参数补充说明：
- MAIN_SERVER.SERVER_TYPE: 
    - EASYSWOOLE_WEB_SERVER: 表示框架主服务为 `Http` 服务(框架默认提供的服务类型)
    - EASYSWOOLE_SERVER: 表示框架主服务为 `Tcp` 服务
    - EASYSWOOLE_WEB_SOCKET_SERVER: 表示框架主服务为 `WebSocket` 服务

::: warning 
  EASYSWOOLE_SERVER、EASYSWOOLE_WEB_SOCKET_SERVER类型，都需要在 `EasySwooleEvent.php` 的 `mainServerCreate` 事件中自行设置回调( `receive` 或 `message` )，否则将出错。具体设置对应的回调的方式请参考 [Tcp 服务章节](/Socket/tcp.md) 和 [WebSocket 服务章节](/Socket/webSocket.md)。关于同时支持多个服务的使用也请查看 [Tcp 服务章节](/Socket/tcp.md) 和 [WebSocket 服务章节](/Socket/webSocket.md)。
:::


## 配置操作类
配置操作类为 `\EasySwoole\EasySwoole\Config` 类，使用方式非常简单，具体请看下面的代码示例，操作类还提供了 `load` 方法重载全部配置，基于这个方法，可以自己定制更多的高级操作。

::: warning 
  设置和获取配置项都支持点语法分隔，具体请看下面获取配置的代码示例
:::

```php
<?php

//获取配置实例
$instance = \EasySwoole\EasySwoole\Config::getInstance();

// 获取配置 按层级用点号分隔
$instance->getConf('MAIN_SERVER.SETTING.task_worker_num');

// 设置配置 按层级用点号分隔
$instance->setConf('DATABASE.host', 'localhost');

// 获取全部配置
$conf = $instance->getConf();

// 用一个数组覆盖当前配置项
$conf['DATABASE'] = [
    'host' => '127.0.0.1',
    'port' => 13306
];
$instance->load($conf);
```

::: warning 
  需要注意的是 `由于进程隔离的原因`，在 `Server` 启动后，动态新增修改的配置项，只对执行操作的进程生效，如果需要全局共享配置需要自己进行扩展
:::

## 添加用户配置项

每个用户都有自己的配置项，添加自己的配置项非常简单，其中一种方法是直接在配置文件中添加即可，如下面的例子:
下面示例中添加了自定义的 `MySQL` 和 `Redis` 配置。

```php
<?php
return [
    'SERVER_NAME' => "EasySwoole",
    'MAIN_SERVER' => [
        'LISTEN_ADDRESS' => '0.0.0.0',
        'PORT' => 9501,
        'SERVER_TYPE' => EASYSWOOLE_WEB_SERVER, // 可选为 EASYSWOOLE_SERVER  EASYSWOOLE_WEB_SERVER EASYSWOOLE_WEB_SOCKET_SERVER
        'SOCK_TYPE' => SWOOLE_TCP,
        'RUN_MODEL' => SWOOLE_PROCESS,
        'SETTING' => [
            'worker_num' => 8,
            'reload_async' => true,
            'max_wait_time'=>3,
            'document_root'            => EASYSWOOLE_ROOT . '/Static',
            'enable_static_handler'    => true,
        ],
        'TASK'=>[
            'workerNum'=>0,
            'maxRunningNum'=>128,
            'timeout'=>15
        ]
    ],
    'TEMP_DIR' => null,
    'LOG_DIR' => null,
    
    
    // 添加 MySQL 及对应的连接池配置
    /*################ MYSQL CONFIG ##################*/
    'MYSQL' => [
        'host'          => '127.0.0.1', // 数据库地址
        'port'          => 3306, // 数据库端口
        'user'          => 'root', // 数据库用户名
        'password'      => 'root', // 数据库用户密码
        'timeout'       => 45, // 数据库连接超时时间
        'charset'       => 'utf8', // 数据库字符编码
        'database'      => 'easyswoole', // 数据库名
       
    ],

    // 添加 Redis 及对应的连接池配置
    /*################ REDIS CONFIG ##################*/
    'REDIS' => [
        'host'          => '127.0.0.1', // Redis 地址
        'port'          => '6379', // Redis 端口
        'auth'          => 'easyswoole', // Redis 密码
        'timeout'       => 3.0, // Redis 操作超时时间
        'reconnectTimes' => 3, // Redis 自动重连次数
        'db'            => 0, // Redis 库
     
    ],
];
```

## 生产与开发配置分离
在 `php easyswoole.php server start` 命令下，默认为开发模式，加载 `dev.php` 

运行 `php easyswoole.php server start -mode=produce` 命令时，为生产模式，加载 `produce.php` 
