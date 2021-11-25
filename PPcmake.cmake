cmake_minimum_required(VERSION 3.20)

function(PPcmake_init)
    include(GNUInstallDirs)
    set(PPCMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/cmake" PARENT_SCOPE)
    set(PPCMAKE_VENDORDIR "${CMAKE_CURRENT_LIST_DIR}/vendor")
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${PPCMAKE_VENDORDIR}/${PPCMAKE_INSTALL_CMAKEDIR}" PARENT_SCOPE)
endfunction()

function(PPcmake_download_package _URL)
    cmake_path(GET _URL FILENAME _filename)

    file(DOWNLOAD "${URL}" "${_filename}")
    file(ARCHIVE_EXTRACT INPUT "${_filename}" DESTINATION "${CMAKE_CURRENT_LIST_DIR}/vendor")
    file(REMOVE "${_filename}")
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
