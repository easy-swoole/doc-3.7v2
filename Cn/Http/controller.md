# 控制器
Easyswoole控制器类所在完整的命名空间是`EasySwoole\Http\AbstractInterface\Controller`,
所有的控制器都应该继承自这个基类。

## Index控制器示例

我们在`App\HttpController`目录地下，建立一个Index.php文件，代码如下：
```php
<?php

namespace App\HttpController;


use EasySwoole\Http\AbstractInterface\Controller;

class Index extends Controller
{

    public function index()
    {
        $file = EASYSWOOLE_ROOT.'/vendor/easyswoole/easyswoole/src/Resource/Http/welcome.html';
        if(!is_file($file)){
            $file = EASYSWOOLE_ROOT.'/src/Resource/Http/welcome.html';
        }
        $this->response()->write(file_get_contents($file));
    }

    function test()
    {
        $this->response()->write('Hello World!');
    }

    protected function actionNotFound(?string $action)
    {
        $this->response()->withStatus(404);
        $file = EASYSWOOLE_ROOT.'/vendor/easyswoole/easyswoole/src/Resource/Http/404.html';
        if(!is_file($file)){
            $file = EASYSWOOLE_ROOT.'/src/Resource/Http/404.html';
        }
        $this->response()->write(file_get_contents($file));
    }
}
```

- 当你访问如：`http://127.0.0.1:9501/` , `http://127.0.0.1:9501/index.html` 的时候，则执行`index()`方法。
- 当你访问如：`http://127.0.0.1:9501/test` , `http://127.0.0.1:9501/test.html` 的时候，则执行`test()`方法。
- 当你访问一个不存在的方法，如：`http://127.0.0.1:9501/php` , `http://127.0.0.1:9501/php.html` 的时候，则执行`actionNotFound()`方法。

## 控制器基础方法

### 获取当前行为名方法

```
protected function getActionName(): ?string
```

用来获取当前请求是执行当前控制器的哪个`action`

### 获取请求实例
```
protected function request(): Request
```
该方法返回的是当前请求的请求实例。返回的实例是`EasySwoole\Http\Request`


### 获取响应实例
```
protected function response(): Response
```
该方法返回的是当前请求的响应实例。返回的实例是`EasySwoole\Http\Response`

### 响应JSON方法

```
protected function writeJson($statusCode = 200, $result = null, $msg = null)
```
该方法用来向客户端响应一个json。例如：
```
use EasySwoole\Http\Message\Status;

$this->writeJson(
    Status::CODE_OK, 
    [
        'timestamp'=>time()
    ],
    'get timestamp success'
);
```
得到的响应如下：
```json
{"code":200,"result":{"timestamp":1759163648},"msg":"get timestamp success"}
```

### 获取请求JSON方法
```
protected function json(): array
```
当请求中存在以RAW格式POST的json数据的时候，则会把当前数据自动解析为数组并且返回。


### 获取请求xml方法
```
protected function xml($options = LIBXML_NOERROR | LIBXML_NOCDATA, string $className = 'SimpleXMLElement')
```
当请求中存在以RAW格式POST的xml数据的时候，则会把当前数据自动解析为`SimpleXMLElement`实例并返回。

### 404方法

```
protected function actionNotFound(?string $action)
```

当访问了任何此控制器不存在的方法的时候，它都会被执行。你可以在子类中重写它的实现。用以重定向，或者是发送404方法，或者是发送错误代码等。例如:
```php
function actionNotFound(?string $action)
{
    $this->writeJson(Status::CODE_NOT_FOUND);
}
```

### 执行前方法
```
protected function onRequest(?string $action): ?bool
```
每次控制器被访问的时候，都会先执行一次该方法。当返回值为`false`的时候，控制器则不会执行实际的请求`action`。可以在子类中重写这个函数，用来实现访问鉴权和安全拦截等。

### 行为执行后方法
```
protected function afterAction(?string $actionName): void
```
该控制器每次被访问的时候，都会执行一次该方法，可以在子类重写掉它，用来实现例如行为统计等。

### 异常方法
```
protected function onException(\Throwable $throwable): void
```
当该控制器被访问，且出现异常的时候，则会调用此方法，你可以重写它用来实现日志异常记录等。例如：
```php
protected function onException(\Throwable $throwable): void
{
    $msg = "{$throwable->getMessage()} at file {$throwable->getFile()} line {$throwable->getLine()}";
    $this->writeJson(Status::CODE_INTERNAL_SERVER_ERROR,null,$msg);
    Trigger::getInstance()->throwable($throwable);  
}
```