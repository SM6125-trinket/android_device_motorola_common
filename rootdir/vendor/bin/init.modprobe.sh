#!/vendor/bin/sh

MODULES_PATH="/vendor/lib/modules/"

if [ -f "${MODULES_PATH}modules.load" ]; then
    /vendor/bin/modprobe -b -d ${MODULES_PATH} --all="${MODULES_PATH}modules.load"
    exit 0
fi

MODULES=$(/vendor/bin/modprobe -d ${MODULES_PATH} -l)

# Iterate over module list and modprobe them in background.
for MODULE in ${MODULES}; do
	/vendor/bin/modprobe -a -b -d ${MODULES_PATH} "${MODULE}" &
done

# Wait until all the modprobes are finished
wait
