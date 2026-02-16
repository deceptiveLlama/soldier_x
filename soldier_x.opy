#!define TOP_RIGHT_TEXT "Soldier: X [v3.1.6] - Made By Psyrius#21775 - Workshop Code: ZEKK3", "[Discord In Description]"
#!define GAME_MODE_DESCRIPTION "● Made by Psyrius\n● Code: ZEKK3\n● v3.1.6\n● RPG, Level up, Buy talents, FFA, Deathmatch\n● Developed since 2020\n● Discord: discord.gg/3MBymdF"
#!define GAME_MODE_NAME "SOLDIER: X [v3.1.6]"

settings {
    "main": {
        "description": GAME_MODE_DESCRIPTION,
        "modeName": GAME_MODE_NAME
        

    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "ffaSlots": 7,
        "spectatorSlots": 1,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "blackForestWinter",
                "blizzWorldWinter",
                "castillo",
                "chateauGuillard",
                "dorado",
                "eichenwalde",
                "hanamuraWinter",
                "havana",
                "hollywood",
                "horizonLunarColony",
                "kanezaka",
                "kingsRowWinter",
                "malevento",
                "necropolis",
                "paris",
                "petra",
                "templeOfAnubis",
                "volskaya"
            ],
                "scoreToWin": 100,
            /*"disabledMaps": [
                "ecopointAntarcticaWinter",
                "castillo",
                "havana",
                "lijiangControlCenter",
                "lijiangGarden",
                "lijiangNightMarket",
                "route66",
                "workshopChamber",
                "workshopExpanse",
                "workshopGreenScreen",
                "workshopIsland"
            ]*/
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableKillFeed": false,
            "spawnHealthPacks": "disabled"
        }
    },
    "heroes": {
        "allTeams": {
            "brigitte": {
                "enableAbility2": false,
                "combatUltGen%": 175,
                "passiveUltGen%": 175,
                "ultGen%": 175,
                "ability1Kb%": 25
            },
            "reaper": {
                "damageDealt%": 50,
                "enableUlt": false
            },
            "reinhardt": {
                "secondaryFireCooldown%": 50,
                "ability1Cooldown%": 25,
                "combatUltGen%": 180,
                "passiveUltGen%": 180,
                "ultGen%": 180
            },
            "soldier": {
                "secondaryFireCooldown%": 17,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
            },
            "winston": {
                "ultDuration%": 500,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
            },
            "hammond": {
                "ability3Cooldown%": 25,
                "enableRollOnly": true
            },
            "zarya": {
                "enableAbility1": false,
                "combatUltGen%": 250,
                "passiveUltGen%": 250,
                "ultGen%": 250
            },
            "enabledHeroes": [
                "soldier"
            ],
            "general": {
                # due to a bug in the OW Workshop this will actually resolve to false
                "passiveHealthRegen": true
            }
        }
    }
}

enum Talent:
    BLOODTHIRST, #0
    PURITY_FIELD, #1
    CYBERNETICS, #2
    SOUL_HARVEST, #3
    POISONOUS_DAGGER, #4
    STEALTH, #5
    JUGGERNAUT, #6
    DIVE_BOMB, #7
    CRYOGENICS, #8
    RAILGUN, #9
    PREDATOR, #10
    JETPACK, #11
    LIFESTEAL_AMMO, #12
    HEALTH_REGEN, #13
    HEALTH_POTIONS, #14
    IGNITE, #15
    OVERCLOCK, #16
    SHADOWSTEP, #17
    BURNING_SOUL, #18
    BERSERKER, #19
    FIREBALL, #20
    IGNORE_PAIN, #21
    JAVELIN, #22
    BANDAGE, #23
    PYROMANIAC, #24
    POISON_VIALS, #25
    ALCHEMIST, #26
    BOMBARDMENT, #27
    GIGACHAD, #28
    GUNSLINGER, #29
    SPRINTER #30

#Global variables
globalvar debugging = false
/*
globalvar debugging = createWorkshopSetting(bool, "Settings", "Debugging", true, 0)
globalvar debug_stealth = createWorkshopSetting(int[0:5], "Talents", "Stealth", 0, Talent.STEALTH)
globalvar debug_poisonous_dagger = createWorkshopSetting(int[0:5], "Talents", "Poisonous Dagger", 0, Talent.POISONOUS_DAGGER)
globalvar debug_gunslinger = createWorkshopSetting(int[0:5], "Talents", "Gunslinger", 0, Talent.GUNSLINGER)
globalvar debug_bombardment = createWorkshopSetting(int[0:5], "Talents", "Bombardment", 0, Talent.BOMBARDMENT)
globalvar debug_railgun = createWorkshopSetting(int[0:5], "Talents", "Railgun", 0, Talent.RAILGUN)
globalvar debug_lifesteal_ammo = createWorkshopSetting(int[0:5], "Talents", "Lifesteal Ammo", 0, Talent.LIFESTEAL_AMMO)
globalvar debug_cryogenics = createWorkshopSetting(int[0:5], "Talents", "Cryogenics", 0, Talent.CRYOGENICS)
globalvar debug_ignite = createWorkshopSetting(int[0:5], "Talents", "Ignite", 0, Talent.IGNITE)
globalvar debug_overclock = createWorkshopSetting(int[0:5], "Talents", "Overclock", 0, Talent.OVERCLOCK)
globalvar debug_ignore_pain = createWorkshopSetting(int[0:5], "Talents", "Ignore Pain", 0, Talent.IGNORE_PAIN)
globalvar debug_burning_soul = createWorkshopSetting(int[0:5], "Talents", "Burning Soul", 0, Talent.BURNING_SOUL)
globalvar debug_sprinter = createWorkshopSetting(int[0:5], "Talents", "Sprinter", 0, Talent.SPRINTER)
globalvar debug_dive_bomb = createWorkshopSetting(int[0:5], "Talents", "Dive Bomb", 0, Talent.DIVE_BOMB)
globalvar debug_jetpack = createWorkshopSetting(int[0:5], "Talents", "Jetpack", 0, Talent.JETPACK)
globalvar debug_bandage = createWorkshopSetting(int[0:5], "Talents", "Bandage", 0, Talent.BANDAGE)
globalvar debug_berserker = createWorkshopSetting(int[0:5], "Talents", "Berserker", 0, Talent.BERSERKER)
globalvar debug_bloodthirst = createWorkshopSetting(int[0:5], "Talents", "Bloodthirst", 0, Talent.BLOODTHIRST)
globalvar debug_purity_field = createWorkshopSetting(int[0:5], "Talents", "Purity Field", 0, Talent.PURITY_FIELD)
globalvar debug_juggernaut = createWorkshopSetting(int[0:5], "Talents", "Juggernaut", 0, Talent.JUGGERNAUT)
globalvar debug_fireball = createWorkshopSetting(int[0:5], "Talents", "Fireball", 0, Talent.FIREBALL)
globalvar debug_predator = createWorkshopSetting(int[0:5], "Talents", "Predator", 0, Talent.PREDATOR)
globalvar debug_gigachad = createWorkshopSetting(int[0:5], "Talents", "Gigachad", 0, Talent.GIGACHAD)

/*
globalvar dpstracking_dpsTime = createWorkshopSetting(int[1:60], "Settings", "DPS Time", 20, 1)
globalvar dpstracking_bot
*/
globalvar init_lock = false
globalvar init_owner = null
globalvar amount_of_dummy_bots = 0
globalvar map_is_changing = false
globalvar antiCrashActivated
globalvar dummy_bot_spawn_facing
globalvar dummy_bot_spawn_position
/*globalvar health_potions_time_in_combat
globalvar health_potions_total_healing
globalvar health_regen_time_in_combat
globalvar health_regen_total_healing
globalvar ignore_pain_time_in_combat
globalvar ignore_pain_total_resisted
globalvar lifesteal_time_in_combat
globalvar lifesteal_total_healing*/
globalvar orb_rarity_colors = [Color.WHITE, Color.GREEN, Color.BLUE, Color.PURPLE, Color.ORANGE, Color.RED]
/*globalvar pathfinding_connections
globalvar pathfinding_positions*/
globalvar talent_rarity_colors = [Color.WHITE, Color.WHITE, Color.GREEN, Color.BLUE, Color.PURPLE, Color.ORANGE]
globalvar xp_orb_effects = [null, null, null, null, null, null, null, null]
globalvar xp_orb_locations = [null, null, null, null, null, null, null, null]
globalvar xp_orb_mines = [null, null, null, null, null, null, null, null]
globalvar xp_orb_values = [null, null, null, null, null, null, null, null]
globalvar players_with_predator_rank = [[], [], [], [], []]
globalvar someone_in_match_have_predator = false
globalvar global_dummy_var
globalvar players_with_predator = [[], [], [], [], []]

#Player variables
/*playervar dpstracking_started_timer
playervar dpstracking_time
playervar dpstracking_damage
playervar dpstracking_textID
playervar dpstracking_position*/
playervar rockets_cooldown
playervar totalTimeElapsed
playervar dummy_var
playervar amount_of_potions_or_vials
playervar amount_of_talents_purchased = 0
playervar bought_talents = []
playervar browsing_shop
playervar can_enter_shop = false
playervar poison_vials_cloudData
playervar dropped_xp_orb
playervar experience_current = 0
playervar experience_max = 250
/*playervar healing_done_in_combat*/
playervar health_potion_cooldown_memory
playervar in_combat = 0
playervar indexMemory
playervar interactablePlayers
playervar is_electrified = 0
playervar is_using_ability = []
playervar is_using_hearthstone = [false, false]
playervar javelin_middle_position
playervar juggernaut_charge
playervar talents_offered_in_shop
/*playervar pathfinding_pos_pre_current_next*/
playervar player_name = "{0}".format(eventPlayer)
playervar player_temp_effects
playervar poison_vial_clouds_spawned
playervar poison_vial_effects
playervar possible_talents = [Talent.PURITY_FIELD, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.PREDATOR, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, */Talent.BOMBARDMENT, Talent.GIGACHAD, Talent.GUNSLINGER, Talent.SPRINTER]
playervar poison_vials_projPos
playervar poison_vials_projPosIn0032
playervar random_integer_between_0_to_5
/*playervar replace_replacing_or_cancelled = [false, false, false]*/
playervar skipped_a_talent
#[0] = Damage, [1] = Health, [2] = Speed, [3] = Armor, [4] = Shields, [5] = XP, [6] = Voice, [7] = Berserker Helper, [8] = Size, [9] = Knockback Resist
playervar stats = [100, 200, 100, 0, 0, 0.65, 1, 0, 1, 100]
playervar talent_counter_or_position_etc
playervar talent_ranks = []
playervar talents_you_do_not_have = [Talent.PURITY_FIELD, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.PREDATOR, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, */Talent.BOMBARDMENT, Talent.GIGACHAD, Talent.GUNSLINGER, Talent.SPRINTER]
playervar time_since_poison_vial_exploded
playervar using_one_of_the_hearthstones
playervar which_is_talent_unique_unlocked = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
playervar xp_boost_is_active
playervar xp_orb_destination
playervar made_outlines_for_predator_rank
playervar dive_bomb_damage
playervar berserker_duration
playervar in_combat_passive_health_regen
playervar cryogenics_travel_time
playervar using_cryogenics = false
playervar hit_by_talent

#!defineMember is_using_hearthstone dummy_var[0]
#!defineMember is_using_skip_talent dummy_var[1]
#!defineMember is_using_vote_yes dummy_var[2]
#!defineMember is_using_vote_no dummy_var[3]
#!defineMember replacing_talent_show_confirmation dummy_var[4]
#!defineMember replacing_talent_show_bought_talents dummy_var[5]
#!defineMember replacing_talent_cancelled dummy_var[6]
#!defineMember totalTimeElapsed_alignment dummy_var[7]
#!defineMember amount_of_bullets dummy_var[8]
#!defineMember bandage_heal_over_time_id dummy_var[9]
#!defineMember is_charging_railgun dummy_var[10]
#!defineMember bloodthirst_heal_amount_for_hud dummy_var[11]
#!defineMember bloodthirst_remaining_heal_amount dummy_var[12]
#!defineMember bloodthirst_total_heal_amount dummy_var[13]
#!defineMember bloodthirst_decay_per_second dummy_var[14]
#!defineMember spawning_for_the_first_time dummy_var[15]
#!defineMember selected_bought_talent dummy_var[16]
#!defineMember selected_talent_in_shop dummy_var[17]
#!defineMember amount_of_bonus_talents dummy_var[18]
#!defineMember xp_orb_position_on_player dummy_var[19]
#!defineMember owner_of_picked_up_xp_orb dummy_var[20]
#!defineMember predator_damage_dealt dummy_var[21]
#!defineMember predator_damage_resisted dummy_var[22]
#!defineMember gigachad_damage_resisted dummy_var[23]

#!defineMember highest_predator_rank_in_match global_dummy_var[0]
#!defineMember leading_player_talents_purchased global_dummy_var[1]

#Subroutine names
subroutine buy_debug_talents
subroutine bloodthirst_effects
subroutine break_stealth
subroutine cancel_ability
subroutine cancel_shop_camera
subroutine create_talent_helpers
subroutine create_talent_hud_texts
subroutine dropped_burning_soul_orb
subroutine dropped_xp_orb
subroutine If_map
/*subroutine juggernaut_effects
subroutine juggernaut_impulse_sound_cd
subroutine juggernaut_knockback*/
subroutine map_antarctica
subroutine map_black_forest
subroutine map_blizzard_world
subroutine map_chateau_guillard
subroutine map_eichenwalde
subroutine map_hollywood
subroutine map_kanezaka
subroutine map_kings_row
subroutine map_malevento
subroutine map_necropolis
subroutine map_paris
subroutine map_petra
/*subroutine new_reaper_pathfinding*/
subroutine replace_talent
subroutine poisonous_dagger
subroutine spawned_with_fireball
subroutine start_pathfinding
subroutine stopped_using_hearthstone
subroutine using_one_of_the_hearthstones
subroutine burning_soul_orb_effect
subroutine late_to_the_party
subroutine player_slowed
subroutine which_players_have_predator

#Activated extensions

#!extension buffStatusEffects
#!extension debuffStatusEffects
#!extension energyExplosionEffects
#!extension kineticExplosionEffects
#!extension explosionSounds
#!extension buffAndDebuffSounds
#!extension projectiles

#!define generateTalents() __script__("talents.js")
generateTalents()

#!define ALCHEMIST_PROC_CHANCE random.randint(eventPlayer.talent_ranks[Talent.ALCHEMIST] * 13.2, 100) >= 66
#!define BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT eventDamage * (0.19 + eventPlayer.talent_ranks[Talent.BLOODTHIRST] * 0.062)
#!define BERSERKER_DURATION 3.75 + eventPlayer.talent_ranks[Talent.BERSERKER] * 1.25
#!define BURNING_SOUL_DAMAGE 3 + eventPlayer.talent_ranks[Talent.BURNING_SOUL] * 0.6
#!define BURNING_SOUL_ORB_DAMAGE 75 + eventPlayer.hit_by_talent[Talent.BURNING_SOUL].talent_ranks[Talent.BURNING_SOUL] * 25
#!define CRYOGENICS_SLOW_DURATION 2 + eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 0.2
#!define CRYOGENICS_SLOW_AMOUNT eventPlayer.stats[2] * 0.5 - eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 10
#!define SHADOWSTEP_BASE_COOLDOWN 22.5
#!define SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK 2.5
#!define STEALTH_BASE_COOLDOWN 20
#!define STEALTH_COOLDOWN_REDUCTION_PER_RANK 4
#!define PREDATOR_COOLDOWN_REDUCTION_PER_RANK 6
#!define HEALTH_POTIONS_COOLDOWN_REDUCTION_PER_RANK 1
#!define HEALTH_POTIONS_HEALING_OVER_TIME 21.875 + eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] * 8.75
#!define HEALTH_REGEN_HEALING_OVER_TIME 4.5 + eventPlayer.talent_ranks[Talent.HEALTH_REGEN] * 0.9
#FIREBALL_DAMAGE: Rank 1: 40 damage, Rank 5: 80 damage
#FIREBALL_DAMAGE_OVER_TIME: Rank 1: 40 damage, Rank 5: 80 damage
#!define FIREBALL_DAMAGE 30 + eventPlayer.talent_ranks[Talent.FIREBALL] * 10
#!define FIREBALL_DAMAGE_SELF 12.5 + eventPlayer.talent_ranks[Talent.FIREBALL] * 4.166
#!define FIREBALL_DAMAGE_SELF_OVER_TIME_DURATION 5
#!define FIREBALL_DAMAGE_SELF_OVER_TIME 2.5 + eventPlayer.talent_ranks[Talent.FIREBALL] * 0.833
#!define FIREBALL_DAMAGE_OVER_TIME 6 + eventPlayer.talent_ranks[Talent.FIREBALL] * 2
#!define PYROMANIAC_INSTANT_HEALING 30 + eventPlayer.talent_ranks[Talent.PYROMANIAC] * 10
#!define PYROMANIAC_HEALING_OVER_TIME 6 + eventPlayer.talent_ranks[Talent.PYROMANIAC] * 2
#Railgun: Rank 1: 150(300 headshot) damage, Rank 5: 200(400 headshot) damage
#!define RAILGUN_ADDITIONAL_DAMAGE 275 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 25 if eventWasCriticalHit else 137.5 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 12.5
#Gunslinger: Rank 1: 66(132 headshot) damage, Rank 5: 79(158 headshot) damage - - - 19(38 headshot) damage added as well from the primary fire
#!define GUNSLINGER_ADDITIONAL_DAMAGE round(eventDamage * 3.333 + eventDamage * attacker.talent_ranks[Talent.GUNSLINGER] * 0.166)
#IGNITE_DAMAGE_PER_SECOND: Rank 1: 40 total damage, Rank 5: 80 total damage
#IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND: Rank 1 25 damage, Rank 5: 50 damage
#IGNITE_RAILGUN_DAMAGE_PER_SECOND: Rank 1 50 damage, Rank 5: 100 damage
#!define IGNITE_DAMAGE_PER_SECOND round(9.97 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * eventDamage)
#!define IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND round(9.97 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * eventDamage / 2)
#!define IGNITE_RAILGUN_DAMAGE_PER_SECOND round(12.45 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * 150)
#Bombardment: Rank 1: 4 total damage, Rank 5: 20 total damage
#!define BOMBARDMENT_DAMAGE attacker.talent_ranks[Talent.BOMBARDMENT] * 4
#Poisonous Dagger: Rank 1: 75 total damage, Rank 5: 150 total damage
#!define POISONOUS_DAGGER_DAMAGE_PER_SECOND round(11.25 + attacker.talent_ranks[Talent.POISONOUS_DAGGER] * 3.75)
#!define POISONOUS_DAGGER_DURATION 5
#Soul Harvest: Rank 1: 150 total healing, Rank 5: 300 total healing
#!define SOUL_HARVEST_HEALING round(112.5 + eventPlayer.talent_ranks[Talent.SOUL_HARVEST] * 37.5)
#Bandage: Rank 1: 200 total healing, Rank 5: 400 total healing
#!define BANDAGE_HEAL_OVER_TIME (15 + eventPlayer.talent_ranks[Talent.BANDAGE] * 5)
#!define BANDAGE_HEAL_OVER_TIME_DURATION 10
#!define IGNORE_PAIN_DAMAGE_RESISTANCE eventPlayer.talent_ranks[Talent.IGNORE_PAIN] * 6.666 + 33.333
#!define IGNORE_PAIN_DAMAGE_RECEIVED 66.666 - eventPlayer.talent_ranks[Talent.IGNORE_PAIN] * 6.666
#!define JUGGERNAUT_DAMAGE 125 + eventPlayer.talent_ranks[Talent.JUGGERNAUT] * 25
#!define JUGGERNAUT_VS_JUGGERNAUT_SELF_DAMAGE 125 + eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_ranks[Talent.JUGGERNAUT] * 25
#Predator: Rank 1: <20%, Rank 5: <40%
#!define PREDATOR_WALLHACK_THRESHOLD (0.150 + (player.talent_ranks[Talent.PREDATOR] * 0.050))
#!define PREDATOR_THRESHOLD_NORMALIZED_ATTACKER (0.150 + (attacker.talent_ranks[Talent.PREDATOR] * 0.050))
#!define PREDATOR_THRESHOLD_NORMALIZED_VICTIM (0.150 + (victim.talent_ranks[Talent.PREDATOR] * 0.050))
#!define POISON_VIALS_DAMAGE 28.125 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 9.375
#!define POISON_VIALS_DAMAGE_OVER_TIME 5, floor(5.6 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 1.9)
#!define SPRINTER_MOVE_SPEED_MULTIPLIER eventPlayer.stats[2] * (1 + eventPlayer.talent_ranks[Talent.SPRINTER] * 0.066)
#Dive Bomb: Rank 1: 75 total damage, Rank 5: 150 total damage (The damage is doubled if you have been in air for 1 second)
#!define DIVE_BOMB_DAMAGE (75 + eventPlayer.talent_ranks[Talent.DIVE_BOMB] * 25)
#For HUD
#!define DIVE_BOMB_DAMAGE_LOCAL (75 + localPlayer.talent_ranks[Talent.DIVE_BOMB] * 25)
#Lifesteal: Rank 1: 18.7% healing, Rank 5: 37.5% healing
#!define LIFESTEAL_HEAL eventDamage * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#!define LIFESTEAL_BOMBARDMENT_HEAL eventDamage * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047) / 2
#!define LIFESTEAL_RAILGUN_HEAL (RAILGUN_ADDITIONAL_DAMAGE + eventDamage) * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#!define LIFESTEAL_GUNSLINGER_HEAL (GUNSLINGER_ADDITIONAL_DAMAGE + eventDamage) * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#!define GIGACHAD_RESIST_NORMALIZED_VICTIM (0.15 + victim.talent_ranks[Talent.GIGACHAD] * 0.05)
#!define PURITY_FIELD_HEALING_RECEIVED 125 + eventPlayer.talent_ranks[Talent.PURITY_FIELD] * 25
#!define PURITY_FIELD_DURATION 3.75 + eventPlayer.talent_ranks[Talent.PURITY_FIELD] * 1.25

#!include "bots.opy"
#!include "xp.opy"
#!include "shop.opy"
#!include "talents.opy"
#!include "debug.opy"

/*
rule "Rule 142":
    @Event eachPlayer
    @Hero soldier
    
    hudHeader(eventPlayer, "GR {0}".format(eventPlayer.dummy_var[23]), HudPosition.TOP, 200, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/
rule "Player Left Match":
    @Event playerLeft

    if init_owner in getAllPlayers() == false:
        init_owner = null
        init_lock = false

    leading_player_talents_purchased = sorted(getAllPlayers(), lambda player: player.amount_of_talents_purchased).last().amount_of_talents_purchased

    if someone_in_match_have_predator == true:
        if all([player.talent_ranks[Talent.PREDATOR] == 0 for player in getAllPlayers()]) == true:
            someone_in_match_have_predator = false
            highest_predator_rank_in_match = 0
            return
        if len([player.talent_ranks[Talent.PREDATOR] > 4 for player in getAllPlayers()]) > 0:
            highest_predator_rank_in_match = 5
        elif len([player.talent_ranks[Talent.PREDATOR] > 3 for player in getAllPlayers()]) > 0:
            highest_predator_rank_in_match = 4
        elif len([player.talent_ranks[Talent.PREDATOR] > 2 for player in getAllPlayers()]) > 0:
            highest_predator_rank_in_match = 3
        elif len([player.talent_ranks[Talent.PREDATOR] > 1 for player in getAllPlayers()]) > 0:
            highest_predator_rank_in_match = 2
        elif len([player.talent_ranks[Talent.PREDATOR] > 0 for player in getAllPlayers()]) > 0:
            highest_predator_rank_in_match = 1
        players_with_predator_rank[1] = len([player.talent_ranks[Talent.PREDATOR] == 1 for player in getAllPlayers()])
        players_with_predator_rank[2] = len([player.talent_ranks[Talent.PREDATOR] == 2 for player in getAllPlayers()])
        players_with_predator_rank[3] = len([player.talent_ranks[Talent.PREDATOR] == 3 for player in getAllPlayers()])
        players_with_predator_rank[4] = len([player.talent_ranks[Talent.PREDATOR] == 4 for player in getAllPlayers()])
        players_with_predator_rank[5] = len([player.talent_ranks[Talent.PREDATOR] == 5 for player in getAllPlayers()])

rule "GENERAL - - - Global Variables":
    #leading_player_talents_purchased = 5
    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, "Amount of texts: {0}".format(getNumberOfTextIds()), "", "", HudPosition.RIGHT, 99, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, "Amount of effects: {0}".format(getNumberOfEntityIds()), "", "", HudPosition.RIGHT, 99.1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, "Leading Player Talents: {0}".format(leading_player_talents_purchased), "", "", HudPosition.RIGHT, 99.3, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, "Init_owner: {0}, Init_lock: {1}".format(init_owner, init_lock), "", "", HudPosition.RIGHT, 99.3, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, "Srv Load: {0} {1} {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), "", "", HudPosition.RIGHT, 105, Color.RED, Color.RED, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    disableInspector()
    highest_predator_rank_in_match = 0
    If_map()
    createInWorldText(localPlayer if localPlayer.browsing_shop == true else null, "YES {0}                        {1} NO".format(buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)) if localPlayer.replacing_talent_show_confirmation == true else "{0}            {1}            {2}".format(buttonString(Button.PRIMARY_FIRE) if localPlayer.replacing_talent_show_bought_talents == true else buttonString(Button.PRIMARY_FIRE) if localPlayer.selected_talent_in_shop >= 1 else "    ", buttonString(Button.INTERACT), buttonString(Button.SECONDARY_FIRE) if localPlayer.replacing_talent_show_bought_talents == true else buttonString(Button.SECONDARY_FIRE) if localPlayer.selected_talent_in_shop <= 1 else "    "), localPlayer.selected_talent_position + vect(0, -0.375, 0), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    async(create_talent_hud_texts, AsyncBehavior.NOOP)
    async(create_talent_helpers, AsyncBehavior.NOOP)
    #Additional Talent Descriptions
    createInWorldText(localPlayer if localPlayer.browsing_shop == true and localPlayer.replacing_talent_show_confirmation == false and localPlayer.replacing_talent_show_bought_talents == false else null, "{0}".format(additional_information[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]) if localPlayer.isHoldingButton(Button.JUMP) else "Hold {0} for more information...".format(buttonString(Button.JUMP)), localPlayer.selected_talent_position + vect(0, -1.25, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if localPlayer.isHoldingButton(Button.JUMP) else Color.GRAY, SpecVisibility.DEFAULT)
    #Talent Information Unique
    createInWorldText(localPlayer if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.JUMP) and not localPlayer.replacing_talent_show_confirmation and not localPlayer.replacing_talent_show_bought_talents and is_talent_unique[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]] else null, "[Unique]: {0} Can not be learned after learning {1}".format(talent_names[talent_information_unique[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]], talent_names[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]) if len(talent_information_unique[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]) == 1 else "[Unique]: {0} and {1} Can not be learned after learning {2}".format(talent_names[talent_information_unique[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]], talent_names[talent_information_unique[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]][1]], talent_names[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]), localPlayer.selected_talent_position + vect(0, -1.5, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #Talent Information Expand Mind
    createInWorldText(localPlayer if localPlayer.browsing_shop and talent_information_expand_mind[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]] != null and localPlayer.isHoldingButton(Button.JUMP) and not localPlayer.replacing_talent_show_confirmation and not localPlayer.replacing_talent_show_bought_talents else null, "[Expand Mind]: {0} can appear in shop after learning {1}".format(talent_names[talent_information_expand_mind[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]], talent_names[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]), localPlayer.selected_talent_position + vect(0, -1.375, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)

rule "GENERAL - - - [EACH PLAYER] INIT":
    @Event eachPlayer

    #"Wait for our turn (one player initializes at a time)"
    waitUntil(init_lock == false, 99999)
    #"Claim lock"
    init_lock = true
    init_owner = eventPlayer

    if not eventPlayer.isDummy():
        #spawning_for_the_first_time
        eventPlayer.spawning_for_the_first_time = true
        #eventPlayer.amount_of_bonus_talents = 0
        eventPlayer.amount_of_bonus_talents = 0
        #eventPlayer.selected_talent_in_shop = 1
        eventPlayer.selected_talent_in_shop = 1
        #eventPlayer.selected_bought_talent = 0
        eventPlayer.selected_bought_talent = 0
        chase(eventPlayer.rockets_cooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        #[HUD Text for talent slot 1]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 1 else null, "{0}".format(talent_names[eventPlayer.bought_talents[0]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[0]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.LEFT, 0, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 2]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 2 else null, "{0}".format(talent_names[eventPlayer.bought_talents[1]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[1]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.LEFT, 1, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 3]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 3 else null, "{0}".format(talent_names[eventPlayer.bought_talents[2]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[2]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.LEFT, 2, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 4]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 4 else null, "{0}".format(talent_names[eventPlayer.bought_talents[3]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[3]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.LEFT, 3, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 5]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 5 else null, "{0}".format(talent_names[eventPlayer.bought_talents[4]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[4]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.LEFT, 4, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        eventPlayer.setAbility2Enabled(false)
        eventPlayer.setUltEnabled(false)
        #XP HUD
        progressBarHud(eventPlayer, 100 if eventPlayer.amount_of_bonus_talents > 0 else eventPlayer.experience_current / eventPlayer.experience_max * 100, "You are late to the party!" if eventPlayer.amount_of_bonus_talents > 0 else "Max Level - XP Boost: Active" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current < eventPlayer.experience_max else "You can replace a talent" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current >= eventPlayer.experience_max else "You have a talent point" if eventPlayer.can_enter_shop == true else "You skipped a talent! XP Boost: Active" if eventPlayer.skipped_a_talent == true else "Too far behind! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.xp_boost_is_active == true and eventPlayer.amount_of_talents_purchased > 0 else "First Level! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.amount_of_talents_purchased == 0 else "", HudPosition.TOP, 1, Color.SKY_BLUE if eventPlayer.amount_of_bonus_talents > 0 else Color.ORANGE, Color.SKY_BLUE if eventPlayer.amount_of_bonus_talents > 0 else Color.ORANGE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #Upgrade Information (or selected talent of bought talents when replacing talents)
        createInWorldText(eventPlayer if eventPlayer.browsing_shop == true and (eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] > 0 or eventPlayer.replacing_talent_show_bought_talents == true) else null, "{0}".format(talent_names[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]]) if eventPlayer.replacing_talent_show_bought_talents == true else "{0}".format(upgrade_information[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]]), eventPlayer.selected_talent_position + vect(0, 0.125, 0) if eventPlayer.replacing_talent_show_bought_talents == true else eventPlayer.selected_talent_position + vect(0, -1, 0), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]]], SpecVisibility.DEFAULT)
        wait()
        #Talent Descriptions
        createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}".format(talent_descriptions[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]]), eventPlayer.selected_talent_position + vect(0, -1.125, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        #Left Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, Effect.ORB, orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[0]]], shop_talent_positions[0], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        wait()
        #Middle Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop == true else null, Effect.ORB, Color.WHITE if eventPlayer.replacing_talent_show_confirmation == true and eventPlayer.replacing_talent_show_bought_talents == false else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[1]]], shop_talent_positions[eventPlayer.selected_talent_in_shop] if eventPlayer.replacing_talent_show_confirmation or eventPlayer.replacing_talent_show_bought_talents else shop_talent_positions[1], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        wait()
        #Right Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, Effect.ORB, orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[2]]], shop_talent_positions[2], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        wait()
        #Left Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[0]]), shop_talent_positions[0] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        #Middle Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop else null, "{0} Are you sure you want to replace one of your talents?".format(iconString(Icon.WARNING)) if eventPlayer.replacing_talent_show_confirmation else "{0} What talent would you like to replace?".format(iconString(Icon.WARNING)) if eventPlayer.replacing_talent_show_bought_talents else "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[1]]), shop_talent_positions[eventPlayer.selected_talent_in_shop] + vect(0, 0.375, 0) if eventPlayer.replacing_talent_show_confirmation or eventPlayer.replacing_talent_show_bought_talents else shop_talent_positions[1] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        #Right Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[2]]), shop_talent_positions[2] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #For bots and players:
    eventPlayer.hit_by_talent[Talent.POISON_VIALS] = null
    eventPlayer.disableGamemodeHud()
    eventPlayer.setMaxHealth(eventPlayer.stats[1])
    chase(eventPlayer.in_combat, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    createEffect(getAllPlayers() if eventPlayer.hit_by_talent[Talent.RAILGUN] != null else null, Effect.WINSTON_TESLA_CANNON_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer if eventPlayer.talent_ranks[Talent.RAILGUN] > 0 and eventPlayer.railgun_charge > 0 or eventPlayer.hit_by_talent[Talent.RAILGUN] != null else null, Effect.ENERGY_SOUND, Color.TEAM_1, eventPlayer, eventPlayer.railgun_charge, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait()
    chase(eventPlayer.is_electrified, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.CRYOGENICS] == true else null, Effect.MEI_FROZEN, Color.WHITE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.CRYOGENICS] == true else null, Effect.MEI_FROZEN_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #Predator effect
    #createEffect([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 0 and eventPlayer.getHealth() < eventPlayer.getMaxHealth() * (0.15 + player.talent_ranks[Talent.PREDATOR] * 0.05) and eventPlayer.isAlive() and player != eventPlayer], Effect.ECHO_CLONING, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    chase(eventPlayer.in_combat_passive_health_regen, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.cryogenics_travel_time = 0
    async(which_players_have_predator, AsyncBehavior.RESTART)
    wait()
    createIcon(players_with_predator[0] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.2 else players_with_predator[1] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.25 else players_with_predator[2] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.3 else players_with_predator[3] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.35 else players_with_predator[4] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.4 else null, updateEveryTick(eventPlayer.getPosition() + Vector.UP * 0.5), Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.RED, false)

    #"Release lock"
    init_owner = null
    init_lock = false
    

rule "GENERAL - - - Match Time":
    @Condition isAssemblingHeroes() == true
    @Condition map_is_changing == false
    
    setMatchTime(0)
    while map_is_changing == false:
        waitUntil(getNumberOfHeroes(Hero.SOLDIER, Team.ALL) > 0 or accurateTime > 14400, 99999)
        if map_is_changing == true:
            return
        if accurateTime < 10800:
            setMatchTime(3600)
        waitUntil(getNumberOfHeroes(Hero.SOLDIER, Team.ALL) == 0 or accurateTime > 14400, 14400)
        if accurateTime < 10800:
            goto lbl_0
        if accurateTime > 14400 and map_is_changing == false:
            map_is_changing = true
            bigMessage(getAllPlayers(), "Game session lasted too long!")
            wait(7.5)
            bigMessage(getAllPlayers(), "Map will automatically change in 60 seconds...")
            setMatchTime(60)
            wait(7.5)
            bigMessage(getAllPlayers(), "Hope you enjoyed my game mode!")
            wait(7.5)
            bigMessage(getAllPlayers(), "Don't forget to join the Discord :)")
            return
        if map_is_changing == true:
            return
        #change map if no players and server time is above 3 hours
        setMatchTime(1)
        return
        lbl_0:

rule "GENERAL - - - Add Bots":
    @Condition spawn_bots == true
    @Condition getNumberOfPlayers(Team.ALL) < 8
    
    createDummy(Hero.REAPER, Team.ALL, -1, dummy_bot_spawn_position, dummy_bot_spawn_facing)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START

rule "GENERAL - - - Is Match Complete?":
    @Condition isMatchComplete() == true
    
    bigMessage(getAllPlayers(), "{0} Join the discord! {1}".format(iconString(Icon.ARROW_RIGHT), iconString(Icon.ARROW_LEFT)))

def If_map():
    @Name "GENERAL - - - [SUBROUTINE] if Map"
    
    if getCurrentMap() == Map.EICHENWALDE or getCurrentMap() == Map.EICHENWALDE_HALLOWEEN:
        map_eichenwalde()
        dummy_bot_spawn_position = vect(99.42, 13.121, -71.747)
        dummy_bot_spawn_facing = vect(99.42, 13.121, -71.747)
        shop_location = vect(13.219, 5.89, -49.768)
        shop_talent_positions[0] = vect(16.177, 8.003, -45.05)
        shop_talent_positions[1] = vect(13.174, 8.287, -44.887)
        shop_talent_positions[2] = vect(10.425, 8.09, -44.999)
    elif getCurrentMap() == Map.BLACK_FOREST or getCurrentMap() == Map.BLACK_FOREST_WINTER:
        map_black_forest()
        dummy_bot_spawn_position = vect(-25.204, 12.546, 3.92)
        dummy_bot_spawn_facing = vect(-19.306, 13.739, 3.922)
        shop_location = vect(-33.308, 4.599, 1.094)
        shop_talent_positions[0] = vect(-38.288, 6.869, 2.713)
        shop_talent_positions[1] = vect(-38.063, 6.77, -0.092)
        shop_talent_positions[2] = vect(-36.726, 6.549, -2.176)
    elif getCurrentMap() == Map.HOLLYWOOD:
        map_hollywood()
        dummy_bot_spawn_position = vect(28.865, 7.252, -77.34)
        dummy_bot_spawn_facing = vect(28.865, 7.252, -77.34)
        shop_location = vect(-5.95, 4.611, -102.526)
        shop_talent_positions[0] = vect(-7.025, 4.948, -108.214)
        shop_talent_positions[1] = vect(-4.132, 5.164, -107.363)
        shop_talent_positions[2] = vect(-1.687, 4.883, -106.065)
    elif getCurrentMap() == Map.ECOPOINT_ANTARCTICA:
        map_antarctica()
        dummy_bot_spawn_position = vect(-33.601, 9.455, -0.077)
        dummy_bot_spawn_facing = vect(-29.427, 10.582, 0.021)
        shop_location = vect(-11.287, 27.001, 22.31)
        shop_talent_positions[0] = vect(-15.965, 29.219, 25.678)
        shop_talent_positions[1] = vect(-16.535, 29.46, 22.783)
        shop_talent_positions[2] = vect(-16.45, 29.219, 19.92)
    elif getCurrentMap() == Map.CHATEAU_GUILLARD or getCurrentMap() == Map.CHATEAU_GUILLARD_HALLOWEEN:
        map_chateau_guillard()
        dummy_bot_spawn_position = vect(206.444, 15.955, 86.831)
        dummy_bot_spawn_facing = vect(206.444, 15.955, 86.831)
        shop_location = vect(247.531, -0.506, 50.543)
        shop_talent_positions[0] = vect(252.604, 1.63, 48.43)
        shop_talent_positions[1] = vect(252.429, 2.033, 51.359)
        shop_talent_positions[2] = vect(251.716, 1.586, 53.944)
    elif getCurrentMap() == Map.KINGS_ROW or getCurrentMap() == Map.KINGS_ROW_WINTER:
        map_kings_row()
        dummy_bot_spawn_position = vect(-95.498, 7.937, -30.638)
        dummy_bot_spawn_facing = vect(-95.498, 7.937, -30.638)
        shop_location = vect(-140.793, 6.939, 22.963)
        shop_talent_positions[0] = vect(-144.654, 7.111, 26.609)
        shop_talent_positions[1] = vect(-145.924, 7.492, 23.767)
        shop_talent_positions[2] = vect(-145.762, 7.073, 20.701)
    elif getCurrentMap() == Map.BLIZZ_WORLD or getCurrentMap() == Map.BLIZZ_WORLD_WINTER:
        map_blizzard_world()
        dummy_bot_spawn_position = vect(-45.778, 4.981, 95.978)
        dummy_bot_spawn_facing = vect(-45.778, 4.981, 95.978)
        shop_location = vect(-140.141, 1.684, 105.206)
        shop_talent_positions[0] = vect(-145.471, 3.066, 106.655)
        shop_talent_positions[1] = vect(-144.712, 3.141, 103.87)
        shop_talent_positions[2] = vect(-143.468, 2.792, 101.504)
    elif getCurrentMap() == Map.HANAMURA or getCurrentMap() == Map.HANAMURA_WINTER:
        dummy_bot_spawn_position = vect(11.903, 11.666, 21.966)
        dummy_bot_spawn_facing = vect(11.903, 11.666, 21.966)
        shop_location = vect(1.859, 0.68, 19.337)
        shop_talent_positions[0] = vect(-1.152, 1.611, 15.181)
        shop_talent_positions[1] = vect(1.875, 1.631, 14.133)
        shop_talent_positions[2] = vect(4.708, 1.483, 15.417)
    elif getCurrentMap() == Map.NECROPOLIS:
        map_necropolis()
        dummy_bot_spawn_position = vect(-27.407, 9.455, -0.003)
        dummy_bot_spawn_facing = vect(-27.407, 9.455, -0.003)
        shop_location = vect(42.975, 8.571, -0.079)
        shop_talent_positions[0] = vect(46.729, 9.457, -4.042)
        shop_talent_positions[1] = vect(48.006, 9.655, -1.553)
        shop_talent_positions[2] = vect(48.256, 9.406, 1.45)
    elif getCurrentMap() == Map.PETRA:
        map_petra()
        dummy_bot_spawn_position = vect(43.642, 13.747, 33.965)
        dummy_bot_spawn_facing = vect(43.642, 13.747, 33.965)
        shop_location = vect(-52.288, -18.045, 5.863)
        shop_talent_positions[0] = vect(-56.327, -16.669, 9.215)
        shop_talent_positions[1] = vect(-57.335, -16.73, 5.903)
        shop_talent_positions[2] = vect(-56.46, -16.67, 2.626)
    elif getCurrentMap() == Map.KANEZAKA:
        map_kanezaka()
        dummy_bot_spawn_position = vect(-8.115, 6.507, -38.928)
        dummy_bot_spawn_facing = vect(-8.115, 6.507, -38.928)
        shop_location = vect(-22.798, 23.978, 54.659)
        shop_talent_positions[0] = vect(-21.18, 24.327, 48.941)
        shop_talent_positions[1] = vect(-18.936, 24.588, 51.056)
        shop_talent_positions[2] = vect(-17.535, 24.302, 53.351)
    elif getCurrentMap() == Map.CASTILLO:
        dummy_bot_spawn_position = vect(-112.424, 33.763, 59.87)
        dummy_bot_spawn_facing = vect(-112.424, 33.763, 59.87)
        shop_location = vect(-60.288, 22.011, 50.687)
        shop_talent_positions[0] = vect(-55.86, 22.533, 46.725)
        shop_talent_positions[1] = vect(-54.774, 22.706, 49.529)
        shop_talent_positions[2] = vect(-54.935, 22.481, 52.534)
    elif getCurrentMap() == Map.DORADO:
        dummy_bot_spawn_position = vect(27.568, 4.221, -17.033)
        dummy_bot_spawn_facing = vect(27.568, 4.221, -17.033)
        shop_location = vect(78.814, -7.22, 60.419)
        shop_talent_positions[0] = vect(78.019, -6.203, 66.255)
        shop_talent_positions[1] = vect(75.547, -6.043, 64.771)
        shop_talent_positions[2] = vect(73.356, -6.27, 62.604)
    elif getCurrentMap() == Map.HAVANA:
        dummy_bot_spawn_position = vect(107.152, 2.067, -27.697)
        dummy_bot_spawn_facing = vect(107.152, 2.067, -27.697)
        shop_location = vect(108.634, -6.72, -98.952)
        shop_talent_positions[0] = vect(109.618, -6.593, -104.188)
        shop_talent_positions[1] = vect(112.271, -6.455, -103.031)
        shop_talent_positions[2] = vect(113.836, -6.6, -100.569)
    elif getCurrentMap() == Map.HORIZON_LUNAR_COLONY:
        dummy_bot_spawn_position = vect(-5.277, 8.455, -0.963)
        dummy_bot_spawn_facing = vect(-5.277, 8.455, -0.963)
        shop_location = vect(-38.034, 19.101, -98.472)
        shop_talent_positions[0] = vect(-40.56, 20.427, -94.246)
        shop_talent_positions[1] = vect(-42.443, 20.629, -96.138)
        shop_talent_positions[2] = vect(-42.719, 20.427, -98.671)
    elif getCurrentMap() == Map.PARIS:
        map_paris()
        dummy_bot_spawn_position = vect(-15.892, 11.764, -28.584)
        dummy_bot_spawn_facing = vect(-15.892, 11.765, -28.584)
        shop_location = vect(-57.281, 15, 16.922)
        shop_talent_positions[0] = vect(-58.455, 15.865, 20.72)
        shop_talent_positions[1] = vect(-59.898, 16.065, 19.441)
        shop_talent_positions[2] = vect(-61.128, 15.865, 18)
    elif getCurrentMap() == Map.TEMPLE_OF_ANUBIS:
        dummy_bot_spawn_position = vect(9.821, 1.229, -34.382)
        dummy_bot_spawn_facing = vect(9.821, 1.229, -34.382)
        shop_location = vect(-11.913, 9.69, 140.21)
        shop_talent_positions[0] = vect(-14.907, 10.161, 136.422)
        shop_talent_positions[1] = vect(-12.276, 10.256, 135.274)
        shop_talent_positions[2] = vect(-9.479, 10.212, 135.867)
    elif getCurrentMap() == Map.VOLSKAYA:
        dummy_bot_spawn_position = vect(-5.23, -5.49, 20.299)
        dummy_bot_spawn_facing = vect(-5.23, -5.49, 20.299)
        shop_location = vect(29.638, 0.967, 135.899)
        shop_talent_positions[0] = vect(34.473, 1.742, 133.502)
        shop_talent_positions[1] = vect(35.005, 1.942, 136.165)
        shop_talent_positions[2] = vect(34.623, 1.742, 139)
    elif getCurrentMap() == Map.MALEVENTO:
        map_malevento()
        dummy_bot_spawn_position = vect(19.218, 9.455, 36.238)
        dummy_bot_spawn_facing = vect(19.218, 9.455, 36.238)
        shop_location = vect(-37.854, -3.482, 27.558)
        shop_talent_positions[0] = vect(-42.108, -2.527, 30.596)
        shop_talent_positions[1] = vect(-43.465, -2.309, 28.296)
        shop_talent_positions[2] = vect(-43.142, -2.372, 25.602)


def create_talent_hud_texts():
    @Name "GENERAL - - - [SUBROUTINE] Create HUD Texts"
    
    hudText(getAllPlayers(), null, TOP_RIGHT_TEXT, HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(getAllPlayers(), null, "", "[More info: workshop.codes/ZEKK3]", HudPosition.RIGHT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(localPlayer if localPlayer.amount_of_bonus_talents > 0 or localPlayer.can_enter_shop == true and localPlayer.replacing_talent_show_confirmation == false and localPlayer.replacing_talent_show_bought_talents == false else null, "[Hold: {0} to skip a bonus talent]".format(buttonString(Button.RELOAD)) if localPlayer.amount_of_bonus_talents > 0 else "[Hold: {0} to use Hearthstone]".format(buttonString(Button.RELOAD)) if localPlayer.browsing_shop == false else "[Hold: {0} to skip a talent, exit shop and get a XP boost]".format(buttonString(Button.RELOAD)) if localPlayer.browsing_shop == true else "", HudPosition.TOP, 2, Color.SKY_BLUE if localPlayer.amount_of_bonus_talents > 0 else Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)

def create_talent_helpers():
    @Name "GENERAL - - - [SUBROUTINE] Create Cooldown Ready Icons"
    
    #Health Potions or Poison Vials
    createInWorldText(localPlayer if ((localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or localPlayer.talent_ranks[Talent.POISON_VIALS] > 0) and localPlayer.browsing_shop == false) and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false else null, "{0}   {1}   {2}".format(abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_potions_or_vials >= 1 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_potions_or_vials >= 1 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_potions_or_vials >= 2 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_potions_or_vials >= 2 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_potions_or_vials == 3 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_potions_or_vials >= 3 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else ""), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #Bandage, Jetpack or Dive Bomb
    createProgressBarInWorldText(localPlayer if localPlayer.isAlive() and localPlayer.browsing_shop == false and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false and (localPlayer.is_using_ability[Talent.DIVE_BOMB] == true or localPlayer.bandage_progress > 0 or localPlayer.jetpack_fuel < 100) else null, ((localPlayer.dive_bomb_damage - DIVE_BOMB_DAMAGE_LOCAL) / DIVE_BOMB_DAMAGE_LOCAL) * 100 if localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else localPlayer.bandage_progress * 100 / 10 if localPlayer.is_using_ability[Talent.BANDAGE] == true else localPlayer.jetpack_fuel, "{0} DAMAGE: {1}".format(abilityIconString(Hero.HAMMOND, Button.CROUCH), localPlayer.dive_bomb_damage) if localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else "{0} BANDAGING".format(abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE)) if localPlayer.is_using_ability[Talent.BANDAGE] else "{0} THRUST".format(abilityIconString(Hero.DVA, Button.ABILITY_1)), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.625 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.WHITE if localPlayer.is_using_ability[Talent.BANDAGE] == true or localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else Color.RED if localPlayer.jetpack_fuel < 33 else Color.ORANGE if localPlayer.jetpack_fuel < 66 else Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
    #Entering Stealth
    createProgressBarInWorldText(localPlayer if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.browsing_shop == false and (localPlayer.entering_stealth == true or localPlayer.is_using_ability[Talent.STEALTH] == true) else null, localPlayer.entering_stealth_timer * 100, "Entering Stealth" if localPlayer.is_using_ability[Talent.STEALTH] == false else "Stealthed", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.75 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #Talent Cooldown Icons
    createInWorldText(localPlayer if localPlayer.browsing_shop == false and localPlayer.getCurrentHero() == Hero.SOLDIER and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false else null, "{0}{1}{2}".format(abilityIconString(Hero.SOMBRA, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.talent_trigger_times[Talent.STEALTH] + talent_base_cooldowns[Talent.STEALTH] - localPlayer.talent_ranks[Talent.STEALTH] * 4 <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.REINHARDT, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.JUGGERNAUT] > 0 and localPlayer.talent_trigger_times[Talent.JUGGERNAUT] + talent_base_cooldowns[Talent.JUGGERNAUT] <= localPlayer.totalTimeElapsed else "", "{0}{1}{2}".format(abilityIconString(Hero.HAMMOND, Button.CROUCH) if localPlayer.talent_ranks[Talent.DIVE_BOMB] > 0 and localPlayer.talent_trigger_times[Talent.DIVE_BOMB] + talent_base_cooldowns[Talent.DIVE_BOMB] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE) if localPlayer.talent_ranks[Talent.BLOODTHIRST] > 100 and localPlayer.talent_trigger_times[Talent.PREDATOR] + talent_base_cooldowns[Talent.PREDATOR] <= localPlayer.totalTimeElapsed else "", "{0}{1}{2}".format(iconString(Icon.SKULL) if localPlayer.talent_ranks[Talent.BERSERKER] > 0 and localPlayer.talent_trigger_times[Talent.BERSERKER] + talent_base_cooldowns[Talent.BERSERKER] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.PHARAH, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.FIREBALL] > 0 and localPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= localPlayer.totalTimeElapsed else "", "{0}{1}{2}".format(abilityIconString(Hero.MOIRA, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.SHADOWSTEP] > 0 and localPlayer.talent_trigger_times[Talent.SHADOWSTEP] + talent_base_cooldowns[Talent.SHADOWSTEP] - localPlayer.talent_ranks[Talent.SHADOWSTEP] * 2.5 <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.JUNKER_QUEEN, Button.SECONDARY_FIRE) if localPlayer.talent_ranks[Talent.POISONOUS_DAGGER] > 0 and localPlayer.talent_trigger_times[Talent.POISONOUS_DAGGER] + talent_base_cooldowns[Talent.POISONOUS_DAGGER] <= localPlayer.totalTimeElapsed else "", "{0}{1}".format(abilityIconString(Hero.BAPTISTE, Button.ABILITY_2) if localPlayer.talent_ranks[Talent.PURITY_FIELD] > 0 and localPlayer.talent_trigger_times[Talent.PURITY_FIELD] + talent_base_cooldowns[Talent.PURITY_FIELD] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE) if localPlayer.talent_ranks[Talent.BANDAGE] > 0 and localPlayer.talent_trigger_times[Talent.BANDAGE] + talent_base_cooldowns[Talent.BANDAGE] <= localPlayer.totalTimeElapsed else ""))))), updateEveryTick(localPlayer.getEyePosition() + (100 * (0.5 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.2 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    #Hearthstone
    createProgressBarInWorldText(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.using_one_of_the_hearthstones else null, localPlayer.using_hearthstone_timer / 2.75 * 100 if debugging == false else 50, "{0} Using Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.browsing_shop == false else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} Skipping Bonus Talent".format(iconString(Icon.TRASHCAN)) if localPlayer.amount_of_bonus_talents > 0 and localPlayer.isHoldingButton(Button.RELOAD) else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.RELOAD) else "", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.55 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))) if localPlayer.browsing_shop == false else localPlayer.selected_talent_position + Vector.UP, 1, Clip.NONE, Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #What button to press in Stealth or Berserker or Bandage
    createInWorldText(localPlayer if ((localPlayer.talent_ranks[Talent.STEALTH] > 0 or localPlayer.talent_ranks[Talent.BERSERKER] > 0 or localPlayer.talent_ranks[Talent.BANDAGE] > 0) and localPlayer.browsing_shop == false) and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false else null, "{0}".format("{0} {1} = Cancel".format(iconString(Icon.SKULL), buttonString(Button.ULTIMATE)) if localPlayer.is_using_ability[Talent.BERSERKER] == true else "{0} {1} = Stun".format(abilityIconString(Hero.SOMBRA, Button.ABILITY_1), buttonString(Button.MELEE)) if localPlayer.is_using_ability[Talent.STEALTH] == true else "{0} {1} = Cancel".format(abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE), buttonString(Button.MELEE)) if localPlayer.is_using_ability[Talent.BANDAGE] == true else ""), updateEveryTick(localPlayer.getEyePosition() + (100 * (1.625 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.2 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #Helix Rocket Cooldown or Railgun Cooldown / Charge
    createInWorldText(localPlayer if "{0}".format(localPlayer.isCommunicatingEmote()) == "0" and localPlayer.browsing_shop == false and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false and localPlayer.amount_of_bonus_talents == 0 else null, "{0} {1}%".format(iconString(Icon.BOLT), ceil(localPlayer.railgun_charge)) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge > 0 else ("{0} Ready".format(iconString(Icon.BOLT) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 else abilityIconString(Hero.SOLDIER, Button.SECONDARY_FIRE))) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= localPlayer.totalTimeElapsed or localPlayer.talent_ranks[Talent.RAILGUN] == 0 and localPlayer.rockets_cooldown == 0 else "{0} Cooldown: {1}".format(iconString(Icon.BOLT) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 else abilityIconString(Hero.SOLDIER, Button.SECONDARY_FIRE), localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] - localPlayer.totalTimeElapsed if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > localPlayer.totalTimeElapsed else localPlayer.rockets_cooldown if localPlayer.talent_ranks[Talent.RAILGUN] == 0 else 0), updateEveryTick(localPlayer.getEyePosition() + (100 * (worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge < 100 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= localPlayer.totalTimeElapsed else Color.SKY_BLUE if localPlayer.railgun_charge >= 100 else Color.GRAY if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > localPlayer.totalTimeElapsed or localPlayer.rockets_cooldown > 0 and localPlayer.talent_ranks[Talent.RAILGUN] == 0 else Color.WHITE, SpecVisibility.NEVER)
    #Cancel Juggernaut
    createInWorldText(localPlayer if localPlayer.is_using_ability[Talent.JUGGERNAUT] == true and localPlayer.has_hit_the_ground == true else null, "{0} {1} = Cancel".format(abilityIconString(Hero.REINHARDT, Button.ABILITY_1), buttonString(Button.INTERACT)), updateEveryTick(localPlayer.getEyePosition()), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)

rule "GENERAL - - - Has Spawned":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_respawning == true
    
    if map_is_changing == false:
        setMatchTime(3599)
    eventPlayer.xp_orb_position_on_player = false
    eventPlayer.is_respawning = false
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    if eventPlayer.stats[4] > 0:
        removeHealthPool(eventPlayer.health_pool_id_or_hot_id[7])
        eventPlayer.addHealthPool(Health.SHIELDS, eventPlayer.stats[4], true, true)
        eventPlayer.health_pool_id_or_hot_id[7] = getLastCreatedHealthPool()
    if eventPlayer.can_enter_shop == true and eventPlayer.amount_of_talents_purchased < 25:
        async(open_shop, AsyncBehavior.NOOP)
    else:
        wait(0.125)
        eventPlayer.stopCamera()
    if eventPlayer.getCurrentHero() == Hero.SOLDIER:
        eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    eventPlayer.enableHeroHud()
    eventPlayer.setCrouchEnabled(true)
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
    destroyEffect(eventPlayer.hearthstone_effects_id[0])
    destroyEffect(eventPlayer.hearthstone_effects_id[1])
    if eventPlayer.getCurrentHero() == Hero.REAPER:
        eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    eventPlayer.setMaxHealth(eventPlayer.stats[1])
    heal(eventPlayer, null, eventPlayer.getMaxHealth())
    eventPlayer.setKnockbackReceived(eventPlayer.stats[9])

/*
def late_to_the_party():
    @Name "Subroutine late_to_the_party"
    
    eventPlayer.disableHeroHud()
    eventPlayer.setMoveSpeed(0)
    eventPlayer.setCrouchEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.startCamera(shop_location, shop_talent_positions[1], 0.5)
    wait(1)
    bigMessage(eventPlayer, "Welcome {0}!".format(eventPlayer.player_name))
    wait(3)
    bigMessage(eventPlayer, "{0} You are a bit late to the party...".format(iconString(Icon.HAPPY)))
    wait(3)
    bigMessage(eventPlayer, "You received {0} Bonus talents to catch up!".format(leading_player_talents_purchased if leading_player_talents_purchased <= 5 else 5))
    wait(5)
    open_shop()
*/
    


/*rule "GENERAL - - - OW2 Temporary Health Fix [Needs proper solution when I got time]":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.browsing_shop == false
    
    eventPlayer.setMaxHealth(eventPlayer.stats[1])
    heal(eventPlayer, null, eventPlayer.getMaxHealth())*/


rule "GENERAL - - - Player Died":
    @Event playerDied
    
    if eventPlayer.made_outlines_for_predator_rank > 0:
        eventPlayer.stopForcingOutlineFor(getAllPlayers())
        eventPlayer.made_outlines_for_predator_rank = 0
    if attacker.getCurrentHero() == Hero.REAPER:
        attacker.random_integer_between_0_to_5 = random.randint(0, 9)
        if attacker.random_integer_between_0_to_5 <= 1 and attacker.reaper_hello_cooldown == 0:
            attacker.communicate(Comms.SORRY)
            attacker.reaper_hello_cooldown = 10
    if eventPlayer.xp_boost_is_active == true:
        stopChasingVariable(eventPlayer.experience_current)
    if eventAbility == Button.PRIMARY_FIRE:
        eventPlayer.applyImpulse(worldVector(angleToDirection(0, -45), attacker, Transform.ROTATION), 9.8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    elif eventAbility == Button.SECONDARY_FIRE:
        eventPlayer.applyImpulse(eventDirection + Vector.UP, 9.8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    eventPlayer.dropped_xp_orb = true
    eventPlayer.xp_orb_position_on_player = true
    destroyEffect(eventPlayer.player_temp_effects[42])
    stopChasingVariable(eventPlayer.xp_orb_location)
    eventPlayer.in_combat = 0
    async(dropped_xp_orb, AsyncBehavior.NOOP)
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    #Burning Soul
    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0:
        eventPlayer.burning_soul_orb_timer = 4
        wait()
        async(dropped_burning_soul_orb, AsyncBehavior.RESTART)
        xp_orb_mines[eventPlayer.getSlot()] = eventPlayer
    createEffect(getAllPlayers().exclude(eventPlayer) if eventPlayer.dropped_xp_orb == true else null, Effect.ORB, orb_rarity_colors[round(eventPlayer.amount_of_talents_purchased / 5.56)], updateEveryTick(eventPlayer.getPosition() + Vector.UP * 0.25) if eventPlayer.xp_orb_position_on_player == true else updateEveryTick(eventPlayer.xp_orb_location), 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[42] = getLastCreatedEntity()
    eventPlayer.is_respawning = true
    if attacker == victim:
        eventPlayer.addToScore(1)
    waitUntil(eventPlayer.isInAir(), 0.25)
    waitUntil(eventPlayer.isOnGround(), 2.75)
    eventPlayer.xp_orb_location = eventPlayer.getPosition() + Vector.UP * 0.25
    if eventPlayer.isOnGround():
        return
    eventPlayer.xp_orb_destination = eventPlayer.xp_orb_location + Vector.DOWN * 100
    chase(eventPlayer.xp_orb_location, raycast(eventPlayer.xp_orb_location, eventPlayer.xp_orb_destination, null, getAllPlayers(), true).getHitPosition() + Vector.UP * 0.25, rate=9.8, ChaseReeval.DESTINATION_AND_RATE)

rule "GENERAL - - - Player Dealt Damage":
    @Event playerDealtDamage
    #@Hero soldier
    /*
    if victim.talent_ranks[Talent.PREDATOR] > 0 and attacker.getHealthOfType(Health.NORMAL) < attacker.getMaxHealthOfType(Health.NORMAL) * PREDATOR_THRESHOLD_NORMALIZED_VICTIM and attacker.getHealthOfType(Health.NORMAL) < victim.getHealthOfType(Health.NORMAL):
        heal(victim, victim, min(eventDamage * 0.20, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL)))
        victim.predator_damage_resisted += eventDamage * 0.20
    */
    #if not eventPlayer.isDummy():
    if eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0 and eventPlayer.is_using_ability[Talent.BERSERKER] == true:
        eventPlayer.bloodthirst_remaining_heal_amount += BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT
    if attacker.is_using_ability[Talent.PURITY_FIELD] == false and attacker != victim:
        attacker.using_hearthstone_timer = 0
        attacker.in_combat = 3
    if eventPlayer.experience_current < eventPlayer.experience_max and attacker != victim:
        eventPlayer.experience_current += eventDamage / 5 * eventPlayer.stats[5]
    if attacker.talent_ranks[Talent.PREDATOR] > 0 and victim.getHealthOfType(Health.NORMAL) < victim.getMaxHealthOfType(Health.NORMAL) *    PREDATOR_THRESHOLD_NORMALIZED_ATTACKER and victim.getHealthOfType(Health.NORMAL) < attacker.getHealthOfType(Health.NORMAL):
        damage(victim, attacker, eventDamage * 0.20)
        attacker.predator_damage_dealt += eventDamage * 0.20
    #MELEE
    if eventAbility == Button.MELEE:
        #Dealt Stealth damage?
        if victim.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.STEALTH] == true and eventAbility != null:
            victim.hit_by_talent[Talent.STEALTH] = attacker
            victim.setStatusEffect(attacker, Status.STUNNED, 0.5)
        if victim.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.STEALTH] == true and eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] > 0 and eventPlayer.talent_trigger_times[Talent. POISONOUS_DAGGER] + talent_base_cooldowns[Talent.POISONOUS_DAGGER] <= eventPlayer.totalTimeElapsed:
            victim.startDoT(attacker, POISONOUS_DAGGER_DURATION, POISONOUS_DAGGER_DAMAGE_PER_SECOND)
            eventPlayer.talent_trigger_times[Talent.POISONOUS_DAGGER] = eventPlayer.totalTimeElapsed
        if eventPlayer.talent_ranks[Talent.STEALTH] > 0 and eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
    #PRIMARY FIRE || ULTIMATE
    elif eventAbility == Button.PRIMARY_FIRE or eventAbility == Button.ULTIMATE:
        #Victim = Gigachad?
        if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
            heal(victim, victim, min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL)))
            victim.gigachad_damage_resisted += min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
        #Gunslinger?
        if attacker.talent_ranks[Talent.GUNSLINGER] > 0 and attacker.railgun_charge < 100:
            damage(victim, attacker, GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit else GUNSLINGER_ADDITIONAL_DAMAGE)
            if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
                victim.gigachad_damage_resisted += min(GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
        #Railgun?
        if attacker.railgun_charge >= 100:
            damage(victim, attacker, RAILGUN_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit else RAILGUN_ADDITIONAL_DAMAGE)
            if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
                victim.gigachad_damage_resisted += min(RAILGUN_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
            eventPlayer.railgun_projectile_player_hit = victim
            playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_1, victim.getPosition(), 1)
            playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, victim.getPosition(), 100)
            playEffect(getAllPlayers(), DynamicEffect.PHARAH_CONCUSSIVE_BLAST, Color.TEAM_1, victim.getPosition(), 1)
            if attacker.using_cryogenics == true and victim.is_using_ability[Talent.JUGGERNAUT] == false and victim.is_using_ability[Talent.PURITY_FIELD] == false:
                victim.hit_by_talent[Talent.CRYOGENICS] = attacker
                attacker.talent_trigger_times[Talent.CRYOGENICS] = attacker.totalTimeElapsed - attacker.cryogenics_travel_time
            if attacker.talent_ranks[Talent.IGNITE] > 0 and victim.is_using_ability[Talent.PURITY_FIELD] == false:
                victim.setStatusEffect(attacker, Status.BURNING, 3)
                victim.startDoT(attacker, 3, IGNITE_RAILGUN_DAMAGE_PER_SECOND)
        #Lifesteal Ammo?
        if attacker.talent_ranks[Talent.LIFESTEAL_AMMO] > 0 and attacker.getHealthOfType(Health.NORMAL) < attacker.getMaxHealthOfType(Health.NORMAL):
            heal(attacker, attacker, min(LIFESTEAL_RAILGUN_HEAL if eventPlayer.railgun_charge >= 100 else LIFESTEAL_GUNSLINGER_HEAL if attacker.talent_ranks[Talent.    GUNSLINGER] > 0 else LIFESTEAL_HEAL, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
            eventPlayer.is_lifestealing = 1.5
            lifesteal_hps()
    #SECONDARY FIRE
    elif eventAbility == Button.SECONDARY_FIRE:
        if attacker.talent_ranks[Talent.BOMBARDMENT] > 0:
            damage(victim, attacker, BOMBARDMENT_DAMAGE)
        if attacker.using_cryogenics == true and victim.is_using_ability[Talent.JUGGERNAUT] == false and victim.is_using_ability[Talent.PURITY_FIELD] == false and victim.  is_using_ability[Talent.SHADOWSTEP] == false:
            victim.hit_by_talent[Talent.CRYOGENICS] = attacker
            attacker.talent_trigger_times[Talent.CRYOGENICS] = attacker.totalTimeElapsed - attacker.cryogenics_travel_time
        if attacker.talent_ranks[Talent.IGNITE] > 0 and victim.is_using_ability[Talent.PURITY_FIELD] == false:
            victim.setStatusEffect(attacker, Status.BURNING, 3)
            victim.startDoT(attacker, 3, IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND if attacker.talent_ranks[Talent.BOMBARDMENT] > 0 else IGNITE_DAMAGE_PER_SECOND)
        if attacker.talent_ranks[Talent.LIFESTEAL_AMMO] > 0:
            heal(attacker, attacker, min(LIFESTEAL_HEAL, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
            eventPlayer.is_lifestealing = 1.5
            playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.TEAM_1, attacker.getPosition(), 100)
            lifesteal_hps()
        if attacker.talent_ranks[Talent.IGNITE] > 0 and attacker.is_using_ability[Talent.IGNITE] == true:
            attacker.is_using_ability[Talent.IGNITE] = false

rule "GENERAL - - - Player Took Damage":
    @Event playerTookDamage
    
    victim.in_combat_passive_health_regen = 4.9
    if victim.is_using_ability[Talent.BLOODTHIRST] == true and victim.bloodthirst_remaining_heal_amount >= 1:
        victim.bloodthirst_remaining_heal_amount -= eventDamage
    #Disabled because predator not working (outlines are bugged)
    #if someone_in_match_have_predator == true and victim.getNormalizedHealth() <= 0.15 + highest_predator_rank_in_match * 0.05 and victim.isAlive():
    #If outlines are created for a higher rank
    #if (floor((victim.getNormalizedHealth() - 0.15) / 5)) * 100 >= 1 and (floor((victim.getNormalizedHealth() - 0.15) / 5)) * 100 < victim.made_outlines_for_predator_rank:
    #eventPlayer.stopForcingOutlineFor(getAllPlayers())
    #__end__()
    #if victim.getNormalizedHealth() <= 0.2 and players_with_predator_rank[1] > 0 and (victim.made_outlines_for_predator_rank > 1 or victim.made_outlines_for_predator_rank == 0):
    #eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 0 and player != eventPlayer], true, Color.RED, OutlineVisibility.ALWAYS)
    #elif victim.getNormalizedHealth() <= 0.25 and players_with_predator_rank[2] > 0 and (victim.made_outlines_for_predator_rank > 2 or victim.made_outlines_for_predator_rank == 0):
    #eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 1 and player != eventPlayer], true, Color.RED, OutlineVisibility.ALWAYS)
    #elif victim.getNormalizedHealth() <= 0.3 and players_with_predator_rank[3] > 0 and (victim.made_outlines_for_predator_rank > 3 or victim.made_outlines_for_predator_rank == 0):
    #eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 2 and player != eventPlayer], true, Color.RED, OutlineVisibility.ALWAYS)
    #elif victim.getNormalizedHealth() <= 0.35 and players_with_predator_rank[4] > 0 and (victim.made_outlines_for_predator_rank > 4 or victim.made_outlines_for_predator_rank == 0):
    #eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 3 and player != eventPlayer], true, Color.RED, OutlineVisibility.ALWAYS)
    #elif victim.getNormalizedHealth() <= 0.4 and players_with_predator_rank[5] > 0 and victim.made_outlines_for_predator_rank == 0:
    #eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 4 and player != eventPlayer], true, Color.RED, OutlineVisibility.ALWAYS)
    #__end__()
    #Set variable (1 to 5)
    #victim.made_outlines_for_predator_rank = (floor((victim.getNormalizedHealth() - 0.15) / 5)) * 100
    #if victim.made_outlines_for_predator_rank < 1:
    #victim.made_outlines_for_predator_rank = 1
    #__end__()
    if victim.is_using_ability[Talent.BANDAGE] == true and victim != attacker and victim.is_using_ability[Talent.PURITY_FIELD] == false and victim.bandage_progress > 0.032:
        victim.is_using_ability[Talent.BANDAGE] = false
    if victim.is_using_ability[Talent.PURITY_FIELD] == false and victim != attacker:
        attacker.using_hearthstone_timer = 0
        victim.in_combat = 3
    if victim.talent_ranks[Talent.STEALTH] > 0 and victim.is_using_ability[Talent.PURITY_FIELD] == false and victim != attacker:
        stopChasingVariable(victim.entering_stealth_timer)
        victim.entering_stealth_timer = 0
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
    if victim.is_using_ability[Talent.IGNORE_PAIN] == true /*and attacker.getCurrentHero() == Hero.SOLDIER*/ and victim.is_using_ability[Talent.PURITY_FIELD] == false:
        eventPlayer.ignore_pain_damage_resisted[0] += eventDamage

/*rule "No Health Regen Passive":
    @Event eachPlayer
    @Condition createWorkshopSetting(bool, "General", "Disable Passive Health Regen (Triggers annoying sound and hit markers - blame blizzard)", true, 0) == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getHealth() < eventPlayer.getMaxHealth()
    @Condition eventPlayer.in_combat_passive_health_regen == 0
    
    if eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        damage(eventPlayer, eventPlayer, 1)
    else:
        damage(eventPlayer, eventPlayer, 0.001)
    #eventPlayer.setHealth(eventPlayer.getHealthOfType(Health.NORMAL) - 20)
    #wait(1, Wait.ABORT_WHEN_FALSE)
    #if RULE_CONDITION:
    #        goto RULE_START*/

rule "GENERAL - - - Player Slowed (Hit by Cryogenics Talent)":
    @Event eachPlayer
    @Condition eventPlayer.cryogenics_slow_amount < eventPlayer.stats[2]
    @Condition eventPlayer.refresh_cryogenics_slow == true
    
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.refresh_cryogenics_slow = false
    eventPlayer.setAbility1Enabled(false)
    chase(eventPlayer.cryogenics_slow_amount, eventPlayer.stats[2], duration=eventPlayer.cryogenics_slow_duration, ChaseReeval.DESTINATION_AND_DURATION)
    while eventPlayer.isAlive() and eventPlayer.cryogenics_slow_amount != eventPlayer.stats[2] and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false and eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false:
        eventPlayer.setMoveSpeed(eventPlayer.cryogenics_slow_amount)
        wait(0.032, Wait.RESTART_WHEN_TRUE)
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.cryogenics_slow_amount = eventPlayer.stats[2]
    if eventPlayer.is_using_ability[Talent.BANDAGE] == true or eventPlayer.is_charging_railgun == true or eventPlayer.is_using_hearthstone == true or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        async(player_slowed, AsyncBehavior.RESTART)
    else:
        eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.cryogenics_slow_duration = 0


def dropped_xp_orb():
    @Name "GENERAL - - - Dropped XP Orb"
    
    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0:
        createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[77] = getLastCreatedEntity()
    while eventPlayer.dropped_xp_orb == true:
        #If there are other players near your XP Orb
        if (len([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer])) > 0:
            #Wait until the player near your XP Orb is not picking up another XP Orb
            waitUntil(((((sorted([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer], lambda i: distance(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, i.getPosition())))[0]).dummy_var)[20]) == null, 99999)
            #Set the nearest player to having picked up your XP Orb
            (((sorted([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer], lambda i: distance(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, i.getPosition())))[0]).dummy_var)[20] = eventPlayer
        if eventPlayer.burning_soul_orb_timer > 0:
            playEffect(getAllPlayers().exclude(eventPlayer), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.TEAM_1, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 1)
        wait(0.25)
        destroyEffect(eventPlayer.player_temp_effects[77])

rule "GENERAL - - - Picked Up XP Orb":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.owner_of_picked_up_xp_orb != null
    
    if eventPlayer.experience_current < eventPlayer.experience_max:
        smallMessage(eventPlayer, "{0} +{1} XP!".format(abilityIconString(Hero.GENJI, Button.JUMP), round(eventPlayer.owner_of_picked_up_xp_orb.experience_max * 0.2 * eventPlayer.stats[5])))
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 75)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, orb_rarity_colors[round(eventPlayer.owner_of_picked_up_xp_orb.amount_of_talents_purchased / 5.56)], eventPlayer.getPosition(), 1)
    #EXPERIENCE
    if eventPlayer.experience_current < eventPlayer.experience_max:
        eventPlayer.experience_current += eventPlayer.owner_of_picked_up_xp_orb.experience_max * 0.2 * eventPlayer.stats[5]
    #MINE?
    if eventPlayer.owner_of_picked_up_xp_orb.talent_ranks[Talent.BURNING_SOUL] > 0 and eventPlayer.owner_of_picked_up_xp_orb.burning_soul_orb_timer > 0:
        eventPlayer.owner_of_picked_up_xp_orb.burning_soul_orb_timer = 0
    eventPlayer.owner_of_picked_up_xp_orb.dropped_xp_orb = false
    wait()
    eventPlayer.owner_of_picked_up_xp_orb = null
    if eventPlayer.talent_ranks[Talent.ALCHEMIST] > 0 and eventPlayer.amount_of_potions_or_vials < 3 and ALCHEMIST_PROC_CHANCE:
        if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
            eventPlayer.health_potion_cooldown_memory = eventPlayer.totalTimeElapsed - eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS]
            eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.HEALTH_POTIONS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        elif eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
            eventPlayer.health_potion_cooldown_memory = eventPlayer.totalTimeElapsed - eventPlayer.talent_trigger_times[Talent.POISON_VIALS]
            eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.POISON_VIALS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        wait()
        smallMessage(eventPlayer, "{0} +1 {1}".format(iconString(Icon.RADIOACTIVE), "Health Potion!" if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else "Poison Vial!"))
    if eventPlayer.talent_ranks[Talent.SOUL_HARVEST] > 0:
        heal(eventPlayer, eventPlayer, SOUL_HARVEST_HEALING)
        playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 100)

def which_players_have_predator():
    @Name "Subroutine: Which players have pr3dator"
    
    players_with_predator[0] = [player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 0 and player.talent_ranks[Talent.PREDATOR] <= 5]
    players_with_predator[1] = [player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 1 and player.talent_ranks[Talent.PREDATOR] <= 5]
    players_with_predator[2] = [player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 2 and player.talent_ranks[Talent.PREDATOR] <= 5]
    players_with_predator[3] = [player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 3 and player.talent_ranks[Talent.PREDATOR] <= 5]
    players_with_predator[4] = [player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 4 and player.talent_ranks[Talent.PREDATOR] <= 5]

def player_slowed():
    @Name "Subroutine: Player Slowed"
    
    #using bandage, hearthstone, or purity field
    if eventPlayer.is_using_ability[Talent.BANDAGE] == true or eventPlayer.is_using_hearthstone == true or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.stats[2] = 25
        #if player is not affected by cryogenics
        if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
            eventPlayer.setMoveSpeed(eventPlayer.stats[2])
        waitUntil(eventPlayer.is_using_ability[Talent.BANDAGE] == false and eventPlayer.is_using_hearthstone == false and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false, 99999)
    #railgun
    if eventPlayer.is_charging_railgun == true:
        eventPlayer.stats[2] = 50
        #if player is not affected by cryogenics
        if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
            eventPlayer.setMoveSpeed(eventPlayer.stats[2])
        waitUntil(eventPlayer.is_charging_railgun == false, 99999)
    eventPlayer.stats[2] = 100
    #if player is not affected by cryogenics
    if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
        eventPlayer.setMoveSpeed(eventPlayer.stats[2])

rule "GENERAL - - - Anti Crash Enable":
    @Condition antiCrashActivated == false
    @Condition getServerLoad() > 200
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "Anti crash system activated")
    setSlowMotion(10)
    antiCrashActivated = true


rule "GENERAL - - - Anti Crash Disable":
    @Condition antiCrashActivated == true
    @Condition getServerLoad() < 175
    
    setSlowMotion(100)
    antiCrashActivated = false
/*
rule "dpstracking":
    @Event eachPlayer
    @Hero soldier

    chase(eventPlayer.dpstracking_time, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    hudText(eventPlayer, eventPlayer.dpstracking_damage, "Total Damage", null, HudPosition.RIGHT, 107, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(eventPlayer, eventPlayer.dpstracking_damage / (dpstracking_dpsTime - eventPlayer.dpstracking_time), "DPS", null, HudPosition.RIGHT, 108, Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(eventPlayer, eventPlayer.dpstracking_time, "Time", null, HudPosition.RIGHT, 109, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "dpstracking - dealt damage":
    @Event playerDealtDamage
    @Hero soldier
    @Condition victim != attacker

    destroyInWorldText(eventPlayer.dpstracking_textID)
    eventPlayer.dpstracking_position = victim.getEyePosition()
    createInWorldText(eventPlayer, eventDamage, eventPlayer.dpstracking_position, 0.850 + eventDamage / 30, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.dpstracking_textID = getLastCreatedText()
    chase(eventPlayer.dpstracking_position, victim.getEyePosition() + Vector.UP, rate=0.900, ChaseReeval.NONE)
    if eventPlayer.dpstracking_time == 0:
        return
    eventPlayer.dpstracking_damage += eventDamage

rule "dpstracking - start timer":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true

    eventPlayer.dpstracking_time = dpstracking_dpsTime
    eventPlayer.dpstracking_damage = 0
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH) == true, 99999)
    eventPlayer.dpstracking_time = 0
    eventPlayer.dpstracking_damage = 0
    eventPlayer.dpstracking_started_timer = false
    wait(0.250)
*/