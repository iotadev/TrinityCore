param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$DbcDir)

# Read-only check of early Warrior abilities in the pinned Cata 4.3.4.15595 DBC.
# It deliberately does not infer combat behavior from spell names alone.
$ErrorActionPreference = 'Stop'
$dbcRoot = (Resolve-Path -LiteralPath $DbcDir).Path

function Read-Dbc([string]$name, [int]$expectedFields) {
    $path = Join-Path $dbcRoot $name
    $bytes = [IO.File]::ReadAllBytes($path)
    if ([Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'WDBC') { throw "$name is not a WDBC file." }
    $count = [BitConverter]::ToInt32($bytes, 4)
    $fields = [BitConverter]::ToInt32($bytes, 8)
    $size = [BitConverter]::ToInt32($bytes, 12)
    $strings = [BitConverter]::ToInt32($bytes, 16)
    if ($fields -ne $expectedFields -or $size -ne $fields * 4 -or $bytes.Length -lt 20 + $count * $size + $strings) {
        throw "$name has an unexpected 4.3.4 layout."
    }
    return [pscustomobject]@{ Bytes=$bytes; Count=$count; Size=$size; StringStart=(20 + $count * $size) }
}

function Field([object]$dbc, [int]$row, [int]$column) {
    return [BitConverter]::ToInt32($dbc.Bytes, 20 + $row * $dbc.Size + $column * 4)
}

$spell = Read-Dbc 'Spell.dbc' 48
$levels = Read-Dbc 'SpellLevels.dbc' 4
$skills = Read-Dbc 'SkillLineAbility.dbc' 14
$effects = Read-Dbc 'SpellEffect.dbc' 27

$levelById = @{}
for ($row = 0; $row -lt $levels.Count; $row++) {
    $levelById[(Field $levels $row 0)] = Field $levels $row 3
}

$expected = @(
    @{ Id=88161; Name='Strike'; Level=1; Skill=26; Acquire=2; Implemented=$true },
    @{ Id=100; Name='Charge'; Level=3; Skill=26; Acquire=0; Implemented=$false },
    @{ Id=34428; Name='Victory Rush'; Level=5; Skill=256; Acquire=0; Implemented=$true },
    @{ Id=772; Name='Rend'; Level=7; Skill=26; Acquire=0; Implemented=$true },
    @{ Id=6343; Name='Thunder Clap'; Level=9; Skill=26; Acquire=0; Implemented=$false },
    @{ Id=78; Name='Heroic Strike'; Level=14; Skill=26; Acquire=0; Implemented=$false },
    @{ Id=6673; Name='Battle Shout'; Level=20; Skill=256; Acquire=0; Implemented=$true }
)

$result = foreach ($entry in $expected) {
    $spellRows = @(for ($row = 0; $row -lt $spell.Count; $row++) {
        if ((Field $spell $row 0) -eq $entry.Id) { $row }
    })
    $skillRows = @(for ($row = 0; $row -lt $skills.Count; $row++) {
        if ((Field $skills $row 2) -eq $entry.Id) { $row }
    })
    if ($spellRows.Count -ne 1 -or $skillRows.Count -ne 1) {
        throw "Spell $($entry.Id) must have one Spell and one SkillLineAbility row."
    }

    $spellRow = $spellRows[0]
    $skillRow = $skillRows[0]
    $nameOffset = Field $spell $spellRow 21
    $nameStart = $spell.StringStart + $nameOffset
    $nameEnd = $nameStart
    while ($nameEnd -lt $spell.Bytes.Length -and $spell.Bytes[$nameEnd] -ne 0) { $nameEnd++ }
    if ($nameEnd -eq $spell.Bytes.Length) { throw "Spell $($entry.Id) has an unterminated name." }
    $name = [Text.Encoding]::UTF8.GetString($spell.Bytes, $nameStart, $nameEnd - $nameStart)
    $levelId = Field $spell $spellRow 41
    $level = $levelById[$levelId]
    $skill = Field $skills $skillRow 1
    $classMask = Field $skills $skillRow 4
    $acquire = Field $skills $skillRow 9
    if ($name -ne $entry.Name -or $level -ne $entry.Level -or $skill -ne $entry.Skill -or
        $classMask -ne 1 -or $acquire -ne $entry.Acquire) {
        throw "Spell $($entry.Id) differs from the reviewed Cata Warrior mapping: $name level=$level skill=$skill classMask=$classMask acquire=$acquire."
    }
    [pscustomobject]@{
        Level=$level
        Spell=$name
        Id=$entry.Id
        Acquisition=$(if ($acquire -eq 2) { 'automatic' } else { 'trainer' })
        InPrototype=$entry.Implemented
    }
}

$rendTrigger = @(for ($row = 0; $row -lt $effects.Count; $row++) {
    if ((Field $effects $row 24) -eq 772 -and (Field $effects $row 1) -eq 64) {
        Field $effects $row 21
    }
})
if ($rendTrigger.Count -ne 1 -or $rendTrigger[0] -ne 94009) {
    throw 'Rend (772) no longer has the reviewed trigger to periodic aura 94009.'
}

$battleShoutEffects = @(for ($row = 0; $row -lt $effects.Count; $row++) {
    if ((Field $effects $row 24) -eq 6673) {
        [pscustomobject]@{
            Effect = Field $effects $row 1
            Aura = Field $effects $row 3
            Target = Field $effects $row 22
            Trigger = Field $effects $row 21
        }
    }
})
if ($battleShoutEffects.Count -ne 3 -or
    @($battleShoutEffects | Where-Object { $_.Effect -eq 64 -and $_.Target -eq 1 -and $_.Trigger -eq 92049 }).Count -ne 1 -or
    @($battleShoutEffects | Where-Object { $_.Effect -eq 6 -and $_.Aura -eq 29 -and $_.Target -eq 56 }).Count -ne 2) {
    throw 'Battle Shout (6673) no longer has the reviewed self trigger and party aura effects.'
}

Write-Output "Pinned Cata DBC: $dbcRoot"
$result | Format-Table -AutoSize
Write-Output 'Rend cast 772 -> periodic aura 94009: verified.'
Write-Output 'Battle Shout cast 6673 -> self trigger 92049 and two party aura effects: verified.'
