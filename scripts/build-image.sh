#!/bin/sh

echo "INFO: building image"
podman build -t mupwit-builder .
