/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#include "OptionalModules.h"
#include "ModuleConfigFiles.h"
#include "ModuleScriptLoader.h"
#include "Config.h"
#include "Log.h"
#include <filesystem>

void AddOptionalModuleScripts()
{
    RegisterOptionalModuleScripts();
}

bool LoadOptionalModuleConfigs()
{
    if (ModuleConfigFiles.empty())
        return true;

    namespace fs = std::filesystem;
    fs::path directory(sConfigMgr->GetStringDefault("Modules.ConfigDirectory", "modules"));
    if (directory.is_relative())
        directory = fs::path(sConfigMgr->GetFilename()).parent_path() / directory;

    bool valid = true;
    for (char const* name : ModuleConfigFiles)
    {
        fs::path file = directory / name;
        std::error_code ec;
        bool exists = fs::exists(file, ec);
        if (!exists && !ec)
            continue; // Legacy worldserver.conf options and compiled defaults still work.

        std::string error;
        if (ec || !sConfigMgr->LoadAdditional(file.string(), error))
        {
            TC_LOG_ERROR("server.loading", "Cannot load module config %s: %s", file.string().c_str(),
                ec ? ec.message().c_str() : error.c_str());
            valid = false;
        }
        else
            TC_LOG_INFO("server.loading", "Loaded module config %s", file.string().c_str());
    }
    return valid;
}
