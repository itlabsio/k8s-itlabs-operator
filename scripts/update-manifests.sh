#!/bin/sh

find "${MANIFEST_FOLDER}" \
  -name '*.yaml' \
  -exec sh -c '''
    filename="$1";
    envsubst < "$filename" > "$filename.env";
    mv "$filename.env" "$filename";
  ''' shell {} \;
