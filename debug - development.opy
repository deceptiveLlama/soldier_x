#!mainFile "soldier_x.opy"

#--- Fly camera (dev tool) state + tunables ---
playervar debug_flycam_active = false
playervar debug_flycam_position
macro DEBUG_FLYCAM_SPEED = 0.25             #meters moved per tick (~15 m/s at 60 fps)
macro DEBUG_FLYCAM_BOOST_MULTIPLIER = 4     #speed multiplier while holding Ability 1 (boost)

#--- Workshop Settings (only active when this file is included) ---
rule "DEBUG - - - Init Workshop Settings":
    debug_spectator_tools = createWorkshopSettingBool("00. Debug", "Spectator Tools (bot selector, asserts, etc.)", true, 0)

#--- Element budget + server load readout (host, visible while playing) ---
rule "DEBUG - - - Element & Load Readout":
    hudText(hostPlayer, null, \
        "Texts: {0} | Effects: {1}".format(getNumberOfTextIds(), getNumberOfEntityIds()), \
        "Srv Load: {0} | Avg: {1} | Peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), \
        HudPosition.ACTUALLY_LEFT, 0, \
        Color.RED if getAverageServerLoad() > 150 else Color.YELLOW if getAverageServerLoad() >= 100 else Color.LIME_GREEN, \
        Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

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


#--- Shop placement helper: fly to a spot, aim where the middle talent should float, copy both values into If_map ---
#--- Reports the eye position (the actual shop camera point) and the horizontal facing angle ---
rule "DEBUG - - - Shop Placement Readout":
    @Condition debug_spectator_tools == true

    hudText(hostPlayer, null, \
        "shop_location = vect({0}, {1}, {2})   |   shop_rotation = {3}".format( \
            round(hostPlayer.getEyePosition().x * 1000) / 1000, \
            round(hostPlayer.getEyePosition().y * 1000) / 1000, \
            round(hostPlayer.getEyePosition().z * 1000) / 1000, \
            round(horizontalAngleOfDirection(hostPlayer.getFacingDirection()))), \
        null, HudPosition.ACTUALLY_LEFT, 1, Color.ORANGE, Color.ORANGE, Color.ORANGE, \
        HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)


#--- Fly camera: toggle a free-fly noclip on your hero so you can place shops from the air (position/rotation readouts work) ---
#--- Toggle = Interact + Melee. While flying: Primary = forward (where you look), Secondary = back, Jump = up, Crouch = down, Ability 1 = boost ---
#--- Primary/Secondary fire are suppressed while flying (still read for thrust); position is forced (so you hover and can still look around) and you are PHASED_OUT (can't die) ---
def debug_flycam_loop():
    @Name "DEBUG - - - [SUBROUTINE] Fly Camera Movement"

    #startForcingPosition reevaluates debug_flycam_position every frame, so we only update the variable here (no teleport — teleporting each tick is what locked the camera)
    while eventPlayer.debug_flycam_active == true:
        eventPlayer.debug_flycam_position += (eventPlayer.getFacingDirection() * (eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) - eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)) + Vector.UP * (eventPlayer.isHoldingButton(Button.JUMP) - eventPlayer.isHoldingButton(Button.CROUCH))) * DEBUG_FLYCAM_SPEED * (DEBUG_FLYCAM_BOOST_MULTIPLIER if eventPlayer.isHoldingButton(Button.ABILITY_1) == true else 1)
        wait()


rule "DEBUG - - - Toggle Fly Camera (Interact + Melee)":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true

    eventPlayer.debug_flycam_active = not eventPlayer.debug_flycam_active
    if eventPlayer.debug_flycam_active == true:
        eventPlayer.debug_flycam_position = eventPlayer.getPosition()
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.startForcingPosition(eventPlayer.debug_flycam_position, true)
        async(debug_flycam_loop, AsyncBehavior.NOOP)
    else:
        eventPlayer.stopForcingPosition()
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) == false or eventPlayer.isHoldingButton(Button.MELEE) == false, 99999)


#--- Cooldown-on-spawn capture (assistant debug): snapshots the just-bought talent's cooldown math across the spawn window after a purchase ---
#--- tte ~0 climbing while remain stays high => stale per-player clock; ready=False while the ability is usable => stuck @Condition (w_ow2_rule_condition_chase) ---
def debug_cooldown_snapshot():
    @Name "DEBUG - - - [SUBROUTINE] Cooldown Spawn Snapshot"

    eventPlayer.debug_cd_end = eventPlayer.talent_trigger_times[eventPlayer.current_talent_replace_or_buy] + talent_base_cooldowns[eventPlayer.current_talent_replace_or_buy] - eventPlayer.talent_ranks[eventPlayer.current_talent_replace_or_buy] * talent_cd_reduction_p_rank[eventPlayer.current_talent_replace_or_buy]
    hudText(eventPlayer, null, "[t={0}] {1}  trig={2} base={3} tte={4}  remain={5} ready={6} alive={7}".format(evalOnce(round(getTotalTimeElapsed() * 100) / 100), talent_names[eventPlayer.current_talent_replace_or_buy], evalOnce(round(eventPlayer.talent_trigger_times[eventPlayer.current_talent_replace_or_buy] * 100) / 100), talent_base_cooldowns[eventPlayer.current_talent_replace_or_buy], evalOnce(round(eventPlayer.totalTimeElapsed * 100) / 100), evalOnce(round((eventPlayer.debug_cd_end - eventPlayer.totalTimeElapsed) * 100) / 100), evalOnce(eventPlayer.debug_cd_end <= eventPlayer.totalTimeElapsed), evalOnce(eventPlayer.isAlive())), null, HudPosition.ACTUALLY_LEFT, 2, Color.ORANGE, Color.ORANGE, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    debug_texts.append(getLastCreatedText())


rule "DEBUG - - - [Cooldown] Capture Spawn After Purchase":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.debug_cooldown_capture == true

    eventPlayer.debug_cd_sample_i = 0
    while eventPlayer.debug_cd_sample_i < 10:
        debug_cooldown_snapshot()
        wait(0.5)
        eventPlayer.debug_cd_sample_i += 1
    eventPlayer.debug_cooldown_capture = false
