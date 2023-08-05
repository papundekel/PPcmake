cmake_minimum_required(VERSION 3.20)

include(GNUInstallDirs)

set(PP_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/cmake")

set(_package_distribution_name
    "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}"
)

#

function(pp_reset_notfound_var _LIST)
    if(NOT ${_LIST})
        set(${_LIST}
            ""
            PARENT_SCOPE)
    endif()
endfunction()

macro(pp_include_cpack)
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
    set(CPACK_PACKAGE_FILE_NAME ${_package_distribution_name})
    include(CPack)
endmacro()

function(pp_target_pedantic_errors _target)
    if(CMAKE_COMPILER_IS_GNUCXX)
        target_compile_options("${_target}" PUBLIC "-Wall" "-Wextra"
                                                   "-pedantic" "-Werror")
    endif()
endfunction()

macro(pp_add_subdirectory _DIR)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${_DIR}/")
        add_subdirectory("${_DIR}")
    endif()
endmacro()

function(pp_install_file _FILE _DESTINATION)
    install(FILES "${_FILE}"
            DESTINATION "${_package_distribution_name}/${_DESTINATION}")
endfunction()
