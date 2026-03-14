#!define TOP_RIGHT_TEXT "Soldier: X [v3.2.1] - Made By Psyrius#21775 - Workshop Code: ZEKK3", "[Discord In Description]"
#!define GAME_MODE_DESCRIPTION "● Made by Psyrius\n● Code: ZEKK3\n● v3.2.1\n● RPG, Level up, Buy talents, FFA, Deathmatch\n● Developed since 2020\n● Discord: discord.gg/3MBymdF"
#!define GAME_MODE_NAME "SOLDIER: X [v3.2.1]"

#!setupTags
#!include "declarations.opy"
#!include "shop.opy"
#!include "debug - release.opy"
#!include "debug - development.opy"
#!include "settings.opy"
#!include "bots.opy"
#!include "bots - pathfinding.opy"
#!include "xp.opy"
#!include "talents.opy"

rule "Player Left Match":
    @Event playerLeft
    @Condition (not eventPlayer.isDummy()) == true

    if init_owner in getAllPlayers() == false:
        init_owner = null
        init_locked = false

rule "GENERAL - - - Global Variables":
    #disableInspector()

    /*
    highest_grim_reaper_rank_in_match = 0
    */

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
    #Hearthstone or Grim Reaper
    progressBarHud(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.is_using_vote_yes or localPlayer.is_using_vote_no or (localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success) else null, localPlayer.casting_timer / (2.75 if (localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.is_using_vote_yes or localPlayer.is_using_vote_no) and not faster_testing else GRIM_REAPER_CAST_TIME_LOCAL if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else 0.5 if localPlayer.is_using_hearthstone and faster_testing else 0) * 100, "{0} Casting Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.is_using_hearthstone and not localPlayer.browsing_shop else "{0} Casting Grim Reaper".format('<tx0C0000000004F741>') if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop and localPlayer.isHoldingButton(Button.RELOAD) else "", HudPosition.TOP, 2, Color.GREEN if localPlayer.is_using_hearthstone else Color.RED if localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.casting_success else Color.WHITE, Color.WHITE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.NEVER)

rule "GENERAL - - - [EACH PLAYER] INIT":
    @Event eachPlayer

    #"Wait for our turn (one player initializes at a time)"
    waitUntil(init_locked == false, 99999)
    init_locked = true
    init_owner = eventPlayer

    # INIT FOR PLAYERS (NOT BOTS)
    if not eventPlayer.isDummy():
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
        chase(eventPlayer.rockets_cooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        #[HUD Text for talent slot 1]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 1 else null, "{0}".format(talent_names[eventPlayer.bought_talents[0]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[0]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.ACTUALLY_LEFT, 0, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[0]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 2]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 2 else null, "{0}".format(talent_names[eventPlayer.bought_talents[1]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[1]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.ACTUALLY_LEFT, 1, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[1]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 3]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 3 else null, "{0}".format(talent_names[eventPlayer.bought_talents[2]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[2]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.ACTUALLY_LEFT, 2, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[2]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 4]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 4 else null, "{0}".format(talent_names[eventPlayer.bought_talents[3]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[3]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.ACTUALLY_LEFT, 3, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[3]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        #[HUD Text for talent slot 5]
        hudText(eventPlayer if len(eventPlayer.bought_talents) >= 5 else null, "{0}".format(talent_names[eventPlayer.bought_talents[4]]), "Cooldown: {0}".format(eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] - eventPlayer.totalTimeElapsed) if eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] > eventPlayer.totalTimeElapsed else "", "{0}".format(talent_keybinds[eventPlayer.bought_talents[4]].replace("[F]", buttonString(Button.INTERACT)).replace("[R]", buttonString(Button.RELOAD)).replace("[E]", buttonString(Button.ABILITY_2)).replace("[Q]", buttonString(Button.ULTIMATE)).replace("[SHIFT]", buttonString(Button.ABILITY_1)).replace("[CTRL]", buttonString(Button.CROUCH)).replace("[SPACEBAR]", buttonString(Button.JUMP)).replace("[LEFTCLICK]", buttonString(Button.PRIMARY_FIRE)).replace("[RIGHTCLICK]", buttonString(Button.SECONDARY_FIRE)).replace("[MELEE]", buttonString(Button.MELEE))), HudPosition.ACTUALLY_LEFT, 4, talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], talent_rarity_colors[eventPlayer.talent_ranks[eventPlayer.bought_talents[4]]], Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
        eventPlayer.setAbility2Enabled(false)
        eventPlayer.setUltEnabled(false)

        

        #createProgressBarInWorldText(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.using_one_of_the_hearthstones else null, localPlayer.using_hearthstone_timer / 2.75 * 100 if faster_testing == false else 50, "{0} Using Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.browsing_shop == false else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} Skipping Bonus Talent".format(iconString(Icon.TRASHCAN)) if localPlayer.amount_of_bonus_talents > 0 and localPlayer.isHoldingButton(Button.RELOAD) else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.RELOAD) else "", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.55 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))) if localPlayer.browsing_shop == false else localPlayer.selected_talent_position + Vector.UP, 1, Clip.NONE, Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        #XP HUD
        progressBarHud(eventPlayer, eventPlayer.experience_current / eventPlayer.experience_max * 100, "Max Level - XP Boost: Active" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current < eventPlayer.experience_max else "You can replace a talent" if eventPlayer.amount_of_talents_purchased == 25 and eventPlayer.experience_current >= eventPlayer.experience_max else "You have a talent point" if eventPlayer.can_enter_shop == true else "You skipped a talent! XP Boost: Active" if eventPlayer.skipped_a_talent == true else "Too far behind! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.xp_boost_is_active == true and eventPlayer.amount_of_talents_purchased > 0 else "First Level! XP Boost: Active" if eventPlayer.can_enter_shop == false and eventPlayer.amount_of_talents_purchased == 0 else "", HudPosition.TOP, 1, Color.ORANGE, Color.ORANGE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
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
        chase(eventPlayer.in_combat, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.totalTimeElapsed = 0
        eventPlayer.exit_shop_with_fireball = false

    # INIT FOR BOTS (NOT PLAYERS)

    if eventPlayer.isDummy():
        #eventPlayer.setMaxHealth(eventPlayer.stats[BotStat.HEALTH])
        eventPlayer.reaper_view_angle = 90
        eventPlayer.reaper_turn_speed = 200
        eventPlayer.stats = [100, 166.666, 75, 0, 0, 1, 1, 0, 100]
        eventPlayer.bot_memory = [null, false, false, false, false]
        eventPlayer.reaper_aggro_list = []
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
        eventPlayer.reaper_has_respawned_once = false
        #eventPlayer.reaper_hello_cooldown = 0
        #chase(eventPlayer.reaper_hello_cooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        #eventPlayer.startHoT(eventPlayer, 9999, 500)
    
    # INIT FOR BOTS AND PLAYERS

    #eventPlayer.hit_by_talent[Talent.POISON_VIALS] = null
    chase(eventPlayer.totalTimeElapsed, 99999, rate=1, ChaseReeval.DESTINATION_AND_RATE)
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
    if damage_text == true:
        createInWorldText(null if localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()] == 0 or localPlayer == eventPlayer else localPlayer, ceil(localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()]), eventPlayer, 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
    wait()
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

    # Grim Reaper Icon
    createInWorldText(players_with_grim_reaper.exclude(eventPlayer)
    if eventPlayer.getHealth() < eventPlayer.getMaxHealth() * GRIM_REAPER_HEALTH_THRESHOLD 
    and not eventPlayer.is_using_ability[Talent.STEALTH] 
    and not eventPlayer.browsing_shop 
    and eventPlayer.isAlive() 
    and localPlayer.grim_reaper_aim_indicator == eventPlayer 
    else null,
    "{0}".format(('<tx00000004F741>')), updateEveryFrame(eventPlayer.getPosition() + Vector.UP if not localPlayer.is_using_ability[Talent.GRIM_REAPER] or not localPlayer.casting_success else localPlayer.grim_reaper_feet_destination + Vector.UP), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.grim_reaper_effect_id4 = getLastCreatedText()
    
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
    hudSubheader(localPlayer if localPlayer.can_enter_shop == true and localPlayer.replacing_talent_show_confirmation == false and localPlayer.replacing_talent_show_bought_talents == false else null, "[Hold: {0} to use Hearthstone]".format(buttonString(Button.RELOAD)) if localPlayer.browsing_shop == false else "[Hold: {0} to skip a talent, exit shop and get a XP boost]".format(buttonString(Button.RELOAD)) if localPlayer.browsing_shop == true else "", HudPosition.TOP, 2, Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)

def create_talent_helpers():
    @Name "GENERAL - - - [SUBROUTINE] Create Cooldown Ready Icons"
    
    #Health Potions or Poison Vials
    createInWorldText(localPlayer if ((localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or localPlayer.talent_ranks[Talent.POISON_VIALS] > 0) and localPlayer.browsing_shop == false) and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false else null, "{0}   {1}   {2}".format(abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_health_potions >= 1 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 1 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_health_potions >= 2 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 2 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else "", abilityIconString(Hero.ROADHOG, Button.ABILITY_2) if localPlayer.amount_of_health_potions == 3 and localPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 else iconString(Icon.POISON_2) if localPlayer.amount_of_health_potions >= 3 and localPlayer.talent_ranks[Talent.POISON_VIALS] > 0 else ""), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    #Purity Field, Bandage, Jetpack, Dive Bomb
    createProgressBarInWorldText(localPlayer if localPlayer.isAlive() and localPlayer.browsing_shop == false and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false and localPlayer.is_using_ability[Talent.GRIM_REAPER] == false and (localPlayer.is_using_ability[Talent.DIVE_BOMB] == true or localPlayer.purity_field_duration > 0 or localPlayer.bandage_progress > 0 or localPlayer.jetpack_fuel < 100) else null, ((localPlayer.dive_bomb_damage - DIVE_BOMB_DAMAGE_LOCAL) / DIVE_BOMB_DAMAGE_LOCAL) * 100 if localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else localPlayer.purity_field_duration if localPlayer.is_using_ability[Talent.PURITY_FIELD] == true else localPlayer.bandage_progress * 100 / 10 if localPlayer.is_using_ability[Talent.BANDAGE] == true else localPlayer.jetpack_fuel, "{0} DAMAGE: {1}".format(abilityIconString(Hero.HAMMOND, Button.CROUCH), localPlayer.dive_bomb_damage) if localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else "{0} PURITY FIELD".format(abilityIconString(Hero.BAPTISTE, Button.ABILITY_2)) if localPlayer.is_using_ability[Talent.PURITY_FIELD] else "{0} BANDAGING".format(abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE)) if localPlayer.is_using_ability[Talent.BANDAGE] else "{0} THRUST".format(abilityIconString(Hero.DVA, Button.ABILITY_1)), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.625 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.WHITE if localPlayer.is_using_ability[Talent.BANDAGE] == true or localPlayer.is_using_ability[Talent.DIVE_BOMB] == true else Color.RED if localPlayer.jetpack_fuel < 33 else Color.ORANGE if localPlayer.jetpack_fuel < 66 else Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
    #Entering Stealth
    createProgressBarInWorldText(localPlayer if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.browsing_shop == false and (localPlayer.entering_stealth == true or localPlayer.is_using_ability[Talent.STEALTH] == true) else null, localPlayer.entering_stealth_timer * 100, "Entering Stealth" if localPlayer.is_using_ability[Talent.STEALTH] == false else "Stealthed", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.75 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))), 0.75, Clip.NONE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, Color.VIOLET if localPlayer.is_using_ability[Talent.STEALTH] == true else Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #Talent Cooldown Icons
    createInWorldText(localPlayer if localPlayer.browsing_shop == false and localPlayer.getCurrentHero() == Hero.SOLDIER and not localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.is_using_hearthstone else null, "{0}{1}{2}".format(abilityIconString(Hero.REAPER, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.STEALTH] > 0 and localPlayer.is_using_ability[Talent.STEALTH] == false and localPlayer.talent_trigger_times[Talent.STEALTH] + talent_base_cooldowns[Talent.STEALTH] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.REINHARDT, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.JUGGERNAUT] > 0 and localPlayer.talent_trigger_times[Talent.JUGGERNAUT] + talent_base_cooldowns[Talent.JUGGERNAUT] <= localPlayer.totalTimeElapsed else "", "{0}{1}{2}".format(abilityIconString(Hero.HAMMOND, Button.CROUCH) if localPlayer.talent_ranks[Talent.DIVE_BOMB] > 0 and localPlayer.talent_trigger_times[Talent.DIVE_BOMB] + talent_base_cooldowns[Talent.DIVE_BOMB] <= localPlayer.totalTimeElapsed else "", /*abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE) if localPlayer.talent_ranks[Talent.BLOODTHIRST] > 100 and localPlayer.talent_trigger_times[Talent.GRIM_REAPER] + talent_base_cooldowns[Talent.GRIM_REAPER] <= localPlayer.totalTimeElapsed else */"", "{0}{1}{2}".format(iconString(Icon.SKULL) if localPlayer.talent_ranks[Talent.BERSERKER] > 0 and localPlayer.talent_trigger_times[Talent.BERSERKER] + talent_base_cooldowns[Talent.BERSERKER] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.PHARAH, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.FIREBALL] > 0 and localPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= localPlayer.totalTimeElapsed else "", "{0}{1}{2}".format(abilityIconString(Hero.MOIRA, Button.ABILITY_1) if localPlayer.talent_ranks[Talent.SHADOWSTEP] > 0 and localPlayer.talent_trigger_times[Talent.SHADOWSTEP] + talent_base_cooldowns[Talent.SHADOWSTEP] - localPlayer.talent_ranks[Talent.SHADOWSTEP] * SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK <= localPlayer.totalTimeElapsed else "", "", "{0}{1}".format(abilityIconString(Hero.BAPTISTE, Button.ABILITY_2) if localPlayer.talent_ranks[Talent.PURITY_FIELD] > 0 and localPlayer.talent_trigger_times[Talent.PURITY_FIELD] + talent_base_cooldowns[Talent.PURITY_FIELD] <= localPlayer.totalTimeElapsed else "", abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE) if localPlayer.talent_ranks[Talent.BANDAGE] > 0 and localPlayer.talent_trigger_times[Talent.BANDAGE] + talent_base_cooldowns[Talent.BANDAGE] <= localPlayer.totalTimeElapsed else ""))))), updateEveryTick(localPlayer.getEyePosition() + (100 * (0.5 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.2 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    #Hearthstone
    #createProgressBarInWorldText(localPlayer if localPlayer.is_using_hearthstone or localPlayer.is_using_skip_talent or localPlayer.using_one_of_the_hearthstones else null, localPlayer.using_hearthstone_timer / 2.75 * 100 if faster_testing == false else 50, "{0} Using Hearthstone".format(iconString(Icon.SPIRAL)) if localPlayer.browsing_shop == false else "{0} YES".format(iconString(Icon.CHECKMARK)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.PRIMARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} NO".format(iconString(Icon.NO)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.SECONDARY_FIRE) and localPlayer.replacing_talent_show_confirmation == true else "{0} Skipping Bonus Talent".format(iconString(Icon.TRASHCAN)) if localPlayer.amount_of_bonus_talents > 0 and localPlayer.isHoldingButton(Button.RELOAD) else "{0} Skipping Talents For XP Boost".format(iconString(Icon.TRASHCAN)) if localPlayer.browsing_shop == true and localPlayer.isHoldingButton(Button.RELOAD) else "", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.55 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90)) + 3 * localPlayer.getFacingDirection()))) if localPlayer.browsing_shop == false else localPlayer.selected_talent_position + Vector.UP, 1, Clip.NONE, Color.WHITE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    #What button to press in Stealth or Berserker or Bandage
    createInWorldText(localPlayer if ((
        localPlayer.talent_ranks[Talent.STEALTH] > 0
        or localPlayer.talent_ranks[Talent.BERSERKER] > 0
        or localPlayer.talent_ranks[Talent.BANDAGE] > 0
        /*or localPlayer.talent_ranks[Talent.GRIM_REAPER] > 0*/)
        and localPlayer.browsing_shop == false)
        and localPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    else null, "{0}".format(
    "{0} {1} = Cancel".format(iconString(Icon.SKULL), buttonString(Button.ULTIMATE))
        if localPlayer.is_using_ability[Talent.BERSERKER] == true
    else "{0} {1} = Cancel".format(abilityIconString(Hero.KIRIKO, Button.PRIMARY_FIRE), buttonString(Button.MELEE))
        if localPlayer.is_using_ability[Talent.BANDAGE] == true
    /*else "{0} {1} = Cancel".format('<tx0C0000000004F741>', buttonString(Button.INTERACT))
        if localPlayer.is_using_ability[Talent.GRIM_REAPER] == true and localPlayer.casting_success == false*/
    else ""), 
    updateEveryTick(localPlayer.getEyePosition() + (100 * (1.625 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.2 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1.25, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
    
    #Railgun Cooldown / Charge
    createInWorldText(localPlayer if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and "{0}".format(localPlayer.isCommunicatingEmote()) == "0" and localPlayer.browsing_shop == false and not localPlayer.is_using_ability[Talent.GRIM_REAPER] and not localPlayer.is_using_hearthstone else null, "{0} {1}%".format(iconString(Icon.BOLT), ceil(localPlayer.railgun_charge)) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge > 0 else ("{0} Ready".format(iconString(Icon.BOLT))) if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= localPlayer.totalTimeElapsed else "{0} Cooldown: {1}".format(iconString(Icon.BOLT), localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] - localPlayer.totalTimeElapsed if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge == 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > localPlayer.totalTimeElapsed else 0), updateEveryTick(localPlayer.getEyePosition() + (100 * (worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + (-0.3 * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.railgun_charge < 100 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= localPlayer.totalTimeElapsed else Color.SKY_BLUE if localPlayer.railgun_charge >= 100 else Color.GRAY if localPlayer.talent_ranks[Talent.RAILGUN] > 0 and localPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] > localPlayer.totalTimeElapsed or localPlayer.rockets_cooldown > 0 and localPlayer.talent_ranks[Talent.RAILGUN] == 0 else Color.WHITE, SpecVisibility.NEVER)
    /*
    #Cancel Juggernaut
    createInWorldText(localPlayer if localPlayer.is_using_ability[Talent.JUGGERNAUT] == true and localPlayer.has_hit_the_ground == true else null, "{0} {1} = Cancel".format(abilityIconString(Hero.REINHARDT, Button.ABILITY_1), buttonString(Button.INTERACT)), updateEveryTick(localPlayer.getEyePosition()), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE, SpecVisibility.NEVER)
    */

rule "GENERAL - - - [EACH PLAYER] Has Spawned":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_respawning == true
    
    eventPlayer.is_respawning = false
    if map_is_changing == false:
        setMatchTime(3599)
    #eventPlayer.xp_orb_position_on_player = false
    if not eventPlayer.isDummy():
        if eventPlayer.xp_boost_is_active == false and ((eventPlayer.amount_of_talents_purchased == 0 or eventPlayer.amount_of_talents_purchased == 25) or eventPlayer.skipped_a_talent == true or (eventPlayer.amount_of_talents_purchased > 0 and eventPlayer.amount_of_talents_purchased <= (player_with_most_talents.amount_of_talents_purchased - 5))):
            async(activate_xp_boost, AsyncBehavior.RESTART)
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
    eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
    #wait is needed to see if max health is upgraded first
    wait()
    heal(eventPlayer, null, eventPlayer.getMaxHealth())

rule "GENERAL - - - Player Died":
    @Event playerDied
    @Condition (not eventPlayer.isDummy() or (eventPlayer.isDummy() and eventPlayer.reaper_has_respawned_once == true)) == true

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
    
    if not eventPlayer.isDummy():
        /*
        if attacker.getCurrentHero() == Hero.REAPER:
            attacker.random_integer_between_0_to_5 = random.randint(0, 9)
            if attacker.random_integer_between_0_to_5 <= 1 and attacker.reaper_hello_cooldown == 0:
                attacker.communicate(Comms.SORRY)
                attacker.reaper_hello_cooldown = 10
                */
        eventPlayer.in_combat = 0
        if eventPlayer.xp_boost_is_active == true:
            stopChasingVariable(eventPlayer.experience_current)
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
            
        
        /*
        if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0:
            eventPlayer.burning_soul_orb_timer = 4
            wait()
            async(dropped_burning_soul_orb, AsyncBehavior.RESTART)
            xp_orb_mines[eventPlayer.getSlot()] = eventPlayer
        */

        /*
        createEffect(getAllPlayers().exclude(eventPlayer) if eventPlayer.dropped_xp_orb == true else null, Effect.ORB, orb_rarity_colors[round(eventPlayer.amount_of_talents_purchased / 5.56)], updateEveryTick(eventPlayer.getPosition() + Vector.UP * 0.25) if eventPlayer.xp_orb_position_on_player == true else updateEveryTick(eventPlayer.xp_orb_location), 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

        eventPlayer.player_temp_effects[42] = getLastCreatedEntity()
        */
        eventPlayer.is_respawning = true
        if attacker == victim:
            eventPlayer.addToScore(1)
        /*
        waitUntil(eventPlayer.isInAir(), 0.25)
        waitUntil(eventPlayer.isOnGround(), 2.75)
        eventPlayer.xp_orb_location = eventPlayer.getPosition() + Vector.UP * 0.25
        if eventPlayer.isOnGround():
            return
        eventPlayer.xp_orb_destination = eventPlayer.xp_orb_location + Vector.DOWN * 100
        chase(eventPlayer.xp_orb_location, raycast(eventPlayer.xp_orb_location, eventPlayer.xp_orb_destination, null, getAllPlayers(), true).getHitPosition() + Vector.UP * 0.25, rate=9.8, ChaseReeval.DESTINATION_AND_RATE)
        */


rule "GENERAL - - - Player Dealt Damage":
    @Event playerDealtDamage
    @Hero soldier

    if eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0 and eventPlayer.is_using_ability[Talent.BERSERKER] == true:
        eventPlayer.bloodthirst_remaining_heal_amount += BLOODTHIRST_DAMAGE_TO_HEALING_AMOUNT
    if attacker.is_using_ability[Talent.PURITY_FIELD] == false and attacker != victim:
        attacker.using_hearthstone_timer = 0
        attacker.in_combat = 3
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
        if victim.is_using_ability[Talent.PURITY_FIELD] == false and attacker.is_using_ability[Talent.STEALTH] == true and eventAbility != null:
            #victim.hit_by_talent[Talent.STEALTH] = attacker
            victim.setStatusEffect(attacker, Status.KNOCKED_DOWN, STEALTH_STUN_DURATION)

        #Dealt Poisonous Dagger damage?    
        if victim.is_using_ability[Talent.PURITY_FIELD] == false and attacker.is_using_ability[Talent.STEALTH] == true and attacker.talent_ranks[Talent.POISONOUS_DAGGER] > 0 and attacker.talent_trigger_times[Talent.POISONOUS_DAGGER] + talent_base_cooldowns[Talent.POISONOUS_DAGGER] <= attacker.totalTimeElapsed:

            victim.poisonous_dagger_attackers.append(attacker)
            victim.poisonous_dagger_timestamp.append(victim.totalTimeElapsed)
            #victim.remaining_poisonous_dagger_duration = POISONOUS_DAGGER_DURATION
            attacker.talent_trigger_times[Talent.POISONOUS_DAGGER] = attacker.totalTimeElapsed

        if attacker.talent_ranks[Talent.STEALTH] > 0 and attacker.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
            
    #PRIMARY FIRE || ULTIMATE
    elif eventAbility == Button.PRIMARY_FIRE or eventAbility == Button.ULTIMATE:
        #Victim = Gigachad?
        /*
        if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
            heal(victim, victim, min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL)))
            victim.gigachad_damage_resisted += min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
        */
        #Gunslinger?
        /*
        if attacker.talent_ranks[Talent.GUNSLINGER] > 0 and attacker.railgun_charge < 100:
            damage(victim, attacker, GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit else GUNSLINGER_ADDITIONAL_DAMAGE)
            if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
                victim.gigachad_damage_resisted += min(GUNSLINGER_ADDITIONAL_DAMAGE * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
        */
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
            heal(attacker, attacker, min(LIFESTEAL_RAILGUN_HEAL if eventPlayer.railgun_charge >= 100 else LIFESTEAL_HEAL, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
            eventPlayer.is_lifestealing = 1.5
            lifesteal_hps()
    #SECONDARY FIRE
    elif eventAbility == Button.SECONDARY_FIRE:
        #if attacker.talent_ranks[Talent.BOMBARDMENT] > 0:
            #damage(victim, attacker, BOMBARDMENT_DAMAGE)
        if attacker.using_cryogenics == true and victim.is_using_ability[Talent.JUGGERNAUT] == false and victim.is_using_ability[Talent.PURITY_FIELD] == false and victim.  is_using_ability[Talent.SHADOWSTEP] == false:
            victim.hit_by_talent[Talent.CRYOGENICS] = attacker
            attacker.talent_trigger_times[Talent.CRYOGENICS] = attacker.totalTimeElapsed - attacker.cryogenics_travel_time
        if attacker.talent_ranks[Talent.IGNITE] > 0 and victim.is_using_ability[Talent.PURITY_FIELD] == false:
            victim.setStatusEffect(attacker, Status.BURNING, 3)
            victim.startDoT(attacker, 3, /*IGNITE_BOMBARDMENT_DAMAGE_PER_SECOND if attacker.talent_ranks[Talent.BOMBARDMENT] > 0 else */ IGNITE_DAMAGE_PER_SECOND)
        if attacker.talent_ranks[Talent.LIFESTEAL_AMMO] > 0:
            heal(attacker, attacker, min(LIFESTEAL_HEAL, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
            eventPlayer.is_lifestealing = 1.5
            playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.TEAM_1, attacker.getPosition(), 100)
            lifesteal_hps()
        if attacker.talent_ranks[Talent.IGNITE] > 0 and attacker.is_using_ability[Talent.IGNITE] == true:
            attacker.is_using_ability[Talent.IGNITE] = false

rule "GENERAL - - - Player Took Damage":
    @Event playerTookDamage
    @Hero soldier

    #if victim.cybernetics_shields > 0:
        #stopChasingVariable(victim.cybernetics_shields)
        #victim.cybernetics_shields -= min(eventDamage, victim.cybernetics_shields)
    if eventAbility == Button.PRIMARY_FIRE or eventAbility == Button.ULTIMATE:
        if victim.talent_ranks[Talent.GIGACHAD] > 0 and eventWasCriticalHit:
            heal(victim, victim, min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL)))
            victim.gigachad_damage_resisted += min(eventDamage * GIGACHAD_RESIST_NORMALIZED_VICTIM, victim.getMaxHealthOfType(Health.NORMAL) - victim.getHealthOfType(Health.NORMAL))
    if victim.is_using_ability[Talent.BLOODTHIRST] == true and victim.bloodthirst_remaining_heal_amount >= 1:
        victim.bloodthirst_remaining_heal_amount -= eventDamage
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
    if victim.is_using_ability[Talent.IGNORE_PAIN] == true and victim.is_using_ability[Talent.PURITY_FIELD] == false:
        eventPlayer.ignore_pain_damage_resisted[0] += eventDamage

rule "GENERAL - - - Player Slowed (Hit by Cryogenics Talent)":
    @Event eachPlayer
    @Condition eventPlayer.cryogenics_slow_amount < eventPlayer.stats[Stat.SPEED]
    @Condition eventPlayer.refresh_cryogenics_slow == true
    
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.refresh_cryogenics_slow = false
    eventPlayer.setAbility1Enabled(false)
    chase(eventPlayer.cryogenics_slow_amount, eventPlayer.stats[Stat.SPEED], duration=eventPlayer.cryogenics_slow_duration, ChaseReeval.DESTINATION_AND_DURATION)
    while eventPlayer.isAlive() and eventPlayer.cryogenics_slow_amount != eventPlayer.stats[Stat.SPEED] and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false and eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false:
        eventPlayer.setMoveSpeed(eventPlayer.cryogenics_slow_amount * eventPlayer.adrenaline_rush_value / 100)
        wait(0.032, Wait.RESTART_WHEN_TRUE)
    stopChasingVariable(eventPlayer.cryogenics_slow_amount)
    eventPlayer.cryogenics_slow_amount = eventPlayer.stats[Stat.SPEED]
    if eventPlayer.is_using_ability[Talent.BANDAGE] == true or eventPlayer.is_charging_railgun == true or eventPlayer.is_using_hearthstone == true or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        async(player_slowed, AsyncBehavior.RESTART)
    else:
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)
    #if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] == 0:
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.cryogenics_slow_duration = 0

/*
def dropped_xp_orb():
    @Name "GENERAL - - - Dropped XP Orb"
    
    
    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0:

        createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

        eventPlayer.player_temp_effects[77] = getLastCreatedEntity()
    */
    /*
    while eventPlayer.dropped_xp_orb == true:
        #If there are other players near your XP Orb
        if (len([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer])) > 0:
            #Wait until the player near your XP Orb is not picking up another XP Orb
            waitUntil(((((sorted([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer], lambda i: distance(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, i.getPosition())))[0]).variable)[20]) == null, 99999)
            #Set the nearest player to having picked up your XP Orb
            (((sorted([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 2, Team.ALL, LosCheck.OFF)) if player.getCurrentHero() == Hero.SOLDIER and player != eventPlayer], lambda i: distance(eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, i.getPosition())))[0]).variable)[20] = eventPlayer
        if eventPlayer.burning_soul_orb_timer > 0:
            playEffect(getAllPlayers().exclude(eventPlayer), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.TEAM_1, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 1)
        wait(0.25)
        destroyEffect(eventPlayer.player_temp_effects[77])*/

        /*
rule "GENERAL - - - Picked Up XP Orb":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.owner_of_picked_up_xp_orb != null
    
    if eventPlayer.experience_current < eventPlayer.experience_max:
        smallMessage(eventPlayer, "{0} +{1} XP!".format(abilityIconString(Hero.GENJI, Button.JUMP), round(eventPlayer.owner_of_picked_up_xp_orb.experience_max * 0.2 * eventPlayer.stats[Stat.XP])))
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 75)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, orb_rarity_colors[round(eventPlayer.owner_of_picked_up_xp_orb.amount_of_talents_purchased / 5.56)], eventPlayer.getPosition(), 1)
    #EXPERIENCE
    if eventPlayer.experience_current < eventPlayer.experience_max:
        eventPlayer.experience_current += eventPlayer.owner_of_picked_up_xp_orb.experience_max * 0.2 * eventPlayer.stats[Stat.XP]
    #MINE?
    if eventPlayer.owner_of_picked_up_xp_orb.talent_ranks[Talent.BURNING_SOUL] > 0 and eventPlayer.owner_of_picked_up_xp_orb.burning_soul_orb_timer > 0:
        eventPlayer.owner_of_picked_up_xp_orb.burning_soul_orb_timer = 0
    eventPlayer.owner_of_picked_up_xp_orb.dropped_xp_orb = false
    wait()
    eventPlayer.owner_of_picked_up_xp_orb = null
    
    if eventPlayer.talent_ranks[Talent.ALCHEMIST] > 0 and eventPlayer.amount_of_health_potions < 3 and ALCHEMIST_PROC_CHANCE:
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
    */
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

def player_slowed():
    @Name "Subroutine: Player Slowed"
    
    #using bandage, hearthstone, grim reaper or purity field
    if eventPlayer.is_using_ability[Talent.BANDAGE] == true or eventPlayer.is_using_ability[Talent.GRIM_REAPER] == true or eventPlayer.is_using_hearthstone == true or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.stats[Stat.SPEED] = 25
        #if player is not affected by cryogenics
        if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
            eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)
        waitUntil(eventPlayer.is_using_ability[Talent.BANDAGE] == false and eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false and eventPlayer.is_using_hearthstone == false and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false, 99999)
    #railgun
    if eventPlayer.is_charging_railgun == true:
        eventPlayer.stats[Stat.SPEED] = 50
        #if player is not affected by cryogenics
        if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
            eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)
        waitUntil(eventPlayer.is_charging_railgun == false, 99999)
    if eventPlayer.is_using_ability[Talent.BANDAGE] == false and eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false and eventPlayer.is_using_hearthstone == false and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false:
        eventPlayer.stats[Stat.SPEED] = 100
        if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == null:
            eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)
        

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

rule "GENERAL - - - Update Damage Text":
    @Event playerTookDamage
    @Hero soldier
    @Condition damage_text == true

    attacker.recentDamageDealtToSlot[victim.getSlot()] += eventDamage
    wait(1.5, Wait.RESTART_WHEN_TRUE)
    attacker.recentDamageDealtToSlot[victim.getSlot()] = 0

    #if damage_text == true:
        #async(update_damage_text, AsyncBehavior.RESTART)

#def update_damage_text():
    #attacker.recentDamageDealtToSlot[victim.getSlot()] += eventDamage
    #wait(1.5, Wait.RESTART_WHEN_TRUE)
    #attacker.recentDamageDealtToSlot[victim.getSlot()] = 0
