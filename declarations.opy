#!mainFile "soldier_x.opy"

enum Talent:
    BLOODTHIRST, #1
    IMMUNITY, #2
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

# ============================================================
# GLOBAL VARIABLES
# ============================================================

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
#--- Bot system ---
globalvar spawn_bots = createWorkshopSettingBool("01. Bots", "Spawn bots?", true, 0)
globalvar amount_of_bots_and_players = createWorkshopSettingInt("01. Bots", "How many bots and players?", 8, 1, 8, 1)
globalvar bots_friendly = createWorkshopSettingBool("01. Bots", "Friendly?", true, 1)

#--- Shop system ---
globalvar shop_location
globalvar shop_rotation
globalvar shop_talent_positions
macro SHOP_TALENT_SPREAD = 31           #degrees each side talent (index 0 = left, 2 = right) sits from the center talent
macro SHOP_TALENT_RADIUS = 5.4          #meters from the camera (shop_location) out to each talent
macro SHOP_TALENT_ELEVATION = 0      #degrees ALL three talents sit above the camera's eye line
macro SHOP_TALENT_MIDDLE_ELEVATION = 4  #EXTRA degrees the middle talent (index 1) sits above the side talents
macro INVISIBLE_CHAR = "­"           #U+00AD soft hyphen: renders as nothing but counts as a character (anchors trailing blank padding lines so they aren't trimmed; pads empty talent slots)
globalvar max_experience_per_level = [250, 275, 303, 333, 366, 403, 443, 487, 536, 589, 648, 713, 785, 863, 949, 1044, 1149, 1264, 1390, 1529, 1682, 1850, 2035, 2239, 2462, 2709]
playervar talent_trigger_times
playervar railgun_charge

globalvar current_time

#--- Debug variables (plain declarations — Workshop Settings assigned in debug files) ---
globalvar debug_spectator_tools
globalvar debug_texts = []
globalvar debug_bot_gigachad
globalvar debug_bot_load_test = false
globalvar debug_bot_move = false
globalvar debug_bot_damage_test = false
globalvar debug_bot_low_hp = false
#!define IS_PLAYER(p) ((not p.isDummy()) or (p.isDummy() and debug_bot_load_test))
#!define SWEEP_WAIT(window, count) wait(max((window) / (count), 0.016))

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





# ============================================================
# PLAYER VARIABLES
# ============================================================

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
playervar rockets_cooldown
playervar variable
playervar amount_of_health_potions
playervar amount_of_talents_purchased = 0
playervar bought_talents = []
playervar browsing_shop
playervar using_gamepad = false   #detected once on shop entry: true = gamepad, false = keyboard/mouse
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
playervar juggernaut_charge
playervar talents_offered_in_shop
playervar player_name = "{0}".format(eventPlayer)
playervar player_temp_effects
playervar possible_talents = [Talent.IMMUNITY, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.GRIM_REAPER, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, Talent.BOMBARDMENT,*/ Talent.GIGACHAD/*, Talent.GUNSLINGER, Talent.ADRENALINE_RUSH*/]
#playervar poison_vials_projPos
#playervar poison_vials_projPosIn0032
/*playervar replace_replacing_or_cancelled = [false, false, false]*/
playervar skipped_a_talent
playervar talent_counter_or_position_etc
playervar talent_ranks = []
playervar talents_you_do_not_have = [Talent.IMMUNITY, Talent.CYBERNETICS, Talent.SOUL_HARVEST, Talent.STEALTH, Talent.DIVE_BOMB, Talent.CRYOGENICS, Talent.RAILGUN, Talent.GRIM_REAPER, Talent.JETPACK, Talent.LIFESTEAL_AMMO, Talent.HEALTH_REGEN, Talent.HEALTH_POTIONS, Talent.IGNITE, Talent.SHADOWSTEP, Talent.BURNING_SOUL, Talent.BERSERKER, Talent.FIREBALL, Talent.IGNORE_PAIN, Talent.BANDAGE, /*Talent.POISON_VIALS, Talent.BOMBARDMENT,*/ Talent.GIGACHAD/*, Talent.GUNSLINGER, Talent.ADRENALINE_RUSH*/]
playervar using_one_of_the_hearthstones
playervar xp_boost_is_active
#playervar xp_orb_destination
playervar dive_bomb_damage
playervar berserker_duration
playervar cryogenics_travel_time
playervar using_cryogenics = false
playervar hit_by_talent
playervar player_xp_orb_index
#playervar cybernetics_shields = 0
playervar immunity_position = null
playervar victims_in_burning_soul_radius
#playervar remaining_poisonous_dagger_duration = 0
playervar poisonous_dagger_attackers = []       # list of attackers who've poisoned this victim
playervar poisonous_dagger_timestamp = []    # parallel array: getTotalTimeElapsed() when each expires
playervar grim_reaper_camera_position = null
playervar casting_timer = 0
playervar grim_reaper_ramp_up = 0
playervar immunity_duration = 0
playervar adrenaline_rush_value = 100
playervar current_immunity_target = 0
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
#!defineMember victims_in_immunity_radius variable[35]
#!defineMember victims_in_dive_bomb_radius variable[36]
#!defineMember dive_bomb_damage_total variable[37]
#!defineMember bot_throttle_paused variable[38]
#!defineMember railgun_damage_dealt variable[39]
#!defineMember current_damage_received variable[40]

#--- Damage numbers: recent damage dealt per victim (variable[408-414]) ---
#!defineMember recent_damage_victims variable[408]
#!defineMember recent_damage_other variable[409]
#!defineMember recent_damage_time_other variable[410]
#!defineMember recent_damage_crit_other variable[412]

#--- Shared global defineMember (global_variable[0-49]) ---

#!defineMember highest_grim_reaper_rank_in_match global_variable[0]

#--- Burning Soul serialized-sweep state (global_variable[1-2]) ---
#!defineMember burning_soul_owners global_variable[1]
#!defineMember burning_soul_current_owner global_variable[2]
globalvar burning_soul_sweep_index
globalvar burning_soul_victim_index

#--- Grim Reaper aim-scan/sweep state (global_variable[3-8]) ---
#!defineMember current_grim_reaper_candidate global_variable[3]
#!defineMember grim_reaper_scan_angle global_variable[4]
#!defineMember grim_reaper_best_angle global_variable[5]
#!defineMember grim_reaper_valid_targets global_variable[6]
#!defineMember current_grim_reaper_owner global_variable[7]
#!defineMember grim_reaper_owners global_variable[8]
globalvar grim_reaper_scan_index
globalvar grim_reaper_sweep_index

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
subroutine replace_talent
subroutine spawned_with_fireball
subroutine stopped_using_hearthstone
subroutine using_one_of_the_hearthstones
subroutine recalculate_player_speed
subroutine recalculate_damage_received
subroutine restore_ability1
subroutine which_players_have_grim_reaper
subroutine detect_input_device
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

#--- Per-talent tuning macros (damage/healing/durations/radii/etc.) are GENERATED from talents.js. ---
#--- Edit a talent's stats/tuning block there; see generateTalents() above. The macros below were NOT moved: ---

#Unused cooldown macros (kept; talents.js cooldown/cd_reduction fields are the live source)
macro SHADOWSTEP_BASE_COOLDOWN = 22.5
macro STEALTH_BASE_COOLDOWN = 20
macro STEALTH_COOLDOWN_REDUCTION_PER_RANK = 4
macro GRIM_REAPER_COOLDOWN_REDUCTION_PER_RANK = 6
macro HEALTH_POTIONS_COOLDOWN_REDUCTION_PER_RANK = 1
macro FIREBALL_PROJECTILE_RADIUS = 1.75

#Disabled/removed-talent tuning (kept commented for revival)
#macro GUNSLINGER_ADDITIONAL_DAMAGE = round(eventDamage * 3.333 + eventDamage * attacker.talent_ranks[Talent.GUNSLINGER] * 0.166)
#macro IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND = round(9.97 + attacker.talent_ranks[Talent.IGNITE] * 0.028 * eventDamage / 2)
#macro BOMBARDMENT_DAMAGE = attacker.talent_ranks[Talent.BOMBARDMENT] * 4
#macro POISON_VIALS_DAMAGE = 28.125 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 9.375
#macro POISON_VIALS_DAMAGE_OVER_TIME_DURATION = 5
#macro POISON_VIALS_DAMAGE_OVER_TIME = floor(5.6 + eventPlayer.talent_ranks[Talent.POISON_VIALS] * 1.9)
#macro SPRINTER_MOVE_SPEED_MULTIPLIER = eventPlayer.stats[Stat.SPEED] * (1 + eventPlayer.talent_ranks[Talent.SPRINTER] * 0.066)
#macro GRIM_REAPER_WALLHACK_THRESHOLD = (0.150 + (player.talent_ranks[Talent.GRIM_REAPER] * 0.050))
#macro LIFESTEAL_BOMBARDMENT_HEAL = eventDamage * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047) / 2
#macro LIFESTEAL_GUNSLINGER_HEAL = (GUNSLINGER_ADDITIONAL_DAMAGE + eventDamage) * (0.14 + eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] * 0.047)
#macro ADRENALINE_RUSH_MAX_SPEED = 125 + (eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] - 1) * 6.25
#macro ADRENALINE_RUSH_DECAY_RATE = 2.5

macro IMMUNITY_EFFECTS_VISIBLE = eventPlayer.browsing_shop == false and not (eventPlayer.is_using_ability[Talent.GRIM_REAPER] and eventPlayer.casting_success) and not eventPlayer.is_using_ability[Talent.STEALTH]
macro DAMAGE_NUMBER_WINDOW = 1.5
macro DAMAGE_NUMBER_Y_NEAR = 2
macro DAMAGE_NUMBER_Y_FAR = 3
macro DAMAGE_NUMBER_DIST_MIN = 1
macro DAMAGE_NUMBER_DIST_MAX = 25
macro DAMAGE_NUMBER_Y = DAMAGE_NUMBER_Y_NEAR + (DAMAGE_NUMBER_Y_FAR - DAMAGE_NUMBER_Y_NEAR) * max(0, min(1, (distance(eventPlayer.getPosition(), localPlayer.getPosition()) - DAMAGE_NUMBER_DIST_MIN) / (DAMAGE_NUMBER_DIST_MAX - DAMAGE_NUMBER_DIST_MIN)))
macro DAMAGE_NUMBER_HELIX_THRESHOLD = 120
#Adrenaline Rush: Rank 1: 125% speed over 10s. Rank 5: 150% speed over 20s. Decays 2.5% per second.
#macro ADRENALINE_RUSH_MAX_SPEED = 125 + (eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] - 1) * 6.25
#macro ADRENALINE_RUSH_DECAY_RATE = 2.5

#--- Camera-basis vectors for in-world HUD texts anchored to localPlayer's view ---
macro HUD_CAM_UP = angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)
macro HUD_CAM_FWD = localPlayer.getFacingDirection()
