# Docker-Qsign

本项目是 [unidbg-fetch-qsign](https://github.com/fuqiuluo/unidbg-fetch-qsign) 的 Docker 镜像源码，基于 `Alpine` 系统编译。

默认使用的是项目中的 `8.9.63` 版本 `.so` 资源，可以通过挂载文件替换。

## 快速开始

```shell
docker run -d \
--name qsign-server \
--restart always \
-p 8080:80 \
-e COUNT=1 \
-e ANDROID_ID=<your android_id> \
bennettwu/qsign-server:1.0.4
```

然后使用 `http://127.0.0.1:8080/sign` 作为签名服务地址即可。

## Docker-Compose

```yaml
version: "3"
services:
  qsign-server:
    image: bennettwu/qsign-server:1.0.4
    ports:
      - "8080:80"
    environment:
      - COUNT=1
      - ANDROID_ID=<your android_id>
    container_name: qsign-server
    volumes:
      # 可以放txlib目录中的.so文件
      - ./txlib:/app/txlib
    restart: always
```

## 环境变量

| 名称         |      默认值      | 描述                                        |
|:-----------|:-------------:|:------------------------------------------|
| COUNT      |       1       | unidbg 实例数量 (建议等于核心数) 【数值越大并发能力越强，内存占用越大】 |
| ANDROID_ID |       无       | `device.json` 中的 `android_id` 值           |
| TZ         | Asia/Shanghai | 时区                                        |
