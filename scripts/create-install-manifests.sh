#!/bin/sh

export INSTALLATION_FOLDER="$MANIFEST_FOLDER/$ENVIRONMENT"
export INSTALLATION_FILENAME="$INSTALLATION_FOLDER/install.yaml"

mkdir -p "$INSTALLATION_FOLDER"
touch "$INSTALLATION_FILENAME"
find "$MANIFEST_FOLDER" \
  -name "*.yaml" \
  -not -name "kustomization.yaml" \
  -not -path "$INSTALLATION_FOLDER/*" \
  -exec sh -c 'cat "$1" >> "$INSTALLATION_FILENAME"' _ {} \;
