cmake_minimum_required(VERSION 3.20)

include(GNUInstallDirs)

find_package(Git)
if(NOT Git_FOUND)
    message(FATAL_ERROR "Git not found")
endif()

#

if (EXISTS "${CMAKE_SOURCE_DIR}/deps")
    file(READ "${CMAKE_SOURCE_DIR}/deps" _deps)
    string(REGEX REPLACE "\n" ";" _deps "${_deps}")
endif()

#

if (NOT DEFINED ENV{PProot})
    message(FATAL_ERROR "Variable PProot undefined, please define it first.")
endif()

set(_root_dir "$ENV{PProot}")
set(_install_cmake_subdir "${CMAKE_INSTALL_DATADIR}/cmake")

#

function(PPcmake_execute_process _NAME _COMMAND _LOGS_OUTPUT_DIR _LOGS_ERRORS_DIR)
    execute_process(
        COMMAND "${_COMMAND}"
        OUTPUT_FILE "${_LOGS_OUTPUT_DIR}/${_NAME}.log"
        ERROR_FILE "${_LOGS_ERRORS_DIR}/${_NAME}.log"
        COMMAND_ECHO STDOUT
        COMMAND_ERROR_IS_FATAL ANY
    )
endfunction(PPcmake_execute_process )

#

function(PPcmake_package _NAME _TAG _PATH)
    set(_package_dir "${_root_dir}/${_NAME}/${_TAG}")
    
    if(NOT EXISTS "${_package_dir}")
        set(_source_dir "${_package_dir}/source")
        set(_build_dir "${_package_dir}/build")
        set(_install_dir "${_package_dir}/install")
        set(_logs_output_dir "${_package_dir}/logs/output")
        set(_logs_errors_dir "${_package_dir}/logs/errors")

        file(MAKE_DIRECTORY "${_logs_output_dir}" "${_logs_errors_dir}")

        execute_process(
            COMMAND "${GIT_EXECUTABLE}"
                "clone"
                "--branch" "${_TAG}"
                "--depth" "1"
                "${_PATH}"
                "${_source_dir}"
            OUTPUT_FILE "${_logs_output_dir}/clone.log"
            ERROR_FILE "${_logs_errors_dir}/clone.log"
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "-S" "${_source_dir}"
                "-B" "${_build_dir}"
                "-G" "Ninja Multi-Config"
            OUTPUT_FILE "${_logs_output_dir}/generate.log"
            ERROR_FILE "${_logs_errors_dir}/generate.log"
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "--build" "${_build_dir}"
                "--config" "Release"
                "--target all"
                "-j" "8"
            OUTPUT_FILE "${_logs_output_dir}/build.log"
            ERROR_FILE "${_logs_errors_dir}/build.log"
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND "${CMAKE_COMMAND}"
                "--install" "${_build_dir}"
                "--config" "Release"
                "--prefix" "${_install_dir}"
            OUTPUT_FILE "${_logs_output_dir}/install.log"
            ERROR_FILE "${_logs_errors_dir}/install.log"
            COMMAND_ECHO STDOUT
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif()

    set(CMAKE_MODULE_PATH "${_install_dir}/${_install_cmake_subdir}" PARENT_SCOPE)
endfunction()

function(PPcmake_reset_notfound_var _LIST)
    if(NOT ${_LIST})
        set(${_LIST} "" PARENT_SCOPE)
    endif()
endfunction()

macro(PPcmake_cpack)
    set(CPACK_GENERATOR "TGZ")
    include(CPack)
endmacro()

function(PPcmake_install_file _FILEPATH)
    if("${_FILEPATH}" MATCHES "\.cmake$")
        set(_dest "${_install_cmake_subdir}")
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

macro(PPcmake_add_subdirectory _DIR)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${_DIR}/")
        add_subdirectory("${_DIR}")
    endif()
endmacro()

#

foreach(_dep ${_deps})
    string(REGEX REPLACE " " ";" _dep "${_dep}")

    list(POP_FRONT _dep _name)
    list(POP_FRONT _dep _tag)
    list(POP_FRONT _dep _path)

    PPcmake_package("${_name}" "${_tag}" "${_path}")

endforeach()
