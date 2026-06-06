/*
 * TProxyService.c
 *
 * JNI wrapper cho hev-socks5-tunnel trên Android.
 * Class: com.v2ray.ang.service.TProxyService
 *
 * TProxyStartService(String configPath, int tunFd):
 *   - configPath: đường dẫn file YAML config
 *   - tunFd: file descriptor của TUN interface từ VpnService.Builder.establish().detachFd()
 *            Truyền -1 nếu muốn hev tự mở interface theo tunnel.name trong YAML
 *
 * Build: ndk-build (đặt file này vào thư mục jni/ cùng với Android.mk)
 */

#include <jni.h>
#include <android/log.h>
#include <string.h>

/* API từ hev-socks5-tunnel/src/hev-socks5-tunnel.h */
extern int  hev_socks5_tunnel_main (const char *config_path, int tun_fd);
extern void hev_socks5_tunnel_quit (void);
extern void hev_socks5_tunnel_stats (size_t *tx_packets, size_t *tx_bytes,
                                     size_t *rx_packets, size_t *rx_bytes);

#define TAG "HevTunnel-JNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

/* -----------------------------------------------------------------------
 * Java_com_v2ray_ang_service_TProxyService_TProxyStartService
 *
 * Signature: (Ljava/lang/String;I)V
 * Blocks until hev_socks5_tunnel_quit() is called or an error occurs.
 * ----------------------------------------------------------------------- */
JNIEXPORT void JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyStartService(
        JNIEnv *env, jobject thiz,
        jstring config_path, jint tun_fd)
{
    const char *path = (*env)->GetStringUTFChars(env, config_path, NULL);
    if (!path) {
        LOGE("TProxyStartService: null config_path");
        return;
    }
    LOGI("TProxyStartService: config=%s tunFd=%d", path, (int)tun_fd);

    int ret = hev_socks5_tunnel_main(path, (int)tun_fd);

    (*env)->ReleaseStringUTFChars(env, config_path, path);

    if (ret != 0) {
        LOGE("TProxyStartService: hev_socks5_tunnel_main returned %d", ret);
    } else {
        LOGI("TProxyStartService: exited normally");
    }
}

/* -----------------------------------------------------------------------
 * Java_com_v2ray_ang_service_TProxyService_TProxyStopService
 *
 * Signature: ()V
 * ----------------------------------------------------------------------- */
JNIEXPORT void JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyStopService(
        JNIEnv *env, jobject thiz)
{
    LOGI("TProxyStopService: quitting hev tunnel");
    hev_socks5_tunnel_quit();
}

/* -----------------------------------------------------------------------
 * Java_com_v2ray_ang_service_TProxyService_TProxyGetStats
 *
 * Signature: ()[J
 * Returns: long[] { tx_bytes, rx_bytes }
 * ----------------------------------------------------------------------- */
JNIEXPORT jlongArray JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyGetStats(
        JNIEnv *env, jobject thiz)
{
    size_t tx_packets = 0, tx_bytes = 0;
    size_t rx_packets = 0, rx_bytes = 0;
    hev_socks5_tunnel_stats(&tx_packets, &tx_bytes, &rx_packets, &rx_bytes);

    jlongArray arr = (*env)->NewLongArray(env, 2);
    if (!arr) return NULL;
    jlong buf[2] = { (jlong)tx_bytes, (jlong)rx_bytes };
    (*env)->SetLongArrayRegion(env, arr, 0, 2, buf);
    return arr;
}
