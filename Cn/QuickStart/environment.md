# 基础运行环境
- 保证 **PHP** 版本大于等于 **8.1**
- 保证 **Swoole PHP** 拓展版本大于等于 **4.8.13** ,**5.x**版本也可以
- 需要 **Pcntl PHP** 拓展的任意版本 
- 可能需要 **OpenSSL PHP** 扩展的任意版本（如需要使用到 HTTPS）
- 使用 **Linux** / **FreeBSD** / **MacOS** 这三类操作系统
- 使用 **Composer** 作为依赖管理工具

::: warning 
 参考下面的建议，它们都不是必须的，但是有助于更高效的使用框架和进行开发
:::

- 使用 **Ubuntu14** / **CentOS 7.0** 或更高版本操作系统
- 使用 **Docker** 

## Windows 环境下开发特殊说明

如果您想在 `Windows` 环境下进行开发，您可以通过 `Docker for Windows` 或 `WSL` 或 `虚拟机` 来作为运行环境。

### Windows 下使用 Docker 

具体如何安装 `Docker`，请自行`Google`查询资料进行安装。

### Windows 下使用 WSL2 (Windows Subsystem for Linux)

具体如何安装 `Windows Subsystem for Linux`，请自行`Google`查询资料进行安装。
注意，WSL的挂载目录无法写入sock文件，请在启动前，修改EasySwoole配置的`TEMP_DIR`为`WSl`的系统临时目录。

### Windows 下使用 虚拟机

你还可以通过安装虚拟机的方式来模拟 `Linux` 环境，用该环境进行 `EasySwoole` 项目的开发。具体如何安装虚拟机，请自行`Google`查询资料进行安装。
