##############################################################################
#
# hazel
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
macro(hazel_project)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/package.xml")
        message(FATAL_ERROR "cannot find 'package.xml' in current source directory")
    endif()
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
    execute_process(COMMAND ${HAZEL_PYTHON_EXECUTABLE} -m hazel package --cmake --main --source "${CMAKE_CURRENT_SOURCE_DIR}" OUTPUT_FILE "${HAZEL_GENERATED_DIR}/package-info.cmake")
    include("${HAZEL_GENERATED_DIR}/package-info.cmake")
    if(NOT PROJECT_NAME STREQUAL "${HAZEL_PACKAGE_NAME}")
        message(FATAL_ERROR "Project name '${PROJECT_NAME}' differs from package name '${HAZEL_PACKAGE_NAME}'")
    endif()
    if(DEFINED PROJECT_VERSION AND NOT PROJECT_VERSION VERSION_EQUAL "${HAZEL_PACKAGE_VERSION}")
        message(AUTHOR_WARNING "Project version '${PROJECT_VERSION}' differs from package version '${HAZEL_PACKAGE_VERSION}'")
    endif()
    if(NOT DEFINED PROJECT_VERSION)
        set(PROJECT_VERSION "${HAZEL_PACKAGE_VERSION}")
        if(HAZEL_PACKAGE_VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
            set(PROJECT_VERSION_MAJOR "${CMAKE_MATCH_1}")
            set(PROJECT_VERSION_MINOR "${CMAKE_MATCH_2}")
            set(PROJECT_VERSION_PATCH "${CMAKE_MATCH_3}")
        endif()
    endif()
    if(NOT "hazel" IN_LIST HAZEL_PACKAGE_BUILDTOOL_DEPENDS AND NOT PROJECT_NAME STREQUAL "hazel")
        message(AUTHOR_WARNING "Package '${PROJECT_NAME}' does not declare its buildtool_depend on 'hazel'")
    endif()
endmacro()