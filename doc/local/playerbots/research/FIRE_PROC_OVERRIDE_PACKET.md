# Fire proc support and native spell overrides

Source checked 2026-10-01 against donor mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` and matching TrinityCore Cata.

Donor FireMageStrategy.cpp schedules `hot streak` -> Pyroblast at 25 and
`improved scorch` -> Scorch at 19. Preserve those names/priorities. Living Bomb
is deliberately deferred: native spell_mage_living_bomb creates an area explosion
on expiry, which needs the future AoE/pull-safety policy, not a single-target label.

Cata Hot Streak aura 48108 uses override-actionbar effect 332 to replace learned
Pyroblast 11366 with Pyroblast! 92315. The replacement itself requires Hot Streak.
The trigger/action require the learned base, current proc and native resolver
returning 92315; stale or mismatched overrides are rejected. No hard-cast Pyroblast
filler or direct authorization of an unlearned replacement.

Shared TryCast now checks the learned requested base before resolving
Unit::GetCastSpellInfo, as the native pending-cast path does. Resolve before
cooldown/GCD checks and construct Spell with the returned native flags. The
native resolver changes only override power-cost flags here; it does not waive
GCD, cooldown, range, equipment or target checks. No TRIGGERED_FULL_MASK shortcut.
Existing CanAutoCast/prepare still own validation and execution. Current adapter
callers already check learned base spells; this common check fails closed too.
Native casting owns Hot Streak consumption, instant casting and Pyroblast damage/
periodic effects. No aura removal or damage duplication.

Scorch 2948 is useful only when a currently active native proc talent triggers
Critical Mass 22959, its loaded proc metadata permits Scorch's family/mask, and
the target lacks the existing debuff from any caster. Use SpellMgr's loaded
proc entry, including database overrides, rather than assuming the raw effect
mask matches Scorch. Missing/mismatched metadata fails closed; raw Cata DBC
Critical Mass effect masks alone do not establish usable Scorch proc behavior.
No talent grants, refresh clipping, new proc data or database repair. Native
application remains unverified and may require further proc-data auditing.

Both actions stay inside existing controlled single-target Mage casting and
single-target threat checks. A reusable condition predicate supplies trigger
and execution eligibility; existing Frost/Arcane behavior remains unchanged
except that shared casts can now follow legitimate native overrides. No new
target acquisition, scheduler, lifecycle or AoE path.

Policy tests cover learned base/proc/override combinations and Scorch learned/
talent/debuff combinations. They do not test native aura resolution or loaded
database proc entries. Cross-platform results are in PORTING.md. Native Hot
Streak/Scorch behavior remains pending one bundled learned/talented Fire fixture,
with level-appropriate mobs. Do not describe this as full Fire rotation parity.
