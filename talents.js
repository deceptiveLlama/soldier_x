//=================================================================================
//  SOLDIER X — TALENT DATA + COMPILE-TIME GENERATOR
//  Run by OverPy via  __script__("talents.js")  (see declarations.opy).
//  Single source of truth for: shop display (name/description/stats/availability)
//  AND every per-talent gameplay tuning macro.
//
//  Per talent:
//    stats[]  -> the shop "Talent Stats" lines (player-facing numbers)
//    tuning[] -> the gameplay macros emitted into OverPy (the real damage/healing/etc)
//
//  Tuning expr sugar: "{r}" expands to  <context>.talent_ranks[Talent.<THIS_ID>]
//  ("context" defaults to "eventPlayer"; set it for attacker/victim/etc).
//  Stat lines: value at rank r = base + (r-1)*perRank. perRank 0 => static (no arrow).
//=================================================================================

//--- Shop info-box knobs (the info-bg bar auto-derives its size from these — nothing about it is hardcoded in the .opy) ---
var WRAP_WIDTH = 42                 // description word-wrap width (characters); also drives the bar width & height below
var BG_WIDTH_FACTOR = 1.3          // bar width = round(longestLine * this) spaces, where longestLine = the talent's OWN longest visible text line (> 1: header-font spaces are narrower than text glyphs; this doubles as the side margin). Tune in-game.
var BG_HEIGHT_FACTOR = 0.7         // bar height = round(textLines * this) header rows (< 1: a header row is taller than a description/subheader row). Tune in-game.
var EMDASH_FILL = 0.55             // em-dash divider length = round(barWidthSpaces * this). Em-dashes (and "»") are Latin-1 and do NOT reskin the font, so the dividers sit in the normal merged text; an em-dash is ~2 spaces wide, so < 1. Tune until the line spans the background.
var INFO_TEXT_PAD = 21             // blank lines above the description text — moves the whole text block DOWN toward/under the orbs
var INFO_BAR_PAD = 13               // blank rows above the bar — moves the bar DOWN to sit behind the text (pair with INFO_TEXT_PAD)
var PAD_CHAR = "\xAD"               // soft hyphen (U+00AD): renders as nothing but counts as a character; anchors each bar/pad row so trailing spaces & blank lines aren't trimmed
var ARROW = " » "                   // " » " (U+00BB) between current and upgraded stat value. Like "—", it's a Latin-1 char that does NOT reskin the font, so it's safe inside the normal merged text.
//--- Colored upgrade value matches the talent's orb color, indexed by current rank ---
//--- (must mirror orb_rarity_colors in declarations.opy: WHITE,GREEN,BLUE,PURPLE,ORANGE,ORANGE) ---
var ORB_HEX = ["FFFFFFFF", "45FF57FF", "27AAFFFF", "A149C5FF", "EC9900FF", "EC9900FF"]

var talents = [
    {
      id: "bloodthirst",
      name: "Bloodthirst",
      icon: "abilityIconString(Hero.JUNKER_QUEEN, Button.ABILITY_1)",
      keybind: '"[Passive]"',
      description: "Heal yourself based on the damage you deal during Berserker. Health can be overhealed, and overheal slowly decays.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: ["berserker"],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Healing", base: 25.2, perRank: 6.2, suffix: "%" },
      ],
      tuning: [
        { macro: "BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT", expr: "eventDamage * (0.19 + {r} * 0.062)" },
      ],
    },
    {
      id: "immunity",
      name: "Immunity",
      icon: "('<tx0C00000000004120>')",
      keybind: '"[[Q]]"',
      description: "Activate to gain immunity, exit combat and increase healing received. Can't use damage abilities while immune.",
      cooldown: 45,
      upgrade_information: "[Upgrade: +Duration, +Healing Received]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["berserker"],
      stats: [
        { label: "Duration", base: 5, perRank: 1.25, suffix: "s", decimals: 1 },
        { label: "Healing Received", base: 150, perRank: 25, suffix: "%" },
        { label: "Cooldown", base: 45, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "IMMUNITY_HEALING_RECEIVED", expr: "125 + {r} * 25" },
        { macro: "IMMUNITY_DURATION", expr: "3.75 + {r} * 1.25" },
        { macro: "IMMUNITY_MOVE_SPEED", expr: "100" },
      ],
    },
    {
      id: "cybernetics",
      name: "Cybernetics",
      icon: "('<tx0C00000000028FCB>')",
      keybind: '"[Passive]"',
      description: "Install shield protection. Shields regenerate automatically and can't be healed with healing abilities.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Shields]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Shields", base: 75, perRank: 18.75 },
      ],
      tuning: [
        { macro: "CYBERNETICS_SHIELD_AMOUNT", expr: "56.25 + {r} * 18.75" },
      ],
    },
    {
      id: "soul_harvest",
      name: "Soul Harvest",
      icon: "abilityIconString(Hero.ZENYATTA, Button.ABILITY_1)",
      keybind: '"[Passive]"',
      description: "Picking up XP orbs will heal you.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Healing per orb", base: 125, perRank: 31.25 },
      ],
      tuning: [
        { macro: "SOUL_HARVEST_HEALING", expr: "round(93.75 + {r} * 31.25)", context: "player_picking_up_orb" },
      ],
    },
    {
      id: "poisonous_dagger",
      name: "Poisonous Dagger",
      icon: "('<tx0C0000000001F937>')",
      keybind: '"[[MELEE] (In Stealth)]"',
      description: "Your melee in stealth will debuff your target(s) with a poison that deals damage after 5s.",
      cooldown: 20,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: ["stealth"],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Poison Damage", base: 100, perRank: 25 },
        { label: "Cooldown", base: 20, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "POISONOUS_DAGGER_DAMAGE", expr: "max(75 + eventPlayer.poisonous_dagger_attackers[0].talent_ranks[Talent.POISONOUS_DAGGER] * 25, 100)" },
        { macro: "POISONOUS_DAGGER_DURATION", expr: "5" },
      ],
    },
    {
      id: "stealth",
      name: "Stealth",
      icon: "('<tx0C000000000207B6>')",
      keybind: '"[Hold: [CTRL]]"',
      description: "Enter stealth when crouching out of combat. Melee from stealth will stun the target. Taking damage or using damage dealing abilities will break stealth.",
      cooldown: 10,
      upgrade_information: "[Upgrade: +Stealth Duration, +Stun Duration]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: "poisonous_dagger",
      locks: [],
      stats: [
        { label: "Stun Duration", base: 1, perRank: 0.2, suffix: "s", decimals: 1 },
        { label: "Cooldown", base: 10, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "STEALTH_STUN_DURATION", expr: "0.8 + {r} * 0.2" },
      ],
    },
    {
      id: "juggernaut",
      name: "Juggernaut",
      icon: "abilityIconString(Hero.DOOMFIST, Button.SECONDARY_FIRE)",
      keybind: '"[[F]]"',
      description: "Activate to sprint. Hitting a player stuns and carries them; hitting a wall damages nearby players. Immune to knockback and slows while active.",
      cooldown: 20,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["fireball"],
      stats: [
        { label: "Damage", base: 150, perRank: 25 },
        { label: "Cooldown", base: 20, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "JUGGERNAUT_DAMAGE", expr: "125 + {r} * 25" },
        { macro: "JUGGERNAUT_VS_JUGGERNAUT_SELF_DAMAGE", expr: "125 + eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_ranks[Talent.JUGGERNAUT] * 25" },
      ],
    },
    {
      id: "dive_bomb",
      name: "Dive Bomb",
      icon: "('<tx0C000000000207B7>')",
      keybind: '"[[CTRL] (In Air)]"',
      description: "Deal damage and knock players away. Can only be used above 3.5m altitude. Damage & knockback grows with air time (up to 1s).",
      cooldown: 20,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Damage", base: 75, perRank: 18.75, maxBase: 150, maxPerRank: 37.5 },
        { label: "Cooldown", base: 20, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "DIVE_BOMB_DAMAGE", expr: "(56.25 + {r} * 18.75)" },
        { macro: "DIVE_BOMB_DAMAGE_LOCAL", expr: "(56.25 + {r} * 18.75)", context: "localPlayer" },
      ],
    },
    {
      id: "cryogenics",
      name: "Cryogenics",
      icon: "('<tx0C0000000002D38F>')",
      keybind: '"[[RIGHTCLICK]]"',
      description: "Your secondary fire will slow enemies and disable their sprint. Affected targets slowly regain their speed over the duration.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Slow Amount, +Slow Duration]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Slow Amount", base: 60, perRank: 10, suffix: "%" },
        { label: "Slow Duration", base: 2.2, perRank: 0.2, suffix: "s", decimals: 1 },
      ],
      tuning: [
        { macro: "CRYOGENICS_SLOW_DURATION", expr: "2 + eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 0.2" },
        { macro: "CRYOGENICS_SLOW_AMOUNT", expr: "eventPlayer.stats[Stat.SPEED] * (0.5 - eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 0.1)" },
      ],
    },
    {
      id: "railgun",
      name: "Railgun",
      icon: "iconString(Icon.BOLT)",
      keybind: '"[[RIGHTCLICK] + [LEFTCLICK]]"',
      description: "Replace your secondary fire with a railgun attachment. Railgun will count as your secondary fire. Hitscan ability.",
      cooldown: 6,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: "overclock",
      locks: [/*"bombardment"*/],
      stats: [
        { label: "Damage", base: 100, perRank: 25 },
        { label: "Headshot Damage", base: 150, perRank: 0, suffix: "%" },
        { label: "Cooldown", base: 6, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "RAILGUN_ADDITIONAL_DAMAGE", expr: "112.5 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 37.5 if eventWasCriticalHit else 75 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 25" },
      ],
    },
    {
      id: "grim_reaper",
      name: "Grim Reaper",
      icon: "('<tx0C0000000004F741>')",
      keybind: '"[[F]]"',
      description: "See low-health players through walls. Cast to project yourself to a low-health target.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Cast Speed, +Flight Speed]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["fireball"],
      stats: [
        { label: "Cast Time", base: 2, perRank: -0.25, suffix: "s", decimals: 2 },
        { label: "Flight Speed", base: 15.6, perRank: 3.6, decimals: 1 },
      ],
      tuning: [
        { macro: "GRIM_REAPER_RADIUS", expr: "4" },
        { macro: "GRIM_REAPER_THRESHOLD_NORMALIZED_ATTACKER", expr: "(0.150 + ({r} * 0.050))", context: "attacker" },
        { macro: "GRIM_REAPER_THRESHOLD_NORMALIZED_VICTIM", expr: "(0.150 + ({r} * 0.050))", context: "victim" },
        { macro: "GRIM_REAPER_CAST_TIME", expr: "2.25 - {r} * 0.25" },
        { macro: "GRIM_REAPER_CAST_TIME_LOCAL", expr: "2.25 - {r} * 0.25", context: "localPlayer" },
        { macro: "GRIM_REAPER_FLIGHT_SPEED", expr: "12 + {r} * 3.6" },
        { macro: "GRIM_REAPER_HEALTH_THRESHOLD", expr: "0.25" },
        { macro: "GRIM_REAPER_SCAN_WINDOW", expr: "0.128" },
      ],
    },
    {
      id: "jetpack",
      name: "Jetpack",
      icon: "('<tx0C00000000011E06>')",
      keybind: '"[Hold: [JETPACKBTN][JETPACKAIR]]"',
      description: "Hold while airborne to fly.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Fuel Efficiency]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Fuel", base: 100, perRank: 0 },
        { label: "Fuel Drain", base: 22, perRank: -3, suffix: "/s" },
      ],
      tuning: [],
    },
    {
      id: "lifesteal_ammo",
      name: "Lifesteal Ammo",
      icon: "('<tx0C0000000004F73D>')",
      keybind: '"[[LEFTCLICK] or [RIGHTCLICK]]"',
      description: "A percentage of the damage you deal with primary fire or secondary fire will heal you.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Lifesteal", base: 15, perRank: 3.75, suffix: "%" },
      ],
      tuning: [
        { macro: "LIFESTEAL_HEAL", expr: "eventDamage * (11.25 + {r} * 3.75) / 100" },
        { macro: "LIFESTEAL_RAILGUN_HEAL", expr: "eventPlayer.railgun_damage_dealt * (11.25 + {r} * 3.75) / 100" },
      ],
    },
    {
      id: "health_regen",
      name: "Health Regen",
      icon: "('<tx0C000000000039DD>')",
      keybind: '"[Passive]"',
      description: "Passively regenerate health over time.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Healing Per Second", base: 5, perRank: 1.25, decimals: 2 },
      ],
      tuning: [
        // Hidden +0.2084 on rank 1 (5 -> 5.2084/s) clears the ~5.2083 (125/24) heal-rate threshold below which OW's per-HP heal sound stutters.
        { macro: "HEALTH_REGEN_HEALING_OVER_TIME", expr: "3.75 + {r} * 1.25 + (2084 / 10000 if {r} == 1 else 0)" },
      ],
    },
    {
      id: "health_potions",
      name: "Health Potions",
      icon: "('<tx0C0000000005FA7F>')",
      keybind: '"[[E]]"',
      description: "Gain 3 Rechargable Health Potions.",
      cooldown: 15,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: "alchemist",
      locks: [],
      stats: [
        { label: "Healing Per Potion", base: 200/3, perRank: 50/3 },
        { label: "Heal Duration", base: 2, perRank: 0, suffix: "s" },
        { label: "Recharge Time", base: 15, perRank: 0, suffix: "s" },
        { label: "Max Charges", base: 3, perRank: 0 },
      ],
      tuning: [
        { macro: "HEALTH_POTIONS_HEALING_OVER_TIME", expr: "(150 + {r} * 50) / 6" },
      ],
    },
    {
      id: "ignite",
      name: "Ignite",
      icon: "('<tx0C00000000070EAE>')",
      keybind: '"[[RIGHTCLICK]]"',
      description: "Secondary fire deals additional fire damage over time.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Fire Damage", base: 40, perRank: 10 },
        { label: "Duration", base: 3, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "IGNITE_DAMAGE_PER_SECOND", expr: "(30 + {r} * 10) / 3", context: "attacker" },
      ],
    },
    {
      id: "overclock",
      name: "Overclock",
      icon: "('<tx0C0000000004F73C>')",
      keybind: '"[Passive]"',
      description: "Reduces the cooldown of Railgun.",
      cooldown: 0,
      upgrade_information: "[Upgrade: -Cooldown]",
      cd_reduction_per_rank: 0,
      requires_any_of: ["railgun"],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Cooldown Reduction", base: 1, perRank: 1, suffix: "s" },
      ],
      tuning: [],
    },
    {
      id: "shadowstep",
      name: "Shadowstep",
      icon: "('<tx0C0000000007550C>')",
      keybind: '"[Double Tap: [SPACEBAR]]"',
      description: "Dash in any direction, and briefly become invisible and invulnerable. XP Orbs will reset the cooldown.",
      cooldown: 22.5,
      upgrade_information: "[Upgrade: -Cooldown]",
      cd_reduction_per_rank: 2.5,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Duration", base: 0.5, perRank: 0, suffix: "s", decimals: 1 },
        { label: "Cooldown", base: 20, perRank: -2.5, suffix: "s", decimals: 1 },
      ],
      tuning: [
        { macro: "SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK", expr: "2.5" },
      ],
    },
    {
      id: "burning_soul",
      name: "Burning Soul",
      icon: "abilityIconString(Hero.REAPER, Button.ULTIMATE)",
      keybind: '"[Passive]"',
      description: "Deal damage to nearby, visible players when not sprinting. Enemies take damage from your XP orb if it's picked up before 4s.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Damage Per Second", base: 12, perRank: 3 },
        { label: "Aura Radius", base: 8, perRank: 0 },
        { label: "Orb Damage", base: 100, perRank: 25 },
      ],
      tuning: [
        { macro: "BURNING_SOUL_DAMAGE", expr: "4.5 + {r} * 1.5", context: "burning_soul_current_owner" },
        { macro: "BURNING_SOUL_TICK", expr: "0.5" },
        { macro: "BURNING_SOUL_ORB_DAMAGE", expr: "75 + xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE_RANK] * 25" },
        { macro: "BURNING_SOUL_AURA_RADIUS", expr: "8" },
        { macro: "BURNING_SOUL_ORB_DURATION", expr: "4" },
      ],
    },
    {
      id: "berserker",
      name: "Berserker",
      icon: "iconString(Icon.SKULL)",
      keybind: '"[[Q]]"',
      description: "Activate to deal 25% more damage and receive 10% more damage temporarily.",
      cooldown: 45,
      upgrade_information: "[Upgrade: +Duration]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["immunity"],
      stats: [
        { label: "Duration", base: 5, perRank: 1.25, suffix: "s", decimals: 1 },
        { label: "Damage Bonus", base: 25, perRank: 0, suffix: "%" },
        { label: "Cooldown", base: 45, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "BERSERKER_DURATION", expr: "3.75 + {r} * 1.25" },
        { macro: "BERSERKER_DURATION_LOCAL", expr: "3.75 + {r} * 1.25", context: "localPlayer" },
      ],
    },
    {
      id: "fireball",
      name: "Fireball",
      icon: "iconString(Icon.FIRE)",
      keybind: '"[[F]]"',
      description: "Install a weapon attachment that will let you launch fireballs.",
      cooldown: 20,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: "pyromaniac",
      locks: ["grim_reaper"],
      stats: [
        { label: "Instant Damage", base: 40, perRank: 10 },
        { label: "Damage Over Time", base: 40, perRank: 10 },
        { label: "DoT Duration", base: 5, perRank: 0, suffix: "s" },
        { label: "Cooldown", base: 20, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "FIREBALL_DAMAGE", expr: "30 + {r} * 10" },
        { macro: "FIREBALL_DAMAGE_SELF", expr: "12.5 + {r} * 4.166" },
        { macro: "FIREBALL_DAMAGE_SELF_OVER_TIME_DURATION", expr: "5" },
        { macro: "FIREBALL_DAMAGE_SELF_OVER_TIME", expr: "2.5 + {r} * 0.833" },
        { macro: "FIREBALL_DAMAGE_OVER_TIME", expr: "6 + {r} * 2" },
        { macro: "FIREBALL_DAMAGE_OVER_TIME_DURATION", expr: "5" },
        { macro: "FIREBALL_SPEED", expr: "15" },
        { macro: "FIREBALL_EXPLOSION_RADIUS", expr: "4" },
      ],
    },
    {
      id: "ignore_pain",
      name: "Ignore Pain",
      icon: "('<tx0C0000000004F73E>')",
      keybind: '"[Passive]"',
      description: "Resist a lot of damage while you are casting, reloading, sprinting or stunned.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Damage Resistance]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Damage Resistance", base: 40, perRank: 6.666, suffix: "%" },
      ],
      tuning: [
        { macro: "IGNORE_PAIN_DAMAGE_RESISTANCE", expr: "{r} * 6.666 + 33.333" },
        { macro: "IGNORE_PAIN_DAMAGE_RECEIVED", expr: "66.666 - {r} * 6.666" },
      ],
    },
    {
      id: "javelin",
      name: "Javelin",
      icon: "iconString(Icon.ARROW_RIGHT)",
      keybind: '"[Passive]"',
      description: "Gain the ability to throw a javelin that deals damage, stuns and knocks back the player hit.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [],
      tuning: [],
    },
    {
      id: "bandage",
      name: "Bandage",
      icon: "abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE)",
      keybind: '"[Double Tap: [MELEE]]"',
      description: "Instantly clear all your debuffs and heal yourself up over 10s. Reduces movement speed. Interrupted if taking damage. Can not remove stuns.",
      cooldown: 30,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Total Healing", base: 200, perRank: 50 },
        { label: "Heal Duration", base: 10, perRank: 0, suffix: "s" },
        { label: "Cooldown", base: 30, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "BANDAGE_HEAL_OVER_TIME", expr: "(15 + {r} * 5)" },
        { macro: "BANDAGE_HEAL_OVER_TIME_DURATION", expr: "10" },
      ],
    },
    {
      id: "pyromaniac",
      name: "Pyromaniac",
      icon: "('<tx0C0000000000333A>')",
      keybind: '"[Passive]"',
      description: "Your Fireball will heal you if you stand near the explosion radius.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Healing]",
      cd_reduction_per_rank: 0,
      requires_any_of: ["fireball"],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Instant Healing", base: 40, perRank: 10 },
        { label: "Healing Over Time", base: 40, perRank: 10 },
        { label: "HoT Duration", base: 5, perRank: 0, suffix: "s" },
      ],
      tuning: [
        { macro: "PYROMANIAC_INSTANT_HEALING", expr: "min(30 + {r} * 10, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL))" },
        { macro: "PYROMANIAC_HEALING_OVER_TIME", expr: "6 + {r} * 2" },
        { macro: "PYROMANIAC_HEALING_DURATION", expr: "5" },
      ],
    },
    {
      id: "poison_vials",
      name: "Poison Vials",
      icon: "iconString(Icon.POISON_2)",
      keybind: '"[[E]]"',
      description: "Targets hit will take damage over time. The damage of the poison vials stack.",
      cooldown: 15,
      upgrade_information: "[Upgrade: +Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: "alchemist",
      locks: ["health_potions"],
      stats: [],
      tuning: [
        // Disabled talent — macros kept commented for revival:
        // { macro: "POISON_VIALS_DAMAGE", expr: "28.125 + {r} * 9.375" },
        // { macro: "POISON_VIALS_DAMAGE_OVER_TIME_DURATION", expr: "5" },
        // { macro: "POISON_VIALS_DAMAGE_OVER_TIME", expr: "floor(5.6 + {r} * 1.9)" },
      ],
    },
    {
      id: "alchemist",
      name: "Alchemist",
      icon: "iconString(Icon.RADIOACTIVE)",
      keybind: '"[Passive]"',
      description: "Reduces the cooldown of your Health Potions and gives you a chance to pick up another when picking up XP Orbs.",
      cooldown: 0,
      upgrade_information: "[Upgrade: -Cooldown, +Chance]",
      cd_reduction_per_rank: 1,
      requires_any_of: ["health_potions", "poison_vials"],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Extra Potion Chance", base: 33, perRank: 8.25, suffix: "%" },
        { label: "Cooldown Reduction", base: 1, perRank: 1, suffix: "s" },
      ],
      tuning: [
        { macro: "ALCHEMIST_PROC_CHANCE", expr: "random.randint(33 + (({r} - 1) * 8.25), 100)", context: "player_picking_up_orb" },
      ],
    },
    /*
    {
      id: "bombardment",
      name: "Bombardment",
      icon: "abilityIconString(Hero.PHARAH, Button.ULTIMATE)",
      keybind: '"[[LEFTCLICK] or [RIGHTCLICK]]"',
      description: "Disable your primary fire and reduce the cooldown of your Helix Rockets from 6s down to 1s.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Helix Rocket Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["gunslinger", "railgun"],
      stats: [],
      tuning: [],
    },
    */
    {
      id: "gigachad",
      name: "Gigachad",
      icon: "('<tx0C00000000004121>')",
      keybind: '"[Passive]"',
      description: "Gain a massive health boost, but as a side effect become slower and increase in size. Warning: May affect vocal chords.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Health, +Headshot Healing, +Size]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: [],
      stats: [
        { label: "Health", base: 600, perRank: 100 },
        { label: "Move Speed", base: 95, perRank: -5, suffix: "%" },
        { label: "Size", base: 107, perRank: 7, suffix: "%" },
      ],
      tuning: [
        { macro: "GIGACHAD_SCALED_SIZE", expr: "1 + {r} * 0.07" },
        { macro: "GIGACHAD_MOVE_SPEED", expr: "100 - {r} * 5" },
      ],
    },
    /*
    {
      id: "gunslinger",
      name: "Gunslinger",
      icon: "abilityIconString(Hero.CASSIDY, Button.ULTIMATE)",
      keybind: '"[[LEFTCLICK]]"',
      description: "Reduce your magazine size, your rate of fire and increase damage dealt of primary fire.",
      cooldown: 0,
      upgrade_information: "[Upgrade: +Primary Fire Damage]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["bombardment"],
      stats: [],
      tuning: [],
    },
    {
      id: "adrenaline_rush",
      name: "Adrenaline Rush",
      icon: "abilityIconString(Hero.SOLDIER, Button.ABILITY_1)",
      keybind: '"[[Passive]]"',
      description: "Deal damage to gain Adrenaline. Adrenaline increases your movement speed in stages: 20%, 40%, 60%.",
      cooldown: 0,
      upgrade_information: "[Upgrade: -Damage Required, +Decay Duration]",
      cd_reduction_per_rank: 0,
      requires_any_of: [],
      unlocks: null,
      locks: ["ignore_pain"],
      stats: [],
      tuning: [],
    },
    */
  ]

//=================================================================================
//  GENERATOR
//=================================================================================

var fmtNum = (n, decimals) => {
    var p = Math.pow(10, decimals || 0)
    return "" + (Math.round(n * p) / p)
}

var valueAt = (stat, rank) => stat.base + (rank - 1) * stat.perRank

//--- format a value + unit; suffix "s" (seconds) shows JUST the number — players know it's seconds ---
var fmtVal = (value, decimals, suffix) => {
    var shown = fmtNum(value, decimals)
    if (suffix === "s") {
        return shown
    }
    return shown + suffix
}

//--- a stat's displayed value at a rank: a single number, or "min-max" when the stat has maxBase/maxPerRank (e.g. Dive Bomb damage, which scales with air time) ---
var valStr = (stat, rank) => {
    var decimals = stat.decimals || 0
    var suffix = stat.suffix || ""
    var lo = fmtVal(valueAt(stat, rank), decimals, suffix)
    if (stat.maxBase === undefined) {
        return lo
    }
    return lo + "-" + fmtVal(stat.maxBase + (rank - 1) * stat.maxPerRank, decimals, suffix)
}

var statLine = (stat, currentRank) => {
    if (currentRank <= 0) {
        return stat.label + ": " + valStr(stat, 1)
    }
    var current = valStr(stat, currentRank)
    var next = valStr(stat, currentRank + 1)
    if (current === next) {
        return stat.label + ": " + current
    }
    return stat.label + ": " + current + ARROW + "<fg" + ORB_HEX[currentRank] + ">" + next + "</fg>"
}

var statsBlock = (talent, currentRank) => (talent.stats || []).map(stat => statLine(stat, currentRank)).join("\n")

var wrapText = (text, width) => {
    var out = []
    text.split("\n").forEach(paragraph => {
        var line = ""
        paragraph.split(" ").forEach(word => {
            if (line === "") {
                line = word
            } else if ((line + " " + word).length <= width) {
                line += " " + word
            } else {
                out.push(line)
                line = word
            }
        })
        out.push(line)
    })
    return out.join("\n")
}

//--- Shared availability builder: the display rows (Unlocks/Locks) and the .format() arg expressions, or null when the talent has neither ---
var availabilityRows = (talent) => {
    var hasUnlock = !!talent.unlocks
    var hasLock = talent.locks.length > 0
    if (!hasUnlock && !hasLock) {
        return null
    }
    var args = []
    var rows = []
    if (hasUnlock) {
        rows.push("Unlocks: {" + args.length + "}")
        args.push("talent_names[Talent." + talent.unlocks.toUpperCase() + "]")
    }
    if (hasLock) {
        var placeholders = talent.locks.map(lock => {
            var placeholder = "{" + args.length + "}"
            args.push("talent_names[Talent." + lock.toUpperCase() + "]")
            return placeholder
        })
        rows.push("Locks: " + placeholders.join(", "))
    }
    return { rows: rows, args: args }
}

var rankExpr = (talent, entry) => {
    var context = entry.context || "eventPlayer"
    return entry.expr.split("{r}").join(context + ".talent_ranks[Talent." + talent.id.toUpperCase() + "]")
}

//--- Info-bg bar: a single centered hudHeader of blank rows sized to the talent's WHOLE text block (description + stats + locks). Width from the block's longest visible line; height (rows) from its total line count. Sections are divided in the text by a dashes line (talent_separator) as wide as that longest line. ---
var visibleLen = (line) => line.replace(/<fg[0-9A-Fa-f]*>/g, "").replace(/<\/fg>/g, "").length
var ICON_APPROX_W = 2   // approx visible width (chars) of an icon glyph inside an availability line
var descLines = (talent) => wrapText(talent.description, WRAP_WIDTH).split("\n")
var descLongest = (talent) => {
    var max = 0
    descLines(talent).forEach(line => {
        if (line.length > max) max = line.length
    })
    return max
}
var statsLongest = (talent) => {
    var max = 0
    for (var rank = 1; rank <= 5; rank++) {
        statsBlock(talent, rank).split("\n").forEach(line => {
            var len = visibleLen(line)
            if (len > max) max = len
        })
    }
    return max
}
var talentNameById = (id) => {
    var found = talents.find(other => other.id === id)
    return found ? found.name : id   // tolerate a dangling lock/unlock id (e.g. mid-rename) instead of crashing
}
var availLongest = (talent) => {
    var max = 0
    if (talent.unlocks) {
        var unlockName = talentNameById(talent.unlocks)
        var unlockLen = "Unlocks: ".length + ICON_APPROX_W + (" [" + unlockName + "]").length
        if (unlockLen > max) max = unlockLen
    }
    if (talent.locks.length > 0) {
        var locksLen = "Locks: ".length
        talent.locks.forEach((id, idx) => {
            var lockName = talentNameById(id)
            locksLen += ICON_APPROX_W + (" [" + lockName + "]").length
            if (idx < talent.locks.length - 1) {
                locksLen += 2
            }
        })
        if (locksLen > max) max = locksLen
    }
    return max
}
var overallLongest = (talent) => Math.max(descLongest(talent), statsLongest(talent), availLongest(talent))
var textLineCount = (talent) => {
    var lines = descLines(talent).length
    if (talent.stats && talent.stats.length > 0) {
        lines += 1 + talent.stats.length   // 1 em-dash separator line + stat rows
    }
    var availability = availabilityRows(talent)
    if (availability) {
        lines += 1 + availability.rows.length   // 1 em-dash separator line + locks rows
    }
    return lines
}
var infoBgRows = (talent) => {
    var row = " ".repeat(Math.round(overallLongest(talent) * BG_WIDTH_FACTOR)) + PAD_CHAR
    var barLines = Math.max(1, Math.round(textLineCount(talent) * BG_HEIGHT_FACTOR))
    var rows = []
    for (var k = 0; k < barLines; k++) {
        rows.push(row)
    }
    return rows.join("\n")
}

var result = ""
result += "globalvar talent_base_cooldowns = [" + talents.map(t => t.cooldown) + "]\n"
result += "globalvar talent_cd_reduction_p_rank = [" + talents.map(t => t.cd_reduction_per_rank) + "]\n"
result += "globalvar talent_names = [" + talents.map(t => `"{} [${t.name}]".format(${t.icon})`) + "]\n"
result += "globalvar talent_descriptions = [" + talents.map(t => JSON.stringify("\n".repeat(INFO_TEXT_PAD) + wrapText(t.description, WRAP_WIDTH))) + "]\n"
result += "globalvar talent_info_bg = [" + talents.map(t => JSON.stringify(infoBgRows(t))) + "]\n"
result += "globalvar talent_emdash_sep = [" + talents.map(t => JSON.stringify("—".repeat(Math.round(Math.round(overallLongest(t) * BG_WIDTH_FACTOR) * EMDASH_FILL)))) + "]\n"
result += "globalvar talent_info_bar_pad = " + JSON.stringify(Array(INFO_BAR_PAD).fill(PAD_CHAR).join("\n")) + "\n"
//--- talent_availability[talent]: precomputed "Unlocks: ...\nLocks: a, b" block (multiple separated by commas) for the HUD subheader, or "" if the talent has no unlocks/locks. References talent_names (declared above) for the icon+name. ---
result += "globalvar talent_availability = [" + talents.map(t => {
    var availability = availabilityRows(t)
    if (!availability) {
        return '""'
    }
    return JSON.stringify(availability.rows.join("\n")) + ".format(" + availability.args.join(", ") + ")"
}).join(", ") + "]\n"
result += "globalvar talent_has_availability = [" + talents.map(t => (t.unlocks || t.locks.length > 0) ? "true" : "false") + "]\n"
result += "globalvar talent_requirements = [" + talents.map(t => "[" + t.requires_any_of.map(req => "Talent." + req.toUpperCase()) + "]") + "]\n"
//--- talent_dependents[talent]: inverse of requires_any_of — the talents that require this one (drives the systemic removal-blocking check, shop.opy validate_talent_removal) ---
result += "globalvar talent_dependents = [" + talents.map(t => "[" + talents.filter(other => other.requires_any_of.indexOf(t.id) !== -1).map(dependent => "Talent." + dependent.id.toUpperCase()).join(", ") + "]").join(", ") + "]\n"
result += "globalvar talent_keybinds = [" + talents.map(t => t.keybind) + "]\n"
//--- talent_stats_lines[talent][rank]: the "Talent Stats" block for the HUD subheader, one stat per line (unpadded — the HUD auto-sizes) ---
result += "globalvar talent_stats_lines = [" + talents.map(t => "[" + [0, 1, 2, 3, 4, 5].map(rank => JSON.stringify(statsBlock(t, rank))) + "]") + "]\n"
//--- talent_has_stats[talent]: lets the shop skip the stats subheader without a (unreliable) Workshop string-empty check ---
result += "globalvar talent_has_stats = [" + talents.map(t => (t.stats && t.stats.length > 0) ? "true" : "false") + "]\n"

talents.forEach(t => {
    (t.tuning || []).forEach(entry => {
        result += "macro " + entry.macro + " = " + rankExpr(t, entry) + "\n"
    })
})

result
