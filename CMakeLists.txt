cmake_minimum_required(VERSION 3.20)
project(RaytracingInOneHour)

# -------------------------------
# C++ standard
# -------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

# -------------------------------
# Target and sources
# -------------------------------
set(TARGET RaytracingInOneHour)

set(SOURCES
    src/main.cpp
    Includes/RenderingEngine.cpp
    Includes/RenderingEngine.hpp
    Includes/DebugInfoLog.hpp
    Includes/Utils.hpp
    Includes/Structs.hpp
    Includes/Camera/Camera.cpp
    Includes/Camera/Camera.hpp
)

# -------------------------------
# Compiler flags
# -------------------------------
set(CFLAGS_RELEASE "-O2")
set(CFLAGS_DEBUG "-g")

# -------------------------------
# External libraries
# -------------------------------
# ImGui
set(IMGUI_PATH "${CMAKE_SOURCE_DIR}/external/imgui")
file(GLOB IMGUI_SOURCES
    ${IMGUI_PATH}/*.cpp
    ${IMGUI_PATH}/backends/imgui_impl_glfw.cpp
    ${IMGUI_PATH}/backends/imgui_impl_vulkan.cpp
    ${IMGUI_PATH}/backends/imgui_impl_glfw.h
    ${IMGUI_PATH}/backends/imgui_impl_vulkan.h
)

# -------------------------------
# Create executable
# -------------------------------
add_executable(${TARGET} ${SOURCES})

# Include directories
target_include_directories(${TARGET} PRIVATE
    external/glm
    ${CMAKE_SOURCE_DIR}/Includes
)

# -------------------------------
# Compile options per build type
# -------------------------------
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(${TARGET} PRIVATE ${CFLAGS_RELEASE})
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${TARGET} PRIVATE ${CFLAGS_DEBUG})
endif()

# -------------------------------
# Copy resources
# -------------------------------
file(COPY ${CMAKE_SOURCE_DIR}/Shaders DESTINATION ${CMAKE_BINARY_DIR})
file(COPY ${CMAKE_SOURCE_DIR}/Fonts DESTINATION ${CMAKE_BINARY_DIR})

# -------------------------------
# Link libraries
# -------------------------------
# ImGui library
add_library(ImGui STATIC ${IMGUI_SOURCES})
target_include_directories(ImGui PUBLIC
    ${IMGUI_PATH}
    ${IMGUI_PATH}/backends
    ${CMAKE_SOURCE_DIR}/external/volk
)

# GLFW library
add_subdirectory(external/glfw)

# volk library
add_subdirectory(external/volk)

# Link to executable
target_link_libraries(${TARGET} PRIVATE
    volk    
    glfw
    ImGui
)


# -------------------------------
# Custom targets
# -------------------------------
# Run the program
add_custom_target(run
    COMMAND ./${TARGET}
    COMMAND ./Shaders/compile.sh
    DEPENDS ${TARGET}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Clean the build
add_custom_target(reset
    COMMAND ${CMAKE_COMMAND} -E remove ${TARGET}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
