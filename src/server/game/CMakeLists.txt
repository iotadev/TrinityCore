# This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

CollectSourceFiles(
  ${CMAKE_CURRENT_SOURCE_DIR}
  PRIVATE_SOURCES
  # Exclude
  ${CMAKE_CURRENT_SOURCE_DIR}/PrecompiledHeaders)

if(USE_COREPCH)
  set(PRIVATE_PCH_HEADER PrecompiledHeaders/gamePCH.h)
endif()

GroupSources(${CMAKE_CURRENT_SOURCE_DIR})

add_definitions(-DTRINITY_API_EXPORT_GAME)

CollectIncludeDirectories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC_INCLUDES
  # Exclude
  ${CMAKE_CURRENT_SOURCE_DIR}/PrecompiledHeaders)

# Provide an interface target for the game project to allow
# dependent projects to build meanwhile.
add_library(game-interface INTERFACE)

target_include_directories(game-interface
  INTERFACE
    ${PUBLIC_INCLUDES})

target_link_libraries(game-interface
  INTERFACE
    shared
    Detour)

add_library(game
  ${PRIVATE_SOURCES})

# Optional module sources live outside the core and use its native static target.
add_subdirectory("${CMAKE_SOURCE_DIR}/modules" "modules")
get_property(TC_MODULE_CONFIG_FILES GLOBAL PROPERTY TC_MODULE_CONFIG_FILES)
list(LENGTH TC_MODULE_CONFIG_FILES TC_MODULE_CONFIG_COUNT)
set(TC_MODULE_CONFIG_ENTRIES "")
foreach(MODULE_CONFIG_FILE IN LISTS TC_MODULE_CONFIG_FILES)
  string(APPEND TC_MODULE_CONFIG_ENTRIES "    \"${MODULE_CONFIG_FILE}\",\n")
endforeach()
get_property(TC_ENABLED_MODULE_NAMES GLOBAL PROPERTY TC_ENABLED_MODULE_NAMES)
list(FIND TC_ENABLED_MODULE_NAMES "mod-playerbots" TC_PLAYERBOTS_INDEX)
set(TC_MODULE_PLAYERBOTS OFF)
if(NOT TC_PLAYERBOTS_INDEX EQUAL -1)
  set(TC_MODULE_PLAYERBOTS ON)
endif()
list(FIND TC_ENABLED_MODULE_NAMES "mod-ahbot" TC_AHBOT_INDEX)
set(TC_MODULE_AHBOT OFF)
if(NOT TC_AHBOT_INDEX EQUAL -1)
  set(TC_MODULE_AHBOT ON)
endif()
configure_file("${CMAKE_SOURCE_DIR}/modules/ModuleConfigFiles.h.in" ModuleConfigFiles.h @ONLY)
configure_file("${CMAKE_SOURCE_DIR}/modules/ModuleBuildConfig.h.in" ModuleBuildConfig.h)
get_property(TC_MODULE_SCRIPT_LOADERS GLOBAL PROPERTY TC_MODULE_SCRIPT_LOADERS)
set(TC_MODULE_SCRIPT_DECLARATIONS "")
set(TC_MODULE_SCRIPT_CALLS "")
foreach(MODULE_SCRIPT_LOADER IN LISTS TC_MODULE_SCRIPT_LOADERS)
  string(APPEND TC_MODULE_SCRIPT_DECLARATIONS "void ${MODULE_SCRIPT_LOADER}();\n")
  string(APPEND TC_MODULE_SCRIPT_CALLS "    ${MODULE_SCRIPT_LOADER}();\n")
endforeach()
configure_file("${CMAKE_SOURCE_DIR}/modules/ModuleScriptLoader.h.in" ModuleScriptLoader.h @ONLY)

target_include_directories(game
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(game
  PRIVATE
    trinity-core-interface
    efsw
  PUBLIC
    game-interface)

set_target_properties(game
    PROPERTIES
      FOLDER
        "server")

if(UNITY_BUILDS)
  set_target_properties(game
      PROPERTIES UNITY_BUILD ON)
  set_target_properties(game
      PROPERTIES
        UNITY_BUILD_MODE BATCH
        UNITY_BUILD_BATCH_SIZE 8)
endif()

if(BUILD_SHARED_LIBS)
  if(UNIX)
    install(TARGETS game
      LIBRARY
        DESTINATION lib)
  elseif(WIN32)
    install(TARGETS game
      RUNTIME
        DESTINATION "${CMAKE_INSTALL_PREFIX}")
  endif()
endif()

# Generate precompiled header
if(USE_COREPCH)
  add_cxx_pch(game ${PRIVATE_PCH_HEADER})
endif()
