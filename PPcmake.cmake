cmake_minimum_required(VERSION 3.22)

include(GNUInstallDirs)

find_package(Git)
if(NOT Git_FOUND)
    message(FATAL_ERROR "Git not found")
endif()

#

set(PPCMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/cmake")
set(PPCMAKE_VENDORDIR "${CMAKE_SOURCE_DIR}/vendor")
set(PPCMAKE_MODULE_PATH "${PPCMAKE_VENDORDIR}/${PPCMAKE_INSTALL_CMAKEDIR}")
set(PPCMAKE_PACKAGES_DIR "${CMAKE_BINARY_DIR}/packages/")

#

set(CMAKE_MODULE_PATH "${PPCMAKE_VENDORDIR}/${PPCMAKE_INSTALL_CMAKEDIR}")

#

file(MAKE_DIRECTORY "${PPCMAKE_PACKAGES_DIR}")

#

function(PPcmake_package _GIT_SERVER _USER _REPOSITORY _TAG)
    set(_repo_dir_src "${PPCMAKE_PACKAGES_DIR}/${_REPOSITORY}")
    set(_repo_dir_out "${_repo_dir_src}/out-cmake")

    if(NOT EXISTS "${_repo_dir_src}")
        execute_process(
            COMMAND "${GIT_EXECUTABLE}"
                "clone"
                "--branch" "${_TAG}"
                "--depth" "1"
                "https://${_GIT_SERVER}/${_USER}/${_REPOSITORY}"
                "${_repo_dir_src}"
            OUTPUT_FILE "${PPCMAKE_PACKAGES_DIR}/output.log"
            ERROR_FILE "${PPCMAKE_PACKAGES_DIR}/errors.log"
            COMMAND_ECHO STDOUT
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "-S" "${_repo_dir_src}"
                "-B" "${_repo_dir_out}"
                "-G" "Ninja Multi-Config"
            OUTPUT_FILE "${PPCMAKE_PACKAGES_DIR}/output.log"
            ERROR_FILE "${PPCMAKE_PACKAGES_DIR}/errors.log"
            COMMAND_ECHO STDOUT
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "--build" "${_repo_dir_out}"
                "--config" "Release"
                "--target all"
                "-j" "10"
            OUTPUT_FILE "${PPCMAKE_PACKAGES_DIR}/output.log"
            ERROR_FILE "${PPCMAKE_PACKAGES_DIR}/errors.log"
            COMMAND_ECHO STDOUT
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "--install" "${_repo_dir_out}"
                "--config" "Release"
                "--prefix" "${PPCMAKE_VENDORDIR}"
            OUTPUT_FILE "${PPCMAKE_PACKAGES_DIR}/output.log"
            ERROR_FILE "${PPCMAKE_PACKAGES_DIR}/errors.log"
            COMMAND_ECHO STDOUT
        )
    endif()
endfunction()

function(PPcmake_reset_notfound_var _LIST)
    if(NOT ${_LIST})
        set(${_LIST} "" PARENT_SCOPE)
    endif()
endfunction()

function(PPcmake_cpack)
    set(CPACK_GENERATOR "TGZ" PARENT_SCOPE)
    include(CPack)
endfunction()

function(PPcmake_install_file _FILEPATH)
    if("${_FILEPATH}" MATCHES "\.cmake$")
        set(_dest "${PPCMAKE_INSTALL_CMAKEDIR}")
    elseif("${_FILEPATH}" MATCHES "\.format$")
        set(_dest "${CMAKE_INSTALL_SHAREDSTATEDIR}")
    endif()

    install(FILES "${_FILEPATH}" DESTINATION "${_dest}")
endfunction()

function(PPcmake_target_pedantic_errors _target)
	if(CMAKE_COMPILER_IS_GNUCXX)
		target_compile_options("${_target}"
			PUBLIC "-Wall" "-Wextra" "-pedantic" "-Werror"
		)
	endif()
endfunction()

function(PPcmake_add_subdirectory _DIR)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${_DIR}/")
        add_subdirectory("${_DIR}")
    endif()
endfunction()
