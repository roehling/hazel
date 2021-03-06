##############################################################################
#
# Hazel Build System
# Copyright 2020-2021 Timo Röhling <timo@gaussglocke.de>
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
function(hazel_export)
    cmake_parse_arguments(arg "ONLY_LIBRARIES" "EXPORT;FILE;NAMESPACE" "TARGETS;CMAKE_SCRIPTS" ${ARGN})
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "package '${PROJECT_NAME}' called hazel_export() with invalid parameters: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_NAMESPACE)
        set(arg_NAMESPACE "${PROJECT_NAME}::")
    endif()
    if(arg_ONLY_LIBRARIES)
        set(libs)
        set(exes)
        foreach(target IN LISTS arg_TARGETS)
            get_property(target_type TARGET ${target} PROPERTY TYPE)
            if(target_type MATCHES ".+_LIBRARY$")
                list(APPEND libs "${target}")
            elseif(target_type STREQUAL "EXECUTABLE")
                list(APPEND exes "${target}")
            endif()
        endforeach()
        set(arg_TARGETS "${libs}")
        install(TARGETS ${exes} RUNTIME DESTINATION "${HAZEL_PACKAGE_BIN_DESTINATION}")
    endif()
    if(arg_TARGETS AND NOT arg_EXPORT)
        set(arg_EXPORT "${PROJECT_NAME}Targets")
    endif()
    if(arg_EXPORT)
        if(NOT arg_FILE)
            set(arg_FILE "${arg_EXPORT}")
        endif()
    endif()
    if(arg_FILE)
        if(arg_FILE MATCHES "^(.*)\\.cmake$")
            set(arg_FILE "${CMAKE_MATCH_1}")
        endif()
    endif()
    if(arg_FILE MATCHES "^${PROJECT_NAME}Config(Version)?$")
        message(FATAL_ERROR "hazel_export: export to '${arg_FILE}' conflicts with package configuration files")
    endif()
    if(arg_TARGETS)
        install(TARGETS ${arg_TARGETS} EXPORT "${arg_EXPORT}"
            RUNTIME DESTINATION "${HAZEL_PACKAGE_BIN_DESTINATION}"
            ARCHIVE DESTINATION "${HAZEL_PACKAGE_LIB_DESTINATION}"
            LIBRARY DESTINATION "${HAZEL_PACKAGE_LIB_DESTINATION}"
            OBJECTS DESTINATION "${HAZEL_PACKAGE_OBJECTS_DESTINATION}"
            PUBLIC_HEADER DESTINATION "${HAZEL_PACKAGE_INCLUDE_DESTINATION}"
            INCLUDES DESTINATION "${HAZEL_GLOBAL_INCLUDE_DESTINATION}"
        )
        hazel_append_property(HAZEL_PACKAGE_INSTALLED_TARGETS ${arg_TARGETS})
        foreach(target IN LISTS arg_TARGETS)
            get_property(target_type TARGET ${target} PROPERTY TYPE)
            get_property(depends TARGET ${target} PROPERTY MANUALLY_ADDED_DEPENDENCIES)
            if(target_type MATCHES ".+_LIBRARY$")
                get_property(interface_depends TARGET ${target} PROPERTY INTERFACE_LINK_LIBRARIES)
                list(APPEND depends ${interface_depends})
                if(target_type STREQUAL "STATIC_LIBRARY")
                    get_property(private_depends TARGET ${target} PROPERTY LINK_LIBRARIES)
                    list(APPEND depends ${private_depends})
                endif()
            endif()
            foreach(pkg IN LISTS HAZEL_IMPORTED_PACKAGES)
                foreach(dep IN LISTS depends)
                    if(dep IN_LIST ${pkg}_TARGETS)
                        message(STATUS "hazel_export: exported target '${target}' depends on package '${pkg}'")
                        hazel_append_property(HAZEL_PACKAGE_EXPORTED_DEPENDS "${pkg}")
                        if(NOT pkg IN_LIST HAZEL_PACKAGE_BUILD_EXPORT_DEPENDS)
                            message(AUTHOR_WARNING "package '${PROJECT_NAME}' does not declare its build_export_depend on '${pkg}'")
                        endif()
                        break()
                    endif()
                endforeach()
            endforeach()
            hazel_get_properties(HAZEL_PACKAGE_IMPORTED_TARGETS)
            foreach(dep IN LISTS depends)
                if(dep IN_LIST HAZEL_PACKAGE_IMPORTED_TARGETS)
                    message(STATUS "hazel_export: exported target '${target}' depends on imported target '${dep}'")
                    hazel_append_property(HAZEL_PACKAGE_EXPORTED_DEPENDS "${dep}")
                endif()
                if(dep MATCHES "::" AND NOT TARGET "${dep}")
                    message(SEND_ERROR "hazel_export: exported target '${target}' depends on undefined target '${dep}'")
                endif()
            endforeach()
        endforeach()
    endif()
    if(arg_EXPORT)
        hazel_get_properties(HAZEL_PACKAGE_EXPORTS HAZEL_PACKAGE_EXPORTED_CMAKE_FILES)
        if(NOT arg_EXPORT IN_LIST HAZEL_PACKAGE_EXPORTS)
            if(arg_FILE IN_LIST HAZEL_PACKAGE_EXPORTED_CMAKE_FILES)
                message(SEND_ERROR "package '${PROJECT_NAME}' installs script '${arg_FILE}' more than once")
                return()
            endif()
            install(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}" FILE "${arg_FILE}.cmake")
            if(HAZEL_DEVEL_PREFIX)
                file(MAKE_DIRECTORY "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
                export(EXPORT "${arg_EXPORT}" NAMESPACE "${arg_NAMESPACE}" FILE "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}/${arg_FILE}.cmake")
            endif()
            hazel_append_property(HAZEL_PACKAGE_EXPORTS "${arg_EXPORT}")
            hazel_append_property(HAZEL_PACKAGE_EXPORTED_CMAKE_FILES "${arg_FILE}")
            hazel_append_property(HAZEL_PACKAGE_EXPORTED_TARGET_FILES "${arg_FILE}")
        endif()
    endif()
    if(arg_CMAKE_SCRIPTS)
        _hazel_export_cmake_scripts(${arg_CMAKE_SCRIPTS})
    endif()
endfunction()

macro(_hazel_export_cmake_scripts)
    set(HAZEL_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/hazel-generated")
    file(MAKE_DIRECTORY "${HAZEL_GENERATED_DIR}" "${HAZEL_GENERATED_DIR}/scripts" "${HAZEL_GENERATED_DIR}/scripts/develspace" "${HAZEL_GENERATED_DIR}/scripts/installspace")
    set(PREFIX "\${PACKAGE_PREFIX_DIR}")
    if(HAZEL_DEVEL_PREFIX)
        set(DEVELSPACE TRUE)
        set(INSTALLSPACE FALSE)
        configure_file("${HAZEL_CMAKE_DIR}/script.context.in" "${HAZEL_GENERATED_DIR}/script.develspace.context")
    endif()
    set(DEVELSPACE FALSE)
    set(INSTALLSPACE TRUE)
    configure_file("${HAZEL_CMAKE_DIR}/script.context.in" "${HAZEL_GENERATED_DIR}/script.installspace.context")
    unset(DEVELSPACE)
    unset(INSTALLSPACE)
    foreach(script IN ITEMS ${ARGN})
        if(script MATCHES "^(.*)\\.cmake(\\.develspace|\\.installspace)?(\\.in|\\.em)?$")
            set(script "${CMAKE_MATCH_1}")
        endif()
        if(NOT IS_ABSOLUTE "${script}")
            set(script "${CMAKE_CURRENT_SOURCE_DIR}/${script}")
        endif()
        get_filename_component(script_name "${script}" NAME)
        hazel_get_properties(HAZEL_PACKAGE_EXPORTED_CMAKE_FILES)
        if(script_name IN_LIST HAZEL_PACKAGE_EXPORTED_CMAKE_FILES)
            message(SEND_ERROR "package '${PROJECT_NAME}' installs script '${script_name}' more than once")
            continue()
        endif()
        set(devel_script)
        set(install_script)

        if(EXISTS "${script}.cmake")  # install as-is
            set(devel_script "${script}.cmake")
            set(install_script "${script}.cmake")
        elseif(EXISTS "${script}.cmake.in")  # run configure_file() on it
            set(install_script "${HAZEL_GENERATED_DIR}/scripts/${script_name}.cmake")
            if(HAZEL_DEVEL_PREFIX)
                set(devel_script "${install_script}")
            endif()
            configure_file("${script}.cmake.in" "${install_script}" @ONLY)
        elseif(EXISTS "${script}.cmake.em")  # run empy on it
            if(HAZEL_DEVEL_PREFIX)
                set(devel_script "${HAZEL_GENERATED_DIR}/scripts/develspace/${script_name}.cmake")
                execute_process(COMMAND "${HAZEL_PYTHON_EXECUTABLE}" -m em -F "${HAZEL_GENERATED_DIR}/script.develspace.context" -o "${devel_script}" "${script}.cmake.em")
            endif()
            set(install_script "${HAZEL_GENERATED_DIR}/scripts/installspace/${script_name}.cmake")
            execute_process(COMMAND "${HAZEL_PYTHON_EXECUTABLE}" -m em -F "${HAZEL_GENERATED_DIR}/script.installspace.context" -o "${install_script}" "${script}.cmake.em")
        elseif(EXISTS "${script}.cmake.develspace.in" OR EXISTS "${script}.cmake.installspace.in")  # run configure_file() on it, different versions for develspace and installspace
            if(HAZEL_DEVEL_PREFIX)
                set(devel_script "${HAZEL_GENERATED_DIR}/scripts/develspace/${script_name}.cmake")
                if(EXISTS "${script}.cmake.develspace.in")
                    configure_file("${script}.cmake.develspace.in" "${devel_script}" @ONLY)
                else()
                    file(WRITE "${devel_script}" "# This script is unavailable in develspace")
                endif()
            endif()
            set(install_script "${HAZEL_GENERATED_DIR}/scripts/installspace/${script_name}.cmake")
            if(EXISTS "${script}.cmake.installspace.in")
                configure_file("${script}.cmake.installspace.in" "${install_script}" @ONLY)
            else()
                file(WRITE "${install_script}" "# This script is unavailable in installspace")
            endif()
        elseif(EXISTS "${script}.cmake.develspace.em" OR EXISTS "${script}.cmake.installspace.em")  # run empy on it, different versions for develspace and installspace
            if(HAZEL_DEVEL_PREFIX)
                set(devel_script "${HAZEL_GENERATED_DIR}/scripts/develspace/${script_name}.cmake")
                if(EXISTS "${script}.cmake.develspace.em")
                    execute_process(COMMAND "${HAZEL_PYTHON_EXECUTABLE}" -m em -F "${HAZEL_GENERATED_DIR}/script.develspace.context" -o "${devel_script}" "${script}.cmake.develspace.em")
                else()
                    file(WRITE "${devel_script}" "# This script is unavailable in develspace")
                endif()
            endif()
            set(install_script "${HAZEL_GENERATED_DIR}/scripts/installspace/${script_name}.cmake")
            if(EXISTS "${script}.cmake.installspace.em")
                execute_process(COMMAND "${HAZEL_PYTHON_EXECUTABLE}" -m em -F "${HAZEL_GENERATED_DIR}/script.installspace.context" -o "${install_script}" "${script}.cmake.installspace.em")
            else()
                file(WRITE "${install_script}" "# This script is unavailable in installspace")
            endif()
        else()
            message(SEND_ERROR "cannot find installable CMake script '${script_name}' for package '${PROJECT_NAME}'")
        endif()
        if(devel_script)
            file(COPY "${devel_script}" DESTINATION "${HAZEL_DEVEL_PREFIX}/${HAZEL_PACKAGE_CMAKE_DESTINATION}")
        endif()
        if(install_script)
            install(FILES "${install_script}" DESTINATION "${HAZEL_PACKAGE_CMAKE_DESTINATION}")
        endif()
        hazel_append_property(HAZEL_PACKAGE_EXPORTED_CMAKE_FILES "${script_name}")
    endforeach()
endmacro()
