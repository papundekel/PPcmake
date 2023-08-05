cmake_minimum_required(VERSION 3.20)

project(
    PPcmake
    VERSION 0.1.1
    LANGUAGES CXX)

include("PPcmake.cmake")
pp_include_cpack()

pp_install_file("PPcmake.cmake" ${PP_INSTALL_CMAKEDIR})
