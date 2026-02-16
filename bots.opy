#!mainFile "soldier_x.opy"
#Global variables

globalvar spawn_bots = createWorkshopSetting(bool, "Bots", "Spawn bots (Recommended)", true, 0)

#Player variables

playervar reaper_view_angle
playervar reaper_hello_cooldown
playervar reaper_turn_speed
playervar reaper_brain_information
playervar reaper_aggro_list
playervar reaper_has_respawned_once
playervar last_known_position_of_target

#Subroutine names

subroutine reaper_has_a_target
subroutine reaper_target_lost

rule "BOT SYSTEM - - - Bot INIT":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    
    eventPlayer.reaper_view_angle = 90
    eventPlayer.reaper_turn_speed = 200
    #eventPlayer.setMaxHealth(200)
    #eventPlayer.setMaxHealth(1000)
    #[0] = Damage, [1] = Health, [2] = Speed, [3] = Armor, [4] = Shields, [5] = XP, [6] = Voice, [7] = Berserker Helper, [8] = Size, [9] = Knockback Resist
    eventPlayer.stats = [100, 166.666, 75, 0, 0, 1, 1, 0, 1, 100]
    #[0] = Current Target, [1] = Searching For Target, [2] = Using Teleport Ability, [3] = Is Pathfinding, [4] = Is Changing Direction
    eventPlayer.reaper_brain_information = [null, false, false, false, false]
    eventPlayer.reaper_aggro_list = []
    eventPlayer.setMoveSpeed(75)
    eventPlayer.reaper_has_respawned_once = false
    eventPlayer.reaper_hello_cooldown = 0
    chase(eventPlayer.reaper_hello_cooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    #eventPlayer.startHoT(eventPlayer, 9999, 500)


rule "BOT SYSTEM - - - Add Player To Aggro List":
    @Event playerTookDamage
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.reaper_brain_information[0] == null
    
    if attacker.getCurrentHero() == Hero.SOLDIER and eventPlayer.reaper_aggro_list == []:
        eventPlayer.reaper_aggro_list[0] = attacker
        return
    if attacker.getCurrentHero() == Hero.SOLDIER and attacker in victim.reaper_aggro_list == false:
        eventPlayer.reaper_aggro_list = eventPlayer.reaper_aggro_list.concat(attacker)


rule "BOT SYSTEM - - - Bot Got Aggro":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.reaper_aggro_list != []
    @Condition eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER
    @Condition eventPlayer.reaper_brain_information[2] == false
    @Condition eventPlayer.reaper_brain_information[1] == false
    
    async(reaper_has_a_target, AsyncBehavior.NOOP)


rule "BOT SYSTEM - - - Bot Brain - What to do next?":
    @Event eachPlayer
    @Hero reaper
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
    
    eventPlayer.random_integer_between_0_to_5 = random.randint(0, 9)
    if eventPlayer.random_integer_between_0_to_5 <= 1 and eventPlayer.reaper_hello_cooldown == 0:
        eventPlayer.communicate(Comms.HELLO)
        eventPlayer.reaper_hello_cooldown = 10
    eventPlayer.reaper_brain_information[3] = false
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getPosition() + Vector.UP) if eventPlayer.reaper_brain_information[0] != null and eventPlayer.reaper_brain_information[1] == false else directionTowards(eventPlayer.getEyePosition(), eventPlayer.last_known_position_of_target[0]) if eventPlayer.reaper_brain_information[0] != null and eventPlayer.reaper_brain_information[1] == true else directionTowards(eventPlayer.getEyePosition(), eventPlayer.last_known_position_of_target[1] + Vector.UP) if eventPlayer.reaper_brain_information[0] == null and eventPlayer.reaper_brain_information[1] == false else 0, 1000 if eventPlayer.reaper_brain_information[2] == true else 150, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    if eventPlayer.reaper_aggro_list == []:
        #If there is a player in sight, set the player as the current target
        eventPlayer.reaper_brain_information[0] = (sorted([player for player in eventPlayer.getPlayersInViewAngle(Team.ALL, 90) if player.getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), player.getPosition()) <= 30 and player.isAlive() and player.browsing_shop == false and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and player.is_using_ability[Talent.STEALTH] == false], lambda i: distance(eventPlayer.getPosition(), i.getPosition())))[0]
    else:
        #Set the player on top of the aggro list as the current target
        eventPlayer.reaper_brain_information[0] = eventPlayer.reaper_aggro_list[0]
    waitUntil(not isInLoS(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) or eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER or eventPlayer.isDead() or eventPlayer.reaper_brain_information[0].browsing_shop == true or eventPlayer.reaper_brain_information[0].isDead() or eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == true, 99999)
    if eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER or eventPlayer.isDead() or eventPlayer.reaper_brain_information[0].browsing_shop == true or eventPlayer.reaper_brain_information[0].isDead() or eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == true:
        eventPlayer.reaper_aggro_list = []
        eventPlayer.reaper_brain_information[0] = null
        return
    #If Current Target Can't Be Seen
    if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isAlive() and eventPlayer.reaper_brain_information[0].isAlive() or eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == true:
        reaper_target_lost()
    #If Current Target Is Found Again
    if isInLoS(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isAlive() and eventPlayer.reaper_brain_information[0].isAlive() and eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == false and eventPlayer.reaper_brain_information[0].browsing_shop == false:
        wait()
        goto RULE_START
    #If Reaper Died
    #return
    #If current target is out of sight or dead
    if eventPlayer.reaper_brain_information[0].isDead() or eventPlayer.reaper_brain_information[0].browsing_shop == true or eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER or not isInLoS(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) or eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == true:
        eventPlayer.reaper_aggro_list = eventPlayer.reaper_aggro_list.exclude(eventPlayer.reaper_brain_information[0])
        #Current target is out of sight or dead, is there more aggroed players in sight?
        #return
        eventPlayer.random_integer_between_0_to_5 = random.randint(0, 9)
        if eventPlayer.random_integer_between_0_to_5 <= 1 and eventPlayer.reaper_hello_cooldown == 0:
            eventPlayer.communicate(Comms.GOODBYE)
            eventPlayer.reaper_hello_cooldown = 10
        eventPlayer.reaper_aggro_list = []
        eventPlayer.reaper_brain_information[0] = null


def reaper_target_lost():
    @Name "BOT SYSTEM - - - [SUBROUTINE] Bot Lost the Target"
    
    eventPlayer.last_known_position_of_target[0] = null
    eventPlayer.last_known_position_of_target[1] = null
    eventPlayer.last_known_position_of_target[0] = eventPlayer.reaper_brain_information[0].getPosition()
    wait(0.032)
    eventPlayer.last_known_position_of_target[0] = eventPlayer.reaper_brain_information[0].getPosition() + vectorTowards(eventPlayer.reaper_brain_information[0], eventPlayer.last_known_position_of_target[0]) * 12
    eventPlayer.last_known_position_of_target[1] = eventPlayer.reaper_brain_information[0].getPosition()
    eventPlayer.reaper_brain_information[1] = true
    waitUntil(isInLoS(eventPlayer.getEyePosition(), eventPlayer.reaper_brain_information[0].getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.reaper_brain_information[0].is_using_ability[Talent.STEALTH] == false or eventPlayer.reaper_brain_information[0].isDead() or eventPlayer.isDead() or distance(eventPlayer.getPosition() + Vector.UP, eventPlayer.last_known_position_of_target[0] + Vector.UP) < 1, 5)
    eventPlayer.reaper_brain_information[1] = false


rule "BOT SYSTEM - - - Bot Moving - Towards Target / Searching For Target":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.reaper_brain_information[0].getCurrentHero() == Hero.SOLDIER
    @Condition distance(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[0].getPosition()) > 7
    @Condition eventPlayer.reaper_brain_information[2] == false
    
    wait(0.25, Wait.RESTART_WHEN_TRUE)
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[0].getPosition()) if eventPlayer.reaper_brain_information[1] == false else directionTowards(eventPlayer.getPosition(), eventPlayer.last_known_position_of_target[0]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    waitUntil(eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER or eventPlayer.reaper_brain_information[2] == true or eventPlayer.reaper_brain_information[0].getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[0].getPosition()) <= 7 and eventPlayer.reaper_brain_information[1] == false, 99999)
    eventPlayer.stopThrottleInDirection()
    if RULE_CONDITION:
        goto RULE_START


rule "BOT SYSTEM - - - Bot Start Shooting":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.reaper_brain_information[0].getCurrentHero() == Hero.SOLDIER
    @Condition eventPlayer.reaper_brain_information[2] == false
    @Condition eventPlayer.reaper_brain_information[1] == false
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    waitUntil(eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER or eventPlayer.reaper_brain_information[1] == true or eventPlayer.reaper_brain_information[2] == true, 99999)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    if RULE_CONDITION:
        goto RULE_START

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
    eventPlayer.setMaxHealth(eventPlayer.stats[1])
    heal(eventPlayer, null, eventPlayer.getMaxHealth())


rule "BOT SYSTEM - - - Bot Died":
    @Event playerDied
    @Hero reaper
    @Condition spawn_bots == true
    
    #eventPlayer.setGravity(100)
    eventPlayer.reaper_brain_information[0] = null
    eventPlayer.reaper_aggro_list = []
    eventPlayer.stopFacing()
    eventPlayer.reaper_brain_information[1] = false
    eventPlayer.stopThrottleInDirection()
    eventPlayer.reaper_brain_information[3] = false
    waitUntil(eventPlayer.isAlive() and eventPlayer.hasSpawned(), 99999)
    #eventPlayer.setGravity(50)


rule "BOT SYSTEM - - - Bot Use Teleport":
    @Event eachPlayer
    @Hero reaper
    @Condition spawn_bots == true
    @Condition eventPlayer.reaper_brain_information[0].getCurrentHero() == Hero.SOLDIER
    @Condition eventPlayer.talent_counter_or_position_etc[7] == 0
    @Condition eventPlayer.hit_by_talent[Talent.DIVE_BOMB] == null
    @Condition distance(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[0].getPosition()) >= 5
    @Condition (eventPlayer.getVerticalFacingAngle() + 89 < 59 and eventPlayer.reaper_brain_information[0].isOnGround() or eventPlayer.reaper_brain_information[1] == true and eventPlayer.getVerticalFacingAngle() + 89 < 59 or eventPlayer.reaper_brain_information[0].getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[0].getPosition()) >= 35) == true
    
    eventPlayer.reaper_brain_information[2] = true
    wait(0.25)
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    wait(0.125)
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
    wait(2)
    if eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0:
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
    eventPlayer.reaper_brain_information[2] = false

/*
def start_pathfinding():
    @Name "BOT SYSTEM - - - [SUBROUTINE] Start Pathfinding [DEFAULT: OFF]"
    
    eventPlayer.reaper_brain_information[3] = true
    eventPlayer.stopFacing()
    eventPlayer.stopThrottleInDirection()
    eventPlayer.pathfinding_pos_pre_current_next[2] = pathfinding_positions.index((sorted([player for player in pathfinding_positions if isInLoS(eventPlayer.getPosition() + vect(0, 0.7, 0), player, BarrierLos.PASS_THROUGH_BARRIERS) == true], lambda i: distance(eventPlayer.getPosition(), i)))[0])
    eventPlayer.pathfinding_pos_pre_current_next[0] = random.choice([i for i in pathfinding_connections[eventPlayer.pathfinding_pos_pre_current_next[2]] if i != eventPlayer.pathfinding_pos_pre_current_next[0]])
    if eventPlayer.pathfinding_pos_pre_current_next[2] == -1 * 1 * 1 * 1:
        return
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), pathfinding_positions[eventPlayer.pathfinding_pos_pre_current_next[2]]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.startFacing(directionTowards(eventPlayer.getPosition(), pathfinding_positions[eventPlayer.pathfinding_pos_pre_current_next[2]]), 200, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(1)
    while eventPlayer.isAlive() == true and eventPlayer.reaper_brain_information[0].getCurrentHero() != Hero.SOLDIER:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), pathfinding_positions[eventPlayer.pathfinding_pos_pre_current_next[2]]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
        waitUntil(distance(eventPlayer.getPosition(), pathfinding_positions[eventPlayer.pathfinding_pos_pre_current_next[2]]) <= 1.5 or eventPlayer.reaper_brain_information[3] == false, 10)
        #If Pathfinding was interrupted.
        if eventPlayer.reaper_brain_information[3] == false:
            return
        #Did not find next node. Restart...
        if eventPlayer.reaper_brain_information[3] == true and distance(eventPlayer.getPosition(), pathfinding_positions[eventPlayer.pathfinding_pos_pre_current_next[2]]) > 1.5:
            wait()
            goto RULE_START
        eventPlayer.pathfinding_pos_pre_current_next[1] = eventPlayer.pathfinding_pos_pre_current_next[2]
        eventPlayer.stopThrottleInDirection()
        eventPlayer.pathfinding_pos_pre_current_next[2] = random.choice([i for i in pathfinding_connections[eventPlayer.pathfinding_pos_pre_current_next[2]] if i != eventPlayer.pathfinding_pos_pre_current_next[0]])
        eventPlayer.reaper_brain_information[4] = true
        wait(1)
        eventPlayer.reaper_brain_information[4] = false
        if eventPlayer.reaper_brain_information[3] == false:
            return
        #If there is a player in sight, set the player as the current target
        if ([player for player in eventPlayer.getPlayersInViewAngle(Team.ALL, 90) if player.getCurrentHero() == Hero.SOLDIER and distance(eventPlayer.getPosition(), player.getPosition()) <= 30 and player.isAlive() == true and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) == true and player.is_using_ability[Talent.STEALTH] == false]) != []:
            reaper_has_a_target()
            return
        eventPlayer.pathfinding_pos_pre_current_next[0] = eventPlayer.pathfinding_pos_pre_current_next[1]
        wait()
*/

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
    @Condition eventPlayer.reaper_brain_information[3] == true
    @Condition eventPlayer.reaper_brain_information[4] == false
    @Condition eventPlayer.getSpeed() < 1.5
    @Condition eventPlayer.isOnGround() == true
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.MELEE)
    eventPlayer.forceButtonPress(Button.JUMP)
*/