#!/system/bin/sh
ALPINE_DIR=/data/user/0/org.ccwhitex.hyperterm/alpine
BIN_DIR=/data/user/0/org.ccwhitex.hyperterm/bin
TMP_DIR=/data/user/0/org.ccwhitex.hyperterm/tmp
PROOT_TMP=/data/user/0/org.ccwhitex.hyperterm/proot-tmp
PROOT_TMP_DIR=/data/user/0/org.ccwhitex.hyperterm/proot-tmp

mkdir -p $TMP_DIR
mkdir -p $PROOT_TMP
mkdir -p $ALPINE_DIR/tmp
chmod 1777 $ALPINE_DIR/tmp
chmod 1777 $PROOT_TMP

ARGS="--kill-on-exit"
ARGS="$ARGS -w /"

for system_mnt in /apex /odm /product /system /system_ext /vendor /linkerconfig/ld.config.txt /linkerconfig/com.android.art/ld.config.txt; do
    if [ -e "$system_mnt" ]; then
        ARGS="$ARGS -b $system_mnt"
    fi
done

ARGS="$ARGS -b /dev"
ARGS="$ARGS -b /proc"
ARGS="$ARGS -b /sys"
ARGS="$ARGS -b /sdcard"
ARGS="$ARGS -b /storage"
ARGS="$ARGS -b /data"
ARGS="$ARGS -b /dev/urandom:/dev/random"

[ -e "/proc/self/fd" ] && ARGS="$ARGS -b /proc/self/fd:/dev/fd"
[ -e "/proc/self/fd/0" ] && ARGS="$ARGS -b /proc/self/fd/0:/dev/stdin"
[ -e "/proc/self/fd/1" ] && ARGS="$ARGS -b /proc/self/fd/1:/dev/stdout"
[ -e "/proc/self/fd/2" ] && ARGS="$ARGS -b /proc/self/fd/2:/dev/stderr"

ARGS="$ARGS -b $ALPINE_DIR/tmp:/dev/shm"
ARGS="$ARGS -r $ALPINE_DIR"
ARGS="$ARGS -0"
ARGS="$ARGS --link2symlink"
ARGS="$ARGS --sysvipc"

if [ -f /system/bin/linker64 ]; then
    LINKER=/system/bin/linker64
else
    LINKER=/system/bin/linker
fi

cd $ALPINE_DIR
exec $LINKER $BIN_DIR/proot $ARGS /bin/sh -l
