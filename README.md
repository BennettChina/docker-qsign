# Docker-Qsign

本项目是 [unidbg-fetch-qsign](https://github.com/fuqiuluo/unidbg-fetch-qsign) 的 Docker 镜像源码，基于 `Alpine` 系统编译。

默认使用的是项目中的 `8.9.63` 版本 `.so` 资源，可以通过挂载文件替换 （ `1.1.1` 开始默认使用 `8.9.68` ）。

## 配置文件

自 `1.1.1` 开始，引入了 `config.json` 配置文件，此前的 `ANDROID_ID` 、 `DYNAMIC` 等环境变量参数将在此配置文件中进行调整，以及引入白名单
QQ 号规则，若未配置该规则将不会响应任何 QQ 号的请求。

```json5
{ // 复制这里的话，请把注释删除
  "server": {
    "host": "0.0.0.0",
    "port": 80 //端口不建议改，容器默认用 80 最舒服，如果改则需要暴露端口时的容器内端口与此一致。
  },
  "uin_list": [ // 未出现在uinList的qq无法访问api!
    {
      // uin也就是你的QQQ
      "uin": 114514,
      // 该uin对应的android_id
      "android_id": "1145141919810114",
      // 不能是空的哦~~
      "guid":       "5141919810114514",
      "qimei36":    "8e11b1f9764fa3b43121f6f510001fa1721a"
    }
  ],
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
  }
}
```

## 快速开始

启动前当前文件夹要有 `txlib` 这个文件夹。

```shell
docker run -d \
--name qsign-server \
--restart always \
-p 8080:80 \
-v $(pwd)/txlib/:/app/txlib \
bennettwu/qsign-server:1.1.1
```

然后使用 `http://127.0.0.1:8080/sign` 作为签名服务地址即可。

## Docker-Compose

```yaml
version: "3"
services:
  qsign-server:
    image: bennettwu/qsign-server:1.1.1
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

- [1.1.0](https://github.com/BennettChina/docker-qsign/tree/v1.1.0)
- [1.0.5](https://github.com/BennettChina/docker-qsign/tree/v1.0.5)
- [1.0.4](https://github.com/BennettChina/docker-qsign/tree/v1.0.4)
