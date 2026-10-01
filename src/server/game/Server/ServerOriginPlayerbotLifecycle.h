/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_SERVER_ORIGIN_PLAYERBOT_LIFECYCLE_H
#define TRINITY_SERVER_ORIGIN_PLAYERBOT_LIFECYCLE_H

#include <atomic>
#include <cstdint>

// A session-owned receipt can outlive session deletion. It contains no Player,
// session or callback pointers. One receipt represents one admission attempt.
class ServerOriginPlayerbotLifecycle
{
public:
    enum class State { Loading, Online, Stopping, Stopped, LoginFailed, Disconnected, Shutdown };

    void LoginCompleted() { _flags.fetch_or(Loaded); }
    void StopRequested() { _flags.fetch_or(Stop); }
    void LoginFailed() { _flags.fetch_or(Failed); }
    void SessionClosed(bool shutdown) { _flags.fetch_or(Closed | (shutdown ? Shutdown : 0)); }
    bool HasLoggedIn() const { return (_flags.load() & Loaded) != 0; }
    bool IsClosed() const { return (_flags.load() & Closed) != 0; }

    State GetState() const
    {
        uint8_t flags = _flags.load();
        if (flags & Closed)
        {
            if (flags & Shutdown)
                return State::Shutdown;
            if (flags & Stop)
                return State::Stopped;
            return !(flags & Loaded) ? State::LoginFailed : State::Disconnected;
        }
        if (flags & Stop)
            return State::Stopping;
        if (flags & Failed)
            return State::LoginFailed;
        return flags & Loaded ? State::Online : State::Loading;
    }

    static char const* Describe(State state)
    {
        switch (state)
        {
            case State::Loading: return "loading";
            case State::Online: return "online";
            case State::Stopping: return "exit pending";
            case State::Stopped: return "stopped";
            case State::LoginFailed: return "login failed";
            case State::Disconnected: return "disconnected";
            case State::Shutdown: return "shutdown";
        }
        return "unknown";
    }

private:
    enum : uint8_t { Loaded = 1, Stop = 2, Failed = 4, Closed = 8, Shutdown = 16 };
    std::atomic<uint8_t> _flags { 0 };
};
#endif
