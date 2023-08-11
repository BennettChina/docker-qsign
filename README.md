<h1 align="center"> Docker-Qsign </h1>

<p align="center">
    <a href="https://github.com/BennettChina/docker-qsign/actions/workflows/ci.yml">
        <img src="https://github.com/BennettChina/docker-qsign/actions/workflows/ci.yml/badge.svg" alt="ci status"/>
    </a>
    <a href="https://github.com/adoptium/containers/tree/main/8/jre/alpine">
        <img src="https://img.shields.io/badge/openjdk-8-blue?logo=openjdk" alt="jdk version"/>
    </a>
    <a href="https://hub.docker.com/r/bennettwu/qsign-server">
        <img src="https://img.shields.io/docker/v/bennettwu/qsign-server?logo=docker" alt="docker image version"/>
    </a>
    <a href="https://hub.docker.com/r/bennettwu/qsign-server">
        <img src="https://img.shields.io/docker/image-size/bennettwu/qsign-server" alt="docker image size"/>
    </a>
    <a href="https://hub.docker.com/r/bennettwu/qsign-server">
        <img src="https://img.shields.io/docker/pulls/bennettwu/qsign-server" alt="docker pulls"/>
    </a>
</p>

本项目是 [unidbg-fetch-qsign](https://github.com/fuqiuluo/unidbg-fetch-qsign) 的 Docker 镜像源码，基于 `Alpine` 系统编译。

默认使用的是项目中的 `8.9.63` 版本 `.so` 资源，可以通过挂载文件替换 。

## 配置文件

自 `1.1.1` 开始，引入了 `config.json` 配置文件，此前的 `ANDROID_ID` 、 `DYNAMIC` 等环境变量参数将在此配置文件中进行调整，以及引入白名单
QQ 号规则，若未配置该规则将不会响应任何 QQ 号的请求。

```json5
{ // 复制这里的话，请把注释删除
  "server": {
    "host": "0.0.0.0",
    "port": 80 //端口不建议改，容器默认用 80 最舒服，如果改则需要暴露端口时的容器内端口与此一致。
  },
  // 注册实例的密钥
  "key": "114514",
  // 启用自动注册实例（需要1.1.4及以上版本才会生效，8.9.68可开启）
  "auto_register": true,
  // 实例重载间隔
  // i>=20 i<=50
  "reload_interval": 40, 
  "protocol": {
    "qua": "V1_AND_SQ_8.9.68_4218_HDBM_T",
    // version和code可以从qua中提取
    "version": "8.9.68", 
    "code": "4218"
  },
  "unidbg": {
    // 启用Dynarmic，它是一个开源的动态ARM指令集模拟器
    // 有时候会出现https://github.com/fuqiuluo/unidbg-fetch-qsign/issues/52
    "dynarmic": false,
    "unicorn": true,
    "debug": false
  },
  // 黑名单的uin，禁止以下uin注册实例，自qsign-1.1.6版本启用...
  "black_list": [
    1008611
  ]
}
```

## 快速开始

首先把需要挂载的内容复制到宿主机，避免因为宿主机文件夹空的导致挂载后覆盖容器内的文件夹内容。

```shell
docker run -d --rm --name tmp_cont bennettwu/qsign-server:1.1.6 sh -c 'sleep 10'  && docker cp tmp_cont:/app/txlib "$(pwd)/"
```

之后需要修改 `txlib/config.json` 文件中的参数，修改后用挂载方式启动。

```shell
docker run -d \
--name qsign-server \
--restart always \
-p 8080:80 \
-v $(pwd)/txlib/:/app/txlib \
bennettwu/qsign-server:1.1.6
```

然后使用 `http://127.0.0.1:8080/sign?key=114514` 作为签名服务地址即可。

## Docker-Compose

同样需要先把挂载的内容复制到宿主机，避免因为宿主机文件夹空的导致挂载后覆盖容器内的文件夹内容，启动前需要修改配置文件。

```shell
docker run -d --rm --name tmp_cont bennettwu/qsign-server:1.1.6 sh -c 'sleep 10'  && docker cp tmp_cont:/app/txlib "$(pwd)/"
```

```yaml
version: "3"
services:
  qsign-server:
    image: bennettwu/qsign-server:1.1.6
    ports:
      # 如果改了 config.json 中的 port 值则需要跟此处的第二个端口一致
      - "8080:80"
    container_name: qsign-server
    volumes:
      # 可以放txlib目录中的.so文件
      - ./txlib/:/app/txlib
    restart: always
```

## 环境变量

程序启动的参数将不再通过环境变量控制，而由 `config.json` 管理。

| 名称             |      默认值      | 描述                                                                                       |
|:---------------|:-------------:|:-----------------------------------------------------------------------------------------|
| ~~COUNT~~      |       1       | unidbg 实例数量 (建议等于核心数) 【数值越大并发能力越强，内存占用越大】                                                |
| ~~ANDROID_ID~~ |       无       | `device.json` 中的 `android_id` 值                                                          |
| TZ             | Asia/Shanghai | 时区                                                                                       |
| ~~DYNAMIC~~    |     false     | 是否开启动态引擎（加速Sign计算，有时候会出现[#52](https://github.com/fuqiuluo/unidbg-fetch-qsign/issues/52)） |

## 历史版本

- [1.1.5](https://github.com/BennettChina/docker-qsign/tree/v1.1.5)
- [1.1.4](https://github.com/BennettChina/docker-qsign/tree/v1.1.4)
- [1.1.3](https://github.com/BennettChina/docker-qsign/tree/v1.1.3)
- [1.1.2](https://github.com/BennettChina/docker-qsign/tree/v1.1.2)
- [1.1.1](https://github.com/BennettChina/docker-qsign/tree/v1.1.1)
- [1.1.0](https://github.com/BennettChina/docker-qsign/tree/v1.1.0)
- [1.0.5](https://github.com/BennettChina/docker-qsign/tree/v1.0.5)
- [1.0.4](https://github.com/BennettChina/docker-qsign/tree/v1.0.4)
