#!/bin/bash
#
# setup_stage1_usb.sh generates per-machine USB images.
#
# setup_stage1_usb.sh should only be run after setup_stage2.sh has run
# successfully and the stage2_vmlinuz kernel is available.

SOURCE_DIR=$( realpath $( dirname "${BASH_SOURCE[0]}" ) )

set -e

USAGE="$0 <project> <builddir> <outputdir> <configdir> <hostname-pattern>"
PROJECT=${1:?Please provide the GCP Project: $USAGE}
BUILD_DIR=${2:?Please specify a build directory: $USAGE}
OUTPUT_DIR=${3:?Please provide an output directory: $USAGE}
CONFIG_DIR=${4:?Please specify a config directory: $USAGE}
HOSTNAMES=${5:?Please specify a hostname pattern: $USAGE}

# Report all commands to log file (set -x writes to stderr).
set -xuo pipefail

# Use mlabconfig to fill in the template for every machine matching the given
# HOSTNAMES pattern.
pushd ${BUILD_DIR}
  test -d operator || git clone https://github.com/m-lab/operator
  pushd operator/plsync
    mkdir -p ${OUTPUT_DIR}/scripts
    ./mlabconfig.py --format=server-network-config \
        --select "${HOSTNAMES}" \
        --label "project=${PROJECT}" \
        --template_input "${CONFIG_DIR}/create-stage1-usb-template.sh" \
        --template_output "${BUILD_DIR}/create-stage1-usb-{{hostname}}.sh"
  popd
popd

# Run each per-machine build script.
for create_usb_script in `ls ${BUILD_DIR}/create-stage1-usb-*.sh` ; do
  echo $create_usb_script
  chmod 755 $create_usb_script
  mkdir -p ${OUTPUT_DIR}/stage1_usbs
  $create_usb_script ${SOURCE_DIR} ${OUTPUT_DIR} ${OUTPUT_DIR}/stage1_usbs
done