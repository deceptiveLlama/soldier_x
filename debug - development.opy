#!mainFile "soldier_x.opy"

#--- Debug global defineMember (global_variable[106-107]) ---
#!defineMember debug_selected_bot global_variable[106]
#!defineMember debug_selected_player global_variable[107]

#--- Workshop Settings (only active when this file is included) ---
rule "DEBUG - - - Init Workshop Settings":
    debug_spectator_tools = createWorkshopSettingBool("00. Debug", "Spectator Tools (bot selector, asserts, etc.)", false, 0)

#--- Bot state text above each bot (debug only) ---
rule "DEBUG - - - Bot State Text":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true

    createInWorldText(getAllPlayers() if debug_spectator_tools else null, ">> Bot{0} {1} <<".format(eventPlayer.getSlot(), eventPlayer.debug_bot_state) if eventPlayer == debug_selected_player else "Bot{0} {1}".format(eventPlayer.getSlot(), eventPlayer.debug_bot_state), updateEveryTick(eventPlayer.getPosition() + vect(0, 2.5, 0)), 1 if eventPlayer == debug_selected_player else 0.75, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.YELLOW if pathfinder_owner != null and pathfinder_owner != eventPlayer and eventPlayer.bot_state_id == BotState.NAVIGATE and eventPlayer.bot_throttle_paused else Color.LIME_GREEN if len(eventPlayer.pathfinder_path) > 1 and eventPlayer.bot_state_id == BotState.IDLE else Color.WHITE, SpecVisibility.DEFAULT)

#--- PF Budget HUD (moved from bots) ---
rule "DEBUG - - - PF Budget HUD":
    @Condition debug_spectator_tools == true
    @Condition map_ready == true

    hudText(getAllPlayers(), null, "Pathfinding: Budget {0} | Owner: {1}".format(pathfinder_budget, pathfinder_owner.getSlot() if pathfinder_owner != null else -1), null, HudPosition.ACTUALLY_LEFT, 1, Color.WHITE, Color.ORANGE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#--- Reactive assert: Bot Stuck ---
rule "DEBUG - - - Assert: Bot Stuck":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.debug_bot_stuck == true

    hudText(getAllPlayers(), null, evalOnce("[{0}] Bot{1} STUCK pos={2} src={3} dest={4}".format(round(getTotalTimeElapsed()), eventPlayer.getSlot(), eventPlayer.getPosition(), eventPlayer.pathfinder_source, eventPlayer.pathfinder_destination)), null, HudPosition.ACTUALLY_LEFT, 2, Color.WHITE, Color.ORANGE, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    debug_texts.append(getLastCreatedText())

#--- Reactive assert: No Path Found ---
rule "DEBUG - - - Assert: No Path":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.debug_no_path_found == true

    hudText(getAllPlayers(), null, evalOnce("[{0}] Bot{1} NO PATH src={2} dest={3}".format(round(getTotalTimeElapsed()), eventPlayer.getSlot(), eventPlayer.pathfinder_source, eventPlayer.pathfinder_destination)), null, HudPosition.ACTUALLY_LEFT, 2, Color.WHITE, Color.ORANGE, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    debug_texts.append(getLastCreatedText())
    eventPlayer.debug_no_path_found = false

#--- Reactive assert: A* Timeout ---
rule "DEBUG - - - Assert: A* Timeout":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.debug_astar_timed_out == true

    hudText(getAllPlayers(), null, evalOnce("[{0}] Bot{1} A* TIMEOUT src={2} dest={3}".format(round(getTotalTimeElapsed()), eventPlayer.getSlot(), eventPlayer.pathfinder_source, eventPlayer.pathfinder_destination)), null, HudPosition.ACTUALLY_LEFT, 2, Color.WHITE, Color.ORANGE, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    debug_texts.append(getLastCreatedText())
    eventPlayer.debug_astar_timed_out = false

#--- Reactive assert: First Walk Fail (white, user-owned) ---
rule "DEBUG - - - Assert: First Walk Fail":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer.isDummy() == true
    @Condition debug_bot_walk_fail_pos != 0

    hudText(hostPlayer if hostPlayer.getCurrentHero() != Hero.SOLDIER else null, null, evalOnce("[{0}] FIRST WALK FAIL pos={1}".format(round(getTotalTimeElapsed()), debug_bot_walk_fail_pos)), null, HudPosition.ACTUALLY_LEFT, 2, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    debug_texts.append(getLastCreatedText())
    waitUntil(debug_bot_walk_fail_pos == 0, 99999)
/*
rule "Test":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() 
    
    print(eventPlayer.getAltitude())


globalvar server_load_sample_duration = 0


rule "DEBUG - - - [SERVER LOAD]: Bots joining":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
*/
/*
    destroyAllDummies()
    server_load_sample_duration = 6
    server_load_samples = 0
    server_load_avg = 0
    server_load_peak = 0
    chaseAtRate(server_load_sample_duration, 0, 1)
    while server_load_sample_duration > 0:
        server_load_samples = server_load_samples + 1
        server_load_avg = server_load_avg + getServerLoad()
        server_load_peak = getPeakServerLoad() if getPeakServerLoad() > server_load_peak else server_load_peak
        wait()
    stopChasingVariable(server_load_sample_duration)
    */
/*
rule "DEBUG - - - [SERVER LOAD] HUD TEXT":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition hostPlayer == eventPlayer
    
    hudText(eventPlayer, "Avg: {0} Peak: {1}".format(server_load_avg / server_load_samples, server_load_peak), "Avg: {0} Peak: {1}".format(getAverageServerLoad(), getPeakServerLoad()), null, HudPosition.RIGHT, 100, Color.WHITE,Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
*/
/*
rule "DEBUG - - - Host HUD Texts [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition hostPlayer == eventPlayer
    @Condition eventPlayer.player_name == "Psyrius"

    hudText(hostPlayer, null, null, ("DPS:"), HudPosition.RIGHT, 106, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudText(hostPlayer, "Lifesteal Ammo:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(lifesteal_total_healing[1] / lifesteal_time_in_combat[1], lifesteal_total_healing[2] / lifesteal_time_in_combat[2], lifesteal_total_healing[3] / lifesteal_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(lifesteal_total_healing[4] / lifesteal_time_in_combat[4], lifesteal_total_healing[5] / lifesteal_time_in_combat[5])), null, HudPosition.LEFT, 100, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Health Regen:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(health_regen_total_healing[1] / health_regen_time_in_combat[1], health_regen_total_healing[2] / health_regen_time_in_combat[2], health_regen_total_healing[3] / health_regen_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(health_regen_total_healing[4] / health_regen_time_in_combat[4], health_regen_total_healing[5] / health_regen_time_in_combat[5])), null, HudPosition.LEFT, 101, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Health Potions:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(health_potions_total_healing[1] / health_potions_time_in_combat[1], health_potions_total_healing[2] / health_potions_time_in_combat[2], health_potions_total_healing[3] / health_potions_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(health_potions_total_healing[4] / health_potions_time_in_combat[4], health_potions_total_healing[5] / health_potions_time_in_combat[5])), null, HudPosition.LEFT, 102, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Ignore Pain:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(ignore_pain_total_resisted[1] / ignore_pain_time_in_combat[1], ignore_pain_total_resisted[2] / ignore_pain_time_in_combat[2], ignore_pain_total_resisted[3] / ignore_pain_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(ignore_pain_total_resisted[4] / ignore_pain_time_in_combat[4], ignore_pain_total_resisted[5] / ignore_pain_time_in_combat[5])), null, HudPosition.LEFT, 103, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/
/*

*/

/*
rule "DEBUG - - - Hold Crouch + Jump to take Damage [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.browsing_shop == false
        damage(eventPlayer, eventPlayer, 100)
        wait(1, Wait.IGNORE_CONDITION)
*/

/*
def lifesteal_hps():
    @Name "DEBUG - - - [Talent: Lifesteal] Healing Done In Combat [DEFAULT: OFF]"
    
    eventPlayer.healing_done_in_combat[12] += LIFESTEAL_HEAL
*/

/*
def health_potion_hps():
    @Name "DEBUG - - - [Talent: Health Potions] Healing Done In Combat [DEFAULT: OFF]"
    
    eventPlayer.healing_done_in_combat[14] += 43.75 + eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] * 17.5
*/

/*
def ignore_pain_hps():
    @Name "DEBUG - - - [Talent: Ignore Pain] Healing Done In Combat [DEFAULT: OFF]"
    
    eventPlayer.healing_done_in_combat[22] += eventPlayer.ignore_pain_damage_resisted[1]
*/

rule "DEBUG - - - Activate Slow Motion With Melee & Cancel Slow Motion With Interact [DEFAULT: OFF]":
    @Condition (hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.INTERACT) and hostPlayer.isHoldingButton(Button.ABILITY_1)) == true
    
    setSlowMotion(10)
    
    waitUntil(hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false or hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false or hostPlayer.isHoldingButton(Button.INTERACT) == false or hostPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)

    waitUntil((hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.INTERACT) and hostPlayer.isHoldingButton(Button.ABILITY_1)) == true, 99999)

    setSlowMotion(100)

    waitUntil(hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false or hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false or hostPlayer.isHoldingButton(Button.INTERACT) == false or hostPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)
    


/*
rule "DEBUG - - - Create Dummy Bot With Crouch + Primary Fire [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    
    createDummy(Hero.REAPER, Team.ALL, -1 * 1 * 1 * 1, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, getAllPlayers(), eventPlayer, true).getHitPosition(), vect(0, 0, 0))
*/

/*
rule "DEBUG - - - Restart Match With Primary Fire + Secondary Fire + Jump + Crouch [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    
    restartMatch()
*/

/*
rule "DEBUG - - - [Talent: Juggernaut] Debug [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    
    createEffect(eventPlayer, Effect.SPHERE, Color.GRAY, eventPlayer.getPosition() + worldVector(vect(0, 1, 3), eventPlayer, Transform.ROTATION), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer, Effect.SPHERE, Color.GRAY, eventPlayer.getPosition() + worldVector(vect(0, 1, 1), eventPlayer, Transform.ROTATION), 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer, Effect.SPHERE, Color.RED, eventPlayer.getPosition() + worldVector(vect(0, 1, 1), eventPlayer, Transform.ROTATION), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
*/

/*
rule "DEBUG - - - Activate Third Person Camera With ABILITY_1 [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 1, 4), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == true, 99999)
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(4, 2, -1 * 1 * 1 * 3), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == true, 99999)
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 1, -1 * 1 * 1 * 4), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) == true, 99999)
    eventPlayer.stopCamera()
*/

/*
rule "DEBUG - - - Inspector Always On (crash investigation)":
    enableInspector()
*/

/*
rule "DEBUG - - - Reset [Talent: Juggernaut] Cooldown With Reload [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true

    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.JUGGERNAUT]


rule "Test":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()

    print(eventPlayer.xp_orb_chase_position)
   */

rule "DEBUG - - - Clear Assert Texts (Spectator: Move Up + Move Down)":
    @Condition debug_spectator_tools == true
    @Condition (hostPlayer.isHoldingButton(Button.INTERACT) and hostPlayer.isHoldingButton(Button.ABILITY_1)) == true
    @Condition hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false

    for i in range(len(debug_texts)):
        destroyHudText(debug_texts[i])
    debug_texts = []
    bigMessage(getAllPlayers(), "Asserts cleared")

    waitUntil(hostPlayer.isHoldingButton(Button.INTERACT) == false or hostPlayer.isHoldingButton(Button.ABILITY_1) == false, 99999)


rule "DEBUG - - - Bot Selector Init":
    @Condition debug_spectator_tools == true

    debug_selected_bot = -1
    debug_selected_player = null

    #--- HUD: selected bot info (center of screen) ---
    hudText(hostPlayer, \
        "Selected: Bot{0} | {1} | attr={2}".format(debug_selected_player.getSlot(), debug_selected_player.debug_bot_state, debug_selected_player.bot_edge_attr) if debug_selected_player != null else "No bot selected [-1]", \
        null, null, \
        HudPosition.TOP, 50, \
        Color.LIME_GREEN if debug_selected_player != null else Color.WHITE, \
        Color.WHITE, Color.WHITE, \
        HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

    #--- White assert: in-world text at last walk failure position (user-owned, spectator-only) ---
    debug_bot_walk_fail_pos = 0
    createInWorldText(\
        hostPlayer if debug_bot_walk_fail_pos != 0 and hostPlayer.getCurrentHero() != Hero.SOLDIER else null, \
        "WALK FAIL", \
        debug_bot_walk_fail_pos, \
        1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)


rule "DEBUG - - - Select Next Bot (Ctrl+Shift+E)":
    @Condition debug_spectator_tools == true
    @Condition (hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.INTERACT)) == true
    @Condition hostPlayer.isHoldingButton(Button.ABILITY_1) == false

    debug_selected_bot = min(debug_selected_bot + 1, len([p for p in getAllPlayers() if p.getCurrentHero() == Hero.REAPER]) - 1)
    debug_selected_player = sorted([p for p in getAllPlayers() if p.getCurrentHero() == Hero.REAPER], lambda p: p.getSlot())[debug_selected_bot] if debug_selected_bot >= 0 else null

    waitUntil(not (hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.INTERACT)), 99999)


rule "DEBUG - - - Select Prev Bot (Ctrl+Shift+Q)":
    @Condition debug_spectator_tools == true
    @Condition (hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.ABILITY_1)) == true
    @Condition hostPlayer.isHoldingButton(Button.INTERACT) == false

    debug_selected_bot = max(debug_selected_bot - 1, -1)
    debug_selected_player = sorted([p for p in getAllPlayers() if p.getCurrentHero() == Hero.REAPER], lambda p: p.getSlot())[debug_selected_bot] if debug_selected_bot >= 0 else null

    waitUntil(not (hostPlayer.isHoldingButton(Button.PRIMARY_FIRE) and hostPlayer.isHoldingButton(Button.SECONDARY_FIRE) and hostPlayer.isHoldingButton(Button.ABILITY_1)), 99999)
