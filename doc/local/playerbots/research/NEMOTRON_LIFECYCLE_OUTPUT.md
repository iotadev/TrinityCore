# Nemotron lifecycle research output

Received from the user's OpenCode desktop session on 2026-09-29. The exact
model and generation settings were not supplied with the pasted output.
The report below is preserved as received. Reviewer corrections are in
`NEMOTRON_LIFECYCLE_PILOT.md`; do not treat this original as approved guidance.

**Revision:** 7bae1b5c58c76a0aa20381155edc08096d1485b2

### Login/Logout Entry Points Table

| Entry Point (File:Line:Symbol) | Callers (File:Line:Symbol) | Async Boundary | Success/Failure Observable |
|--------------------------------|----------------------------|----------------|----------------------------|
| **Login:**<br>src/Bot/PlayerbotMgr.cpp:85:<br>`PlayerbotHolder::AddPlayerBot` | • src/Bot/PlayerbotMgr.cpp:706:<br>`PlayerbotHolder::ProcessBotCommand` ("add"/"addaccount"/"login")<br>• src/Bot/PlayerbotMgr.cpp:1177:<br>`PlayerbotHolder::HandlePlayerbotCommand` ("addclass")<br>• src/Bot/PlayerbotMgr.cpp:1300:<br>`PlayerbotHolder::HandlePlayerbotCommand` (bot list processing) | src/Bot/PlayerbotMgr.cpp:158-189:<br>Lambda in `CharacterDatabase.DelayQueryHolder(holder).AfterComplete()` (line 159) | **Success:** After bot session login (line 209:<br>`botSession->HandlePlayerLoginFromDB(holder)`) – bot enters world.<br>**Failure:** In callback if bot load fails (lines 212-221:<br>`botSession->LogoutPlayer(true); delete botSession;`). |
| **Logout:**<br>src/Bot/PlayerbotMgr.cpp:350:<br>`PlayerbotHolder::LogoutPlayerBot` | • src/Bot/PlayerbotMgr.cpp:717:<br>`PlayerbotHolder::ProcessBotCommand` ("remove"/"logout"/"rm")<br>• src/Bot/PlayerbotMgr.cpp:295:<br>`PlayerbotHolder::LogoutAllBots` (loop) | src/Bot/PlayerbotMgr.cpp:359:<br>`PlayerbotWorldThreadProcessor::instance().QueueOperation(std::move(cleanupOp))`<br>(`BotLogoutGroupCleanupOperation`) | **Success:** After bot session logout (line 408:<br>`botWorldSessionPtr->LogoutPlayer(true)`) and session deletion (line 409).<br>**Failure:** Early return if bot not found (line 352) or null AI (line 355). |

### Failure/Test Scenarios (Source-Supported)
1. **Login: Account not found** – `AddPlayerBot` returns early if `sCharacterCache->GetCharacterAccountIdByGuid` returns 0 (line 95-97).
2. **Login: Already in world** – Returns early if `ObjectAccessor::FindConnectedPlayer(guid)` finds bot `IsInWorld()` (lines 91-93).
3. **Login: Not allowed** – Fails account/guild/link checks (lines 113-147), sends sys message to master.
4. **Login: Bot load failure** – In `HandlePlayerBotLoginCallback`, if `botSession->GetPlayer()` is null, logs out session and deletes it (lines 212-221).

### Missing Dependencies (Unknown in Supplied Source)
- `WorldSession::HandlePlayerLoginFromDB` (called line 209) – implements actual world login.
- `WorldSession::LogoutPlayer` (called line 408) – implements actual world logout.
- `OnBotLoginOperation` and `BotLogoutGroupCleanupOperation` – defined outside supplied Bot/Mgr/Script directories.
- `PlayerbotWorldThreadProcessor::QueueOperation` – thread-scheduling mechanism (declared but not defined in supplied source).

Word count: 398. All facts cite exact file:line:symbol from supplied source. No architecture/security/compatibility claims or changes made. Distinguishes queued/accepted (e.g., `AddPlayerBot` call, `QueueOperation`) from completed (observable world entry/exit). Reports immutable revision. Evidence for audit only.
