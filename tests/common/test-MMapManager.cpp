/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include "catch2/catch.hpp"
#include "MMapDefines.h"
#include "MMapManager.h"
#include "DetourNavMeshBuilder.h"
#include <boost/filesystem.hpp>
#include <cstddef>
#include <fstream>
#include <memory>

namespace
{
    // Synthetic navigation data keeps these tests independent of a WoW client,
    // server installation, database, or a user's extracted map assets.
    class MMapTestFiles
    {
    public:
        MMapTestFiles()
            : _directory(boost::filesystem::temp_directory_path() /
                boost::filesystem::unique_path("trinity-mmap-test-%%%%-%%%%-%%%%"))
        {
            REQUIRE(boost::filesystem::create_directory(_directory));
            REQUIRE(boost::filesystem::create_directory(_directory / "mmaps"));

            dtNavMeshParams meshParams{};
            meshParams.tileWidth = 1.0f;
            meshParams.tileHeight = 1.0f;
            meshParams.maxTiles = 8;
            meshParams.maxPolys = 8;
            WriteMap("007.mmap", meshParams);
            WriteMap("008.mmap", meshParams);

            unsigned short const vertices[] = { 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0 };
            unsigned short const polygons[] = { 0, 1, 2, 3, 0xffff, 0xffff, 0xffff, 0xffff };
            unsigned short const flags[] = { 1 };
            unsigned char const areas[] = { 1 };
            dtNavMeshCreateParams params{};
            params.verts = vertices;
            params.vertCount = 4;
            params.polys = polygons;
            params.polyFlags = flags;
            params.polyAreas = areas;
            params.polyCount = 1;
            params.nvp = 4;
            params.bmax[0] = params.bmax[1] = params.bmax[2] = 1.0f;
            params.walkableHeight = 1.0f;
            params.cs = params.ch = 1.0f;

            unsigned char* rawData = nullptr;
            int dataSize = 0;
            bool built = dtCreateNavMeshData(&params, &rawData, &dataSize);
            std::unique_ptr<unsigned char, decltype(&dtFree)> data(rawData, &dtFree);
            REQUIRE(built);
            REQUIRE(dataSize > 0);

            MmapTileHeader header;
            header.size = static_cast<uint32>(dataSize);
            std::ofstream tile(TilePath().string(), std::ios::binary);
            tile.write(reinterpret_cast<char const*>(&header), sizeof(header));
            tile.write(reinterpret_cast<char const*>(data.get()), dataSize);
            tile.close();
            REQUIRE(tile.good());
        }

        ~MMapTestFiles()
        {
            // Only the uniquely created fixture directory is owned by this test.
            boost::system::error_code error;
            boost::filesystem::remove_all(_directory, error);
        }

        std::string BasePath() const { return _directory.generic_string() + "/"; }

        void SetTileVersion(uint32 version)
        {
            std::fstream tile(TilePath().string(), std::ios::binary | std::ios::in | std::ios::out);
            tile.seekp(offsetof(MmapTileHeader, mmapVersion));
            tile.write(reinterpret_cast<char const*>(&version), sizeof(version));
            tile.close();
            REQUIRE(tile.good());
        }

    private:
        boost::filesystem::path TilePath() const { return _directory / "mmaps" / "0070000.mmtile"; }

        void WriteMap(char const* name, dtNavMeshParams const& params)
        {
            std::ofstream map((_directory / "mmaps" / name).string(), std::ios::binary);
            map.write(reinterpret_cast<char const*>(&params), sizeof(params));
            map.close();
            REQUIRE(map.good());
        }

        boost::filesystem::path _directory;
    };
}

TEST_CASE("MMap tile loading is idempotent", "[MMapManager]")
{
    MMapTestFiles files;
    MMAP::MMapManager manager;

    REQUIRE(manager.loadMap(files.BasePath(), 7, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 1);
    dtNavMesh const* mesh = manager.GetNavMesh(7);

    REQUIRE(manager.loadMap(files.BasePath(), 7, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 1);
    REQUIRE(manager.GetNavMesh(7) == mesh);

    REQUIRE(manager.unloadMap(7, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 0);
    REQUIRE(manager.loadMap(files.BasePath(), 7, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 1);
    REQUIRE(manager.unloadMap(7));
    REQUIRE(manager.getLoadedTilesCount() == 0);
}

TEST_CASE("MMap load failures remain distinguishable from success", "[MMapManager]")
{
    MMapTestFiles files;
    MMAP::MMapManager manager;

    SECTION("Missing map")
    {
        REQUIRE_FALSE(manager.loadMap(files.BasePath(), 9, 0, 0));
    }
    SECTION("Missing tile")
    {
        REQUIRE_FALSE(manager.loadMap(files.BasePath(), 7, 1, 1));
    }
    SECTION("Mismatched generator version")
    {
        files.SetTileVersion(MMAP_VERSION + 1);
        REQUIRE_FALSE(manager.loadMap(files.BasePath(), 7, 0, 0));
    }
    REQUIRE(manager.getLoadedTilesCount() == 0);
}

TEST_CASE("MMap parent tile fallback remains idempotent", "[MMapManager]")
{
    MMapTestFiles files;
    MMAP::MMapManager manager;
    manager.InitializeThreadUnsafe({ { 7, { 8 } }, { 8, {} } });

    REQUIRE(manager.loadMap(files.BasePath(), 8, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 1);
    REQUIRE(manager.loadMap(files.BasePath(), 8, 0, 0));
    REQUIRE(manager.getLoadedTilesCount() == 1);
    REQUIRE(manager.unloadMap(8));
    REQUIRE(manager.getLoadedTilesCount() == 0);
}
