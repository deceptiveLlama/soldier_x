#!mainFile "soldier_x.opy"

#--- Bot-only defineMember (variable[312-315]) ---
#!defineMember potion_earliest_expiry variable[312]
#!defineMember bot_search_destination variable[313]
#!defineMember bot_was_shot variable[314]
#!defineMember bot_combat_awareness_start variable[315]

# ============================================================
# BOT SYSTEM v2 — Combat-only bots for Soldier X
# Node navigation removed to free element count.
# Bots stand still until they see a player or get shot.
# ============================================================


# ============================================================
# MACROS — all tweakable values in one place
# ============================================================

#--- Movement ---
macro BOT_PATROL_SPEED = 1
macro BOT_TURN_SPEED = 100
macro BOT_RESPAWN_WAIT = 1

#--- Combat scan ---
macro BOT_SCAN_INTERVAL = 0.25 # full cycle time for all bots (min 0.128 — divided by max players, each wait must be >= 0.016)

#--- Combat ---
macro BOT_DETECTION_RANGE = 30
macro BOT_VIEW_ANGLE = 90
macro BOT_COMBAT_REACTION_SCAN = 1
macro BOT_COMBAT_REACTION_SHOT = 0.25
macro BOT_DISENGAGE_RANGE = 40
macro BOT_SEARCH_DURATION = 5
macro BOT_COMBAT_CLOSE_RANGE = 7
macro BOT_COMBAT_TELEPORT_RANGE = 35
macro BOT_SHADOW_STEP_AIM_ANGLE = 1            # degrees — bot must face within this angle before teleporting


# ============================================================
# ENUMS
# ============================================================

enum BotState:
    IDLE,
    COMBAT,
    SEARCHING,
    DEAD


# ============================================================
# GLOBAL VARIABLES
# ============================================================

globalvar i
globalvar scan_bots = []
globalvar scan_index
globalvar scan_visible_players = []


# ============================================================
# PLAYER VARIABLES
# ============================================================

#--- Reaper init ---
playervar reaper_has_respawned_once

#--- Bot state ---
playervar bot_state_id = BotState.DEAD
playervar bot_face_target

#--- Movement target (walk destination for combat chase + searching) ---
playervar bot_patrol_destination

#--- Combat ---
playervar bot_combat_target = null




# ============================================================
# SUBROUTINE DECLARATIONS
# ============================================================

subroutine bot_state_machine
subroutine bot_sm_idle
subroutine bot_sm_combat
subroutine bot_sm_searching
subroutine bot_combat_scan
subroutine bot_start_facing


# ============================================================
# BOT SPAWN / INIT
# ============================================================

rule "GENERAL - - - Add Bots":
    @Condition spawn_bots == true
    @Condition getNumberOfPlayers(Team.ALL) < amount_of_bots_and_players

    createDummy(Hero.REAPER, Team.ALL, -1, dummy_bot_spawn_position, dummy_bot_spawn_facing)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "BOT - - - Init":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true

    eventPlayer.stats = [100, 181.818, 75, 0, 0, 1, 1, 0, 100, 0]
    eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    eventPlayer.reaper_has_respawned_once = false

    #--- Single startThrottleInDirection with reevaluation — never stopped/restarted ---
    # In combat, moves toward bot_combat_target. Otherwise, toward bot_patrol_destination.
    # Magnitude controlled by bot_throttle_paused.
    eventPlayer.bot_throttle_paused = true
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition() if eventPlayer.bot_state_id == BotState.COMBAT else eventPlayer.bot_patrol_destination), 0 if eventPlayer.bot_throttle_paused or (eventPlayer.bot_state_id == BotState.COMBAT and distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) <= BOT_COMBAT_CLOSE_RANGE) else BOT_PATROL_SPEED, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)


    #--- Wait for first spawn, then respawn to get correct eye height ---
    waitUntil(eventPlayer.hasSpawned() and eventPlayer.isAlive() and spawn_bots, 99999)
    wait(BOT_RESPAWN_WAIT)
    eventPlayer.respawn()
    wait(BOT_RESPAWN_WAIT)
    eventPlayer.stats[Stat.EYE_HEIGHT] = eventPlayer.getEyePosition().y - eventPlayer.getPosition().y
    eventPlayer.reaper_has_respawned_once = true
    eventPlayer.bot_state_id = BotState.IDLE

    #--- Start state machine loop ---
    bot_state_machine()





# ============================================================
# STATE MACHINE
# ============================================================

def bot_state_machine():
    @Name "BOT - - - State Machine"

    while true:
        if not eventPlayer.isAlive() or not spawn_bots:
            wait()
            continue

        if eventPlayer.bot_state_id == BotState.IDLE:
            bot_sm_idle()
        elif eventPlayer.bot_state_id == BotState.COMBAT:
            bot_sm_combat()
        elif eventPlayer.bot_state_id == BotState.SEARCHING:
            bot_sm_searching()

        wait()


# ============================================================
# FACING — on during combat/searching, off (engine spawn facing) when idle
# ============================================================

def bot_start_facing():
    @Name "BOT - - - [SUBROUTINE] Start Facing"

    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getPosition() + vect(0, eventPlayer.bot_combat_target.stats[Stat.EYE_HEIGHT] / 2, 0) if eventPlayer.bot_state_id == BotState.COMBAT else vect(eventPlayer.bot_face_target.x, eventPlayer.getEyePosition().y if distance(eventPlayer.getPosition(), eventPlayer.bot_face_target) < 0.5 else eventPlayer.bot_face_target.y, eventPlayer.bot_face_target.z)), BOT_TURN_SPEED, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)


# ============================================================
# STATE: IDLE
# ============================================================

def bot_sm_idle():
    @Name "BOT - - - [STATE] Idle"

    #--- Stand still until an external state change (combat scan / got shot / death) wakes us ---
    eventPlayer.stopFacing()
    eventPlayer.bot_throttle_paused = true
    waitUntil(eventPlayer.bot_state_id != BotState.IDLE, 99999)


# ============================================================
# STATE: COMBAT — face target, walk toward, shoot
# ============================================================

def bot_sm_combat():
    @Name "BOT - - - [STATE] Combat"

    #--- Validate target ---
    if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or not eventPlayer.bot_combat_target.hasSpawned() or eventPlayer.bot_combat_target.isDummy() or eventPlayer.bot_combat_target.browsing_shop or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH]:
        eventPlayer.bot_combat_target = null
        eventPlayer.bot_state_id = BotState.IDLE
        return

    bot_start_facing()

    #--- Reaction time (0.25s if shot, skip if scanned — awareness timer already waited 1s) ---
    eventPlayer.bot_face_target = eventPlayer.bot_combat_target.getPosition() + vect(0, eventPlayer.bot_combat_target.stats[Stat.EYE_HEIGHT] / 2, 0)
    eventPlayer.bot_throttle_paused = false
    eventPlayer.bot_patrol_destination = eventPlayer.bot_combat_target.getPosition()
    if eventPlayer.bot_was_shot:
        waitUntil(eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), BOT_COMBAT_REACTION_SHOT)
        eventPlayer.bot_was_shot = false
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_combat_target = null
            eventPlayer.bot_state_id = BotState.IDLE
            return

    #--- Combat teleport: shadow step if target is far and ability is ready ---
    if distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) >= BOT_COMBAT_TELEPORT_RANGE and eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0:
        eventPlayer.bot_throttle_paused = true
        waitUntil(angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_face_target)) < BOT_SHADOW_STEP_AIM_ANGLE or eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), 2)
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_combat_target = null
            eventPlayer.bot_state_id = BotState.IDLE
            return
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        wait()
        eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
        waitUntil(eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead(), 1.5)
        eventPlayer.bot_throttle_paused = false
        if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or eventPlayer.isDead():
            eventPlayer.bot_combat_target = null
            eventPlayer.bot_state_id = BotState.IDLE
            return

    #--- Engage: start shooting + walk toward target ---
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)

    #--- Stay engaged until LOS lost, target invalid, target too far, or bot dies ---
    waitUntil(\
        eventPlayer.bot_combat_target == null \
        or eventPlayer.bot_combat_target.isDead() \
        or not eventPlayer.bot_combat_target.hasSpawned() \
        or eventPlayer.bot_combat_target.isDummy() \
        or eventPlayer.bot_combat_target.browsing_shop \
        or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] \
        or eventPlayer.isDead() \
        or distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) > BOT_DISENGAGE_RANGE \
        or distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) >= 1, \
        99999)

    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

    #--- Determine why we exited ---
    if eventPlayer.bot_combat_target == null or eventPlayer.bot_combat_target.isDead() or not eventPlayer.bot_combat_target.hasSpawned() or eventPlayer.bot_combat_target.isDummy() or eventPlayer.bot_combat_target.browsing_shop or eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] or eventPlayer.isDead() or distance(eventPlayer.getPosition(), eventPlayer.bot_combat_target.getPosition()) > BOT_DISENGAGE_RANGE:
        #--- Target invalid or too far — return to navigation ---
        eventPlayer.bot_combat_target = null
        eventPlayer.bot_state_id = BotState.IDLE
    else:
        #--- LOS lost — transition to searching ---
        eventPlayer.bot_search_destination = eventPlayer.bot_combat_target.getPosition()
        eventPlayer.bot_state_id = BotState.SEARCHING


# ============================================================
# STATE: SEARCHING — walk to last known position, look for target
# ============================================================

def bot_sm_searching():
    @Name "BOT - - - [STATE] Searching"

    eventPlayer.bot_patrol_destination = eventPlayer.bot_search_destination
    eventPlayer.bot_face_target = eventPlayer.bot_search_destination + vect(0, eventPlayer.stats[Stat.EYE_HEIGHT], 0)
    eventPlayer.bot_throttle_paused = false

    #--- Wait until: target reacquired (LOS + alive), arrived at search pos, target invalid, or timeout ---
    waitUntil(\
        (eventPlayer.bot_combat_target != null \
            and not eventPlayer.bot_combat_target.isDead() \
            and eventPlayer.bot_combat_target.hasSpawned() \
            and not eventPlayer.bot_combat_target.browsing_shop \
            and not eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] \
            and distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) < 1) \
        or eventPlayer.bot_combat_target == null \
        or eventPlayer.bot_combat_target.isDead() \
        or eventPlayer.isDead() \
        or distance(eventPlayer.getPosition(), eventPlayer.bot_search_destination) < 2, \
        BOT_SEARCH_DURATION)

    #--- Check if target reacquired ---
    if eventPlayer.bot_combat_target != null and not eventPlayer.bot_combat_target.isDead() and eventPlayer.bot_combat_target.hasSpawned() and not eventPlayer.bot_combat_target.browsing_shop and not eventPlayer.bot_combat_target.is_using_ability[Talent.STEALTH] and eventPlayer.isAlive() and distance(raycast(eventPlayer.getEyePosition(), eventPlayer.bot_combat_target.getEyePosition(), null, eventPlayer, false).getHitPosition(), eventPlayer.bot_combat_target.getEyePosition()) < 1:
        eventPlayer.bot_state_id = BotState.COMBAT
    else:
        eventPlayer.bot_combat_target = null
        eventPlayer.bot_state_id = BotState.IDLE





# ============================================================
# COMBAT SCAN — global serialized loop
# Cycles through bots one at a time.
# Full cycle takes BOT_SCAN_INTERVAL.
# ============================================================

def bot_combat_scan():
    @Name "BOT - - - Combat Scan (Global)"

    while true:
        scan_bots = [bot for bot in getAllPlayers() if bot.isDummy() and bot.isAlive() and bot.bot_state_id != BotState.DEAD]
        if len(scan_bots) > 0:
            for scan_index in range(len(scan_bots)):

                #--- Combat scan (not already in combat, bots hostile) ---
                if not bots_friendly and scan_bots[scan_index].bot_state_id != BotState.COMBAT and scan_bots[scan_index].bot_state_id != BotState.SEARCHING and scan_bots[scan_index].bot_combat_target == null:
                    #--- Cheap gate: players in view angle + distance + filters ---
                    scan_visible_players = sorted([player for player in scan_bots[scan_index].getPlayersInViewAngle(Team.ALL, BOT_VIEW_ANGLE) if not player.isDummy() and player.isAlive() and distance(scan_bots[scan_index].getPosition(), player.getPosition()) <= BOT_DETECTION_RANGE and not player.browsing_shop and not player.is_using_ability[Talent.STEALTH]], lambda player: distance(scan_bots[scan_index].getPosition(), player.getPosition()))
                    if len(scan_visible_players) > 0:
                        #--- Expensive: raycast eye → closest player body center ---
                        if distance(raycast(scan_bots[scan_index].getEyePosition(), scan_visible_players[0].getEyePosition(), null, scan_bots[scan_index], false).getHitPosition(), scan_visible_players[0].getEyePosition()) < 1:
                            #--- Player visible — update alert meter ---
                            if scan_bots[scan_index].bot_combat_awareness_start == 0:
                                scan_bots[scan_index].bot_combat_awareness_start = getTotalTimeElapsed()
                            elif getTotalTimeElapsed() - scan_bots[scan_index].bot_combat_awareness_start >= BOT_COMBAT_REACTION_SCAN:
                                #--- 1 second of awareness — enter combat ---
                                scan_bots[scan_index].bot_combat_target = scan_visible_players[0]
                                scan_bots[scan_index].bot_combat_awareness_start = 0
                                scan_bots[scan_index].bot_state_id = BotState.COMBAT
                        else:
                            scan_bots[scan_index].bot_combat_awareness_start = 0
                    else:
                        scan_bots[scan_index].bot_combat_awareness_start = 0

                wait(BOT_SCAN_INTERVAL / len(scan_bots))
        else:
            wait(BOT_SCAN_INTERVAL)



rule "DEBUG - - - Re-enable Ability 2 for non-bots (testing Shadow Step as Reaper)":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Hero reaper

    wait(1)
    eventPlayer.setAbility2Enabled(true)


