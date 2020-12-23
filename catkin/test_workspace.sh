#!/bin/bash
##############################################################################
#
# catkin-ng
# Copyright 2020 Timo Röhling <timo@gaussglocke.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
##############################################################################
set -e
packagedir=$(cd "$(dirname "$0")"; pwd)
pyver=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

if [ "${KEEP_WS:-0}" -eq 1 ]
then
    wsdir="/tmp/catkin_ws"
    rm -rf "$wsdir"
    mkdir -p "$wsdir"
else
    wsdir="$(mktemp -d)"
    trap "rm -rf $wsdir" EXIT
fi

mkdir -p "$wsdir/src"
ln -s "$packagedir" "$wsdir/src/catkin"
for pkg in "$packagedir/test-packages/"*
do
    ln -s "$pkg" "$wsdir/src/${pkg##*/}"
done

cd "$wsdir"

run()
{
    env -i ROS_PYTHON_VERSION=3 LANG=C.UTF-8 \
        PATH="$wsdir/devel/bin:/usr/bin:/bin" \
        CMAKE_PREFIX_PATH="$wsdir/devel" \
        PYTHONPATH="$wsdir/devel/lib/python$pyver/site-packages" \
        "$@"
}

run "$wsdir/src/catkin/bootstrap.sh" --pkg catkin VERBOSE=ON
run catkin_make VERBOSE=ON
run catkin_make install DESTDIR="$wsdir/install"