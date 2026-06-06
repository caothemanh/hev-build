# Android.mk for hev-socks5-tunnel JNI wrapper
# Builds libhev-socks5-tunnel.so for all ABIs

LOCAL_PATH := $(call my-dir)

HEV_DIR     := $(LOCAL_PATH)/hev-socks5-tunnel
LWIP_DIR    := $(HEV_DIR)/third-part/lwip
YAML_DIR    := $(HEV_DIR)/third-part/yaml
TASK_DIR    := $(HEV_DIR)/third-part/hev-task-system

# ── lwip static ──────────────────────────────────────────────────────────────
include $(CLEAR_VARS)
LOCAL_MODULE    := lwip
LOCAL_C_INCLUDES := \
    $(LWIP_DIR)/src/include \
    $(LWIP_DIR)/ports/include
LOCAL_SRC_FILES := \
    hev-socks5-tunnel/third-part/lwip/src/core/init.c \
    hev-socks5-tunnel/third-part/lwip/src/core/def.c \
    hev-socks5-tunnel/third-part/lwip/src/core/dns.c \
    hev-socks5-tunnel/third-part/lwip/src/core/inet_chksum.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ip.c \
    hev-socks5-tunnel/third-part/lwip/src/core/mem.c \
    hev-socks5-tunnel/third-part/lwip/src/core/memp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/netif.c \
    hev-socks5-tunnel/third-part/lwip/src/core/pbuf.c \
    hev-socks5-tunnel/third-part/lwip/src/core/raw.c \
    hev-socks5-tunnel/third-part/lwip/src/core/stats.c \
    hev-socks5-tunnel/third-part/lwip/src/core/sys.c \
    hev-socks5-tunnel/third-part/lwip/src/core/altcp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/altcp_alloc.c \
    hev-socks5-tunnel/third-part/lwip/src/core/altcp_tcp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/tcp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/tcp_in.c \
    hev-socks5-tunnel/third-part/lwip/src/core/tcp_out.c \
    hev-socks5-tunnel/third-part/lwip/src/core/udp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/icmp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/igmp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/autoip.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/dhcp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/etharp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/icmp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/igmp.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/ip4_frag.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/ip4.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv4/ip4_addr.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/dhcp6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/ethip6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/icmp6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/inet6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/ip6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/ip6_addr.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/ip6_frag.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/mld6.c \
    hev-socks5-tunnel/third-part/lwip/src/core/ipv6/nd6.c \
    hev-socks5-tunnel/third-part/lwip/src/netif/ethernet.c \
    hev-socks5-tunnel/third-part/lwip/ports/sys_arch.c
LOCAL_CFLAGS := -O2
include $(BUILD_STATIC_LIBRARY)

# ── yaml static ───────────────────────────────────────────────────────────────
include $(CLEAR_VARS)
LOCAL_MODULE    := yaml
LOCAL_C_INCLUDES := $(YAML_DIR)/include
LOCAL_SRC_FILES := \
    hev-socks5-tunnel/third-part/yaml/src/api.c \
    hev-socks5-tunnel/third-part/yaml/src/dumper.c \
    hev-socks5-tunnel/third-part/yaml/src/emitter.c \
    hev-socks5-tunnel/third-part/yaml/src/loader.c \
    hev-socks5-tunnel/third-part/yaml/src/parser.c \
    hev-socks5-tunnel/third-part/lwip/src/core/mem.c \
    hev-socks5-tunnel/third-part/yaml/src/reader.c \
    hev-socks5-tunnel/third-part/yaml/src/scanner.c \
    hev-socks5-tunnel/third-part/yaml/src/writer.c
LOCAL_CFLAGS := -O2 \
    -DYAML_VERSION_MAJOR=0 \
    -DYAML_VERSION_MINOR=2 \
    -DYAML_VERSION_PATCH=5 \
    -DYAML_VERSION_STRING=\"0.2.5\"
include $(BUILD_STATIC_LIBRARY)

# ── hev-task-system static ────────────────────────────────────────────────────
include $(CLEAR_VARS)
LOCAL_MODULE    := hev-task-system
LOCAL_C_INCLUDES := $(TASK_DIR)/src
LOCAL_SRC_FILES := $(wildcard hev-socks5-tunnel/third-part/hev-task-system/src/*.c)
LOCAL_CFLAGS := -O2
include $(BUILD_STATIC_LIBRARY)

# ── libhev-socks5-tunnel.so (shared + JNI) ───────────────────────────────────
include $(CLEAR_VARS)
LOCAL_MODULE    := hev-socks5-tunnel
LOCAL_C_INCLUDES := \
    $(HEV_DIR)/src \
    $(LWIP_DIR)/src/include \
    $(LWIP_DIR)/ports/include \
    $(YAML_DIR)/include \
    $(TASK_DIR)/src
LOCAL_SRC_FILES := \
    $(wildcard hev-socks5-tunnel/src/*.c) \
    TProxyService.c
LOCAL_STATIC_LIBRARIES := lwip yaml hev-task-system
LOCAL_LDLIBS    := -llog -landroid
LOCAL_CFLAGS    := -O2 -DANDROID -fvisibility=hidden
LOCAL_CFLAGS    += -DHEV_SOCKS5_TUNNEL_ANDROID=1
include $(BUILD_SHARED_LIBRARY)
