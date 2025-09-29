# 如何处理静态资源
### 使用nginx代理
```
server {
    //静态文件目录
    root /data/wwwroot/;
    server_name local.swoole.com;
    location / {
        proxy_http_version 1.1;
        proxy_set_header Connection "keep-alive";
        proxy_set_header X-Real-IP $remote_addr;
        if (!-f $request_filename) {
             proxy_pass http://127.0.0.1:9501;
        }
    }
}
```

### 使用swoole静态处理器


修改配置文件的 `dev.php` 或者 `produce.php`，实现 `Swoole` 对静态文件进行处理。

```php
<?php

return [
    // ...... 这里省略
    'MAIN_SERVER' => [
        // ...... 这里省略
        'SETTING' => [
            // ...... 这里省略
            
            # 设置处理 Swoole 静态文件
            'document_root' => EASYSWOOLE_ROOT . '/Static/',
            'enable_static_handler' => true,
        ],
        // ...... 这里省略
    ],
    // ...... 这里省略
];
```

> 上述配置是假设你的项目根目录有个 Static 目录是用来放置静态文件的。具体的使用可查看 [https://wiki.swoole.com/#/http_server?id=document_root](https://wiki.swoole.com/#/http_server?id=document_root)

# 如何允许跨域请求

### 全局允许跨域
在项目根目录的EasySwooleEvent.php的任意事件中，注入如下代码：
```php

use EasySwoole\Component\Di;
use EasySwoole\Http\Message\Status;
use EasySwoole\Http\Request;
use EasySwoole\Http\Response;


Di::getInstance()->set(SysConst::HTTP_GLOBAL_ON_REQUEST, function (Request $request, Response $response) {
    $origin = $request->getHeader('origin')[0] ?? '*';
    $response->withHeader('Access-Control-Allow-Origin', $origin);
    $response->withHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS，FILE');
    $response->withHeader('Access-Control-Allow-Methods', '*');
    $response->withHeader('Access-Control-Allow-Credentials', 'true');
    $response->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, token');
    if ($request->getMethod() === 'OPTIONS') {
        $response->withStatus(Status::CODE_OK);
        //表示不在执行后续控制器解析
        return false;
    }
    return true;
});
```

### 部分控制器允许

在控制器的onRequest事件中，写入如下代码：
```php

use EasySwoole\Http\Message\Status;
use EasySwoole\Http\Request;
use EasySwoole\Http\Response;


$request = $this->request();
$response = $this->response();
$origin = $request->getHeader('origin')[0] ?? '*';
$response->withHeader('Access-Control-Allow-Origin', $origin);
$response->withHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS，FILE');
$response->withHeader('Access-Control-Allow-Methods', '*');
$response->withHeader('Access-Control-Allow-Credentials', 'true');
$response->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, token');
if ($request->getMethod() === 'OPTIONS') {
    $response->withStatus(Status::CODE_OK);
    //表示不在执行后续控制器解析
    return false;
}
return true;
```

# 如何获取 $HTTP_RAW_POST_DATA

```php
$content = $this->request()->getBody()->__toString();
$raw_array = json_decode($content, true);
```

# 如何获取客户端IP

### 经过Nginx代理时

```php
$xRealIp = $this->request()->getHeader('x-real-ip');
$ip = null;
if(!empty($xRealIp)){
    $ip = $xRealIp[0];
}
$xForwardeFor = $this->request()->getHeader('x-forwarded-for');
if(!empty($xForwardeFor)){
    //这边返回的格式是，string   clientIp , proxy1 , proxy2
    $ip = $xForwardeFor[0];
    $ip = explode(',',$ip);
    return $ip[0];
}
```

> 以上注意配置nginx规则`x-real-ip`和`x-forwarded-for`，取值哪个自己看自己是否经过多重代理

### 客户端直接请求Easyswoole时
```php
$server = ServerManager::getInstance()->getSwooleServer();
$client = $server->getClientInfo($this->request()->getSwooleRequest()->fd);
$ip = $client['remote_ip'];
```



# CURL 发送 POST请求 EasySwoole 服务器端超时

- 出现原因：`CURL` 在发送较大的 `POST` 请求(例如: 上传文件)时会先发一个 `100-continue` 的请求，如果收到服务器的回应才会发送实际的 `POST` 数据。而 `swoole_http_server`(即 `EasySwoole` 的 `Http` 主服务) 不支持 `100-continue`，就会导致 `CURL` 请求超时。
- 解决方法：

### 方法1

关闭 `CURL` 的 `100-continue`，在 `CURL` 的 `Header` 中配置关闭 `100-continue` 选项。

示例代码(php):
```php
<?php
// 创建一个新cURL资源
$ch = curl_init();
// 设置URL和相应的选项
curl_setopt($ch, CURLOPT_URL, "http://127.0.0.1:9501");
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_POST, 1); // 设置为POST方式
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Expect:')); // 关闭 `CURL` 的 `100-continue`
curl_setopt($ch, CURLOPT_POSTFIELDS, array('test' => str_repeat('a', 800000)));// POST 数据
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

```

### 方法2

使用 `Nginx` 做前端代理，由 `Nginx` 处理 `100-Continue`(针对无法关闭 `100-continue`时)

# 配置HTTPS

虽然Swoole也支持HTTPS模式，但是更加推荐使用Nginx来处理ssl.Nginx示例规则如下：
```nginx

server {
    listen 443 ssl;
    server_name xxxxx.com;
    
    ssl_certificate    /etc/letsencrypt/live/xxxx.pem;
    ssl_certificate_key    /etc/letsencrypt/live/xxxxxx.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)
    {
        return 404;
    }

   location /{
       proxy_pass http://127.0.0.1:9501;
       proxy_http_version 1.1;
       proxy_set_header Connection "keep-alive";
       proxy_set_header X-Real-IP $remote_addr;
   }
   
}
```

