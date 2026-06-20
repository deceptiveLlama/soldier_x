#!mainFile "soldier_x.opy"

#--- Asset browser (dev tool): browse talents, icons, and hero ability strings. defineMember range variable[600-602], global_variable[110-111] ---
#!defineMember debug_browser_active variable[600]
#!defineMember debug_browser_index variable[601]
#!defineMember debug_browser_category variable[602]
#!defineMember debug_browser_icon_strings global_variable[110]
#!defineMember debug_browser_heroes global_variable[111]

macro DEBUG_BROWSER_DISTANCE = 8
macro DEBUG_BROWSER_ROW_SPACING = 1.1
macro DEBUG_BROWSER_SCALE = 2.5
macro DEBUG_BROWSER_CATEGORY_TALENTS = 0
macro DEBUG_BROWSER_CATEGORY_ICONS = 1
macro DEBUG_BROWSER_CATEGORY_ABILITIES = 2
macro DEBUG_BROWSER_CATEGORY_COUNT = 3
macro DEBUG_BROWSER_COUNT = len(talent_names) if eventPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_TALENTS else (len(debug_browser_icon_strings) if eventPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ICONS else len(debug_browser_heroes))

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

    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.JUGGERNAUT]


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

/*
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


#--- Asset browser (dev tool): Crouch + Interact toggles a locked browse mode; Reload flips category (Talents/Icons/Abilities); Q/E cycle within it. Talents come from talent_names and abilities from getAllHeroes() so both always match the live roster; icons are a fixed Icon-enum list ---
rule "DEBUG - - - Browse Assets HUD (talents / icons / abilities panel)":
    debug_browser_icon_strings = ["{0}  ARROW_DOWN".format(iconString(Icon.ARROW_DOWN)), "{0}  ARROW_LEFT".format(iconString(Icon.ARROW_LEFT)), "{0}  ARROW_RIGHT".format(iconString(Icon.ARROW_RIGHT)), "{0}  ARROW_UP".format(iconString(Icon.ARROW_UP)), "{0}  ASTERISK".format(iconString(Icon.ASTERISK)), "{0}  BOLT".format(iconString(Icon.BOLT)), "{0}  CHECKMARK".format(iconString(Icon.CHECKMARK)), "{0}  CIRCLE".format(iconString(Icon.CIRCLE)), "{0}  CLUB".format(iconString(Icon.CLUB)), "{0}  DIAMOND".format(iconString(Icon.DIAMOND)), "{0}  DIZZY".format(iconString(Icon.DIZZY)), "{0}  EXCLAMATION_MARK".format(iconString(Icon.EXCLAMATION_MARK)), "{0}  EYE".format(iconString(Icon.EYE)), "{0}  FIRE".format(iconString(Icon.FIRE)), "{0}  FLAG".format(iconString(Icon.FLAG)), "{0}  HALO".format(iconString(Icon.HALO)), "{0}  HAPPY".format(iconString(Icon.HAPPY)), "{0}  HEART".format(iconString(Icon.HEART)), "{0}  MOON".format(iconString(Icon.MOON)), "{0}  NO".format(iconString(Icon.NO)), "{0}  PLUS".format(iconString(Icon.PLUS)), "{0}  POISON".format(iconString(Icon.POISON)), "{0}  POISON_2".format(iconString(Icon.POISON_2)), "{0}  QUESTION_MARK".format(iconString(Icon.QUESTION_MARK)), "{0}  RADIOACTIVE".format(iconString(Icon.RADIOACTIVE)), "{0}  RECYCLE".format(iconString(Icon.RECYCLE)), "{0}  RING_THICK".format(iconString(Icon.RING_THICK)), "{0}  RING_THIN".format(iconString(Icon.RING_THIN)), "{0}  SAD".format(iconString(Icon.SAD)), "{0}  SKULL".format(iconString(Icon.SKULL)), "{0}  SPADE".format(iconString(Icon.SPADE)), "{0}  SPIRAL".format(iconString(Icon.SPIRAL)), "{0}  STOP".format(iconString(Icon.STOP)), "{0}  TRASHCAN".format(iconString(Icon.TRASHCAN)), "{0}  WARNING".format(iconString(Icon.WARNING)), "{0}  CROSS (X)".format(iconString(Icon.CROSS))]
    debug_browser_heroes = getAllHeroes()

    #Header: current asset (talent name, icon glyph+enum name, or hero icon+name)
    createInWorldText(localPlayer if localPlayer.debug_browser_active == true else null, "{0}".format(talent_names[localPlayer.debug_browser_index] if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_TALENTS else (debug_browser_icon_strings[localPlayer.debug_browser_index] if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ICONS else "{0}  {1}".format(heroIcon(debug_browser_heroes[localPlayer.debug_browser_index]), debug_browser_heroes[localPlayer.debug_browser_index]))), updateEveryTick(localPlayer.getEyePosition() + HUD_CAM_FWD * DEBUG_BROWSER_DISTANCE + HUD_CAM_UP * (DEBUG_BROWSER_ROW_SPACING * 0.5)), DEBUG_BROWSER_SCALE, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)

    #Counter: category, position, and the Reload-to-switch hint
    createInWorldText(localPlayer if localPlayer.debug_browser_active == true else null, "[{0}]  {1} / {2}  ({3} swaps)".format("TALENTS" if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_TALENTS else ("ICONS" if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ICONS else "ABILITIES"), localPlayer.debug_browser_index + 1, len(talent_names) if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_TALENTS else (len(debug_browser_icon_strings) if localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ICONS else len(debug_browser_heroes)), buttonString(Button.RELOAD)), updateEveryTick(localPlayer.getEyePosition() + HUD_CAM_FWD * DEBUG_BROWSER_DISTANCE + HUD_CAM_UP * (DEBUG_BROWSER_ROW_SPACING * -0.5)), DEBUG_BROWSER_SCALE, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GRAY, SpecVisibility.ALWAYS)

    #Abilities only: ability icon strings for the current hero, labelled by button
    createInWorldText(localPlayer if localPlayer.debug_browser_active == true and localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ABILITIES else null, "Primary {0}   Secondary {1}   Ability 1 {2}   Ability 2 {3}".format(abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.PRIMARY_FIRE), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.SECONDARY_FIRE), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.ABILITY_1), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.ABILITY_2)), updateEveryTick(localPlayer.getEyePosition() + HUD_CAM_FWD * DEBUG_BROWSER_DISTANCE + HUD_CAM_UP * (DEBUG_BROWSER_ROW_SPACING * -1.5)), DEBUG_BROWSER_SCALE, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)

    createInWorldText(localPlayer if localPlayer.debug_browser_active == true and localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ABILITIES else null, "Ultimate {0}   Reload {1}   Interact {2}   Melee {3}".format(abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.ULTIMATE), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.RELOAD), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.INTERACT), abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.MELEE)), updateEveryTick(localPlayer.getEyePosition() + HUD_CAM_FWD * DEBUG_BROWSER_DISTANCE + HUD_CAM_UP * (DEBUG_BROWSER_ROW_SPACING * -2.5)), DEBUG_BROWSER_SCALE, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)

    createInWorldText(localPlayer if localPlayer.debug_browser_active == true and localPlayer.debug_browser_category == DEBUG_BROWSER_CATEGORY_ABILITIES else null, "Jump {0}".format(abilityIconString(debug_browser_heroes[localPlayer.debug_browser_index], Button.JUMP)), updateEveryTick(localPlayer.getEyePosition() + HUD_CAM_FWD * DEBUG_BROWSER_DISTANCE + HUD_CAM_UP * (DEBUG_BROWSER_ROW_SPACING * -3.5)), DEBUG_BROWSER_SCALE, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)


def debug_browser_loop():
    @Name "DEBUG - - - [SUBROUTINE] Browse Assets (Q = previous, E = next, Reload = swap category)"

    while eventPlayer.debug_browser_active == true:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            eventPlayer.debug_browser_index = (eventPlayer.debug_browser_index - 1 + DEBUG_BROWSER_COUNT) % DEBUG_BROWSER_COUNT
            waitUntil(eventPlayer.isHoldingButton(Button.ULTIMATE) == false, 99999)
        elif eventPlayer.isHoldingButton(Button.ABILITY_2) == true:
            eventPlayer.debug_browser_index = (eventPlayer.debug_browser_index + 1) % DEBUG_BROWSER_COUNT
            waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_2) == false, 99999)
        elif eventPlayer.isHoldingButton(Button.RELOAD) == true:
            eventPlayer.debug_browser_category = (eventPlayer.debug_browser_category + 1) % DEBUG_BROWSER_CATEGORY_COUNT
            eventPlayer.debug_browser_index = 0
            waitUntil(eventPlayer.isHoldingButton(Button.RELOAD) == false, 99999)
        wait()


rule "DEBUG - - - Toggle Browse Assets (Crouch + Interact)":
    @Event eachPlayer
    @Condition debug_spectator_tools == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

    eventPlayer.debug_browser_active = not eventPlayer.debug_browser_active
    if eventPlayer.debug_browser_active == true:
        eventPlayer.debug_browser_index = 0
        eventPlayer.debug_browser_category = DEBUG_BROWSER_CATEGORY_TALENTS
        eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.ULTIMATE)
        eventPlayer.disallowButton(Button.MELEE)
        eventPlayer.disallowButton(Button.JUMP)
        eventPlayer.disallowButton(Button.RELOAD)
        async(debug_browser_loop, AsyncBehavior.NOOP)
    else:
        eventPlayer.clearStatusEffect(Status.ROOTED)
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.allowButton(Button.ULTIMATE)
        eventPlayer.allowButton(Button.MELEE)
        eventPlayer.allowButton(Button.JUMP)
        eventPlayer.allowButton(Button.RELOAD)
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH) == false or eventPlayer.isHoldingButton(Button.INTERACT) == false, 99999)
*/