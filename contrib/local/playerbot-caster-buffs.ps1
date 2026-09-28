param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$DbcDir)

# Read-only validation of the caster buff IDs used by the Cata prototype.
$ErrorActionPreference = 'Stop'
$dbcRoot = (Resolve-Path -LiteralPath $DbcDir).Path
function Read-BuffDbc([string]$name, [int]$expectedFields) {
    $bytes = [IO.File]::ReadAllBytes((Join-Path $dbcRoot $name))
    if ($bytes.Length -lt 20 -or [Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'WDBC') { throw "Invalid $name header." }
    $count = [BitConverter]::ToInt32($bytes, 4)
    $fields = [BitConverter]::ToInt32($bytes, 8)
    $size = [BitConverter]::ToInt32($bytes, 12)
    $strings = [BitConverter]::ToInt32($bytes, 16)
    if ($count -lt 0 -or $strings -lt 0 -or $fields -ne $expectedFields -or $size -ne $fields * 4 -or
        $bytes.Length -ne 20L + [long]$count * $size + $strings) { throw "Unexpected Cata layout for $name." }
    return [pscustomobject]@{ Bytes=$bytes; Count=$count; Size=$size; StringStart=(20 + $count * $size) }
}
function BuffField($dbc, [int]$row, [int]$column) {
    return [BitConverter]::ToInt32($dbc.Bytes, 20 + $row * $dbc.Size + $column * 4)
}
$spells = Read-BuffDbc 'Spell.dbc' 48
$levels = Read-BuffDbc 'SpellLevels.dbc' 4
$skills = Read-BuffDbc 'SkillLineAbility.dbc' 14
$effects = Read-BuffDbc 'SpellEffect.dbc' 27
$levelById = @{}
for ($row=0; $row -lt $levels.Count; $row++) { $levelById[(BuffField $levels $row 0)] = BuffField $levels $row 3 }
$expected = @(
    @{ Id=7302; Name='Frost Armor'; Level=54; Mask=128 },
    @{ Id=6117; Name='Mage Armor'; Level=68; Mask=128 },
    @{ Id=30482; Name='Molten Armor'; Level=34; Mask=128 },
    @{ Id=1459; Name='Arcane Brilliance'; Level=58; Mask=128; Single=79057; Party=79058 },
    @{ Id=21562; Name='Power Word: Fortitude'; Level=14; Mask=16; Single=79104; Party=79105 }
)
foreach ($entry in $expected) {
    $spellRows = @(for ($row=0; $row -lt $spells.Count; $row++) { if ((BuffField $spells $row 0) -eq $entry.Id) { $row } })
    $skillRows = @(for ($row=0; $row -lt $skills.Count; $row++) { if ((BuffField $skills $row 2) -eq $entry.Id) { $row } })
    if ($spellRows.Count -ne 1 -or $skillRows.Count -ne 1) { throw "Ambiguous caster spell $($entry.Id)." }
    $start = $spells.StringStart + (BuffField $spells $spellRows[0] 21)
    if ($start -lt $spells.StringStart -or $start -ge $spells.Bytes.Length) { throw 'Invalid spell name offset.' }
    $end = $start
    while ($end -lt $spells.Bytes.Length -and $spells.Bytes[$end] -ne 0) { $end++ }
    if ($end -eq $spells.Bytes.Length) { throw 'Unterminated spell name.' }
    $name = [Text.Encoding]::UTF8.GetString($spells.Bytes, $start, $end-$start)
    if ($name -ne $entry.Name -or $levelById[(BuffField $spells $spellRows[0] 41)] -ne $entry.Level -or
        (BuffField $skills $skillRows[0] 4) -ne $entry.Mask -or (BuffField $skills $skillRows[0] 9) -ne 0) {
        throw "Spell $($entry.Id) differs from the reviewed Cata caster mapping."
    }
    $spellEffects = @(for ($row=0; $row -lt $effects.Count; $row++) { if ((BuffField $effects $row 24) -eq $entry.Id) { $row } })
    if ($entry.ContainsKey('Single')) {
        if ($spellEffects.Count -ne 1 -or (BuffField $effects $spellEffects[0] 1) -ne 3 -or
            (BuffField $effects $spellEffects[0] 5) -ne $entry.Single -or
            (BuffField $effects $spellEffects[0] 9) -ne 0 -or $entry.Party -ne $entry.Single + 1) {
            throw "Spell $($entry.Id) no longer matches spell_gen_increase_stats_buff."
        }
        foreach ($auraId in @($entry.Single, $entry.Party)) {
            $auras = @(for ($row=0; $row -lt $effects.Count; $row++) {
                if ((BuffField $effects $row 24) -eq $auraId -and (BuffField $effects $row 1) -in @(6,35,65)) { $row }
            })
            if (-not $auras.Count) { throw "Expected applied aura effects for $auraId." }
        }
    }
    elseif (-not $spellEffects.Count -or @($spellEffects | Where-Object { (BuffField $effects $_ 1) -ne 6 -or (BuffField $effects $_ 22) -ne 1 }).Count) {
        throw "Expected self-targeted armor aura for $($entry.Id)."
    }
    [pscustomobject]@{ Spell=$name; Id=$entry.Id; Level=$entry.Level; SingleAura=$entry.Single; PartyAura=$entry.Party }
}
