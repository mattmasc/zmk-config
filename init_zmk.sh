#!/bin/bash

KEYBOARD_HOME="$(pwd)"
export ZMK_HOME="$KEYBOARD_HOME/modules/mattmasc/zmk"

INIT=false
if [[ ! -d "$ZMK_HOME/.west" ]]
then
    INIT=true
    echo "Add git sub-modules..."
    git submodule add -f https://github.com/mattmasc/zmk modules/mattmasc/zmk
fi

echo "Update git sub-modules..."
git submodule sync --recursive
git submodule update --init --recursive --progress

echo "Checking out zmk..."
cd $ZMK_HOME
git fetch
git checkout develop
git pull
cd $KEYBOARD_HOME

if [[ "${INIT}" == "true" ]]
then
    echo "Initializing West..."
    cd $ZMK_HOME
    west init -l app/
    west update
    west zephyr-export
    cd $KEYBOARD_HOME
fi

echo "Exporting Zephyr Toolchain..."
cd $ZMK_HOME
unset ZEPHYR_TOOLCHAIN_VARIANT
unset GNUARMEMB_TOOLCHAIN_PATH
export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.16.3
cd $KEYBOARD_HOME

echo "Creating Duet build alias..."
build_duet_unibody="west build -p -s app -b nice_nano_v2 --build-dir build/duet -- -DSHIELD='duet' -DZMK_CONFIG=$KEYBOARD_HOME"
archive_duet_unibody="mkdir -p $KEYBOARD_HOME/build/artifacts; [ -f build/duet/zephyr/zmk.uf2 ] && mv build/duet/zephyr/zmk.uf2 $KEYBOARD_HOME/build/artifacts/duet-zmk.uf2"
alias build_duet="cd ${ZMK_HOME} && ${build_duet_unibody} && ${archive_duet_unibody} && cd $KEYBOARD_HOME"