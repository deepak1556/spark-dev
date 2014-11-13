#!/bin/bash

COLOR_CLEAR="\x1B[0m"
COLOR_BLUE="\x1B[1;34m"
COLOR_CYAN="\x1B[0;36m"

header () {
  echo -e "${COLOR_BLUE}${1}${COLOR_CLEAR}"
}

subheader () {
  echo -e "-> ${COLOR_CYAN}${1}${COLOR_CLEAR}"
}

BUILD=$(cd "$(dirname "$0")"; pwd)
COMMON=$(cd "$(dirname "$0")"; cd ../common; pwd)
ROOT=$(cd "$(dirname "$0")"; cd ../..; pwd)
TARGET="${ROOT}/dist/linux"
APP_NAME="Spark Dev"
TEMP_DIR=`mktemp -d tmp.XXXXXXXXXX`
TEMP_DIR="${BUILD}/${TEMP_DIR}"
SPARK_DEV_VERSION="0.0.16"
ATOM_VERSION="v0.140.0"
ATOM_NODE_VERSION="0.18.2"

if [ -d $TARGET ]; then rm -rf $TARGET ; fi
mkdir -p $TARGET
cd $TEMP_DIR
header "Working directory is ${TEMP_DIR}"
wget https://github.com/atom/atom/archive/${ATOM_VERSION}.tar.gz -O - | tar -xz --strip-components=1

header "Copy resources"
cp ${BUILD}/sparkide.ico ${TEMP_DIR}/resources/linux/atom.ico
cp ${BUILD}/atom.png ${TEMP_DIR}/resources/atom.png

header "Append 3rd party packages to package.json"
${COMMON}/append-package ${TEMP_DIR}/package.json file-type-icons "0.4.4"
${COMMON}/append-package ${TEMP_DIR}/package.json switch-header-source "0.8.0"
${COMMON}/append-package ${TEMP_DIR}/package.json resize-panes "0.1.0"
${COMMON}/append-package ${TEMP_DIR}/package.json maximize-panes "0.1.0"
${COMMON}/append-package ${TEMP_DIR}/package.json move-panes "0.1.2"
${COMMON}/append-package ${TEMP_DIR}/package.json swap-panes "0.1.0"
${COMMON}/append-package ${TEMP_DIR}/package.json toolbar "0.0.9"
${COMMON}/append-package ${TEMP_DIR}/package.json monokai "0.8.0"
${COMMON}/append-package ${TEMP_DIR}/package.json welcome
${COMMON}/append-package ${TEMP_DIR}/package.json feedback
${COMMON}/append-package ${TEMP_DIR}/package.json release-notes

header "Bootstrap Atom"
script/bootstrap

header "Installing unpublished packages"
subheader "spark-dev"
git clone https://github.com/spark/spark-dev.git node_modules/spark-dev
cd node_modules/spark-dev
git checkout tags/${SPARK_DEV_VERSION}
export ATOM_NODE_VERSION
../../apm/node_modules/atom-package-manager/bin/apm install .
ls -lha node_modules/serialport/build/serialport/v1.4.6/Release/
cd ../..
${COMMON}/append-package ${TEMP_DIR}/package.json spark-dev ${SPARK_DEV_VERSION}

subheader "welcome-spark"
git clone https://github.com/spark/welcome-spark.git node_modules/welcome-spark
${COMMON}/append-package ${TEMP_DIR}/package.json welcome-spark "0.19.0"

subheader "feedback-spark"
git clone https://github.com/spark/feedback-spark.git node_modules/feedback-spark
${COMMON}/append-package ${TEMP_DIR}/package.json feedback-spark "0.34.0"

subheader "release-notes-spark"
git clone https://github.com/spark/release-notes-spark.git node_modules/release-notes-spark
${COMMON}/append-package ${TEMP_DIR}/package.json release-notes-spark "0.36.0"

subheader "language-spark"
git clone https://github.com/spark/language-spark.git node_modules/language-spark
${COMMON}/append-package ${TEMP_DIR}/package.json language-spark "0.3.0"

header "Patch code"
patch ${TEMP_DIR}/src/browser/atom-application.coffee < ${COMMON}/atom-application.patch
patch ${TEMP_DIR}/.npmrc < ${COMMON}/npmrc.patch
patch ${TEMP_DIR}/src/atom.coffee < ${COMMON}/atom.patch
patch ${TEMP_DIR}/src/browser/auto-update-manager.coffee < ${COMMON}/auto-update-manager.patch
patch ${TEMP_DIR}/build/tasks/codesign-task.coffee < ${COMMON}/codesign-task.patch
subheader "Window title"
patch ${TEMP_DIR}/src/browser/atom-window.coffee < ${COMMON}/atom-window.patch
patch ${TEMP_DIR}/src/workspace.coffee < ${COMMON}/workspace.patch
subheader "Menu items"
patch ${TEMP_DIR}/menus/darwin.cson < ${COMMON}/darwin.patch
patch ${TEMP_DIR}/menus/linux.cson < ${COMMON}/linux.patch
patch ${TEMP_DIR}/menus/win32.cson < ${COMMON}/win32.patch
subheader "Settings package"
patch ${TEMP_DIR}/node_modules/settings-view/lib/settings-view.coffee < ${COMMON}/settings-view.patch
cp ${COMMON}/atom.png ${TEMP_DIR}/node_modules/settings-view/images/atom.png
subheader "Exception Reporting package"
patch ${TEMP_DIR}/node_modules/exception-reporting/lib/reporter.coffee < ${COMMON}/reporter.patch
subheader "App version"
${COMMON}/set-version ${TEMP_DIR}/package.json ${SPARK_DEV_VERSION}

header "Building app"
build/node_modules/.bin/grunt --gruntfile build/Gruntfile.coffee --install-dir "${TARGET}/${APP_NAME}" download-atom-shell build set-version codesign install

rm -rf $TEMP_DIR

# header "Build ZIP"
