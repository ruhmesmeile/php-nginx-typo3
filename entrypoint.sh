mkdir -p /tmp/import
if [ -n "$(find "/tmp/import" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    echo "Import directory empty, starting without import";
else
    echo "Import directory has content, starting import";
    /usr/local/bin/rmutil/seed-instance.util.sh;
fi
