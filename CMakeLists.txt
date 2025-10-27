cmake_minimum_required(VERSION 3.20)
project(RaytracingInOneHour)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

set(TARGET RaytracingInOneHour)
set(SOURCES src/main.cpp
        Includes/HelloTriangle.cpp
        Includes/HelloTriangle.hpp
        Includes/DebugInfoLog.hpp
        Includes/Utils.hpp
        Includes/Structs.hpp
        Includes/Utils.hpp
        Includes/Camera/Camera.cpp
        Includes/Camera/Camera.hpp)

set(CFLAGS_RELEASE "-O2")
set(CFLAGS_DEBUG "-g")

set(IMGUI_PATH "${CMAKE_SOURCE_DIR}/Includes/imgui")
file(GLOB IMGUI_SOURCES
        ${IMGUI_PATH}/*.cpp
        ${IMGUI_PATH}/backends/imgui_impl_glfw.h
        ${IMGUI_PATH}/backends/imgui_impl_glfw.cpp
        ${IMGUI_PATH}/backends/imgui_impl_vulkan.cpp
        ${IMGUI_PATH}/backends/imgui_impl_vulkan.h
)



# Find Vulkan, GLFW, and GLM
find_package(Vulkan REQUIRED)
find_package(glfw3 3.3 REQUIRED)
find_package(glm REQUIRED)

# Add executable
add_executable(${TARGET} ${SOURCES})

# Include GLM headers
target_include_directories(${TARGET} PRIVATE ${GLM_INCLUDE_DIRS})

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
        ${CMAKE_SOURCE_DIR}/Includes
)

# Set compile options based on build type
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(${TARGET} PRIVATE ${CFLAGS_RELEASE})
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${TARGET} PRIVATE ${CFLAGS_DEBUG})
endif()

file(COPY ${CMAKE_SOURCE_DIR}/Shaders DESTINATION ${CMAKE_BINARY_DIR})
file(COPY ${CMAKE_SOURCE_DIR}/Fonts DESTINATION ${CMAKE_BINARY_DIR})

# Link libraries
target_link_libraries(${TARGET} PRIVATE glfw Vulkan::Vulkan)
add_library("ImGui" STATIC ${IMGUI_SOURCES})
target_include_directories("ImGui" PUBLIC ${IMGUI_PATH})
target_include_directories("ImGui" PUBLIC ${IMGUI_PATH}/backends)

target_link_libraries(${TARGET} PUBLIC ImGui)

# Custom target for running the executable
add_custom_target(run
        COMMAND ./${TARGET}
        COMMAND ./Shaders/compile.sh
        DEPENDS ${TARGET}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Custom target for cleaning the build
add_custom_target(reset
        COMMAND ${CMAKE_COMMAND} -E remove ${TARGET}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)



