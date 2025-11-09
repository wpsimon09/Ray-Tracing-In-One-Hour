set (CMAKE_SYSTEM_NAME Windows)
set (CMAKE_SYSTEM_VERSION 10)

# Compiler
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)

# Optional: static runtime (no DLLs)
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)

# Adjust find paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Optional: produce static exe (no dependencies)
set(CMAKE_EXE_LINKER_FLAGS "-static")