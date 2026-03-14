#!mainFile "soldier_x.opy"
#Global variables

globalvar spawn_bots = createWorkshopSettingBool("01. Bots", "Spawn bots?", true, 0)
globalvar amount_of_bots_and_players = createWorkshopSettingInt("01. Bots", "How many bots and players?", 8, 1, 8, 2)
globalvar bots_friendly = createWorkshopSettingBool("01. Bots", "Friendly?", false, 1)

#Player variables

playervar reaper_view_angle
playervar reaper_hello_cooldown
playervar reaper_turn_speed
playervar bot_memory
playervar reaper_aggro_list
playervar reaper_has_respawned_once
playervar last_known_position_of_target

#Subroutine names

subroutine reaper_has_a_target
subroutine reaper_target_lost

enum Bot:
        CURRENT_TARGET, #this is the old reaper_brain_information[0]
        SEARCHING_FOR_TARGET, #this is the old reaper_brain_information[1]
        USING_TELEPORT_ABILITY, #this is the old reaper_brain_information[2]
        IS_PATHFINDING, #this is the old reaper_brain_information[3]
        IS_CHANGING_DIRECTION #this is the old reaper_brain_information[4]

/*
rule "GENERAL - - - Moving Test":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    
    while ruleCondition:
        eventPlayer.startForcingThrottle(1, 1, 0, 0, 0, 0)

        wait(3)
        eventPlayer.stopForcingThrottle()

        eventPlayer.startForcingThrottle(0, 0, 1, 1, 0, 0)

        wait(3)
        eventPlayer.stopForcingThrottle()
    
    if RULE_CONDITION:
        goto RULE_START
*/  

rule "GENERAL - - - Add Bots":
    @Condition spawn_bots == true
    @Condition getNumberOfPlayers(Team.ALL) < amount_of_bots_and_players
    
    createDummy(Hero.REAPER, Team.ALL, -1, dummy_bot_spawn_position, dummy_bot_spawn_facing)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START

#to fix spawn positions
rule "BOT SYSTEM - - - Bot Respawn Once":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.reaper_has_respawned_once == false
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    
    wait(1)
    eventPlayer.respawn()
    wait(3)
    eventPlayer.reaper_has_respawned_once = true
    /*eventPlayer.setMaxHealth(eventPlayer.stats[Stat.HEALTH])
    heal(eventPlayer, null, eventPlayer.getMaxHealth())*/

rule "BOT SYSTEM - - - Add Player To Aggro List":
    @Event playerTookDamage
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.bot_memory[Bot.CURRENT_TARGET] == null
    
    if attacker.getCurrentHero() == Hero.SOLDIER and eventPlayer.reaper_aggro_list == []:
        eventPlayer.reaper_aggro_list[0] = attacker
        return
    if attacker.getCurrentHero() == Hero.SOLDIER and attacker in victim.reaper_aggro_list == false:
        eventPlayer.reaper_aggro_list = eventPlayer.reaper_aggro_list.concat(attacker)


rule "BOT SYSTEM - - - Bot Got Aggro":
    @Event eachPlayer
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.reaper_aggro_list != []
    @Condition eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER
    @Condition eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == false
    @Condition eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false
    
    async(reaper_has_a_target, AsyncBehavior.NOOP)


rule "BOT SYSTEM - - - Bot Brain - What to do next?":
    @Event eachPlayer
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.reaper_aggro_list == []
    @Condition eventPlayer.reaper_has_respawned_once == true
    @Condition eventPlayer.hasSpawned() == true
    
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.last_known_position_of_target[1] + Vector.UP) if eventPlayer.last_known_position_of_target[1] != null else eventPlayer.getFacingDirection(), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    #If there is a player in sight, set the player as the current target
    if ([player for player in eventPlayer.getPlayersInViewAngle(Team.ALL, 90) if player.getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), player.getPosition()) <= 20 and player.isAlive() == true and player.browsing_shop == false and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) == true and player.is_using_ability[Talent.STEALTH] == false]) != []:
        reaper_has_a_target()
    wait(1)
    if RULE_CONDITION:
        goto RULE_START

def reaper_has_a_target():
    @Name "BOT SYSTEM - - - [SUBROUTINE] Bot Has a Target"
    
    /*
    eventPlayer.random_integer_between_0_to_5 = random.randint(0, 9)
    if eventPlayer.random_integer_between_0_to_5 <= 1 and eventPlayer.reaper_hello_cooldown == 0:
        eventPlayer.communicate(Comms.HELLO)
        eventPlayer.reaper_hello_cooldown = 10
        */
    eventPlayer.bot_memory[Bot.IS_PATHFINDING] = false
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition() + Vector.UP) if eventPlayer.bot_memory[Bot.CURRENT_TARGET] != null and eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false else directionTowards(eventPlayer.getEyePosition(), eventPlayer.last_known_position_of_target[0]) if eventPlayer.bot_memory[Bot.CURRENT_TARGET] != null and eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == true else directionTowards(eventPlayer.getEyePosition(), eventPlayer.last_known_position_of_target[1] + Vector.UP) if eventPlayer.bot_memory[Bot.CURRENT_TARGET] == null and eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false else 0, 1000 if eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == true else 150, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    if eventPlayer.reaper_aggro_list == []:
        #If there is a player in sight, set the player as the current target
        eventPlayer.bot_memory[Bot.CURRENT_TARGET] = (sorted([player for player in eventPlayer.getPlayersInViewAngle(Team.ALL, 90) if player.getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), player.getPosition()) <= 30 and player.isAlive() and player.browsing_shop == false and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and player.is_using_ability[Talent.STEALTH] == false], lambda i: distance(eventPlayer.getPosition(), i.getPosition())))[0]
    else:
        #Set the player on top of the aggro list as the current target
        eventPlayer.bot_memory[Bot.CURRENT_TARGET] = eventPlayer.reaper_aggro_list[0]
    waitUntil(not isInLoS(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) or eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER or eventPlayer.isDead() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].browsing_shop == true or eventPlayer.bot_memory[Bot.CURRENT_TARGET].isDead() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == true, 99999)
    if eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER or eventPlayer.isDead() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].browsing_shop == true or eventPlayer.bot_memory[Bot.CURRENT_TARGET].isDead() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == true:
        eventPlayer.reaper_aggro_list = []
        eventPlayer.bot_memory[Bot.CURRENT_TARGET] = null
        return
    #If Current Target Can't Be Seen
    if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isAlive() and eventPlayer.bot_memory[Bot.CURRENT_TARGET].isAlive() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == true:
        reaper_target_lost()
    #If Current Target Is Found Again
    if isInLoS(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isAlive() and eventPlayer.bot_memory[Bot.CURRENT_TARGET].isAlive() and eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == false and eventPlayer.bot_memory[Bot.CURRENT_TARGET].browsing_shop == false:
        wait()
        goto RULE_START
    #If Reaper Died
    #return
    #If current target is out of sight or dead
    if eventPlayer.bot_memory[Bot.CURRENT_TARGET].isDead() or eventPlayer.bot_memory[Bot.CURRENT_TARGET].browsing_shop == true or eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER or not isInLoS(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) or eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == true:
        eventPlayer.reaper_aggro_list = eventPlayer.reaper_aggro_list.exclude(eventPlayer.bot_memory[Bot.CURRENT_TARGET])
        #Current target is out of sight or dead, is there more aggroed players in sight?
        #return
        eventPlayer.random_integer_between_0_to_5 = random.randint(0, 9)
        if eventPlayer.random_integer_between_0_to_5 <= 1 and eventPlayer.reaper_hello_cooldown == 0:
            eventPlayer.communicate(Comms.GOODBYE)
            eventPlayer.reaper_hello_cooldown = 10
        eventPlayer.reaper_aggro_list = []
        eventPlayer.bot_memory[Bot.CURRENT_TARGET] = null


def reaper_target_lost():
    @Name "BOT SYSTEM - - - [SUBROUTINE] Bot Lost the Target"
    
    eventPlayer.last_known_position_of_target[0] = null
    eventPlayer.last_known_position_of_target[1] = null
    eventPlayer.last_known_position_of_target[0] = eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()
    wait(0.032)
    eventPlayer.last_known_position_of_target[0] = eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition() + vectorTowards(eventPlayer.bot_memory[Bot.CURRENT_TARGET], eventPlayer.last_known_position_of_target[0]) * 12
    eventPlayer.last_known_position_of_target[1] = eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()
    eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] = true
    waitUntil(isInLoS(eventPlayer.getEyePosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.bot_memory[Bot.CURRENT_TARGET].is_using_ability[Talent.STEALTH] == false or eventPlayer.bot_memory[Bot.CURRENT_TARGET].isDead() or eventPlayer.isDead() or distance(eventPlayer.getPosition() + Vector.UP, eventPlayer.last_known_position_of_target[0] + Vector.UP) < 1, 5)
    eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] = false


rule "BOT SYSTEM - - - Bot Moving - Towards Target / Searching For Target":
    @Event eachPlayer
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() == Hero.SOLDIER
    @Condition distance(eventPlayer.getPosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()) > 7
    @Condition eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == false
    
    wait(0.25, Wait.RESTART_WHEN_TRUE)
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()) if eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false else directionTowards(eventPlayer.getPosition(), eventPlayer.last_known_position_of_target[0]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    waitUntil(eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER or eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == true or eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()) <= 7 and eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false, 99999)
    eventPlayer.stopThrottleInDirection()
    if RULE_CONDITION:
        goto RULE_START


rule "BOT SYSTEM - - - Bot Start Shooting":
    @Event eachPlayer
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() == Hero.SOLDIER
    @Condition eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == false
    @Condition eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == false
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    waitUntil(eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() != Hero.SOLDIER or eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == true or eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] == true, 99999)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    if RULE_CONDITION:
        goto RULE_START

rule "BOT SYSTEM - - - Bot Died":
    @Event playerDied
    @Hero reaper
    @Condition spawn_bots == true
    
    #print("bot died")
    #eventPlayer.setGravity(100)
    eventPlayer.bot_memory[Bot.CURRENT_TARGET] = null
    eventPlayer.reaper_aggro_list = []
    eventPlayer.stopFacing()
    eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] = false
    eventPlayer.stopThrottleInDirection()
    eventPlayer.bot_memory[Bot.IS_PATHFINDING] = false
    waitUntil(eventPlayer.isAlive() and eventPlayer.hasSpawned(), 99999)
    #eventPlayer.setGravity(50)


rule "BOT SYSTEM - - - Bot Use Teleport":
    @Event eachPlayer
    @Hero reaper
    @Condition bots_friendly == false
    @Condition spawn_bots == true
    @Condition eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() == Hero.SOLDIER
    @Condition eventPlayer.hit_by_dive_bomb_effect_counter == 0
    @Condition eventPlayer.hit_by_talent[Talent.DIVE_BOMB] == null
    @Condition distance(eventPlayer.getPosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()) >= 5
    @Condition (eventPlayer.getVerticalFacingAngle() + 89 < 59 and eventPlayer.bot_memory[Bot.CURRENT_TARGET].isOnGround() or eventPlayer.bot_memory[Bot.SEARCHING_FOR_TARGET] == true and eventPlayer.getVerticalFacingAngle() + 89 < 59 or eventPlayer.bot_memory[Bot.CURRENT_TARGET].getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), eventPlayer.bot_memory[Bot.CURRENT_TARGET].getPosition()) >= 35) == true
    
    eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] = true
    wait(0.25)
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    wait(0.125)
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
    wait(2)
    if eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0:
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
    eventPlayer.bot_memory[Bot.USING_TELEPORT_ABILITY] = false

/*
rule "BOT SYSTEM - - - Bot Dealt Damage [DEFAULT: OFF]":
    @Event playerDealtDamage
    @Hero reaper
    @Condition spawn_bots == true
    
    attacker.in_combat = 3
*/

/*
rule "BOT SYSTEM - - - Bot Melee & Jump [DEFAULT: OFF]":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.bot_memory[Bot.IS_PATHFINDING] == true
    @Condition eventPlayer.bot_memory[Bot.IS_CHANGING_DIRECTION] == false
    @Condition eventPlayer.getSpeed() < 1.5
    @Condition eventPlayer.isOnGround() == true
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.MELEE)
    eventPlayer.forceButtonPress(Button.JUMP)
*/