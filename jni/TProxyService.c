/*
 * TProxyService.c — JNI bridge for hev-socks5-tunnel on Android VpnService
 *
 * Class:   com.v2ray.ang.service.TProxyService
 *
 * hev_socks5_tunnel_main(config_path, tun_fd) là public API của hev
 * nhận thẳng fd từ VpnService.Builder.establish().detachFd() — không cần patch gì.
 */

#include <jni.h>
#include <android/log.h>
#include <stddef.h>

/* Public API — hev-socks5-tunnel.h */
int  hev_socks5_tunnel_main  (const char *config_path, int tun_fd);
void hev_socks5_tunnel_quit  (void);
void hev_socks5_tunnel_stats (size_t *tx_packets, size_t *tx_bytes,
                               size_t *rx_packets, size_t *rx_bytes);

#define LOG_TAG "HevTunnel"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

JNIEXPORT void JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyStartService(
    JNIEnv *env, jobject thiz, jstring config_path, jint tun_fd)
{
    const char *path = (*env)->GetStringUTFChars(env, config_path, NULL);
    if (!path) { LOGE("null config_path"); return; }
    LOGI("start config=%s fd=%d", path, (int)tun_fd);
    int ret = hev_socks5_tunnel_main(path, (int)tun_fd);
    (*env)->ReleaseStringUTFChars(env, config_path, path);
    if (ret != 0) LOGE("tunnel exited with error %d", ret);
    else          LOGI("tunnel exited OK");
}

JNIEXPORT void JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyStopService(
    JNIEnv *env, jobject thiz)
{
    LOGI("stop");
    hev_socks5_tunnel_quit();
}

JNIEXPORT jlongArray JNICALL
Java_com_v2ray_ang_service_TProxyService_TProxyGetStats(
    JNIEnv *env, jobject thiz)
{
    size_t tx_p = 0, tx_b = 0, rx_p = 0, rx_b = 0;
    hev_socks5_tunnel_stats(&tx_p, &tx_b, &rx_p, &rx_b);
    jlongArray arr = (*env)->NewLongArray(env, 2);
    if (!arr) return NULL;
    jlong buf[2] = { (jlong)tx_b, (jlong)rx_b };
    (*env)->SetLongArrayRegion(env, arr, 0, 2, buf);
    return arr;
}
