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
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
if(DEFINED CATKIN_INSTALL_PREFIX AND NOT CMAKE_INSTALL_PREFIX STREQUAL "${CATKIN_INSTALL_PREFIX}")
    message(FATAL_ERROR "CATKIN_INSTALL_PREFIX must be identical to CMAKE_INSTALL_PREFIX")
endif()
if(DEFINED CATKIN_DEVEL_PREFIX AND CMAKE_INSTALL_PREFIX STREQUAL "${CATKIN_DEVEL_PREFIX}")
    message(FATAL_ERROR "CATKIN_DEVEL_PREFIX must be different from CMAKE_INSTALL_PREFIX")
endif()
set(CATKIN_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
set(CATKIN_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")

include("${CATKIN_CMAKE_DIR}/destinations.cmake")
include("${CATKIN_CMAKE_DIR}/export.cmake")
include("${CATKIN_CMAKE_DIR}/package.cmake")
include("${CATKIN_CMAKE_DIR}/project.cmake")
include("${CATKIN_CMAKE_DIR}/python.cmake")
include("${CATKIN_CMAKE_DIR}/status.cmake")

catkin_destinations()
catkin_find_python_interpreter()
catkin_project()

# The following dummy variable is merely set to prevent CMake from complaining about
# potentially unused variables:
# - BUILD_SHARED_LIBS is only used if add_library() is called in the package
set(ignore_unused_warning "${BUILD_SHARED_LIBS}")
unset(ignore_unused_warning)
