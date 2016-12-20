cmake_minimum_required(VERSION 3.6)
project(Final)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
    assets/bullet.png
    assets/enemy.png
    assets/plane.png
    assets/readme.txt
    assets/solarpanel.png
    assets/sun.png
    conf.lua
    main.lua)

add_executable(Final ${SOURCE_FILES})