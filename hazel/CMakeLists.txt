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
cmake_minimum_required(VERSION 3.14)
project(hazel)

include(cmake/all.cmake)
include(CMakePackageConfigHelpers)

configure_package_config_file(config.cmake.in "${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
    NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
write_basic_package_version_file("${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
    ARCH_INDEPENDENT
)
if(HAZEL_DEVEL_PREFIX)
    file(COPY "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
    configure_package_config_file(config.cmake.in "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
        NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
        INSTALL_PREFIX "${HAZEL_DEVEL_PREFIX}"
    )
endif()

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}"
)

set(cmake_files
    cmake/all.cmake
    cmake/destinations.cmake
    cmake/export.cmake
    cmake/list_exported_targets.py
    cmake/package-config.cmake.em
    cmake/package-config.context.in
    cmake/package.cmake
    cmake/project.cmake
    cmake/python.cmake
    cmake/script.context.in
    cmake/status.cmake
)

foreach(file IN LISTS cmake_files)
    install(FILES ${file} DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}")
    if(HAZEL_DEVEL_PREFIX)
        file(COPY ${file} DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
    endif()
endforeach()

hazel_python_setup()