##############################################################################
#
# Hazel Build System
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
function(hazel_project)
    set(HAZEL_PACKAGE_XML "${PROJECT_SOURCE_DIR}/package.xml")
    if(NOT EXISTS "${HAZEL_PACKAGE_XML}")
        message(FATAL_ERROR "cannot find 'package.xml' in project source directory")
    endif()
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}")
    execute_process(COMMAND ${HAZEL_PYTHON_EXECUTABLE} -m hazel package --cmake --main --source "${HAZEL_PACKAGE_XML}" OUTPUT_FILE "${HAZEL_GENERATED_DIR}/package-metadata.cmake" RESULT_VARIABLE hazel_package_info_result)
    if(NOT hazel_package_info_result EQUAL 0)
        message(FATAL_ERROR "failed to parse package metadata")
    endif()
    include("${HAZEL_GENERATED_DIR}/package-metadata.cmake")
    if(NOT PROJECT_NAME STREQUAL "${HAZEL_PACKAGE_NAME}")
        message(FATAL_ERROR "project name '${PROJECT_NAME}' differs from package name '${HAZEL_PACKAGE_NAME}'")
    endif()
    if(DEFINED PROJECT_VERSION AND NOT PROJECT_VERSION VERSION_EQUAL "${HAZEL_PACKAGE_VERSION}")
        message(AUTHOR_WARNING "project version '${PROJECT_VERSION}' differs from package version '${HAZEL_PACKAGE_VERSION}'")
    endif()
    if(NOT DEFINED PROJECT_VERSION)
        set(PROJECT_VERSION "${HAZEL_PACKAGE_VERSION}" PARENT_SCOPE)
        if(HAZEL_PACKAGE_VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
            set(PROJECT_VERSION_MAJOR "${CMAKE_MATCH_1}" PARENT_SCOPE)
            set(PROJECT_VERSION_MINOR "${CMAKE_MATCH_2}" PARENT_SCOPE)
            set(PROJECT_VERSION_PATCH "${CMAKE_MATCH_3}" PARENT_SCOPE)
        endif()
    endif()
    if(NOT "hazel" IN_LIST HAZEL_PACKAGE_BUILDTOOL_DEPENDS AND NOT PROJECT_NAME STREQUAL "hazel")
        message(AUTHOR_WARNING "package '${PROJECT_NAME}' does not declare its buildtool_depend on 'hazel'")
    endif()
    set(HAZEL_PACKAGE_XML "${HAZEL_PACKAGE_XML}" PARENT_SCOPE)
endfunction()
