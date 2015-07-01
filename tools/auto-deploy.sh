#!/bin/bash
# fail on errors
set -e

CLOUDSDK_URL=https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
SDK_DIR=google-cloud-sdk

# deploy only master builds
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skip deploy."
  exit 0
fi

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON_SITEPACKAGES=1

if [ ! -d $SDK_DIR ]; then
  mkdir -p $SDK_DIR
  curl -o /tmp/gcloud.tar.gz $CLOUDSDK_URL
  tar xzf /tmp/gcloud.tar.gz --strip 1 -C $SDK_DIR
  $SDK_DIR/install.sh
fi

openssl aes-256-cbc -d -k $MATERIAL_KEY_PASSPHRASE \
        -in tools/web-central-material-c424a92b8bfa.json.enc \
        -out tools/web-central-material-c424a92b8bfa.json

$SDK_DIR/bin/gcloud components update gae-python -q
$SDK_DIR/bin/gcloud auth activate-service-account $MATERIAL_SERVICE_ACCOUNT \
        --key-file tools/web-central-material-c424a92b8bfa.json \
				--quiet
$SDK_DIR/bin/appcfg.py -A web-central-material -V $TRAVIS_BRANCH update ./build
