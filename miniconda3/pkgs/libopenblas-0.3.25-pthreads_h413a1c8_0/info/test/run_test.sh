

set -ex



test -f ${PREFIX}/lib/libopenblasp-r0.3.25.so
python -c "import ctypes; ctypes.cdll['${PREFIX}/lib/libopenblasp-r0.3.25.so']"
exit 0
