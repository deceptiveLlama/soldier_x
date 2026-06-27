#!define TOP_RIGHT_TEXT "Soldier: X [v3.5.2]\nMade By Psyrius#21775\nWorkshop.codes/Zekk3", "[Discord: dsc.gg/soldier-x]"
#!define GAME_MODE_DESCRIPTION "● Made by Psyrius\n● Code: ZEKK3\n● v3.5.2\n● RPG, Level up, Buy talents, FFA, Deathmatch\n● Developed since 2020\n● Discord: discord.gg/3MBymdF"
#!define GAME_MODE_NAME "SOLDIER: X [v3.5.2]"
#--- Shop HUD helpers (localPlayer-scoped) ---
#!define KEYBIND(btn) ("[{0}]".format(buttonString(btn)) if not localPlayer.using_gamepad else buttonString(btn))
#!define SHOP_BROWSING (localPlayer.browsing_shop and not localPlayer.replacing_talent_show_confirmation and not localPlayer.replacing_talent_show_bought_talents)
#!define SHOP_IDLE (SHOP_BROWSING and not localPlayer.is_using_skip_talent and not localPlayer.isHoldingButton(Button.RELOAD))

#!allowMacroRedeclaration

#--- Map pool: release default below; "debug - development.opy" redeclares it to Workshop Chamber when that file is included ---
#!define ENABLED_MAPS ["dorado", "eichenwalde", "hollywood", "chateauGuillard", "ecopointAntarctica", "kanezaka", "malevento", "petra", "paris", "templeOfAnubis", "blizzWorld", "kingsRow", "blackForest", "route66"]

#!setupTags
#!include "declarations.opy"
#!include "shop.opy"
#!include "bots - new system.opy"
#!include "debug - release.opy"
##!include "debug - development.opy"
#!include "settings.opy"
#!include "xp.opy"
#!include "talents.opy"

#--- Soldier_x-only defineMember (variable[400-404]) ---
#!defineMember grim_reaper_cast_sound_id variable[400]
#!defineMember grim_reaper_effect_id3 variable[401]
#!defineMember grim_reaper_effect_id4 variable[402]
#--- Input device auto-detect (runs once on first spawn) ---
#!defineMember input_device_checked variable[403]
#!defineMember device_check_facing variable[404]
#--- Local globalvars (only used in this file) ---
globalvar init_locked = false
globalvar init_owner = null
globalvar antiCrashActivated
globalvar recent_damage_index
globalvar victim_immunity_off

rule "GENERAL - - - Global Variables":
    disableInspector()

    /*
    highest_grim_reaper_rank_in_match = 0
    */

    If_map()
    #Bot combat vision scan loop (moved here from the removed bot navigation map init)
    async(bot_combat_scan, AsyncBehavior.NOOP)
    createInWorldText(localPlayer if localPlayer.browsing_shop == true else null, "YES {0}                        {1} NO".format(buttonString(Button.ABILITY_1 if localPlayer.using_gamepad else Button.PRIMARY_FIRE), buttonString(Button.ABILITY_2 if localPlayer.using_gamepad else Button.SECONDARY_FIRE)) if localPlayer.replacing_talent_show_confirmation == true else "{0}            {1}            {2}".format(buttonString(Button.ABILITY_1 if localPlayer.using_gamepad else Button.PRIMARY_FIRE) if localPlayer.replacing_talent_show_bought_talents == true else buttonString(Button.ABILITY_1 if localPlayer.using_gamepad else Button.PRIMARY_FIRE) if localPlayer.selected_talent_in_shop >= 1 else "    ", buttonString(Button.JUMP if localPlayer.using_gamepad else Button.INTERACT), buttonString(Button.ABILITY_2 if localPlayer.using_gamepad else Button.SECONDARY_FIRE) if localPlayer.replacing_talent_show_bought_talents == true else buttonString(Button.ABILITY_2 if localPlayer.using_gamepad else Button.SECONDARY_FIRE) if localPlayer.selected_talent_in_shop <= 1 else "    "), localPlayer.selected_talent_position + vect(0, -0.125, 0), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    async(create_talent_hud_texts, AsyncBehavior.NOOP)
    async(create_talent_helpers, AsyncBehavior.NOOP)
    #Info-bg spacer: invisible LEFT rows (sortOrder 5) that push the bg bars down to sit behind the text. Height = INFO_BAR_PAD rows (talents.js).
    hudSubheader(localPlayer if SHOP_BROWSING else null, talent_info_bar_pad, HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #Talent info background: one invisible LEFT hudHeader (sortOrder 6), auto-centered by the OW2 ACTUALLY_LEFT bug. Blank-row block sized to the selected talent's whole text (width from its longest line, rows from its line count) — generated in talents.js.
    hudHeader(localPlayer if SHOP_BROWSING else null, talent_info_bg[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]], HudPosition.LEFT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #Shop controls hint (idle, yellow) + Hearthstone, Grim Reaper, Dive Bomb, vote, skip
    progressBarHud(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.is_using_vote_yes or localPlayer.is_using_vote_no or (localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success) or SHOP_BROWSING else null, 100 if SHOP_IDLE else (localPlayer.casting_timer / (2.75 if (localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.is_using_vote_yes or localPlayer.is_using_vote_no) and not faster_testing else GRIM_REAPER_CAST_TIME_LOCAL if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else 0.5 if localPlayer.is_using_hearthstone and faster_testing else 0) * 100), "{0} Casting Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.is_using_hearthstone and not localPlayer.browsing_shop else "{0} Casting Grim Reaper   {1} = Cancel".format('<tx0C0000000004F741>', buttonString(Button.INTERACT)) if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.ABILITY_1 if localPlayer.using_gamepad else Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.ABILITY_2 if localPlayer.using_gamepad else Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.RELOAD) else "Select talent: {0} --- Skip talents: {1}".format(KEYBIND(Button.INTERACT if not localPlayer.using_gamepad else Button.JUMP), KEYBIND(Button.RELOAD)) if SHOP_IDLE else "", HudPosition.TOP, 2, Color.ORANGE if SHOP_IDLE else Color.GREEN if localPlayer.is_using_hearthstone else Color.RED if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else Color.WHITE, Color.ORANGE if SHOP_IDLE else Color.WHITE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.NEVER)

rule "GENERAL - - - Update current_time (drives responsive cooldown HUD numbers)":
    while true:
        current_time = getTotalTimeElapsed()
        wait()


rule "GENERAL - - - [EACH PLAYER] INIT":
    @Event eachPlayer

    #"Wait for our turn (one player initializes at a time)"
    waitUntil(init_locked == false or not (init_owner in getAllPlayers()), 99999)
    init_locked = true
    init_owner = eventPlayer
    wait()
    if init_owner != eventPlayer:
        goto RULE_START

    # INIT FOR PLAYERS (NOT BOTS)
    if IS_PLAYER(eventPlayer):
        /*
        print("total time elapsed: {0}".format(getTotalTimeElapsed()))

        print("length of array: {0}".format(len(xp_orbs)))

        print("owning player: {0} - {1} - {2}".format(xp_orbs[0][0], xp_orbs[1][0], xp_orbs[2][0]))
        print("timestamp: {0} - {1} - {2}".format(xp_orbs[0][1], xp_orbs[1][1], xp_orbs[2][1]))
        print("xp_amount: {0} - {1} - {2}".format(xp_orbs[0][2], xp_orbs[1][2], xp_orbs[2][2]))
        print("explosive: {0} - {1} - {2}".format(xp_orbs[0][3], xp_orbs[1][3], xp_orbs[2][3]))
        print("explosive rank: {0} - {1} - {2}".format(xp_orbs[0][4], xp_orbs[1][4], xp_orbs[2][4]))
        print("position: {0} - {1} - {2}".format(xp_orbs[0][5], xp_orbs[1][5], xp_orbs[2][5]))
        print("color: {0} - {1} - {2}".format(xp_orbs[0][6], xp_orbs[1][6], xp_orbs[2][6]))
        print("orb_effect_id: {0} - {1} - {2}".format(xp_orbs[0][7], xp_orbs[1][7], xp_orbs[2][7]))
        print("burning_soul_sound_id: {0} - {1} - {2}".format(xp_orbs[0][8], xp_orbs[1][8], xp_orbs[2][8]))
        print("burning_soul_effect_id: {0} - {1} - {2}".format(xp_orbs[0][9], xp_orbs[1][9], xp_orbs[2][9]))
        */
        
        #eventPlayer.stats = [100, 200, 100, 0, 0, 0.65, 1, 1, 100]
        #eventPlayer.selected_talent_in_shop = 1
        eventPlayer.selected_talent_in_shop = 1
        #eventPlayer.selected_bought_talent = 0
        eventPlayer.selected_bought_talent = 0
        eventPlayer.recent_damage_victims = []
        eventPlayer.recent_damage_other = []
        eventPlayer.recent_damage_time_other = []
        eventPlayer.recent_damage_crit_other = []
        chase(eventPlayer.rockets_cooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.setSecondaryFireEnabled(false)
        #[HUD Text for talent slot 1]
        if not debug_disable_cooldown_huds: hudText(eventPlayer, "{0}".format(talent_names[eventPlayer.bought_talents[0]]) if len(eventPlayer.bought_talents) >= 1 else "", "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] - current_time) if len(eventPlayer.bought_talents) >= 1 and eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] > current_time else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[0]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH) if buttonString(Button.CROUCH) != "" else "Crouch").replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE)).replace("[JETPACKBTN]", buttonString(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP)).replace("[JETPACKAIR]", " (In Air)" if eventPlayer.using_gamepad else "")) if len(eventPlayer.bought_talents) >= 1 else INVISIBLE_CHAR, HudPosition.ACTUALLY_LEFT, 0, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 2]
        if not debug_disable_cooldown_huds: hudText(eventPlayer, "{0}".format(talent_names[eventPlayer.bought_talents[1]]) if len(eventPlayer.bought_talents) >= 2 else "", "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] - current_time) if len(eventPlayer.bought_talents) >= 2 and eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] > current_time else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[1]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH) if buttonString(Button.CROUCH) != "" else "Crouch").replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE)).replace("[JETPACKBTN]", buttonString(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP)).replace("[JETPACKAIR]", " (In Air)" if eventPlayer.using_gamepad else "")) if len(eventPlayer.bought_talents) >= 2 else INVISIBLE_CHAR, HudPosition.ACTUALLY_LEFT, 1, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 3]
        if not debug_disable_cooldown_huds: hudText(eventPlayer, "{0}".format(talent_names[eventPlayer.bought_talents[2]]) if len(eventPlayer.bought_talents) >= 3 else "", "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] - current_time) if len(eventPlayer.bought_talents) >= 3 and eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] > current_time else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[2]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH) if buttonString(Button.CROUCH) != "" else "Crouch").replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE)).replace("[JETPACKBTN]", buttonString(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP)).replace("[JETPACKAIR]", " (In Air)" if eventPlayer.using_gamepad else "")) if len(eventPlayer.bought_talents) >= 3 else INVISIBLE_CHAR, HudPosition.ACTUALLY_LEFT, 2, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 4]
        if not debug_disable_cooldown_huds: hudText(eventPlayer, "{0}".format(talent_names[eventPlayer.bought_talents[3]]) if len(eventPlayer.bought_talents) >= 4 else "", "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] - current_time) if len(eventPlayer.bought_talents) >= 4 and eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] > current_time else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[3]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH) if buttonString(Button.CROUCH) != "" else "Crouch").replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE)).replace("[JETPACKBTN]", buttonString(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP)).replace("[JETPACKAIR]", " (In Air)" if eventPlayer.using_gamepad else "")) if len(eventPlayer.bought_talents) >= 4 else INVISIBLE_CHAR, HudPosition.ACTUALLY_LEFT, 3, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 5]
        if not debug_disable_cooldown_huds: hudText(eventPlayer, "{0}".format(talent_names[eventPlayer.bought_talents[4]]) if len(eventPlayer.bought_talents) >= 5 else "", "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] - current_time) if len(eventPlayer.bought_talents) >= 5 and eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] > current_time else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[4]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH) if buttonString(Button.CROUCH) != "" else "Crouch").replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE)).replace("[JETPACKBTN]", buttonString(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP)).replace("[JETPACKAIR]", " (In Air)" if eventPlayer.using_gamepad else "")) if len(eventPlayer.bought_talents) >= 5 else INVISIBLE_CHAR, HudPosition.ACTUALLY_LEFT, 4, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        eventPlayer.setAbility2Enabled(false)
        eventPlayer.setUltEnabled(false)

        

        #createProgressBarInWorldText(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.using_one_of_the_hearthstones else null, localPlayer.using_hearthstone_timer / 2.75 * 100 if faster_testing == false else 50, "{0} Using Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.browsing_shop == false else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} Skipping Bonus Talent".format(iconString(Icon.TRASHCAN)) if localPlayer.amount_of_bonus_talents > 0 and localPlayer.isHoldingButton(Button.RELOAD) else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.RELOAD) else "", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.55 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))) if localPlayer.browsing_shop == false else localPlayer.selected_talent_position + Vector.UP, 1, Clip.NONE, Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        #XP HUD
        progressBarHud(eventPlayer if not eventPlayer.browsing_shop else null, eventPlayer.experience_current / eventPlayer.experience_max * 100, "Max Level - XP Boost: Active" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current < eventPlayer.experience_max else "You can replace a talent" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current >= eventPlayer.experience_max else "You have a talent point" if eventPlayer.can_enter_shop == true else "You skipped a talent! XP Boost: Active" if eventPlayer.skipped_a_talent == true else "Too far behind! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.xp_boost_is_active == true and eventPlayer.amount_of_talents_purchased > 0 else "First Level! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.amount_of_talents_purchased == 0 else "", HudPosition.TOP, 1, Color.ORANGE, Color.ORANGE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #Selected bought talent name (shown while choosing which talent to replace)
        createInWorldText(eventPlayer if eventPlayer.browsing_shop == true and eventPlayer.replacing_talent_show_bought_talents == true else null, "{0}".format(talent_names[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]]), eventPlayer.selected_talent_position + vect(0, 0.125, 0), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        wait()
        #Left Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, Effect.ORB, orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[0]]], shop_talent_positions[0], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        wait()
        #Middle Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop == true else null, Effect.ORB, Color.WHITE if eventPlayer.replacing_talent_show_confirmation == true and eventPlayer.replacing_talent_show_bought_talents == false else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[1]]], shop_talent_positions[eventPlayer.selected_talent_in_shop] if eventPlayer.replacing_talent_show_confirmation or eventPlayer.replacing_talent_show_bought_talents else shop_talent_positions[1], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        wait()
        #Right Orb
        createEffect(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, Effect.ORB, orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.selected_bought_talent]] - 1] if eventPlayer.replacing_talent_show_bought_talents == true else orb_rarity_colors[eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[2]]], shop_talent_positions[2], 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        #wait()
        #createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}{1}{2}".format(('<tx00000000000B>'), ('<tx00000000000B>'), ('<tx00000000000B>')), shop_talent_positions[2] + vect(0, 0.375, 0), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, rgb(255, 255, 255, 128), SpecVisibility.DEFAULT)
        wait()
        #Left Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[0]]), shop_talent_positions[0] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        #Middle Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop else null, "{0} Are you sure you want to replace one of your talents?".format(iconString(Icon.WARNING)) if eventPlayer.replacing_talent_show_confirmation else "{0} What talent would you like to replace?".format(iconString(Icon.WARNING)) if eventPlayer.replacing_talent_show_bought_talents else "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[1]]), shop_talent_positions[eventPlayer.selected_talent_in_shop] + vect(0, 0.375, 0) if eventPlayer.replacing_talent_show_confirmation or eventPlayer.replacing_talent_show_bought_talents else shop_talent_positions[1] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()
        #Right Talent
        createInWorldText(eventPlayer if eventPlayer.browsing_shop and not eventPlayer.replacing_talent_show_confirmation and not eventPlayer.replacing_talent_show_bought_talents else null, "{0}".format(talent_names[eventPlayer.talents_offered_in_shop[2]]), shop_talent_positions[2] + vect(0, 0.375, 0), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        eventPlayer.exit_shop_with_fireball = false

    # INIT FOR BOTS AND PLAYERS

    #eventPlayer.hit_by_talent[Talent.POISON_VIALS] = null
    eventPlayer.disableGamemodeHud()
    eventPlayer.setMaxHealth(eventPlayer.stats[Stat.HEALTH])
    createEffect(getAllPlayers() if eventPlayer.hit_by_talent[Talent.RAILGUN] != null else null, Effect.WINSTON_TESLA_CANNON_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer if eventPlayer.talent_ranks[Talent.RAILGUN] > 0 and eventPlayer.railgun_charge > 0 or eventPlayer.hit_by_talent[Talent.RAILGUN] != null else null, Effect.ENERGY_SOUND, Color.TEAM_1, eventPlayer, eventPlayer.railgun_charge, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait()
    chase(eventPlayer.is_electrified, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.CRYOGENICS] == true else null, Effect.MEI_FROZEN, Color.WHITE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.CRYOGENICS] == true else null, Effect.MEI_FROZEN_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.cryogenics_travel_time = 0
    async(which_players_have_grim_reaper, AsyncBehavior.RESTART)
    #Damage Numbers
    createInWorldText(localPlayer if localPlayer != eventPlayer and current_time - localPlayer.recent_damage_time_other[localPlayer.recent_damage_victims.index(eventPlayer)] <= DAMAGE_NUMBER_WINDOW else null, "<fgFF3C65FF>{0}</fg>".format(round(localPlayer.recent_damage_other[localPlayer.recent_damage_victims.index(eventPlayer)])) if localPlayer.recent_damage_crit_other[localPlayer.recent_damage_victims.index(eventPlayer)] else round(localPlayer.recent_damage_other[localPlayer.recent_damage_victims.index(eventPlayer)]), updateEveryFrame(eventPlayer.getPosition() + vect(0, DAMAGE_NUMBER_Y, 0)), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
    wait()

    #hudHeader(getAllPlayers(), "                  ", HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

    #hudHeader(getAllPlayers(), "{0}{1}".format("You are currently us" if [Button.ABILITY_1, Button.ABILITY_2, Button.CROUCH, Button.INTERACT, Button.JUMP, Button.MELEE, Button.PRIMARY_FIRE, Button.RELOAD, Button.SECONDARY_FIRE, Button.ULTIMATE].any(lambda x: inputBindingString(x)[0] and strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&~\"#'{([-|`_\\^@)]=}^$%*,?.;/:>²ÉÈÇÀÙ+¤^ßÜÖÄÑ¡´¿ÒÌСЛП↓←→↑스아좌왼숫우오위空回退大下左暂右上；，向數", inputBindingString(x).charAt(0))) else "You are currently us", "\n\nIs this correct?\nIf not, workshop.cod"), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


    /*
    createIcon(players_with_grim_reaper[0] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.2 else players_with_grim_reaper[1] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.25 else players_with_grim_reaper[2] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.3 else players_with_grim_reaper[3] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.35 else players_with_grim_reaper[4] if eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.isAlive() == true and eventPlayer.getNormalizedHealth() <= 0.4 else null, updateEveryTick(eventPlayer.getPosition() + Vector.UP * 0.5), Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.RED, false)
    */

    #createInWorldText(players_with_grim_reaper if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25 and eventPlayer.is_using_ability[Talent.STEALTH] == false else null, "{0}".format(('<tx0C0000000000D29C>') iconString(Icon.SKULL)), updateEveryFrame(eventPlayer.getPosition() + Vector.UP), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.RED if localPlayer.grim_reaper_aim_indicator == eventPlayer else Color.WHITE, SpecVisibility.DEFAULT)

    #createInWorldText(players_with_grim_reaper if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25 and eventPlayer.is_using_ability[Talent.STEALTH] == false else null, "{0}".format(iconString(Icon.SKULL)), updateEveryFrame(eventPlayer.getPosition() + Vector.UP), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.RED if localPlayer.grim_reaper_aim_indicator == eventPlayer else Color.WHITE, SpecVisibility.DEFAULT)
    
    #createIcon(players_with_grim_reaper if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25 and not eventPlayer.is_using_ability[Talent.STEALTH] and not eventPlayer.browsing_shop and eventPlayer.isAlive() else null, updateEveryFrame(eventPlayer.getPosition() + Vector.UP), Icon.SKULL, IconReeval.VISIBILITY_POSITION_AND_COLOR, Color.RED if localPlayer.grim_reaper_aim_indicator == eventPlayer else Color.WHITE, false)

    # Red Nova Icon
    createInWorldText(players_with_grim_reaper.exclude(eventPlayer) 
    if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * GRIM_REAPER_HEALTH_THRESHOLD 
    and not eventPlayer.is_using_ability[Talent.STEALTH] 
    and not eventPlayer.browsing_shop 
    and eventPlayer.isAlive()  
    else null, 
    "{0}".format(('<tx00000000B667>')), updateEveryFrame(eventPlayer.getPosition() + Vector.UP), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.grim_reaper_effect_id3 = getLastCreatedText()
    
    #tx0000000015BB = skull
    #tx00000004F741 = skull med >>
    #tx00000002178B = röd faded prick
    #tx000000021660 (white faded ring)
    #tx00000002915D (blue faded ring)
    #[00:13:05] <TX C0000000000EE0C>
    #[00:19:29] <TX C0000000002178B>
    #029D41 små röda fyrkanter
    #02CB07 = genomskinlig färg, typ nästan vit, lite ljuslila
    #039E88 = hexagon portrait
    #052D57 = svart mönster, kanske funkar som bakgrund någon gång?


    /*createInWorldText(players_with_grim_reaper 
    if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25 
    and not eventPlayer.is_using_ability[Talent.STEALTH] 
    and not eventPlayer.browsing_shop 
    and eventPlayer.isAlive() 
    and localPlayer.grim_reaper_aim_indicator == eventPlayer 
    else null, 
    "{0}\n{1}".format('<tx0C0000000000B667>', buttonString(Button.INTERACT)), updateEveryFrame(eventPlayer.getPosition() + Vector.UP), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
*/
    eventPlayer.is_respawning = true
    
    #chaseAtRate(eventPlayer.remaining_poisonous_dagger_duration, 0, 1, ChaseRateReeval.DESTINATION_AND_RATE)

    # RELEASE INIT LOCK

    init_owner = null
    init_locked = false
    

rule "GENERAL - - - Match Time":
    @Condition isAssemblingHeroes() == true
    @Condition map_is_changing == false
    
    setMatchTime(0)
    while map_is_changing == false:
        waitUntil(len([player for player in getAllPlayers() if not player.isDummy()]) > 0, 99999)
        if map_is_changing == true:
            return
        if accurateTime < 10800:
            setMatchTime(3600)
        waitUntil(len([p for p in getAllPlayers() if not p.isDummy()]) == 0 or accurateTime > 14400, 14400)
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

rule "GENERAL - - - Is Match Complete?":
    @Condition isMatchComplete() == true
    
    bigMessage(getAllPlayers(), "{0} Discord: dsc.gg/soldier-x".format(iconString(Icon.ARROW_RIGHT)))

    wait(2.5)
    restartMatch()

def If_map():
    @Name "GENERAL - - - [SUBROUTINE] if Map"
    
    if getCurrentMap() == Map.EICHENWALDE or getCurrentMap() == Map.EICHENWALDE_HALLOWEEN:
        dummy_bot_spawn_position = vect(99.42, 13.121, -71.747)
        dummy_bot_spawn_facing = vect(99.42, 13.121, -71.747)
        shop_location = vect(-21.00, 34.15, -84.57)
        shop_rotation = -88
    elif getCurrentMap() == Map.WORKSHOP_CHAMBER:
        dummy_bot_spawn_position = vect(0, 0, 0)
        dummy_bot_spawn_facing = vect(0, 0, 0)
        shop_location = vect(0, 2, 0)
        shop_rotation = -90
    elif getCurrentMap() == Map.BLACK_FOREST or getCurrentMap() == Map.BLACK_FOREST_WINTER:
        dummy_bot_spawn_position = vect(-25.204, 12.546, 3.92)
        dummy_bot_spawn_facing = vect(-19.306, 13.739, 3.922)
        shop_location = vect(-32.73, 9.41, 4.67)
        shop_rotation = -90
    elif getCurrentMap() == Map.HOLLYWOOD:
        dummy_bot_spawn_position = vect(28.865, 7.252, -77.34)
        dummy_bot_spawn_facing = vect(28.865, 7.252, -77.34)
        shop_location = vect(-29.35, 74.00, -103.66)
        shop_rotation = -170
    elif getCurrentMap() == Map.ECOPOINT_ANTARCTICA:
        dummy_bot_spawn_position = vect(-33.601, 9.455, -0.077)
        dummy_bot_spawn_facing = vect(-29.427, 10.582, 0.021)
        shop_location = vect(-31.22, 53.92, 87.77)
        shop_rotation = -39
    elif getCurrentMap() == Map.CHATEAU_GUILLARD or getCurrentMap() == Map.CHATEAU_GUILLARD_HALLOWEEN:
        dummy_bot_spawn_position = vect(206.444, 15.955, 86.831)
        dummy_bot_spawn_facing = vect(206.444, 15.955, 86.831)
        shop_location = vect(72.62, 5.07, 50.17)
        shop_rotation = -137
    elif getCurrentMap() == Map.KINGS_ROW or getCurrentMap() == Map.KINGS_ROW_WINTER:
        dummy_bot_spawn_position = vect(-95.498, 7.937, -30.638)
        dummy_bot_spawn_facing = vect(-95.498, 7.937, -30.638)
        shop_location = vect(-140.793, 6.939, 22.963)
        shop_rotation = -81
    elif getCurrentMap() == Map.BLIZZ_WORLD or getCurrentMap() == Map.BLIZZ_WORLD_WINTER:
        dummy_bot_spawn_position = vect(-45.778, 4.981, 95.978)
        dummy_bot_spawn_facing = vect(-45.778, 4.981, 95.978)
        shop_location = vect(-140.141, 1.684, 105.206)
        shop_rotation = -106
    elif getCurrentMap() == Map.HANAMURA or getCurrentMap() == Map.HANAMURA_WINTER:
        dummy_bot_spawn_position = vect(11.903, 11.666, 21.966)
        dummy_bot_spawn_facing = vect(11.903, 11.666, 21.966)
        shop_location = vect(1.859, 0.68, 19.337)
        shop_rotation = 180
    elif getCurrentMap() == Map.NECROPOLIS:
        dummy_bot_spawn_position = vect(-27.407, 9.455, -0.003)
        dummy_bot_spawn_facing = vect(-27.407, 9.455, -0.003)
        shop_location = vect(166.55, 29.53, -0.96)
        shop_rotation = 90
    elif getCurrentMap() == Map.PETRA:
        dummy_bot_spawn_position = vect(43.642, 13.747, 33.965)
        dummy_bot_spawn_facing = vect(43.642, 13.747, 33.965)
        shop_location = vect(53.86, -8.03, 48.69)
        shop_rotation = 111
    elif getCurrentMap() == Map.KANEZAKA:
        dummy_bot_spawn_position = vect(-8.115, 6.507, -38.928)
        dummy_bot_spawn_facing = vect(-8.115, 6.507, -38.928)
        shop_location = vect(305.94, 43.70, -110.49)
        shop_rotation = 99
    elif getCurrentMap() == Map.CASTILLO:
        dummy_bot_spawn_position = vect(-112.424, 33.763, 59.87)
        dummy_bot_spawn_facing = vect(-112.424, 33.763, 59.87)
        shop_location = vect(3.87, 31.11, 149.14)
        shop_rotation = 63
    elif getCurrentMap() == Map.DORADO:
        dummy_bot_spawn_position = vect(27.568, 4.221, -17.033)
        dummy_bot_spawn_facing = vect(27.568, 4.221, -17.033)
        shop_location = vect(78.814, -7.22, 60.419)
        shop_rotation = -37
    elif getCurrentMap() == Map.HAVANA:
        dummy_bot_spawn_position = vect(107.152, 2.067, -27.697)
        dummy_bot_spawn_facing = vect(107.152, 2.067, -27.697)
        shop_location = vect(108.634, -6.72, -98.952)
        shop_rotation = 138
    elif getCurrentMap() == Map.HORIZON_LUNAR_COLONY:
        dummy_bot_spawn_position = vect(-5.277, 8.455, -0.963)
        dummy_bot_spawn_facing = vect(-5.277, 8.455, -0.963)
        shop_location = vect(70.59, 45.82, -38.84)
        shop_rotation = -62
    elif getCurrentMap() == Map.PARIS:
        dummy_bot_spawn_position = vect(-15.892, 11.764, -28.584)
        dummy_bot_spawn_facing = vect(-15.892, 11.765, -28.584)
        shop_location = vect(-160.69, 9.10, -22.19)
        shop_rotation = -17
    elif getCurrentMap() == Map.TEMPLE_OF_ANUBIS:
        dummy_bot_spawn_position = vect(9.821, 1.229, -34.382)
        dummy_bot_spawn_facing = vect(9.821, 1.229, -34.382)
        shop_location = vect(-26.06, 104.34, -57.04)
        shop_rotation = 150
    elif getCurrentMap() == Map.VOLSKAYA:
        dummy_bot_spawn_position = vect(-5.23, -5.49, 20.299)
        dummy_bot_spawn_facing = vect(-5.23, -5.49, 20.299)
        shop_location = vect(29.638, 0.967, 135.899)
        shop_rotation = 87
    elif getCurrentMap() == Map.MALEVENTO:
        dummy_bot_spawn_position = vect(19.218, 9.455, 36.238)
        dummy_bot_spawn_facing = vect(19.218, 9.455, 36.238)
        shop_location = vect(-54.88, -1.37, -34.13)
        shop_rotation = -138
    elif getCurrentMap() == Map.ROUTE66:
        dummy_bot_spawn_position = vect(-72.46, 8.05, 9.77)
        dummy_bot_spawn_facing = vect(19.218, 9.455, 36.238)
        shop_location = vect(-2.97, 49.67, -36.77)
        shop_rotation = 60

    #--- Derive the three talent positions from shop_location + shop_rotation (same logic for every map) ---
    #--- SHOP_TALENT_ELEVATION lifts all three orbs; SHOP_TALENT_MIDDLE_ELEVATION adds EXTRA lift to the middle (1) only ---
    shop_talent_positions[0] = shop_location + angleToDirection(shop_rotation + SHOP_TALENT_SPREAD, -SHOP_TALENT_ELEVATION) * SHOP_TALENT_RADIUS
    shop_talent_positions[1] = shop_location + angleToDirection(shop_rotation, -(SHOP_TALENT_ELEVATION + SHOP_TALENT_MIDDLE_ELEVATION)) * SHOP_TALENT_RADIUS
    shop_talent_positions[2] = shop_location + angleToDirection(shop_rotation - SHOP_TALENT_SPREAD, -SHOP_TALENT_ELEVATION) * SHOP_TALENT_RADIUS


def create_talent_hud_texts():
    @Name "GENERAL - - - [SUBROUTINE] Create HUD Texts"
    
    hudText(getAllPlayers(), null, TOP_RIGHT_TEXT, HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #hudText(getAllPlayers(), null, "", "[More info: workshop.codes/ZEKK3]", HudPosition.RIGHT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(localPlayer if localPlayer.can_enter_shop == true and localPlayer.replacing_talent_show_confirmation == false and localPlayer.replacing_talent_show_bought_talents == false else null, "[Hold: {0} to use Hearthstone]".format(buttonString(Button.RELOAD)) if localPlayer.browsing_shop == false else "", HudPosition.TOP, 2, Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    #Selected talent description + stats + locks as ONE merged text (TOP/4) over the LEFT bar. Sections divided by a full-width em-dash line (talent_emdash_sep). Description carries the INFO_TEXT_PAD lead (talents.js). Stats per current rank (» upgrade arrows); stats/locks omitted when absent. Em-dash and » are Latin-1 — they don't reskin, so the whole block stays one font.
    hudSubheader(localPlayer if SHOP_BROWSING else null, "{0}{1}{2}".format(talent_descriptions[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]], "\n{0}\n{1}".format(talent_emdash_sep[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]], talent_stats_lines[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]][localPlayer.talent_ranks[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]]) if talent_has_stats[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]] else "", "\n{0}\n{1}".format(talent_emdash_sep[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]], talent_availability[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]]) if talent_has_availability[localPlayer.talents_offered_in_shop[localPlayer.selected_talent_in_shop]] else ""), HudPosition.TOP, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

def create_talent_helpers():
    @Name "GENERAL - - - [SUBROUTINE] Create Cooldown Ready Icons"
    
    #Health Potions or Poison Vials
    createInWorldText(localPlayer if ((localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or localPlayer.talent_ranks[Talent.POISON_VIALS] > 0) and localPlayer.browsing_shop == false) and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false else null, "{0}   {1}   {2}".format(('<tx0C0000000005FA7F>') if localPlayer.amount_of_health_potions >= 1 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else 
    iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 1 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", ('<tx0C0000000005FA7F>') if localPlayer.amount_of_health_potions >= 2 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 2 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", ('<tx0C0000000005FA7F>') if localPlayer.amount_of_health_potions == 3 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 3 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else ""), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #Immunity, Bandage, Jetpack
    createProgressBarInWorldText(localPlayer if localPlayer.isAlive() and localPlayer.browsing_shop == false and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false and localPlayer.is_using_ability[Talent.GRIM_REAPER] == false and localPlayer.is_using_ability[Talent.DIVE_BOMB] == false and (localPlayer.immunity_duration > 0 or localPlayer.bandage_progress > 0 or localPlayer.is_using_ability[Talent.BERSERKER] or localPlayer.talent_ranks[Talent.JETPACK] > 0 and localPlayer.jetpack_fuel < 100) else null, localPlayer.immunity_duration if localPlayer.is_using_ability[Talent.IMMUNITY] == true else localPlayer.bandage_progress * 100 / 10 if localPlayer.is_using_ability[Talent.BANDAGE] == true else (BERSERKER_DURATION_LOCAL - localPlayer.berserker_duration) / BERSERKER_DURATION_LOCAL * 100 if localPlayer.is_using_ability[Talent.BERSERKER] == true else localPlayer.jetpack_fuel, "{0} IMMUNITY   {1} = Cancel".format(('<tx0C00000000004120>'), buttonString(Button.ULTIMATE)) if localPlayer.is_using_ability[Talent.IMMUNITY] else "{0} BANDAGING   {1} = Cancel".format(abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE), buttonString(Button.MELEE)) if localPlayer.is_using_ability[Talent.BANDAGE] else "{0} BERSERKER   {1} = Cancel".format(iconString(Icon.SKULL), buttonString(Button.ULTIMATE)) if localPlayer.is_using_ability[Talent.BERSERKER] else "{0} FUEL".format(('<tx0C00000000011E06>')), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.625 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.WHITE if localPlayer.is_using_ability[Talent.BANDAGE] == true else Color.RED if localPlayer.is_using_ability[Talent.BERSERKER] == true else Color.RED if localPlayer.jetpack_fuel < 33 else Color.ORANGE if localPlayer.jetpack_fuel < 66 else Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #Entering Stealth
    createProgressBarInWorldText(localPlayer if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.browsing_shop == false and (localPlayer.entering_stealth == true or localPlayer.is_using_ability[Talent.STEALTH] == true) else null, localPlayer.entering_stealth_timer * 100, "Entering Stealth" if localPlayer.is_using_ability[Talent.STEALTH] == false else "Stealthed", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.75 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #Talent Cooldown Icons
    createInWorldText(localPlayer if localPlayer.browsing_shop == false and not localPlayer.isDummy() and not localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.is_using_hearthstone else null, "{0}{1}{2}".format(('<tx0C000000000207B6>') if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.is_using_ability[Talent.STEALTH] == false and localPlayer.talent_trigger_times[Talent.STEALTH] + talent_base_cooldowns[Talent.STEALTH] - localPlayer.talent_ranks[Talent.STEALTH] * talent_cd_reduction_p_rank[Talent.STEALTH] <= current_time else "", abilityIconString(Hero.REINHARDT, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.JUGGERNAUT] > 0 and localPlayer.talent_trigger_times[Talent.JUGGERNAUT] + talent_base_cooldowns[Talent.JUGGERNAUT] <= current_time else "", "{0}{1}{2}".format(('<tx0C000000000207B7>') if localPlayer.talent_ranks[Talent.DIVE_BOMB] > 0 and localPlayer.talent_trigger_times[Talent.DIVE_BOMB] + talent_base_cooldowns[Talent.DIVE_BOMB] <= current_time else "", /*abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE) if localPlayer.talent_ranks[Talent.BLOODTHIRST] > 100 and localPlayer.talent_trigger_times[Talent.GRIM_REAPER] + talent_base_cooldowns[Talent.GRIM_REAPER] <= getTotalTimeElapsed() else */"", "{0}{1}{2}".format(iconString(Icon.SKULL) if localPlayer.talent_ranks[Talent.BERSERKER] > 0 and localPlayer.talent_trigger_times[Talent.BERSERKER] + talent_base_cooldowns[Talent.BERSERKER] <= current_time else "", iconString(Icon.FIRE) if localPlayer.talent_ranks[Talent.FIREBALL] > 0 and localPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= current_time else "", "{0}{1}{2}".format(('<tx0C0000000007550C>') if localPlayer.talent_ranks[Talent.SHADOWSTEP] > 0 and localPlayer.talent_trigger_times[Talent.SHADOWSTEP] + talent_base_cooldowns[Talent.SHADOWSTEP] - localPlayer.talent_ranks[Talent.SHADOWSTEP] * SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK <= current_time else "", "", "{0}{1}".format(('<tx0C00000000004120>') if localPlayer.talent_ranks[Talent.IMMUNITY] > 0 and localPlayer.talent_trigger_times[Talent.IMMUNITY] + talent_base_cooldowns[Talent.IMMUNITY] <= current_time else "", abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE) if localPlayer.talent_ranks[Talent.BANDAGE] > 0 and localPlayer.is_using_ability[Talent.BANDAGE] == false and localPlayer.talent_trigger_times[Talent.BANDAGE] + talent_base_cooldowns[Talent.BANDAGE] <= current_time else ""))))), updateEveryTick(localPlayer.getEyePosition() + (100 * (0.5 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.2 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    #Hearthstone
    #createProgressBarInWorldText(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.using_one_of_the_hearthstones else null, localPlayer.using_hearthstone_timer / 2.75 * 100 if faster_testing == false else 50, "{0} Using Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.browsing_shop == false else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} Skipping Bonus Talent".format(iconString(Icon.TRASHCAN)) if localPlayer.amount_of_bonus_talents > 0 and localPlayer.isHoldingButton(Button.RELOAD) else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.RELOAD) else "", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.55 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))) if localPlayer.browsing_shop == false else localPlayer.selected_talent_position + Vector.UP, 1, Clip.NONE, Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #Railgun Cooldown / Charge
    createInWorldText(localPlayer if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and "{0}".format(localPlayer.isCommunicatingEmote()) == "0" and localPlayer.browsing_shop == false and not localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.is_using_hearthstone else null, "{0} {1}%".format(iconString(Icon.BOLT), ceil(localPlayer.railgun_charge)) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge > 0 else ("{0} Ready".format(iconString(Icon.BOLT))) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= current_time else "{0} Cooldown: {1}".format(iconString(Icon.BOLT), localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] - current_time if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > current_time else 0), updateEveryTick(localPlayer.getEyePosition() + (100 * (worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge < 100 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= current_time else Color.SKY_BLUE if localPlayer.railgun_charge >= 100 else Color.GRAY if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > current_time or localPlayer.rockets_cooldown > 0 and localPlayer.talent_ranks[Talent.RAILGUN] == 0 else Color.WHITE, SpecVisibility.NEVER)

    #Grim Reaper Target Skull
    createInWorldText(localPlayer if localPlayer.talent_ranks[Talent.GRIM_REAPER] > 0 and localPlayer.grim_reaper_aim_indicator != null and localPlayer.grim_reaper_aim_indicator.browsing_shop == false and localPlayer.isAlive() == true and localPlayer.browsing_shop == false else null, "{0}".format(('<tx00000004F741>')), updateEveryFrame(((localPlayer.grim_reaper_aim_indicator.getPosition() + Vector.UP if not localPlayer.is_using_ability[Talent.GRIM_REAPER] or not localPlayer.casting_success else localPlayer.grim_reaper_feet_destination + Vector.UP) + directionTowards(localPlayer.grim_reaper_aim_indicator.getPosition(), localPlayer.getEyePosition()) * 0.1) if localPlayer.grim_reaper_aim_indicator != null else localPlayer.getEyePosition()), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)

    /*
    #Cancel Juggernaut
    createInWorldText(localPlayer if localPlayer.is_using_ability[Talent.JUGGERNAUT] == true and localPlayer.has_hit_the_ground == true else null, "{0} {1} = Cancel".format(abilityIconString(Hero.REINHARDT, Button.ABILITY_1), buttonString(Button.INTERACT)), updateEveryTick(localPlayer.getEyePosition()), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    */

rule "GENERAL - - - [EACH PLAYER] Has Spawned":
    @Event eachPlayer
    @Condition eventPlayer.is_respawning == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.is_respawning = false
    if map_is_changing == false:
        setMatchTime(3599)
    #eventPlayer.xp_orb_position_on_player = false
    if not eventPlayer.isDummy():
        if eventPlayer.getCurrentHero() == Hero.SOLDIER:
            eventPlayer.stats[Stat.EYE_HEIGHT] = eventPlayer.getEyePosition().y - eventPlayer.getPosition().y
        if not eventPlayer.input_device_checked and eventPlayer.getCurrentHero() == Hero.SOLDIER:
            eventPlayer.input_device_checked = true
            async(detect_input_device, AsyncBehavior.NOOP)
        if eventPlayer.xp_boost_is_active == false and ((eventPlayer.amount_of_talents_purchased == 0 or eventPlayer.amount_of_talents_purchased == 25) or eventPlayer.skipped_a_talent == true or (eventPlayer.amount_of_talents_purchased > 0 and eventPlayer.amount_of_talents_purchased <= (player_with_most_talents.amount_of_talents_purchased - 5))):
            async(activate_xp_boost, AsyncBehavior.NOOP)
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
        if eventPlayer.stats[Stat.SHIELDS] > 0:
            removeHealthPool(eventPlayer.cybernetics_health_pool_id)
            eventPlayer.addHealthPool(Health.SHIELDS, eventPlayer.stats[Stat.SHIELDS], true, true)
            #eventPlayer.cybernetics_shields = eventPlayer.stats[Stat.SHIELDS]
            eventPlayer.cybernetics_health_pool_id = getLastCreatedHealthPool()
        if eventPlayer.can_enter_shop == true and eventPlayer.amount_of_talents_purchased < 25:
            async(open_shop, AsyncBehavior.NOOP)
        else:
            wait(0.125)
            eventPlayer.stopCamera()

        resume_player_input()

        destroyEffect(eventPlayer.hearthstone_effects_id[0])
        destroyEffect(eventPlayer.hearthstone_effects_id[1])
        #Gigachad
        eventPlayer.setKnockbackReceived(eventPlayer.stats[Stat.KNOCKBACK_RECEIVED])
    eventPlayer.setMaxHealth(eventPlayer.stats[Stat.HEALTH])
    eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
    if eventPlayer.talent_ranks[Talent.EXPLOSIVE_AMMO] > 0:
        generate_explosive_ammo_pattern()
    if not IS_PLAYER(eventPlayer):
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    else:
        recalculate_player_speed()
    #wait is needed to see if max health is upgraded first
    wait()
    heal(eventPlayer, null, eventPlayer.getMaxHealth())


def detect_input_device():
    @Name "GENERAL - - - [SUBROUTINE] Detect Input Device"

    eventPlayer.device_check_facing = round(horizontalAngleOfDirection(eventPlayer.getFacingDirection()))
    eventPlayer.startFacing(angleToDirection(eventPlayer.device_check_facing + 1, 0) if [Button.ABILITY_1, Button.ABILITY_2, Button.CROUCH, Button.INTERACT, Button.JUMP, Button.MELEE, Button.PRIMARY_FIRE, Button.RELOAD, Button.SECONDARY_FIRE, Button.ULTIMATE].any(lambda input_button: inputBindingString(input_button)[0] and strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&~\"#'{([-|`_\\^@)]=}^$%*,?.;/:>²ÉÈÇÀÙ+¤^ßÜÖÄÑ¡´¿ÒÌСЛП↓←→↑스아좌왼숫우오위空回退大下左暂右上；，向數", inputBindingString(input_button).charAt(0))) else angleToDirection(eventPlayer.device_check_facing - 1, 0), 999999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(0.25)
    waitUntil(round(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) * 100) / 100 in [eventPlayer.device_check_facing + 1, eventPlayer.device_check_facing - 1], 3)
    eventPlayer.using_gamepad = round(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) * 100) / 100 == eventPlayer.device_check_facing - 1
    eventPlayer.stopFacing()


rule "GENERAL - - - Player Died":
    @Event playerDied
    @Condition (IS_PLAYER(eventPlayer) or (eventPlayer.isDummy() and eventPlayer.reaper_has_respawned_once == true)) == true

    eventPlayer.stopAllDoT()
    /*
    if len(xp_orbs) >= 8:
        #remove first of sorted array (the oldest xp orb, checking its timestamp value)
        del xp_orbs[xp_orbs_current_index]
        #xp_orbs.remove(sorted(xp_orbs[Orb.TIMESTAMP])[0])
        xp_orbs.remove(sorted(xp_orbs, lambda orb: orb[Orb.TIMESTAMP])[0])*/

    #eventPlayer.player_xp_orb_index = xp_orbs[len(xp_orbs)]
    eventPlayer.player_xp_orb_index = len(xp_orbs)
    xp_orbs[eventPlayer.player_xp_orb_index] = [eventPlayer, getTotalTimeElapsed(), round(eventPlayer.experience_max * 0.2), true if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0 else false, eventPlayer.talent_ranks[Talent.BURNING_SOUL], eventPlayer.getPosition() + Vector.UP * 0.25, orb_rarity_colors[floor(eventPlayer.amount_of_talents_purchased / 5)]]

    createEffect([player for player in getAllPlayers().exclude(eventPlayer) if xp_orbs[player.player_xp_orb_index][Orb.EXPLOSIVE] == false or xp_orbs[player.player_xp_orb_index][Orb.TIMESTAMP] < getTotalTimeElapsed() - BURNING_SOUL_ORB_DURATION], Effect.ORB, orb_rarity_colors[floor(eventPlayer.amount_of_talents_purchased / 5)], eventPlayer.getPosition() + Vector.UP * 0.25, 1, EffectReeval.VISIBILITY)

    xp_orbs[eventPlayer.player_xp_orb_index][Orb.ORB_EFFECT_ID] = getLastCreatedEntity()

    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0:

        createEffect([player for player in getAllPlayers() if xp_orbs[player.player_xp_orb_index][Orb.EXPLOSIVE] == false or xp_orbs[player.player_xp_orb_index][Orb.TIMESTAMP] < getTotalTimeElapsed() - BURNING_SOUL_ORB_DURATION], Effect.TORBJORN_OVERLOADING_SOUND, Color.TEAM_2, eventPlayer.getPosition() + vect(0, 0.25, 0), 100, EffectReeval.VISIBILITY)
        xp_orbs[eventPlayer.player_xp_orb_index][Orb.BURNING_SOUL_SOUND_EFFECT_ID] = getLastCreatedEntity()

        #eventPlayer.player_temp_effects[77] = getLastCreatedEntity()

        createProjectileEffect(getAllPlayers(), Projectile.ZARYA_PARTICLE_CANNON, null, eventPlayer.getPosition() + Vector.UP * 0.25, directionTowards(eventPlayer.getPosition() + Vector.UP * 0.25, eventPlayer.getPosition()/* + Vector.UP * 0.25 + Vector.DOWN*/), 0.085, ProjectileEffectReeval.NONE)
        xp_orbs[eventPlayer.player_xp_orb_index][Orb.BURNING_SOUL_EFFECT_ID] = getLastCreatedEntity()

    /*
    #apply impulse
    if eventAbility == Button.PRIMARY_FIRE:
        eventPlayer.applyImpulse(worldVector(angleToDirection(0, -45), attacker, Transform.ROTATION), 9.8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    elif eventAbility == Button.SECONDARY_FIRE:
        eventPlayer.applyImpulse(eventDirection + Vector.UP, 9.8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    */
    
    /*
    eventPlayer.dropped_xp_orb = true
    eventPlayer.xp_orb_position_on_player = true
    destroyEffect(eventPlayer.player_temp_effects[42])
    stopChasingVariable(eventPlayer.xp_orb_location)
    async(dropped_xp_orb, AsyncBehavior.NOOP)
    */
    
    if IS_PLAYER(eventPlayer):
        eventPlayer.in_combat = false
        if eventPlayer.xp_boost_is_active == true:
            stopChasingVariable(eventPlayer.experience_current)
            eventPlayer.xp_boost_is_active = false
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
        eventPlayer.is_respawning = true
        if attacker == victim:
            eventPlayer.addToScore(1)
    elif spawn_bots:
        #--- Bot death logic (merged from BOT - - - Died) ---
        eventPlayer.bot_combat_target = null
        eventPlayer.bot_combat_awareness_start = 0
        eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
        eventPlayer.stopFacing()
        eventPlayer.bot_state_id = BotState.DEAD
        eventPlayer.bot_throttle_paused = true
        waitUntil(eventPlayer.isAlive() and eventPlayer.hasSpawned(), 99999)
        wait(BOT_RESPAWN_WAIT)
        eventPlayer.bot_state_id = BotState.IDLE


rule "GENERAL - - - Player Dealt Damage":
    @Event playerDealtDamage
    @Condition IS_PLAYER(eventPlayer)

    #Damage Numbers
    if attacker != victim and eventDamage > 0 and victim.is_using_ability[Talent.IMMUNITY] == false:
        recent_damage_index = eventPlayer.recent_damage_victims.index(victim)
        if recent_damage_index == -1:
            recent_damage_index = len(eventPlayer.recent_damage_victims)
            for i in range(len(eventPlayer.recent_damage_time_other)):
                if recent_damage_index == len(eventPlayer.recent_damage_victims) and getTotalTimeElapsed() - eventPlayer.recent_damage_time_other[i] > DAMAGE_NUMBER_WINDOW:
                    recent_damage_index = i
            eventPlayer.recent_damage_victims[recent_damage_index] = victim
            eventPlayer.recent_damage_other[recent_damage_index] = 0
            eventPlayer.recent_damage_crit_other[recent_damage_index] = false
            eventPlayer.recent_damage_time_other[recent_damage_index] = getTotalTimeElapsed() - DAMAGE_NUMBER_WINDOW - 1
        if not (eventAbility == Button.MELEE or ((eventAbility == Button.PRIMARY_FIRE or eventAbility == Button.ULTIMATE) and attacker.railgun_charge < 100)):
            if getTotalTimeElapsed() - eventPlayer.recent_damage_time_other[recent_damage_index] > DAMAGE_NUMBER_WINDOW:
                eventPlayer.recent_damage_other[recent_damage_index] = eventDamage
                eventPlayer.recent_damage_crit_other[recent_damage_index] = eventWasCriticalHit or (eventAbility == Button.SECONDARY_FIRE and eventDamage >= DAMAGE_NUMBER_HELIX_THRESHOLD)
            else:
                eventPlayer.recent_damage_other[recent_damage_index] += eventDamage
                eventPlayer.recent_damage_crit_other[recent_damage_index] = eventPlayer.recent_damage_crit_other[recent_damage_index] or eventWasCriticalHit or (eventAbility == Button.SECONDARY_FIRE and eventDamage >= DAMAGE_NUMBER_HELIX_THRESHOLD)
            eventPlayer.recent_damage_time_other[recent_damage_index] = getTotalTimeElapsed()

    if eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0 and eventPlayer.is_using_ability[Talent.BERSERKER] == true:
        eventPlayer.bloodthirst_remaining_heal_amount += BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT
    if attacker.is_using_ability[Talent.IMMUNITY] == false and attacker != victim:
        attacker.using_hearthstone_timer = 0
        attacker.in_combat = true
        attacker.combat_last_hit_time = getTotalTimeElapsed()
    if eventPlayer.experience_current < eventPlayer.experience_max and attacker != victim:
        eventPlayer.experience_current += eventDamage / 5 * eventPlayer.stats[Stat.XP]

    #if attacker.talent_ranks[Talent.ADRENALINE_RUSH] > 0 and attacker != victim:


    /*
    if attacker.talent_ranks[Talent.GRIM_REAPER] > 0 and victim.getHealthOfType(Health.NORMAL) < victim.getMaxHealthOfType(Health.NORMAL) *    GRIM_REAPER_THRESHOLD_NORMALIZED_ATTACKER and victim.getHealthOfType(Health.NORMAL) < attacker.getHealthOfType(Health.NORMAL):
        damage(victim, attacker, eventDamage * 0.20)
        attacker.grim_reaper_damage_dealt += eventDamage * 0.20
        */

    #MELEE
    if eventAbility == Button.MELEE:

        #Dealt Stealth damage?
        if victim.is_using_ability[Talent.IMMUNITY] == false and attacker.is_using_ability[Talent.STEALTH] == true and eventAbility != null:
            #victim.hit_by_talent[Talent.STEALTH] = attacker
            victim.hacked_until = getTotalTimeElapsed() + STEALTH_HACK_DURATION
            victim.is_hacked = true

        #Dealt Poisonous Dagger damage?    
        if victim.is_using_ability[Talent.IMMUNITY] == false and attacker.is_using_ability[Talent.STEALTH] == true and attacker.talent_ranks[Talent.POISONOUS_DAGGER] > 0 and attacker.talent_trigger_times[Talent.POISONOUS_DAGGER] + talent_base_cooldowns[Talent.POISONOUS_DAGGER] <= getTotalTimeElapsed():

            victim.poisonous_dagger_attackers.append(attacker)
            victim.poisonous_dagger_timestamp.append(getTotalTimeElapsed())
            #victim.remaining_poisonous_dagger_duration = POISONOUS_DAGGER_DURATION
            attacker.talent_trigger_times[Talent.POISONOUS_DAGGER] = getTotalTimeElapsed()

        if attacker.talent_ranks[Talent.STEALTH] > 0 and attacker.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
            
    #PRIMARY FIRE || ULTIMATE
    elif eventAbility == Button.PRIMARY_FIRE or eventAbility == Button.ULTIMATE:
        #Gunslinger?
        /*
        if attacker.talent_ranks[Talent.GUNSLINGER] > 0 and attacker.railgun_charge < 100:
            damage(victim, attacker, GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit else GUNSLINGER_ADDITIONAL_DAMAGE)
            if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
                victim.gigachad_damage_resisted += GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM
        */
        #Railgun?
        if attacker.railgun_charge >= 100:
            attacker.railgun_damage_dealt = victim.getHealth()
            damage(victim, attacker, RAILGUN_ADDITIONAL_DAMAGE)
            attacker.railgun_damage_dealt -= victim.getHealth()
            attacker.railgun_damage_dealt += eventDamage
            #Gigachad headshot refund — railgun is 1.5x crit, so 2/3 of the rifle's rate
            if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit and victim.isAlive():
                heal(victim, victim, attacker.railgun_damage_dealt * GIGACHAD_HEADSHOT_HEAL_RAILGUN)
                victim.gigachad_damage_healed_back[0] += attacker.railgun_damage_dealt * GIGACHAD_HEADSHOT_HEAL_RAILGUN
            eventPlayer.railgun_projectile_player_hit = victim
            if attacker.talent_ranks[Talent.OVERCLOCK] > 0:
                eventPlayer.railgun_chain_origin = victim.getEyePosition() if eventWasCriticalHit else victim.getPosition() + Vector.UP
                eventPlayer.railgun_chain_hit = [victim]
                eventPlayer.railgun_chain_damage = OVERCLOCK_CHAIN_DAMAGE
                async(railgun_chain, AsyncBehavior.NOOP)
            playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_1, victim.getPosition(), 1)
            playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, victim.getPosition(), 100)
            playEffect(getAllPlayers(), DynamicEffect.PHARAH_CONCUSSIVE_BLAST, Color.TEAM_1, victim.getPosition(), 1)
            if attacker.using_cryogenics == true and victim.is_using_ability[Talent.JUGGERNAUT] == false and victim.is_using_ability[Talent.IMMUNITY] == false:
                victim.hit_by_talent[Talent.CRYOGENICS] = attacker
                attacker.talent_trigger_times[Talent.CRYOGENICS] = getTotalTimeElapsed() - attacker.cryogenics_travel_time
                attacker.talent_on_cooldown[Talent.CRYOGENICS] = true
        #Lifesteal Ammo?
        if attacker.talent_ranks[Talent.LIFESTEAL_AMMO] > 0 and attacker.getHealthOfType(Health.NORMAL) < attacker.getMaxHealthOfType(Health.NORMAL) and attacker.railgun_charge < 100:
            if attacker.is_hacked == true:
                attacker.hack_error_pending = true
            else:
                heal(attacker, attacker, min(LIFESTEAL_HEAL, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
                eventPlayer.is_lifestealing = 1.5
                lifesteal_hps()
        #Explosive Ammo?
        if attacker.talent_ranks[Talent.EXPLOSIVE_AMMO] > 0 and attacker.railgun_charge < 100 and victim.is_using_ability[Talent.IMMUNITY] == false:
            if attacker.is_hacked == true:
                attacker.hack_error_pending = true
            elif attacker.explosive_ammo_pattern[EXPLOSIVE_AMMO_MAG_SIZE - 1 - attacker.getAmmo(0)] == true:
                damage(victim, attacker, EXPLOSIVE_AMMO_DAMAGE)
                playEffect(getAllPlayers(), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.TEAM_1, victim.getEyePosition() if eventWasCriticalHit else victim.getPosition() + Vector.UP, 1)
                playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_1, victim.getEyePosition() if eventWasCriticalHit else victim.getPosition() + Vector.UP, 100)
    #SECONDARY FIRE
    elif eventAbility == Button.SECONDARY_FIRE:
        #if attacker.talent_ranks[Talent.BOMBARDMENT] > 0:
            #damage(victim, attacker, BOMBARDMENT_DAMAGE)
        if attacker.using_cryogenics == true and victim.is_using_ability[Talent.JUGGERNAUT] == false and victim.is_using_ability[Talent.IMMUNITY] == false and victim.  is_using_ability[Talent.SHADOWSTEP] == false:
            victim.hit_by_talent[Talent.CRYOGENICS] = attacker
            attacker.talent_trigger_times[Talent.CRYOGENICS] = getTotalTimeElapsed() - attacker.cryogenics_travel_time
            attacker.talent_on_cooldown[Talent.CRYOGENICS] = true

rule "GENERAL - - - Player Took Damage":
    @Event playerTookDamage

    #--- Bot: Got Shot — immediate targeting ---
    if eventPlayer.isDummy():
        if spawn_bots and not bots_friendly and eventPlayer.bot_combat_target == null and not attacker.isDummy() and attacker.isAlive() and not attacker.browsing_shop and not attacker.is_using_ability[Talent.STEALTH]:
            eventPlayer.bot_combat_target = attacker
            eventPlayer.bot_was_shot = true
            eventPlayer.bot_combat_awareness_start = 0
            eventPlayer.bot_state_id = BotState.COMBAT
        return

    #if victim.cybernetics_shields > 0:
        #stopChasingVariable(victim.cybernetics_shields)
        #victim.cybernetics_shields -= min(eventDamage, victim.cybernetics_shields)
    victim_immunity_off = victim.is_using_ability[Talent.IMMUNITY] == false
    if victim.is_using_ability[Talent.BLOODTHIRST] == true and victim.bloodthirst_remaining_heal_amount >= 1:
        victim.bloodthirst_remaining_heal_amount -= eventDamage
    if victim.is_using_ability[Talent.BANDAGE] == true and victim != attacker and victim_immunity_off and victim.bandage_progress > 0.032:
        victim.is_using_ability[Talent.BANDAGE] = false
    if victim_immunity_off and victim != attacker:
        attacker.using_hearthstone_timer = 0
        victim.in_combat = true
        victim.combat_last_hit_time = getTotalTimeElapsed()
    if victim.talent_ranks[Talent.STEALTH] > 0 and victim_immunity_off and victim != attacker:
        stopChasingVariable(victim.entering_stealth_timer)
        victim.entering_stealth_timer = 0
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
    if victim.is_using_ability[Talent.IGNORE_PAIN] == true and victim_immunity_off:
        eventPlayer.ignore_pain_damage_resisted[0] += eventDamage
    if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit and attacker.railgun_charge < 100 and victim.isAlive():
        heal(victim, victim, eventDamage * GIGACHAD_HEADSHOT_HEAL)
        victim.gigachad_damage_healed_back[0] += eventDamage * GIGACHAD_HEADSHOT_HEAL

rule "GENERAL - - - Combat Timeout (clears in_combat ~3s after the last hit)":
    @Event eachPlayer
    @Condition eventPlayer.in_combat == true

    while getTotalTimeElapsed() < eventPlayer.combat_last_hit_time + COMBAT_DURATION:
        wait(eventPlayer.combat_last_hit_time + COMBAT_DURATION - getTotalTimeElapsed())
    eventPlayer.in_combat = false

rule "GENERAL - - - Player Slowed (Hit by Cryogenics Talent)":
    @Event eachPlayer
    @Condition eventPlayer.cryogenics_slow_amount < eventPlayer.stats[Stat.SPEED]
    @Condition eventPlayer.refresh_cryogenics_slow == true
    
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.refresh_cryogenics_slow = false
    eventPlayer.setAbility1Enabled(false)
    chase(eventPlayer.cryogenics_slow_amount, eventPlayer.stats[Stat.SPEED], duration=eventPlayer.cryogenics_slow_duration, ChaseReeval.DESTINATION_AND_DURATION)
    while eventPlayer.isAlive() and eventPlayer.cryogenics_slow_amount != eventPlayer.stats[Stat.SPEED] and eventPlayer.is_using_ability[Talent.IMMUNITY] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false and eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false:
        eventPlayer.setMoveSpeed(eventPlayer.cryogenics_slow_amount * eventPlayer.adrenaline_rush_value / 100)
        wait(0.032, Wait.RESTART_WHEN_TRUE)
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.cryogenics_slow_amount = eventPlayer.stats[Stat.SPEED]
    if not IS_PLAYER(eventPlayer):
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    else:
        recalculate_player_speed()
    #if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] == 0:
    restore_ability1()
    eventPlayer.cryogenics_slow_duration = 0

def which_players_have_grim_reaper():
    @Name "Subroutine: Which players have grim reaper"
    
    /*
    players_with_grim_reaper[0] = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 0 and player.talent_ranks[Talent.GRIM_REAPER] <= 5]
    players_with_grim_reaper[1] = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 1 and player.talent_ranks[Talent.GRIM_REAPER] <= 5]
    players_with_grim_reaper[2] = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 2 and player.talent_ranks[Talent.GRIM_REAPER] <= 5]
    players_with_grim_reaper[3] = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 3 and player.talent_ranks[Talent.GRIM_REAPER] <= 5]
    players_with_grim_reaper[4] = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 4 and player.talent_ranks[Talent.GRIM_REAPER] <= 5]
    */
    #NEW GRIM REAPER
    players_with_grim_reaper = [player for player in getAllPlayers() if player.talent_ranks[Talent.GRIM_REAPER] > 0]

def restore_ability1():
    @Name "GENERAL - - - [SUBROUTINE] Restore Ability 1 (Sprint)"

    eventPlayer.setAbility1Enabled(true)

def recalculate_player_speed():
    @Name "Subroutine: Recalculate Player Speed"

    if eventPlayer.is_using_ability[Talent.IMMUNITY]:
        eventPlayer.stats[Stat.SPEED] = IMMUNITY_MOVE_SPEED
    elif eventPlayer.is_using_ability[Talent.BANDAGE] or eventPlayer.is_using_ability[Talent.GRIM_REAPER] or eventPlayer.is_using_hearthstone:
        eventPlayer.stats[Stat.SPEED] = 25
    elif eventPlayer.is_charging_railgun:
        eventPlayer.stats[Stat.SPEED] = 50
    else:
        eventPlayer.stats[Stat.SPEED] = GIGACHAD_MOVE_SPEED

    if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)


def recalculate_damage_received():
    @Name "Subroutine: Recalculate Damage Received"

    if eventPlayer.is_using_ability[Talent.IMMUNITY]:
        eventPlayer.setDamageReceived(0.001)
    else:
        eventPlayer.current_damage_received = 100
        if eventPlayer.is_using_ability[Talent.BERSERKER]:
            eventPlayer.current_damage_received *= BERSERKER_DAMAGE_RECEIVED
        if eventPlayer.is_using_ability[Talent.IGNORE_PAIN]:
            eventPlayer.current_damage_received *= IGNORE_PAIN_DAMAGE_RECEIVED / 100
        eventPlayer.setDamageReceived(eventPlayer.current_damage_received)


rule "GENERAL - - - Restore Speed When No Slow Active":
    @Event eachPlayer
    @Condition IS_PLAYER(eventPlayer)
    @Condition eventPlayer.is_using_ability[Talent.BANDAGE] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.is_using_hearthstone == false
    @Condition eventPlayer.is_using_ability[Talent.IMMUNITY] == false
    @Condition eventPlayer.is_charging_railgun == false
    @Condition eventPlayer.stats[Stat.SPEED] != GIGACHAD_MOVE_SPEED

    recalculate_player_speed()


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
    @Condition not eventPlayer.isDummy()

    chase(eventPlayer.dpstracking_time, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    hudText(eventPlayer, eventPlayer.dpstracking_damage, "Total Damage", null, HudPosition.RIGHT, 107, Color.YELLOW, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(eventPlayer, eventPlayer.dpstracking_damage / (dpstracking_dpsTime - eventPlayer.dpstracking_time), "DPS", null, HudPosition.RIGHT, 108, Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(eventPlayer, eventPlayer.dpstracking_time, "Time", null, HudPosition.RIGHT, 109, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "dpstracking - dealt damage":
    @Event playerDealtDamage
    @Condition not eventPlayer.isDummy()
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
    @Condition not eventPlayer.isDummy()
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
