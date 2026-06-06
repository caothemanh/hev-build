# hev-socks5-tunnel Android Build

Build `libhev-socks5-tunnel.so` cho Android (arm64-v8a, armeabi-v7a, x86, x86_64)
với JNI wrapper đúng cho `com.v2ray.ang.service.TProxyService`.

## Cấu trúc

```
jni/
  Android.mk        ← NDK build rules
  Application.mk    ← ABI + platform settings
  TProxyService.c   ← JNI wrapper (TProxyStartService, TProxyStopService, TProxyGetStats)
.github/workflows/
  build.yml         ← GitHub Actions CI
```

## JNI API

```java
package com.v2ray.ang.service;

public class TProxyService {
    public static void loadLibrary() {
        System.loadLibrary("hev-socks5-tunnel");
    }
    // tunFd: fd từ VpnService.Builder.establish().detachFd()
    public native void TProxyStartService(String configPath, int tunFd);
    public native void TProxyStopService();
    public native long[] TProxyGetStats(); // [tx_bytes, rx_bytes]
}
```

## Config YAML (không cần tunnel.name khi dùng tunFd)

```yaml
tunnel:
  mtu: 8500
  ipv4: 198.18.0.1
  ipv6: 'fc00::1'

socks5:
  port: 10808
  address: '127.0.0.1'
  udp: udp

misc:
  task-stack-size: 81920
  connect-timeout: 5000
  read-write-timeout: 60000
  log-file: stderr
  log-level: warn
  protect-path: '/data/user/0/com.unlimited.vpn/files/hev-protect.sock'
```

## Build thủ công

Push lên GitHub → Actions tab → chạy workflow → download artifact zip.

Hoặc build local:
```bash
git clone --recursive https://github.com/heiher/hev-socks5-tunnel jni/hev-socks5-tunnel
$NDK/ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=jni/Android.mk NDK_LIBS_OUT=./libs
```
