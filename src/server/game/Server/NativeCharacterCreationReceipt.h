/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_NATIVE_CHARACTER_CREATION_RECEIPT_H
#define TRINITY_NATIVE_CHARACTER_CREATION_RECEIPT_H

#include <cstdint>

// World-thread-only. One immutable terminal outcome per native create request.
// No session/Player pointers. Abandoned means the owner closed before reporting
// an outcome; a submitted database transaction may still finish afterward.
class NativeCharacterCreationReceipt
{
public:
    enum class State { Pending, Reconciling, Succeeded, Rejected, AccountingFailed, Abandoned };

    explicit NativeCharacterCreationReceipt(bool requiresAccounting = false) : _requiresAccounting(requiresAccounting) { }

    bool Complete(uint32_t nativeResult, bool success, uint32_t characterGuidLow = 0)
    {
        if (_state != State::Pending || (success && !characterGuidLow))
            return false;
        _nativeResult = nativeResult;
        _characterGuidLow = success ? characterGuidLow : 0;
        _creationSucceeded = success;
        _state = _requiresAccounting ? State::Reconciling : (success ? State::Succeeded : State::Rejected);
        return true;
    }

    bool AccountingCompleted(bool success)
    {
        if (_state != State::Reconciling)
            return false;
        _state = success ? (_creationSucceeded ? State::Succeeded : State::Rejected) : State::AccountingFailed;
        return true;
    }

    void Abandon() { if (_state == State::Pending || _state == State::Reconciling) _state = State::Abandoned; }
    State GetState() const { return _state; }
    uint32_t GetNativeResult() const { return _nativeResult; }
    uint32_t GetCharacterGuidLow() const { return _state == State::Succeeded ? _characterGuidLow : 0; }
    // Recovery evidence, not permission to admit a fully provisioned character.
    uint32_t GetCommittedCharacterGuidLow() const { return _characterGuidLow; }

private:
    State _state = State::Pending;
    uint32_t _nativeResult = 0; // Valid after native creation completes.
    uint32_t _characterGuidLow = 0;
    bool const _requiresAccounting;
    bool _creationSucceeded = false;
};

#endif
