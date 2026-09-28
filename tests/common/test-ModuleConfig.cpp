/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#include "catch2/catch.hpp"
#include "Config.h"
#include <chrono>
#include <filesystem>
#include <fstream>

namespace
{
struct ModuleConfigFixture
{
    std::filesystem::path Directory = std::filesystem::temp_directory_path() /
        ("tc-module-config-" + std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()));

    ModuleConfigFixture() { std::filesystem::create_directory(Directory); }
    ~ModuleConfigFixture()
    {
        std::error_code error;
        std::filesystem::remove_all(Directory, error);
    }

    std::string Write(char const* name, char const* content)
    {
        std::filesystem::path path = Directory / name;
        std::ofstream(path) << content;
        return path.string();
    }
};
}

TEST_CASE("Module settings override dotted keys without changing main config identity", "[ModuleConfig]")
{
    ModuleConfigFixture fixture;
    std::string error;
    std::string main = fixture.Write("world.conf", "[world]\nPlayerbots.Dev.Enabled=0\nPlayerLimit=25\n");
    std::string module = fixture.Write("playerbots.conf", "[playerbots]\nPlayerbots.Dev.Enabled=1\nPlayerbots.Dev.AccountId=7\n");
    REQUIRE(sConfigMgr->LoadInitial(main, { "test" }, error));
    REQUIRE(sConfigMgr->LoadAdditional(module, error));
    REQUIRE(sConfigMgr->GetBoolDefault("Playerbots.Dev.Enabled", false));
    REQUIRE(sConfigMgr->GetIntDefault("Playerbots.Dev.AccountId", 0) == 7);
    REQUIRE(sConfigMgr->GetIntDefault("PlayerLimit", 0) == 25);
    REQUIRE(sConfigMgr->GetFilename() == main);
    REQUIRE(sConfigMgr->GetArguments() == std::vector<std::string>{ "test" });

    REQUIRE(sConfigMgr->Reload(error));
    REQUIRE_FALSE(sConfigMgr->GetBoolDefault("Playerbots.Dev.Enabled", true));
    REQUIRE(sConfigMgr->LoadAdditional(module, error));
    REQUIRE(sConfigMgr->GetBoolDefault("Playerbots.Dev.Enabled", false));
}

TEST_CASE("Malformed or missing module configs leave loaded settings intact", "[ModuleConfig]")
{
    ModuleConfigFixture fixture;
    std::string error;
    REQUIRE(sConfigMgr->LoadInitial(fixture.Write("world.conf", "[world]\nPlayerLimit=25\n"), {}, error));
    SECTION("duplicate key after a valid override")
    {
        REQUIRE_FALSE(sConfigMgr->LoadAdditional(fixture.Write("bad.conf", "[module]\nPlayerLimit=99\nPlayerLimit=3\n"), error));
    }
    SECTION("multiple sections")
    {
        REQUIRE_FALSE(sConfigMgr->LoadAdditional(fixture.Write("bad.conf", "[first]\nPlayerLimit=99\n[second]\nOther=1\n"), error));
    }
    SECTION("empty section")
    {
        REQUIRE_FALSE(sConfigMgr->LoadAdditional(fixture.Write("bad.conf", "[module]\n"), error));
    }
    SECTION("missing file")
    {
        REQUIRE_FALSE(sConfigMgr->LoadAdditional((fixture.Directory / "absent.conf").string(), error));
    }
    REQUIRE_FALSE(error.empty());
    REQUIRE(sConfigMgr->GetIntDefault("PlayerLimit", 0) == 25);
}
