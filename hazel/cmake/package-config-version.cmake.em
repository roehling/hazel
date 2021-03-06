@##############################################################################
@#
@# Hazel Build System
@# Copyright 2020-2021 Timo Röhling <timo@gaussglocke.de>
@#
@# Licensed under the Apache License, Version 2.0 (the "License");
@# you may not use this file except in compliance with the License.
@# You may obtain a copy of the License at
@#
@# http://www.apache.org/licenses/LICENSE-2.0
@#
@# Unless required by applicable law or agreed to in writing, software
@# distributed under the License is distributed on an "AS IS" BASIS,
@# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@# See the License for the specific language governing permissions and
@# limitations under the License.
@#
@# The following license applies to all configuration files which are
@# generated from this template:
##############################################################################
#
# package configuration version file generated by the Hazel Build System
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty. This file is offered as-is, without
# any warranty.
#
##############################################################################
@{
if HAZEL_PACKAGE_COMPATIBILITY == "SemanticVersion" or HAZEL_PACKAGE_COMPATIBILITY == "Semver":
    if PROJECT_VERSION_MAJOR > 0:
        HAZEL_PACKAGE_COMPATIBILITY = "SameMajorVersion"
    else:
        HAZEL_PACKAGE_COMPATIBILITY = "ExactVersion"
}@
set(PACKAGE_VERSION "@(PROJECT_VERSION)")
@[if HAZEL_PACKAGE_COMPATIBILITY in ["ExactVersion", "SameMajorVersion", "SameMinorVersion", "AnyNewerVersion"] ]@
# Package version strategy is "@(HAZEL_PACKAGE_COMPATIBILITY)"
if(PACKAGE_FIND_VERSION_RANGE)
@[if HAZEL_PACKAGE_COMPATIBILITY != "ExactVersion"]@
@[if HAZEL_PACKAGE_COMPATIBILITY != "AnyNewerVersion"]@
@[if HAZEL_PACKAGE_COMPATIBILITY == "SameMajorVersion"]@
    if(NOT PACKAGE_FIND_VERSION_MIN_MAJOR STREQUAL "@(PROJECT_VERSION_MAJOR)" OR
        (PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "INCLUDE" AND NOT PACKAGE_FIND_VERSION_MAX_MAJOR STREQUAL "@(PROJECT_VERSION_MAJOR)") OR
        (PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "EXCLUDE" AND NOT PACKAGE_FIND_VERSION_MAX VERSION_LESS_EQUAL "@(PROJECT_VERSION_MAJOR + 1)"))
@[elif HAZEL_PACKAGE_COMPATIBILITY == "SameMinorVersion"]@
    if(NOT PACKAGE_FIND_VERSION_MIN_MAJOR STREQUAL "@(PROJECT_VERSION_MAJOR)" OR
        NOT PACKAGE_FIND_VERSION_MAX_MAJOR STREQUAL "@(PROJECT_VERSION_MAJOR)" OR
        NOT PACKAGE_FIND_VERSION_MIN_MINOR STREQUAL "@(PROJECT_VERSION_MINOR)" OR
        (PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "INCLUDE" AND NOT PACKAGE_FIND_VERSION_MAX_MINOR STREQUAL "@(PROJECT_VERSION_MINOR)") OR
        (PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "EXCLUDE" AND NOT PACKAGE_FIND_VERSION_MAX VERSION_LESS_EQUAL "@(PROJECT_VERSION_MAJOR).@(PROJECT_VERSION_MINOR + 1)"))
@[end if]@
        set(PACKAGE_VERSION_COMPATIBLE FALSE)
        return()
    endif()
@[end if]@
    if(PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION_MIN AND
        ((PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "INCLUDE" AND PACKAGE_VERSION VERSION_LESS_EQUAL PACKAGE_FIND_VERSION_MAX) OR
        (PACKAGE_FIND_VERSION_RANGE_MAX STREQUAL "EXCLUDE" AND PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION_MAX)))
        set(PACKAGE_VERSION_COMPATIBLE TRUE)
    endif()
    return()
@[else]@
    message(AUTHOR_WARNING
        "Package '${PACKAGE_FIND_NAME}' declares that different versions are "
        "always incompatible with each other, so version ranges in "
        "find_package() are ignored. Only the lower endpoint of the version "
        "range is used to determine compatibility."
    )
@[end if]@
endif()
@[if HAZEL_PACKAGE_COMPATIBILITY == "AnyNewerVersion"]@
if(PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION)
@[elif HAZEL_PACKAGE_COMPATIBILITY == "SameMajorVersion"]@
if(PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION AND
    PACKAGE_FIND_VERSION_MAJOR STREQUAL "@(PROJECT_VERSION_MAJOR)")
@[elif HAZEL_PACKAGE_COMPATIBILITY == "SameMinorVersion"]@
if(PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION AND
    "${PACKAGE_FIND_VERSION_MAJOR}.${PACKAGE_FIND_VERSION_MINOR}" STREQUAL "@(PROJECT_VERSION_MAJOR).@(PROJECT_VERSION_MINOR)")
@[elif HAZEL_PACKAGE_COMPATIBILITY == "ExactVersion"]@
if(PACKAGE_VERSION VERSION_GREATER_EQUAL PACKAGE_FIND_VERSION AND
    "${PACKAGE_FIND_VERSION_MAJOR}.${PACKAGE_FIND_VERSION_MINOR}.${PACKAGE_FIND_VERSION_PATCH}" STREQUAL "@(PROJECT_VERSION_MAJOR).@(PROJECT_VERSION_MINOR).@(PROJECT_VERSION_PATCH)")
@[end if]@
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
@[if HAZEL_PACKAGE_COMPATIBILITY == "ExactVersion"]@
    set(PACKAGE_VERSION_EXACT TRUE)
@[end if]@
else()
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
endif()
@[if HAZEL_PACKAGE_COMPATIBILITY != "ExactVersion"]@
if("${PACKAGE_FIND_VERSION_MAJOR}.${PACKAGE_FIND_VERSION_MINOR}.${PACKAGE_FIND_VERSION_PATCH}" STREQUAL "@(PROJECT_VERSION_MAJOR).@(PROJECT_VERSION_MINOR).@(PROJECT_VERSION_PATCH)")
    set(PACKAGE_VERSION_EXACT TRUE)
endif()
@[end if]@
@[if not HAZEL_PACKAGE_ARCHITECTURE_INDEPENDENT and CMAKE_SIZEOF_VOID_P != 0]@
if(DEFINED HAZEL_PACKAGE_NAME AND HAZEL_PACKAGE_ARCHITECTURE_INDEPENDENT)
    message(AUTHOR_WARNING
        "Package '${HAZEL_PACKAGE_NAME}' says it is architecture-independent, "
        "but it depends on the architecture-dependent package '${PACKAGE_FIND_NAME}'"
    )
endif()
if(CMAKE_SIZEOF_VOID_P STREQUAL "")
    return()
endif()
if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "@(CMAKE_SIZEOF_VOID_P)")
    set(PACKAGE_VERSION "${PACKAGE_VERSION} (@(8 * CMAKE_SIZEOF_VOID_P)bit)")
    set(PACKAGE_VERSION_UNSUITABLE TRUE)
endif()
@[end if]@
@[else]@
# FIXME The package '@(PROJECT_NAME)' is broken
message(AUTHOR_WARNING
    "Package '${PACKAGE_FIND_NAME}' declares the unknown version "
    "compatibility strategy '@(HAZEL_PACKAGE_COMPATIBILITY)'"
)
set(PACKAGE_VERSION_COMPATIBLE FALSE)
@[end if]@
