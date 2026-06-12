#!mainFile "soldier_x.opy"

enum Talent:
    BLOODTHIRST, #1
    PURITY_FIELD, #2
    CYBERNETICS, #3
    SOUL_HARVEST, #4
    POISONOUS_DAGGER, #5
    STEALTH, #6
    JUGGERNAUT, #7
    DIVE_BOMB, #8
    CRYOGENICS, #9
    RAILGUN, #10
    GRIM_REAPER, #11
    JETPACK, #12
    LIFESTEAL_AMMO, #13
    HEALTH_REGEN, #14
    HEALTH_POTIONS, #15
    IGNITE, #16
    OVERCLOCK, #17
    SHADOWSTEP, #18
    BURNING_SOUL, #19
    BERSERKER, #20
    FIREBALL, #21
    IGNORE_PAIN, #22
    JAVELIN, #23
    BANDAGE, #24
    PYROMANIAC, #25
    POISON_VIALS, #26
    ALCHEMIST, #27
    #BOMBARDMENT, #28
    GIGACHAD, #29
    #GUNSLINGER, #30
    #ADRENALINE_RUSH #31

# GLOBAL VARIABLES

/*
globalvar dpstracking_dpsTime = createWorkshopSetting(int[1:60], "Settings", "DPS Time", 20, 1)
globalvar dpstracking_bot
*/
globalvar map_is_changing = false
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
globalvar orb_rarity_colors = [Color.WHITE, Color.GREEN, Color.BLUE, Color.PURPLE, Color.ORANGE, Color.ORANGE]
globalvar talent_rarity_colors = [Color.WHITE, Color.WHITE, Color.GREEN, Color.BLUE, Color.PURPLE, Color.ORANGE]
#globalvar xp_orb_effects = [null, null, null, null, null, null, null, null]
#globalvar xp_orb_locations = [null, null, null, null, null, null, null, null]
#globalvar xp_orb_mines = [null, null, null, null, null, null, null, null]
#globalvar xp_orb_values = [null, null, null, null, null, null, null, null]
globalvar global_variable
#globalvar players_with_grim_reaper = [[], [], [], [], []]
globalvar players_with_grim_reaper = []
globalvar player_with_most_talents = null
globalvar xp_orbs_current_index
globalvar player_picking_up_orb
#--- Bot system (multi-file) ---
globalvar spawn_bots = createWorkshopSettingBool("01. Bots", "Spawn bots?", true, 0)
globalvar amount_of_bots_and_players = createWorkshopSettingInt("01. Bots", "How many bots and players?", 8, 1, 8, 1)
globalvar bots_friendly = createWorkshopSettingBool("01. Bots", "Friendly?", false, 1)
globalvar pathfinder_owner = null
globalvar pathfinder_budget = 1
globalvar map_nodes = []
globalvar map_attributes_raw = []
globalvar map_flat_neighbors = []
globalvar map_temp_neighbors = []
globalvar map_encoded = false
globalvar map_ready = false

#--- Shop system (multi-file) ---
globalvar shop_location
globalvar shop_talent_positions
globalvar max_experience_per_level = [250, 275, 303, 333, 366, 403, 443, 487, 536, 589, 648, 713, 785, 863, 949, 1044, 1149, 1264, 1390, 1529, 1682, 1850, 2035, 2239, 2462, 2709]
playervar talent_trigger_times
playervar railgun_charge

#--- Debug variables (plain declarations — Workshop Settings assigned in debug files) ---
globalvar debug_spectator_tools
globalvar debug_damage_text
globalvar debug_texts = []

#--- Testing ---
globalvar faster_testing

enum Orb:
    OWNING_PLAYER,
    TIMESTAMP,
    XP_AMOUNT,
    EXPLOSIVE,
    EXPLOSIVE_RANK,
    POSITION,
    COLOR,
    ORB_EFFECT_ID,
    BURNING_SOUL_SOUND_EFFECT_ID,
    BURNING_SOUL_EFFECT_ID,
    

#globalvar xp_orb = [Orb.OWNING_PLAYER, Orb.TIMESTAMP, Orb.XP_AMOUNT, Orb.EXPLOSIVE, Orb.EXPLOSIVE_RANK, Orb.POSITION, Orb.COLOR, Orb.ORB_EFFECT_ID, Orb.BURNING_SOUL_SOUND_EFFECT_ID, Orb.BURNING_SOUL_EFFECT_ID]
globalvar xp_orb = [null, null, null, null, null, null, null, null, null, null]
globalvar xp_orbs = []





# PLAYER VARIABLES

enum Stat:
    DAMAGE,
    HEALTH,
    SPEED,
    ARMOR,
    SHIELDS,
    XP,
    VOICE,
    SIZE,
    KNOCKBACK_RECEIVED,
    EYE_HEIGHT,

#playervar stats = [Stat.DAMAGE, Stat.HEALTH, Stat.SPEED, Stat.ARMOR, Stat.SHIELDS, Stat.XP, Stat.VOICE, Stat.SIZE, Stat.KNOCKBACK_RECEIVED, Stat.EYE_HEIGHT]
playervar stats =  [100,         200,         100,        0,          0,            0.65,    1,          1,         100]

/*playervar dpstracking_started_timer
playervar dpstracking_time
playervar dpstracking_damage
playervar dpstracking_textID
playervar dpstracking_position*/
playervar i
playervar bot_loop_var
playervar rockets_cooldown
playervar totalTimeElapsed
playervar variable
playervar amount_of_health_potions
playervar amount_of_talents_purchased = 0
playervar bought_talents = []
playervar browsing_shop
playervar can_enter_shop = false
#playervar poison_vials_cloudData
#playervar dropped_xp_orb
playervar experience_current = 0
playervar experience_max = 250
/*playervar healing_done_in_combat*/
playervar health_potion_cooldown_memory
playervar in_combat = 0
#playervar indexMemory
playervar is_electrified = 0
playervar is_using_ability = []
playervar is_using_hearthstone = [false, false]
playervar juggernaut_charge
playervar talents_offered_in_shop
playervar player_name = "{0}".format(eventPlayer)
playervar player_temp_effects
playervar possible_talents = [Talent.PURITY_FIELD, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.GRIM_REAPER, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, Talent.BOMBARDMENT,*/ Talent.GIGACHAD/*, Talent.GUNSLINGER, Talent.ADRENALINE_RUSH*/]
#playervar poison_vials_projPos
#playervar poison_vials_projPosIn0032
/*playervar replace_replacing_or_cancelled = [false, false, false]*/
playervar skipped_a_talent
playervar talent_counter_or_position_etc
playervar talent_ranks = []
playervar talents_you_do_not_have = [Talent.PURITY_FIELD, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.GRIM_REAPER, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, Talent.BOMBARDMENT,*/ Talent.GIGACHAD/*, Talent.GUNSLINGER, Talent.ADRENALINE_RUSH*/]
playervar using_one_of_the_hearthstones
playervar which_is_talent_unique_unlocked = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
playervar xp_boost_is_active
#playervar xp_orb_destination
playervar dive_bomb_damage
playervar berserker_duration
playervar cryogenics_travel_time
playervar using_cryogenics = false
playervar hit_by_talent
playervar player_xp_orb_index
#playervar cybernetics_shields = 0
playervar purity_field_position = null
playervar victims_in_burning_soul_radius
#playervar remaining_poisonous_dagger_duration = 0
playervar poisonous_dagger_attackers = []       # list of attackers who've poisoned this victim
playervar poisonous_dagger_timestamp = []    # parallel array: totalTimeElapsed when each expires
playervar grim_reaper_camera_position = null
playervar casting_timer = 0
playervar grim_reaper_ramp_up = 0
playervar purity_field_duration = 0
playervar adrenaline_rush_value = 100
playervar recentDamageDealtToSlot = 0
playervar current_purity_field_target = 0
playervar current_dive_bomb_target = 0

#--- Multi-file defineMember (variable[0-42]) ---
#!defineMember is_using_hearthstone variable[0]
#!defineMember is_using_skip_talent variable[1]
#!defineMember is_using_vote_yes variable[2]
#!defineMember is_using_vote_no variable[3]
#!defineMember replacing_talent_show_confirmation variable[4]
#!defineMember replacing_talent_show_bought_talents variable[5]
#!defineMember replacing_talent_cancelled variable[6]
#!defineMember totalTimeElapsed_alignment variable[7]
#!defineMember is_charging_railgun variable[8]
#!defineMember selected_bought_talent variable[9]
#!defineMember selected_talent_in_shop variable[10]
#!defineMember amount_of_bonus_talents variable[11]
#!defineMember grim_reaper_damage_dealt variable[12]
#!defineMember grim_reaper_damage_resisted variable[13]
#!defineMember gigachad_damage_resisted variable[14]
#!defineMember exit_shop_with_fireball variable[15]
#!defineMember possible_talents_selector variable[16]
#!defineMember grim_reaper_target variable[17]
#!defineMember grim_reaper_camera_destination variable[18]
#!defineMember grim_reaper_feet_destination variable[19]
#!defineMember grim_reaper_effect_id variable[20]
#!defineMember grim_reaper_sound_id variable[21]
#!defineMember victims_in_grim_reaper_radius variable[22]
#!defineMember grim_reaper_cast_effect_id variable[23]
#!defineMember grim_reaper_aim_indicator variable[24]
#!defineMember casting_effect_id variable[25]
#!defineMember casting_sound_effect_id variable[26]
#!defineMember casting_success variable[27]
#!defineMember cybernetics_health_pool_id variable[28]
#!defineMember stealth_effect_id variable[29]
#!defineMember stealth_sound_id variable[30]
#!defineMember stealth_effect_id2 variable[31]
#!defineMember stealth_stun_text_id variable[32]
#!defineMember current_stealth_target variable[33]
#!defineMember railgun_charge_effect_id variable[34]
#!defineMember victims_in_purity_field_radius variable[35]
#!defineMember victims_in_dive_bomb_radius variable[36]
#!defineMember dive_bomb_damage_total variable[37]
#!defineMember bot_throttle_paused variable[38]
#!defineMember bot_edge_attr variable[39]
#!defineMember bot_strafe variable[40]
#!defineMember debug_bot_state variable[41]
#!defineMember debug_bot_stuck variable[42]

#--- Shared global defineMember (global_variable[0-49]) ---

#!defineMember highest_grim_reaper_rank_in_match global_variable[0]
#!defineMember debug_bot_walk_fail_pos global_variable[1]

#Subroutine names
subroutine buy_debug_talents
subroutine bloodthirst_effects
subroutine break_stealth
subroutine cancel_ability
subroutine cancel_shop_camera
subroutine create_talent_helpers
subroutine create_talent_hud_texts
subroutine dropped_burning_soul_orb
#subroutine dropped_xp_orb
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
subroutine replace_talent
subroutine spawned_with_fireball
subroutine stopped_using_hearthstone
subroutine using_one_of_the_hearthstones
subroutine recalculate_player_speed
subroutine which_players_have_grim_reaper
subroutine grim_reaper_casted
subroutine casting
subroutine block_player_input

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

macro ALCHEMIST_PROC_CHANCE = random.randint(33 + ((player_picking_up_orb.talent_ranks[Talent.ALCHEMIST] - 1) * 8.25), 100)
macro BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT = eventDamage * (0.19 + eventPlayer.talent_ranks[Talent.BLOODTHIRST] * 0.062)
macro BERSERKER_DURATION = 3.75 + eventPlayer.talent_ranks[Talent.BERSERKER] * 1.25
macro BURNING_SOUL_DAMAGE = 3 + eventPlayer.talent_ranks[Talent.BURNING_SOUL] * 0.6
macro BURNING_SOUL_ORB_DAMAGE = 75 + xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE_RANK] * 25
macro BURNING_SOUL_AURA_RADIUS = 8
macro BURNING_SOUL_ORB_DURATION = 4
macro GRIM_REAPER_RADIUS = 4
macro CRYOGENICS_SLOW_DURATION = 2 + eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 0.2
macro CRYOGENICS_SLOW_AMOUNT = eventPlayer.stats[Stat.SPEED] * 0.5 - eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 10
macro CYBERNETICS_SHIELD_AMOUNT = 56.25 + eventPlayer.talent_ranks[Talent.CYBERNETICS] * 18.75
macro SHADOWSTEP_BASE_COOLDOWN = 22.5
macro SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK = 2.5
macro STEALTH_BASE_COOLDOWN = 20
macro STEALTH_COOLDOWN_REDUCTION_PER_RANK = 4
macro GRIM_REAPER_COOLDOWN_REDUCTION_PER_RANK = 6
macro HEALTH_POTIONS_COOLDOWN_REDUCTION_PER_RANK = 1
macro HEALTH_POTIONS_HEALING_OVER_TIME = 21.875 + eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] * 8.75
macro HEALTH_REGEN_HEALING_OVER_TIME = 4.5 + eventPlayer.talent_ranks[Talent.HEALTH_REGEN] * 0.9
#FIREBALL_DAMAGE: Rank 1: 40 damage, Rank 5: 80 damage
#FIREBALL_DAMAGE_OVER_TIME: Rank 1: 40 damage, Rank 5: 80 damage
macro FIREBALL_DAMAGE = 30 + eventPlayer.talent_ranks[Talent.FIREBALL] * 10
macro FIREBALL_DAMAGE_SELF = 12.5 + eventPlayer.talent_ranks[Talent.FIREBALL] * 4.166
macro FIREBALL_DAMAGE_SELF_OVER_TIME_DURATION = 5
macro FIREBALL_DAMAGE_SELF_OVER_TIME = 2.5 + eventPlayer.talent_ranks[Talent.FIREBALL] * 0.833
macro FIREBALL_DAMAGE_OVER_TIME = 6 + eventPlayer.talent_ranks[Talent.FIREBALL] * 2
macro FIREBALL_DAMAGE_OVER_TIME_DURATION = 5
macro FIREBALL_SPEED = 15
macro FIREBALL_PROJECTILE_RADIUS = 1.75
macro FIREBALL_EXPLOSION_RADIUS = 4
macro PYROMANIAC_INSTANT_HEALING = min(30 + eventPlayer.talent_ranks[Talent.PYROMANIAC] * 10, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL))
macro PYROMANIAC_HEALING_OVER_TIME = 6 + eventPlayer.talent_ranks[Talent.PYROMANIAC] * 2
macro PYROMANIAC_HEALING_DURATION = 5
#Railgun: Rank 1: 150(300 headshot) damage, Rank 5: 200(400 headshot) damage
macro RAILGUN_ADDITIONAL_DAMAGE = 275 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 25 if eventWasCriticalHit else 137.5 - eventDamage + attacker.talent_ranks[Talent.RAILGUN] * 12.5
#Gunslinger: Rank 1: 66(132 headshot) damage, Rank 5: 79(158 headshot) damage - - - 19(38 headshot) damage added as well from the primary fire
#macro GUNSLINGER_ADDITIONAL_DAMAGE = round(eventDamage * 3.333 + eventDamage * attacker.talent_ranks[Talent.GUNSLINGER] * 0.166)
#IGNITE_DAMAGE_PER_SECOND: Rank 1: 40 total damage, Rank 5: 80 total damage
#IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND: Rank 1 25 damage, Rank 5: 50 damage
#IGNITE_RAILGUN_DAMAGE_PER_SECOND: Rank 1 50 damage, Rank 5: 100 damage
macro IGNITE_DAMAGE_PER_SECOND = round(9.97 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * eventDamage)
#macro IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND = round(9.97 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * eventDamage / 2)
macro IGNITE_RAILGUN_DAMAGE_PER_SECOND = round(12.45 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * 150)
#Bombardment: Rank 1: 4 total damage, Rank 5: 20 total damage
#macro BOMBARDMENT_DAMAGE = attacker.talent_ranks[Talent.BOMBARDMENT] * 4
#Poisonous Dagger: max is there to account for if a player leave and code breaks. To lazy to fix another way atm.
macro POISONOUS_DAGGER_DAMAGE = max(75 + eventPlayer.poisonous_dagger_attackers[0].talent_ranks[Talent.POISONOUS_DAGGER] * 25, 100)
macro POISONOUS_DAGGER_DURATION = 5
#Soul Harvest: Rank 1: 150 total healing, Rank 5: 300 total healing
macro SOUL_HARVEST_HEALING = round(112.5 + player_picking_up_orb.talent_ranks[Talent.SOUL_HARVEST] * 37.5)
#Bandage: Rank 1: 200 total healing, Rank 5: 400 total healing
macro BANDAGE_HEAL_OVER_TIME = (15 + eventPlayer.talent_ranks[Talent.BANDAGE] * 5)
macro BANDAGE_HEAL_OVER_TIME_DURATION = 10
macro IGNORE_PAIN_DAMAGE_RESISTANCE = eventPlayer.talent_ranks[Talent.IGNORE_PAIN] * 6.666 + 33.333
macro IGNORE_PAIN_DAMAGE_RECEIVED = 66.666 - eventPlayer.talent_ranks[Talent.IGNORE_PAIN] * 6.666
macro JUGGERNAUT_DAMAGE = 125 + eventPlayer.talent_ranks[Talent.JUGGERNAUT] * 25
macro JUGGERNAUT_VS_JUGGERNAUT_SELF_DAMAGE = 125 + eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_ranks[Talent.JUGGERNAUT] * 25
#macro GRIM_REAPER_WALLHACK_THRESHOLD = (0.150 + (player.talent_ranks[Talent.GRIM_REAPER] * 0.050))
macro GRIM_REAPER_THRESHOLD_NORMALIZED_ATTACKER = (0.150 + (attacker.talent_ranks[Talent.GRIM_REAPER] * 0.050))
macro GRIM_REAPER_THRESHOLD_NORMALIZED_VICTIM = (0.150 + (victim.talent_ranks[Talent.GRIM_REAPER] * 0.050))
#macro POISON_VIALS_DAMAGE = 28.125 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 9.375
#macro POISON_VIALS_DAMAGE_OVER_TIME_DURATION = 5
#macro POISON_VIALS_DAMAGE_OVER_TIME = floor(5.6 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 1.9)
#macro SPRINTER_MOVE_SPEED_MULTIPLIER = eventPlayer.stats[Stat.SPEED] * (1 + eventPlayer.talent_ranks[Talent.SPRINTER] * 0.066)
#Dive Bomb: Rank 1: 75 total damage, Rank 5: 150 total damage (The damage is doubled if you have been in air for 1 second)
macro DIVE_BOMB_DAMAGE = (56.25 + eventPlayer.talent_ranks[Talent.DIVE_BOMB] * 18.75)
#For HUD
macro DIVE_BOMB_DAMAGE_LOCAL = (56.25 + localPlayer.talent_ranks[Talent.DIVE_BOMB] * 18.75)
#Lifesteal: Rank 1: 18.7% healing, Rank 5: 37.5% healing
macro LIFESTEAL_HEAL = eventDamage * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#macro LIFESTEAL_BOMBARDMENT_HEAL = eventDamage * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047) / 2
macro LIFESTEAL_RAILGUN_HEAL = (RAILGUN_ADDITIONAL_DAMAGE + eventDamage) * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#macro LIFESTEAL_GUNSLINGER_HEAL = (GUNSLINGER_ADDITIONAL_DAMAGE + eventDamage) * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)

#25% at Rank 1, 50% at Rank 5
macro GIGACHAD_RESIST_NORMALIZED_VICTIM = (3 + victim.talent_ranks[Talent.GIGACHAD]) / 16

macro GIGACHAD_KNOCKBACK_RECEIVED = 100 - eventPlayer.talent_ranks[Talent.GIGACHAD] * 20

macro PURITY_FIELD_HEALING_RECEIVED = 125 + eventPlayer.talent_ranks[Talent.PURITY_FIELD] * 25
macro PURITY_FIELD_DURATION = 3.75 + eventPlayer.talent_ranks[Talent.PURITY_FIELD] * 1.25
macro STEALTH_STUN_DURATION = 0.8 + eventPlayer.talent_ranks[Talent.STEALTH] * 0.2
macro GRIM_REAPER_CAST_TIME = 2.25 - eventPlayer.talent_ranks[Talent.GRIM_REAPER] * 0.25
macro GRIM_REAPER_CAST_TIME_LOCAL = 2.25 - localPlayer.talent_ranks[Talent.GRIM_REAPER] * 0.25
macro GRIM_REAPER_FLIGHT_SPEED = 12 + eventPlayer.talent_ranks[Talent.GRIM_REAPER] * 3.6
macro GRIM_REAPER_HEALTH_THRESHOLD = 0.25
#Adrenaline Rush: Rank 1: 125% speed over 10s. Rank 5: 150% speed over 20s. Decays 2.5% per second.
#macro ADRENALINE_RUSH_MAX_SPEED = 125 + (eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] - 1) * 6.25
#macro ADRENALINE_RUSH_DECAY_RATE = 2.5
