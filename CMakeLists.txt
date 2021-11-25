cmake_minimum_required(VERSION 3.20)

project(PPcmake VERSION "1.0.0")

include("PPcmake.cmake")

PPcmake_init()

PPcmake_install_file("PPcmake.cmake")

PPcmake_cpack()
