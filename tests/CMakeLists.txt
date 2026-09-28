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
  ${CMAKE_CURRENT_SOURCE_DIR}/common
  COMMON_SOURCES
)

get_property(MODULE_TEST_SOURCES GLOBAL PROPERTY TC_MODULE_TEST_SOURCES)
get_property(MODULE_TEST_LIBRARIES GLOBAL PROPERTY TC_MODULE_TEST_LIBRARIES)
add_executable(tests-common ${COMMON_SOURCES} ${MODULE_TEST_SOURCES})

target_link_libraries(tests-common
  PRIVATE
    trinity-core-interface
    common
    ${MODULE_TEST_LIBRARIES}
    Catch2::Catch2)

catch_discover_tests(tests-common)
