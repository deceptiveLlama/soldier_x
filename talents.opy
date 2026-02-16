#!mainFile "soldier_x.opy"
#Global variables

globalvar accurateTime

#Player variables

playervar can_be_executed
playervar created_predator_effects_on_self
playervar poison_vials_effectMemory
playervar entering_stealth_timer
playervar poison_vials_exitSpeed
playervar fire_soul_loop
playervar fireball_destination
playervar fireball_effects
playervar fireball_in_air
playervar fireball_loop
playervar gravity
playervar has_hit_the_ground = true
playervar health_regen_in_stealth_id
playervar ignore_pain_damage_resistance
/*playervar in_execution_range_effects*/
playervar jetpack_will_have_a_delay
/*playervar predator_effect_position_1
playervar predator_effect_position_2*/
playervar predator_effects = null
playervar poison_vials_projData
playervar railgun_hit_someone
playervar railgun_projectile_destination
playervar railgun_projectile_is_in_air
playervar railgun_raycasts_counter
playervar refresh_cryogenics_slow
/*playervar poisonous_dagger_enemies_hit*/
playervar cryogenics_slow_amount = 100
playervar cryogenics_slow_duration = 0
playervar time_since_freezing_rocket
playervar total_time_in_combat
/*playervar used_bandage_on*/
playervar victims_in_burning_soul_radius
playervar victims_in_fireball_radius
playervar xp_orb_location

#Subroutine names

subroutine purity_field_impulse
subroutine lifesteal_hps
subroutine railgun_projectile_is_in_air
subroutine already_at_full_health
subroutine health_potion_hps
subroutine health_potion_heal_over_time
subroutine fireball_casted
subroutine pyromaniac_heal_over_time
subroutine ignore_pain_volume
subroutine ignore_pain_hps
subroutine continue_primary_fire
subroutine in_stealth

#!extension explosionSounds
#!extension buffStatusEffects
#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension debuffStatusEffects
#!extension kineticExplosionEffects

rule "TALENT SYSTEM - - - [Reset timeElapsed chase]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_trigger_times[eventPlayer.bought_talents[0]] + talent_base_cooldowns[eventPlayer.bought_talents[0]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[0]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[0]] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.talent_trigger_times[eventPlayer.bought_talents[1]] + talent_base_cooldowns[eventPlayer.bought_talents[1]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[1]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[1]] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.talent_trigger_times[eventPlayer.bought_talents[2]] + talent_base_cooldowns[eventPlayer.bought_talents[2]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[2]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[2]] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.talent_trigger_times[eventPlayer.bought_talents[3]] + talent_base_cooldowns[eventPlayer.bought_talents[3]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[3]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[3]] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.talent_trigger_times[eventPlayer.bought_talents[4]] + talent_base_cooldowns[eventPlayer.bought_talents[4]] - eventPlayer.talent_ranks[eventPlayer.bought_talents[4]] * talent_cd_reduction_p_rank[eventPlayer.bought_talents[4]] <= eventPlayer.totalTimeElapsed
    
    wait(0.32, Wait.ABORT_WHEN_FALSE)
    stopChasingVariable(eventPlayer.totalTimeElapsed)
    chase(eventPlayer.totalTimeElapsed, 99999, rate=1, ChaseReeval.DESTINATION_AND_RATE)

def bloodthirst_effects():
    @Name "TALENT SYSTEM - - - [TALENT 0: BLOODTHIRST] [SUBROUTINE] Bloodthirst Effects"
    
    playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    createEffect(getAllPlayers(), Effect.HEAL_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[45] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[46] = getLastCreatedEntity()
    wait(1.5)
    destroyEffect(eventPlayer.player_temp_effects[45])
    destroyEffect(eventPlayer.player_temp_effects[46])

rule "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] Use Purity Field":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.PURITY_FIELD] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.PURITY_FIELD] + talent_base_cooldowns[Talent.PURITY_FIELD] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.is_using_ability[Talent.GUNSLINGER] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.railgun_charge == 0
    
    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH), 0.25)
    if eventPlayer.isHoldingButton(Button.CROUCH):
        return
    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH), 0.25)
    if not eventPlayer.isHoldingButton(Button.CROUCH):
        return
    eventPlayer.talent_trigger_times[Talent.PURITY_FIELD] = eventPlayer.totalTimeElapsed
    eventPlayer.is_using_ability[Talent.PURITY_FIELD] = true
    #A wait for juggernaut (and maybe more abilities) to run their "end code" first before this triggers
    wait()
    async(purity_field_impulse, AsyncBehavior.NOOP)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setDamageReceived(0.001)
    eventPlayer.clearStatusEffect(Status.STUNNED)
    eventPlayer.clearStatusEffect(Status.BURNING)
    eventPlayer.clearStatusEffect(Status.FROZEN)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.ANA_BIOTIC_GRENADE_INCREASED_HEALING, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[53] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.SPHERE, Color.WHITE, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.talent_counter_or_position_etc[1], 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[47] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.SPHERE, Color.YELLOW, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.talent_counter_or_position_etc[1], 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[48] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.GOOD_AURA, Color.WHITE, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.talent_counter_or_position_etc[1], 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[49] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[50] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED_SOUND, Color.TEAM_1, eventPlayer.getPosition() if eventPlayer.has_hit_the_ground == false else eventPlayer.talent_counter_or_position_etc[1], 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[51] = getLastCreatedEntity()
    eventPlayer.setHealingReceived(PURITY_FIELD_HEALING_RECEIVED)
    #eventPlayer.player_temp_effects[52] = getLastCreatedText()
    eventPlayer.setKnockbackReceived(0)
    eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)
    eventPlayer.startForcingPosition(eventPlayer.getPosition(), true)
    wait()
    eventPlayer.stopForcingPosition()
    eventPlayer.in_combat = 0
    waitUntil(eventPlayer.isOnGround() or eventPlayer.isDead() or eventPlayer.browsing_shop == true, 15)
    eventPlayer.has_hit_the_ground = true
    #eventPlayer.setMoveSpeed(25)
    async(player_slowed, AsyncBehavior.RESTART)
    eventPlayer.stopForcingThrottle()
    eventPlayer.talent_counter_or_position_etc[1] = eventPlayer.getPosition()
    waitUntil(distance(eventPlayer.getEyePosition(), eventPlayer.talent_counter_or_position_etc[1]) > 2.75 or eventPlayer.isDead() or eventPlayer.browsing_shop == true, PURITY_FIELD_DURATION)
    eventPlayer.talent_counter_or_position_etc[1] = null
    destroyEffect(eventPlayer.player_temp_effects[47])
    destroyEffect(eventPlayer.player_temp_effects[48])
    destroyEffect(eventPlayer.player_temp_effects[49])
    destroyEffect(eventPlayer.player_temp_effects[50])
    destroyEffect(eventPlayer.player_temp_effects[51])
    eventPlayer.setDamageReceived(100)
    if eventPlayer.talent_ranks[Talent.GUNSLINGER] == 0:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    #if eventPlayer.talent_ranks[Talent.SPRINTER] > 0 and eventPlayer.isUsingAbility1() or eventPlayer.is_using_ability[Talent.BANDAGE]:
    #        goto lbl_0
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    lbl_0:
    #destroyInWorldText(eventPlayer.player_temp_effects[52])
    eventPlayer.setHealingReceived(100)
    destroyEffect(eventPlayer.player_temp_effects[53])
    eventPlayer.setKnockbackReceived(100 if eventPlayer.talent_ranks[Talent.GIGACHAD] == 0 else 80 if eventPlayer.talent_ranks[Talent.GIGACHAD] == 1 else 60 if eventPlayer.talent_ranks[Talent.GIGACHAD] == 2 else 40 if eventPlayer.talent_ranks[Talent.GIGACHAD] == 3 else 20 if eventPlayer.talent_ranks[Talent.GIGACHAD] == 4 else 0)
    eventPlayer.is_using_ability[Talent.PURITY_FIELD] = false
    waitUntil(eventPlayer.browsing_shop == false, 99999)
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    


def purity_field_impulse():
    @Name "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] [SUBROUTINE] Purity Field Impulse"
    
    while eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        #Impulse
        (([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.has_hit_the_ground == false else eventPlayer.talent_counter_or_position_etc[1], 3.5, Team.ALL, LosCheck.OFF)) if player != eventPlayer and player.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).hit_by_talent)[1] = eventPlayer
        wait(0.125)


rule "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] Hit By Purity Field":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[1] != null
    
    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.hit_by_talent[1].talent_counter_or_position_etc[1], eventPlayer.getPosition())), -30), 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    eventPlayer.hit_by_talent[1] = null

rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Use Stealth":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.STEALTH] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.is_using_ability[Talent.STEALTH] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.in_combat == 0
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.talent_trigger_times[Talent.STEALTH] + talent_base_cooldowns[Talent.STEALTH] - eventPlayer.talent_ranks[Talent.STEALTH] * 4 <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    
    eventPlayer.entering_stealth = true
    chase(eventPlayer.entering_stealth_timer, 0 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, rate=0.113 - eventPlayer.talent_ranks[Talent.STEALTH] * 0.013 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, ChaseReeval.DESTINATION_AND_RATE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.entering_stealth = false
    in_stealth()

def in_stealth():
    @Name "TALENT SYSTEM - - - [STEALTH] [SUBROUTINE] In Stealth"

    eventPlayer.setInvisibility(Invis.ALL)
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_1, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    eventPlayer.is_using_ability[Talent.STEALTH] = true
    waitUntil(eventPlayer.entering_stealth_timer == 0, 99999)
    break_stealth()
    
rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Canceled Entering Stealth":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.STEALTH] > 0
    @Condition eventPlayer.entering_stealth == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    
    eventPlayer.entering_stealth = false
    stopChasingVariable(eventPlayer.entering_stealth_timer)
    eventPlayer.entering_stealth_timer = 0


rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Hit By Stealth Melee":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.STEALTH] != null
    
    playEffect(eventPlayer, DynamicEffect.ANA_BIOTIC_GRENAGE_NO_HEALING_SOUND, Color.WHITE, eventPlayer, 80)
    createEffect(getAllPlayers(), Effect.ANA_BIOTIC_GRENADE_NO_HEALING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[5] = getLastCreatedEntity()
    eventPlayer.setHealingReceived(0)
    waitUntil(eventPlayer.isDead() or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.is_using_ability[Talent.BANDAGE] == true, 4)
    if eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        goto lbl_0
    eventPlayer.setHealingReceived(100)
    lbl_0:
    eventPlayer.hit_by_talent[Talent.STEALTH] = null
    destroyEffect(eventPlayer.player_temp_effects[5])


rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Break Stealth If Being Loud":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.STEALTH] > 0
    @Condition eventPlayer.is_using_ability[Talent.STEALTH] == true
    @Condition (eventPlayer.isFiringPrimaryFire() or eventPlayer.isFiringSecondaryFire()) == true
    
    async(break_stealth, AsyncBehavior.NOOP)


def break_stealth():
    @Name "TALENT SYSTEM - - - [TALENT 5: STEALTH] [SUBROUTINE] Break Stealth"
    
    eventPlayer.is_using_ability[Talent.STEALTH] = false
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.talent_trigger_times[Talent.STEALTH] = eventPlayer.totalTimeElapsed
    stopChasingVariable(eventPlayer.entering_stealth_timer)
    eventPlayer.entering_stealth_timer = 0
    if eventPlayer.talent_ranks[Talent.HEALTH_REGEN] > 0:
        stopHoT(eventPlayer.health_regen_in_stealth_id)
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)

/*
rule "TALENT SYSTEM - - - [JUGGERNAUT] Use Juggernaut":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.JUGGERNAUT] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + talent_base_cooldowns[Talent.JUGGERNAUT] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.BANDAGE] == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition (not eventPlayer.hasStatusEffect(Status.PHASED_OUT) if eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false else eventPlayer.isAlive()) == true
    @Condition eventPlayer.dummy_var[0] == false
    @Condition eventPlayer.is_using_ability[Talent.JETPACK] == false
    @Condition eventPlayer.railgun_charge == 0
    
    eventPlayer.setKnockbackReceived(0)
    eventPlayer.has_hit_the_ground = false
    eventPlayer.is_using_ability[Talent.JUGGERNAUT] = true
    async(juggernaut_knockback, AsyncBehavior.NOOP)
    eventPlayer.setJumpEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setCrouchEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed + 60
    eventPlayer.clearStatusEffect(Status.FROZEN)
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    eventPlayer.setMoveSpeed(0)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP, Color.TEAM_1, eventPlayer, 1)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), eventPlayer.getPosition() + worldVector(vect(0, 1, 0), eventPlayer, Transform.ROTATION)), 5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.067)
    waitUntil(eventPlayer.isDead() or eventPlayer.isOnGround() or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true, 99999)
    eventPlayer.has_hit_the_ground = true
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 0, 0.333), eventPlayer, Transform.ROTATION) if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100 else eventPlayer.getEyePosition() + (worldVector(vect(0.5 if ((eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4) * 0.5 > 0.5 else (-0.5 if ((eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4) * 0.5 < -0.5 else eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4, 0.333, 0), eventPlayer, Transform.ROTATION)), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection(), getAllPlayers(), eventPlayer, true).getHitPosition() if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100 else eventPlayer.getEyePosition() + worldVector(vect(0, 0.25, 3), eventPlayer, Transform.ROTATION), 30 if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100 else 12)
    eventPlayer.startFacing(angleToDirection(eventPlayer.getHorizontalFacingAngle() + 0.4 if eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1, 0, 0), eventPlayer, Transform.ROTATION))) > 3.9 * eventPlayer.stats[2] / 100 else eventPlayer.getHorizontalFacingAngle() - 0.4 if eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1, 0, 0), eventPlayer, Transform.ROTATION))) < -3.9 * eventPlayer.stats[2] / 100 else eventPlayer.getHorizontalFacingAngle(), 0), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    #If the player lands on the ground too quick
    waitUntil(eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] <= eventPlayer.totalTimeElapsed + 59.4, eventPlayer.totalTimeElapsed + 59.4)
    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed
    eventPlayer.has_hit_the_ground = true
    if eventPlayer.isDead() or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        goto lbl_0
    async(cancel_ability, AsyncBehavior.NOOP)
    async(juggernaut_effects, AsyncBehavior.NOOP)
    eventPlayer.stopForcingThrottle()
    eventPlayer.setMoveSpeed(eventPlayer.stats[2] * 3)
    eventPlayer.startForcingThrottle(1, 1, 0, 0, 0, 0.25)
    eventPlayer.juggernaut_charge = 10
    waitUntil(eventPlayer.getSpeed() > 14 * eventPlayer.stats[2] / 100, 1)
    while eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.talent_counter_or_position_etc[6] == null and (eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() > 14 * eventPlayer.stats[2] / 100 or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 >= eventPlayer.totalTimeElapsed):
        #Pick up target
        (((sorted([player for player in getPlayersInRadius(eventPlayer.getPosition() + worldVector(vect(0, 1, 2.5), eventPlayer, Transform.ROTATION), 5, Team.ALL, LosCheck.OFF) if eventPlayer.isInViewAngle(player, 45) and isInLoS(eventPlayer.getEyePosition() + Vector.DOWN, player.getEyePosition() + Vector.DOWN, BarrierLos.PASS_THROUGH_BARRIERS) and player.getPosition().y < (eventPlayer.getEyePosition() + Vector.UP).y and player.getEyePosition().y > eventPlayer.getPosition().y and distance(eventPlayer.getPosition() + Vector.UP, player.getPosition() + Vector.UP) < 3 and player != eventPlayer and player.isAlive() and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false], lambda i: distance(eventPlayer.getPosition() + Vector.UP, i.getPosition() + Vector.UP)))[0]).hit_by_talent)[6] = eventPlayer
        wait()
        #If the player got a target
        if eventPlayer.talent_counter_or_position_etc[6] != null:
            while eventPlayer.talent_counter_or_position_etc[6] != null and eventPlayer.talent_counter_or_position_etc[6] != eventPlayer and eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and (eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() > 14 * eventPlayer.stats[2] / 100 or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 >= eventPlayer.totalTimeElapsed):
                (([player for player in getPlayersInRadius(eventPlayer.getPosition() + worldVector(vect(0, 1, 2.5), eventPlayer, Transform.ROTATION), 5, Team.ALL, LosCheck.OFF) if eventPlayer.isInViewAngle(player, 45) and isInLoS(eventPlayer.talent_counter_or_position_etc[6].getEyePosition() + Vector.DOWN, player.getEyePosition() + Vector.DOWN, BarrierLos.PASS_THROUGH_BARRIERS) and player.getPosition().y < (eventPlayer.getEyePosition() + Vector.UP).y and player.getEyePosition().y > eventPlayer.getPosition().y and distance(eventPlayer.getPosition() + Vector.UP, player.getPosition() + Vector.UP) < 4 and player != eventPlayer and player.isAlive() and player != eventPlayer.talent_counter_or_position_etc[6] and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false and player.hit_by_talent[Talent.CYBERNETICS] == null]).hit_by_talent)[2] = eventPlayer
                wait()
                waitUntil(eventPlayer.talent_counter_or_position_etc[6] == null or eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100, 0.048)
                if eventPlayer.talent_counter_or_position_etc[6] == null or eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100:
                    break
        if eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100:
            break
    if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[2] / 100 and eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false:
        (([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 4, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS) if player != eventPlayer and player.isAlive() and player != eventPlayer.talent_counter_or_position_etc[6] and player.hit_by_talent[Talent.JUGGERNAUT] != eventPlayer and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false and player.hit_by_talent[Talent.CYBERNETICS] == null]).hit_by_talent)[2] = eventPlayer
        damage([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 4, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS) if player != eventPlayer and player.hit_by_talent[Talent.JUGGERNAUT] != eventPlayer and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false], eventPlayer, JUGGERNAUT_DAMAGE)
        playEffect(getAllPlayers(), DynamicEffect.SIGMA_ACCRETION_IMPACT, Color.TEAM_1, eventPlayer.getPosition() + Vector.UP, 1)
        playEffect(getAllPlayers(), DynamicEffect.SIGMA_ACCRETION_IMPACT_SOUND, Color.TEAM_1, eventPlayer.getPosition() + Vector.UP, 100)
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT, Color.TEAM_1, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
    eventPlayer.setMoveSpeed(0)
    wait(0.125)
    eventPlayer.setJumpEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    lbl_0:
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.stopCamera()
    eventPlayer.setCrouchEnabled(true)
    eventPlayer.stopFacing()
    stopChasingVariable(eventPlayer.juggernaut_charge)
    eventPlayer.juggernaut_charge = 0
    eventPlayer.is_using_ability[Talent.JUGGERNAUT] = false
    eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    eventPlayer.stopForcingThrottle()
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.talent_counter_or_position_etc[6] = null
    eventPlayer.setKnockbackReceived(100)
*/

/*
def juggernaut_knockback():
    @Name "TALENT SYSTEM - - - [JUGGERNAUT] [SUBROUTINE] Juggernaut Knockback Start"
    
    #When doing the juggernaut start jump
    while eventPlayer.isAlive() and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true and eventPlayer.talent_counter_or_position_etc[6] == null and eventPlayer.has_hit_the_ground == false:
        (([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 5, Team.ALL, LosCheck.OFF) if eventPlayer.isInViewAngle(player, 45) and isInLoS(eventPlayer.talent_counter_or_position_etc[6].getEyePosition() + Vector.DOWN, player.getEyePosition() + Vector.DOWN, BarrierLos.PASS_THROUGH_BARRIERS) and player.getPosition().y < (eventPlayer.getEyePosition() + Vector.UP).y and player.getEyePosition().y > eventPlayer.getPosition().y and distance(eventPlayer.getPosition() + Vector.UP, player.getPosition() + Vector.UP) < 4 and player != eventPlayer and player.isAlive() and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false and player.hit_by_talent[Talent.CYBERNETICS] == null]).hit_by_talent)[2] = eventPlayer
        wait()
        waitUntil(eventPlayer.isDead() or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false or eventPlayer.talent_counter_or_position_etc[6] != null or eventPlayer.has_hit_the_ground == true, 0.048)
*/

/*
def juggernaut_effects():
    @Name "TALENT SYSTEM - - - [JUGGERNAUT] Juggernaut Effects"
    
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    wait(0.25)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    while eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0:
        playEffect(getAllPlayers() if eventPlayer.isOnGround() and eventPlayer.getSpeedInDirection(worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION)) > 5 else null, DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
        playEffect(getAllPlayers() if eventPlayer.isOnGround() and eventPlayer.getSpeedInDirection(worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION)) > 5 else null, DynamicEffect.REINHARDT_FIRE_STRIKE_TARGET_IMPACT, Color.TEAM_2, eventPlayer.getPosition() + worldVector(vect(0, 0, 0.25), eventPlayer, Transform.ROTATION), 1)
        wait(0.129)
        wait(0.129)
*/

/*
rule "TALENT SYSTEM - - - [JUGGERNAUT] Hit By Juggernaut":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.JUGGERNAUT] != null
    
    if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true and eventPlayer.has_hit_the_ground == true:
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_counter_or_position_etc[6] = null
        eventPlayer.talent_counter_or_position_etc[6] = null
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].juggernaut_charge = 0
        eventPlayer.juggernaut_charge = 0
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].setKnockbackReceived(100)
        eventPlayer.setKnockbackReceived(100)
        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
        return
    eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_counter_or_position_etc[6] = eventPlayer
    eventPlayer.attachTo(eventPlayer.hit_by_talent[Talent.JUGGERNAUT], vect(0, 0, 1))
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.hit_by_talent[Talent.JUGGERNAUT].getEyePosition()), 1500, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.setStatusEffect(null, Status.STUNNED, 10)
    waitUntil(eventPlayer.isDead() or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].isDead() or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].juggernaut_charge == 0 or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].getSpeed() <= 14 * eventPlayer.stats[2] / 100, 10)
    eventPlayer.stopFacing()
    eventPlayer.teleport(eventPlayer.hit_by_talent[Talent.JUGGERNAUT])
    eventPlayer.clearStatusEffect(Status.STUNNED)
    wait()
    if eventPlayer.isDead():
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_counter_or_position_etc[6] = null
        wait(0.032)
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT] = null
        return
    if eventPlayer.hit_by_talent[Talent.JUGGERNAUT].isAlive():
        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
        damage(eventPlayer, eventPlayer.hit_by_talent[Talent.JUGGERNAUT], JUGGERNAUT_VS_JUGGERNAUT_SELF_DAMAGE)
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT].talent_counter_or_position_etc[6] = eventPlayer.hit_by_talent[Talent.JUGGERNAUT]
        wait(0.032)
        eventPlayer.hit_by_talent[Talent.JUGGERNAUT] = null
*/

/*
rule "TALENT SYSTEM - - - [JUGGERNAUT] Juggernaut Hit By Impulse":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.CYBERNETICS] != null
    
    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.hit_by_talent[Talent.CYBERNETICS].getPosition() + worldVector(vect(0, 0, 0.75), eventPlayer.hit_by_talent[Talent.CYBERNETICS], Transform.ROTATION), eventPlayer.getPosition())), -15), 20 if eventPlayer.hit_by_talent[Talent.CYBERNETICS].talent_counter_or_position_etc[6] != null else 20 if eventPlayer.hit_by_talent[Talent.CYBERNETICS].talent_counter_or_position_etc[6] == eventPlayer.hit_by_talent[Talent.CYBERNETICS] else 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    async(juggernaut_impulse_sound_cd, AsyncBehavior.NOOP)
    wait()
    eventPlayer.hit_by_talent[Talent.CYBERNETICS] = null
*/

/*
def juggernaut_impulse_sound_cd():
    @Name "TALENT SYSTEM - - - [JUGGERNAUT] [SUBROUTINE] Juggernaut Impulse Sound Cooldown"
    
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    wait(0.333)
*/

def cancel_ability():
    @Name "TALENT SYSTEM - - - Cancel Juggernaut or Bandage"
    
    wait(0.5)
    if eventPlayer.isDead():
        return
    if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true:
        if eventPlayer.isHoldingButton(Button.INTERACT):
            waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false, 10)
        if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false:
            return
        if not eventPlayer.isHoldingButton(Button.INTERACT):
            waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false, 10)
        if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false:
            return
        if eventPlayer.isAlive() and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true:
            eventPlayer.juggernaut_charge = 0
    elif eventPlayer.is_using_ability[Talent.BANDAGE] == true:
        if eventPlayer.isHoldingButton(Button.MELEE):
            waitUntil(not eventPlayer.isHoldingButton(Button.MELEE) or eventPlayer.is_using_ability[Talent.BANDAGE] == false, 10)
        if eventPlayer.is_using_ability[Talent.BANDAGE] == false:
            return
        if not eventPlayer.isHoldingButton(Button.MELEE):
            waitUntil(eventPlayer.isHoldingButton(Button.MELEE) or eventPlayer.is_using_ability[Talent.BANDAGE] == false, 10)
        if eventPlayer.is_using_ability[Talent.BANDAGE] == false:
            return
        if eventPlayer.isAlive() and eventPlayer.is_using_ability[Talent.BANDAGE] == true:
            eventPlayer.is_using_ability[Talent.BANDAGE] = false

rule "TALENT SYSTEM - - - [DIVE BOMB] Use Dive Bomb":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[7] > 0
    @Condition eventPlayer.is_using_ability[1] == false
    @Condition eventPlayer.is_using_ability[17] == false
    @Condition eventPlayer.is_using_ability[7] == false
    @Condition eventPlayer.is_using_ability[6] == false
    @Condition eventPlayer.is_using_ability[11] == false
    @Condition eventPlayer.is_using_ability[23] == false
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[7] + talent_base_cooldowns[7] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.getAltitude() > 3
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.dummy_var[10] == false
    
    eventPlayer.is_using_ability[7] = true
    eventPlayer.dive_bomb_damage = DIVE_BOMB_DAMAGE
    eventPlayer.setJumpEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    if eventPlayer.is_using_ability[5] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    eventPlayer.talent_trigger_times[7] = eventPlayer.totalTimeElapsed
    playEffect(getAllPlayers(), DynamicEffect.SOLDIER_SPRINT_START_SOUND, Color.TEAM_1, eventPlayer, 100)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP, Color.TEAM_2, eventPlayer, 1)
    playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition() + Vector.UP, 100)
    eventPlayer.startForcingPosition(eventPlayer.getPosition(), true)
    wait()
    eventPlayer.stopForcingPosition()
    eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -3, getAllPlayers(), eventPlayer, true).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3, null, getAllPlayers(), true).getHitPosition(), 20)
    eventPlayer.applyImpulse(Vector.UP, 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.35)
    createEffect(getAllPlayers(), Effect.ASHE_DYNAMITE_BURNING_PARTICLE, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[0] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[1] = getLastCreatedEntity()
    playEffect(getAllPlayers(), DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_2, eventPlayer, 100)
    wait(0.35)
    chase(eventPlayer.dive_bomb_damage, 2 * DIVE_BOMB_DAMAGE, duration=1, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.applyImpulse(eventPlayer.getFacingDirection() if eventPlayer.getVerticalFacingAngle() > 0 else worldVector(vect(0, 0, 1), eventPlayer, Transform.ROTATION), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, true)
    createEffect(getAllPlayers(), Effect.ENERGY_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[2] = getLastCreatedEntity()
    while eventPlayer.isAlive() and eventPlayer.isInAir():
        playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer, 1)
        wait(0.25)
    destroyEffect(eventPlayer.player_temp_effects[0])
    destroyEffect(eventPlayer.player_temp_effects[1])
    destroyEffect(eventPlayer.player_temp_effects[2])
    stopChasingVariable(eventPlayer.dive_bomb_damage)
    eventPlayer.stopCamera()
    if eventPlayer.isAlive():
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
        #Impulse
        (([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 5, Team.ALL, LosCheck.SURFACES) if player.is_using_ability[1] == false and player.is_using_ability[17] == false and player != eventPlayer and player.browsing_shop == false and player.isAlive()]).hit_by_talent)[7] = eventPlayer
        wait(0.125)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
    eventPlayer.is_using_ability[7] = false
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, false)
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setJumpEnabled(true)

rule "TALENT SYSTEM - - - [DIVE BOMB] Hit By Dive Bomb":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.DIVE_BOMB] != null
    
    if eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.hit_by_talent[Talent.DIVE_BOMB] = null
        return
    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.hit_by_talent[Talent.DIVE_BOMB].getPosition(), eventPlayer.getPosition())), -22.5), eventPlayer.hit_by_talent[Talent.DIVE_BOMB].dive_bomb_damage / 10 * (eventPlayer.stats[9] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    wait()
    damage(eventPlayer, eventPlayer.hit_by_talent[Talent.DIVE_BOMB], eventPlayer.hit_by_talent[Talent.DIVE_BOMB].dive_bomb_damage)
    eventPlayer.hit_by_talent[Talent.DIVE_BOMB] = null
    eventPlayer.talent_counter_or_position_etc[7] = 3
    while eventPlayer.talent_counter_or_position_etc[7] > 0 and eventPlayer.hit_by_talent[Talent.DIVE_BOMB] == null and eventPlayer.isAlive():
        playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer, 1)
        eventPlayer.talent_counter_or_position_etc[7] -= 1
        wait(0.5, Wait.RESTART_WHEN_TRUE)

rule "TALENT SYSTEM - - - [TALENT 8: CRYOGENICS] Hit By Cryogenics":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.CRYOGENICS] != null
    
    if eventPlayer.is_using_ability[Talent.SHADOWSTEP] == true:
        eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
        return
    if eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
        return
    if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true:
        eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
        return
    #Is affected by ability
    eventPlayer.is_using_ability[Talent.CRYOGENICS] = false
    if eventPlayer.hit_by_talent[Talent.CRYOGENICS] == eventPlayer:
        eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
        return
    #Is affected by ability
    eventPlayer.is_using_ability[Talent.CRYOGENICS] = true
    stopChasingVariable(eventPlayer.time_since_freezing_rocket)
    eventPlayer.time_since_freezing_rocket = 0
    chase(eventPlayer.time_since_freezing_rocket, 3, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    #If the incoming freezing rocket has a higher duration
    if 2 + eventPlayer.hit_by_talent[Talent.CRYOGENICS].talent_ranks[Talent.CRYOGENICS] * 0.2 > eventPlayer.cryogenics_slow_duration - eventPlayer.time_since_freezing_rocket:
        eventPlayer.cryogenics_slow_duration = CRYOGENICS_SLOW_DURATION
    #If the incoming freezing rocket has a higher slow amount
    if CRYOGENICS_SLOW_AMOUNT < eventPlayer.cryogenics_slow_amount:
        eventPlayer.cryogenics_slow_amount = CRYOGENICS_SLOW_AMOUNT
    eventPlayer.refresh_cryogenics_slow = true
    eventPlayer.hit_by_talent[Talent.CRYOGENICS] = null
    waitUntil(eventPlayer.cryogenics_slow_duration == 0 or eventPlayer.hit_by_talent[Talent.CRYOGENICS] != null or eventPlayer.is_using_ability[Talent.BANDAGE] == true, 9999)
    if eventPlayer.hit_by_talent[Talent.CRYOGENICS] != null:
        goto RULE_START
    #Is affected by ability
    eventPlayer.is_using_ability[Talent.CRYOGENICS] = false
    stopChasingVariable(eventPlayer.time_since_freezing_rocket)
    eventPlayer.time_since_freezing_rocket = 0

rule "TALENT SYSTEM - - - [TALENT 8: CRYOGENICS] Travel Time":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.CRYOGENICS] > 0
    @Condition eventPlayer.using_cryogenics == false
    @Condition eventPlayer.cryogenics_travel_time == 0
    @Condition (eventPlayer.isFiringSecondaryFire() == true or eventPlayer.railgun_projectile_is_in_air == true) == true
    @Condition eventPlayer.talent_trigger_times[Talent.CRYOGENICS] + talent_base_cooldowns[Talent.CRYOGENICS] <= eventPlayer.totalTimeElapsed
    
    eventPlayer.using_cryogenics = true
    chase(eventPlayer.cryogenics_travel_time, 6, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.talent_ranks[Talent.CRYOGENICS] == 0 or eventPlayer.cryogenics_travel_time == 6 or eventPlayer.talent_trigger_times[Talent.CRYOGENICS] == eventPlayer.totalTimeElapsed - eventPlayer.cryogenics_travel_time, 99999)
    stopChasingVariable(eventPlayer.cryogenics_travel_time)
    eventPlayer.cryogenics_travel_time = 0
    wait()
    eventPlayer.using_cryogenics = false

rule "TALENT SYSTEM - - - [TALENT 9: RAILGUN] Charge Railgun":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] > 0
    @Condition eventPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isReloading() == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    #Using hearthstone
    @Condition eventPlayer.dummy_var[0] == false
    
    #is charging railgun
    eventPlayer.is_charging_railgun = true
    chase(eventPlayer.railgun_charge, 100, rate=100, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.setPrimaryFireEnabled(false)
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2] * 0.5)
    async(player_slowed, AsyncBehavior.RESTART)
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isDead() or eventPlayer.browsing_shop == true or eventPlayer.isUsingAbility1() or eventPlayer.isMeleeing() or eventPlayer.is_using_ability[Talent.RAILGUN] == true or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN), 99999)
    eventPlayer.is_charging_railgun = false
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
        eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
        async(continue_primary_fire, AsyncBehavior.NOOP)
    wait()
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    stopChasingVariable(eventPlayer.railgun_charge)
    wait()
    eventPlayer.railgun_charge = 0

def continue_primary_fire():
        @Name "Subroutine continue_primary_fire"
    
    waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 99999)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    
/*
rule "TALENT SYSTEM - - - [TALENT 9: RAILGUN] Discharge Railgun":
    @Event eachPlayer
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] > 0
    @Condition eventPlayer.railgun_discharge == 0
    
    chase(eventPlayer.railgun_charge, 0, rate=10, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.railgun_charge == 0 or eventPlayer.railgun_discharge == 6, 99999)
    stopChasingVariable(eventPlayer.railgun_charge)
*/
rule "TALENT SYSTEM - - - [TALENT 9: RAILGUN] Use Railgun":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] > 0
    @Condition eventPlayer.dummy_var[0] == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.railgun_charge >= 100
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.isReloading() == false

    eventPlayer.setAmmo(0, eventPlayer.getAmmo(0) + 1)
    eventPlayer.is_using_ability[Talent.RAILGUN] = true
    eventPlayer.talent_trigger_times[Talent.RAILGUN] = eventPlayer.totalTimeElapsed - eventPlayer.talent_ranks[Talent.OVERCLOCK]
    if eventPlayer.railgun_charge >= 100:
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    eventPlayer.railgun_hit_someone = false
    eventPlayer.railgun_projectile_destination = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, getAllPlayers(), eventPlayer, true).getHitPosition()
    async(railgun_projectile_is_in_air, AsyncBehavior.NOOP)
    eventPlayer.is_using_ability[Talent.RAILGUN] = false
    eventPlayer.railgun_projectile_start = []
    if eventPlayer.getCurrentHero() != Hero.SOLDIER and eventPlayer.getCurrentHero() != Hero.REAPER:

def railgun_projectile_is_in_air():
    @Name "TALENT SYSTEM - - - [TALENT 9: RAILGUN] [SUBROUTINE] Railgun Projectile Is In Air"
    
    eventPlayer.railgun_projectile_is_in_air = true
    #createBeam(getAllPlayers() if eventPlayer.railgun_projectile_is_in_air == true else null, Beam.BAD, evalOnce(eventPlayer.getPosition() + worldVector(vect(-1 * 1 * 1 * 0.25, 1.375, 0), eventPlayer, Transform.ROTATION) if eventPlayer.isCrouching() == false e
    createBeam(getAllPlayers() if eventPlayer.railgun_projectile_is_in_air == true else null, Beam.BAD, evalOnce(eventPlayer.getPosition() + worldVector(vect(-0.25, 0.875, 0), eventPlayer, Transform.ROTATION) if eventPlayer.isCrouching() else eventPlayer.getPosition() + worldVector(vect(-0.25, 1.375, 0), eventPlayer, Transform.ROTATION)), eventPlayer.railgun_projectile_destination, Color.SKY_BLUE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[30] = getLastCreatedEntity()
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 100)
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_CONCUSSIVE_BLAST, Color.TEAM_1, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 1)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_1, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 1)
    wait(0.375)
    destroyEffect(eventPlayer.player_temp_effects[30])
    eventPlayer.railgun_projectile_is_in_air = false
    eventPlayer.railgun_projectile_start = []
    eventPlayer.railgun_projectile_player_hit = []

/*
rule "TALENT SYSTEM - - - [TALENT 10: PREDATOR] Hit By Predator":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.PREDATOR] != null
    
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1)
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    eventPlayer.predator_effect_position_1 = worldVector(vect(1, 2, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition()
    eventPlayer.predator_effect_position_2 = worldVector(vect(-1 * 1 * 1 * 1, 2, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition()
    createBeam(getAllPlayers(), Beam.BAD, worldVector(vect(1, 2, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition(), eventPlayer.predator_effect_position_1, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.predator_effects.append(getLastCreatedEntity())
    createBeam(getAllPlayers(), Beam.BAD, worldVector(vect(-1 * 1 * 1 * 1, 2, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition(), eventPlayer.predator_effect_position_2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.predator_effects.append(getLastCreatedEntity())
    chase(eventPlayer.predator_effect_position_1, worldVector(vect(-1 * 1 * 1 * 1, 0, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition(), duration=0.25, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.predator_effect_position_2, worldVector(vect(1, 0, 0), eventPlayer.hit_by_talent[Talent.PREDATOR], Transform.ROTATION) + eventPlayer.getPosition(), duration=0.25, ChaseReeval.DESTINATION_AND_DURATION)
    wait(0.25)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.RED, eventPlayer, 3)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.SKY_BLUE, eventPlayer, 50)
    kill(eventPlayer, eventPlayer.hit_by_talent[Talent.PREDATOR])
    destroyEffect(eventPlayer.predator_effects[1])
    destroyEffect(eventPlayer.predator_effects[2])
    eventPlayer.hit_by_talent[Talent.PREDATOR] = null
    eventPlayer.predator_effects = null
    wait(0.05)
    stopChasingVariable(eventPlayer.predator_effect_position_1)
    stopChasingVariable(eventPlayer.predator_effect_position_2)
    eventPlayer.predator_effect_position_1 = null
    eventPlayer.predator_effect_position_2 = null
    wait(3)
*/
/*
rule "TALENT SYSTEM - - - [TALENT 10: PREDATOR] Create Predator Effect On Myself":
    @Event eachPlayer
    @Condition any([player.talent_ranks[Talent.PREDATOR] > 0 for player in getAllPlayers()]) == true
    #when my health is <25%
    @Condition eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25
    @Condition eventPlayer.created_predator_effects_on_self == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.browsing_shop == false
    
    eventPlayer.created_predator_effects_on_self = true

    createEffect([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 0 and eventPlayer.getHealth() < eventPlayer.getMaxHealth() * 0.25 and eventPlayer.isAlive() == true and player != eventPlayer and player.talent_trigger_times[Talent.PREDATOR] + talent_base_cooldowns[Talent.PREDATOR] - player.talent_ranks[Talent.PREDATOR] * PREDATOR_COOLDOWN_REDUCTION_PER_RANK <= player.totalTimeElapsed], Effect.ECHO_CLONING, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    eventPlayer.in_execution_range_effects = getLastCreatedEntity()

    eventPlayer.startForcingOutlineFor([player for player in getAllPlayers() if player.talent_ranks[Talent.PREDATOR] > 0], true, Color.RED, OutlineVisibility.ALWAYS)

    eventPlayer.can_be_executed = true
*/
/*
rule "TALENT SYSTEM - - - [TALENT 10: PREDATOR] Remove Predator Effect On Myself":
    @Event eachPlayer
    #when my health is >=25%
    @Condition eventPlayer.getHealth() >= eventPlayer.getMaxHealth() * 0.25
    @Condition eventPlayer.created_predator_effects_on_self == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.created_predator_effects_on_self = false
    eventPlayer.can_be_executed = false
    destroyEffect(eventPlayer.in_execution_range_effects)
    eventPlayer.stopForcingOutlineFor(getAllPlayers())
*/
rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Use Jetpack":
    @Event eachPlayer
    @Condition eventPlayer.talent_ranks[Talent.JETPACK] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false
    @Condition eventPlayer.has_hit_the_ground == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition (eventPlayer.getCurrentHero() == Hero.SOLDIER or eventPlayer.getCurrentHero() == Hero.BRIGITTE) == true
    
    if eventPlayer.jetpack_will_have_a_delay == true:
        wait(0.25, Wait.ABORT_WHEN_FALSE)
        eventPlayer.jetpack_will_have_a_delay = false
    if eventPlayer.getCurrentHero() == Hero.SOLDIER:
        eventPlayer.stopForcingButton(Button.ABILITY_1)
        eventPlayer.setAbility1Enabled(false)
    eventPlayer.is_using_ability[Talent.JETPACK] = true
    waitUntil(not eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.jetpack_fuel == 0, 9999)
    eventPlayer.is_using_ability[Talent.JETPACK] = false
    if eventPlayer.getCurrentHero() == Hero.SOLDIER:
        if eventPlayer.is_using_ability[Talent.CRYOGENICS] == false:
            eventPlayer.setAbility1Enabled(true)


rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Jetpack Effects":
    @Event eachPlayer
    @Condition eventPlayer.is_using_ability[Talent.JETPACK] == true
    @Condition (eventPlayer.getCurrentHero() == Hero.SOLDIER or eventPlayer.getCurrentHero() == Hero.BRIGITTE) == true
    
    playEffect(null if eventPlayer.is_using_ability[Talent.STEALTH] == true else getAllPlayers().exclude(eventPlayer), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition() + worldVector(vect(0, 1.5, -0.5), eventPlayer, Transform.ROTATION), 1)
    wait(0.125)
    if RULE_CONDITION:
        goto RULE_START


rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Jetpack Will Have a Delay":
    @Event eachPlayer
    @Condition eventPlayer.talent_ranks[Talent.JETPACK] > 0
    @Condition eventPlayer.isOnGround() == true
    @Condition (eventPlayer.getCurrentHero() == Hero.SOLDIER or eventPlayer.getCurrentHero() == Hero.BRIGITTE) == true
    
    eventPlayer.jetpack_will_have_a_delay = true

def health_regen_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 13: HEALTH REGEN] [SUBROUTINE] Health Regen Heal Over Time"
    
    while eventPlayer.talent_ranks[Talent.HEALTH_REGEN] > 0:
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 0, 99999)
        eventPlayer.startHoT(null, 99999, HEALTH_REGEN_HEALING_OVER_TIME)
        eventPlayer.health_pool_id_or_hot_id[2] = getLastHoT()
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) >= eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 0, 99999)
        stopHoT(eventPlayer.health_pool_id_or_hot_id[2])

rule "TALENT SYSTEM - - - [TALENT 14/31: HEALTH POTIONS/POISON VIAL] Use Health Potion or Poison Vial":
    @Event eachPlayer
    @Hero soldier
    @Condition (eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0) == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] == false
    @Condition eventPlayer.amount_of_potions_or_vials > 0
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    
    #So the code can detect if the player is casting purity field at the same time
    wait()
    if eventPlayer.getHealthOfType(Health.NORMAL) == eventPlayer.getMaxHealthOfType(Health.NORMAL) and eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
        async(already_at_full_health, AsyncBehavior.NOOP)
        return
    if (eventPlayer.isUsingAbility1() or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true) and eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
        return
    eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] = true
    if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
        health_potion_hps()
        playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 100)
        playEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.STEALTH] == false else eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT, Color.TEAM_1, eventPlayer, 100)
        eventPlayer.startHoT(eventPlayer, 2, HEALTH_POTIONS_HEALING_OVER_TIME)
        #health_pool_id[4] & health_pool_id[5] & health_pool_id[6] &
        eventPlayer.health_pool_id_or_hot_id[7 - eventPlayer.amount_of_potions_or_vials] = getLastHoT()
        eventPlayer.amount_of_potions_or_vials -= 1
        async(health_potion_heal_over_time, AsyncBehavior.NOOP)
    if eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
        eventPlayer.amount_of_potions_or_vials -= 1
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            async(break_stealth, AsyncBehavior.NOOP)
        eventPlayer.poison_vials_effectMemory = []
        #Customizable except Position:
        createEffect(getAllPlayers(), Effect.ORB, Color.LIME_GREEN, updateEveryTick(evalOnce(eventPlayer.getEyePosition()) + (evalOnce(eventPlayer.poison_vials_exitSpeed * eventPlayer.getFacingDirection()) * (eventPlayer.totalTimeElapsed - evalOnce(eventPlayer.totalTimeElapsed))) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed - evalOnce(eventPlayer.totalTimeElapsed)) ** 2))), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.poison_vials_effectMemory.append(getLastCreatedEntity())
        #Customizable except Position:
        createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.LIME_GREEN, updateEveryTick(evalOnce(eventPlayer.getEyePosition()) + (evalOnce(eventPlayer.poison_vials_exitSpeed * eventPlayer.getFacingDirection()) * (eventPlayer.totalTimeElapsed - evalOnce(eventPlayer.totalTimeElapsed))) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed - evalOnce(eventPlayer.totalTimeElapsed)) ** 2))), 0.6, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.poison_vials_effectMemory.append(getLastCreatedEntity())
        eventPlayer.poison_vials_projData.append([[eventPlayer.totalTimeElapsed, eventPlayer.getEyePosition(), eventPlayer.getFacingDirection(), eventPlayer.poison_vials_effectMemory]])
    wait(0.5)
    eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] = false


rule "TALENT SYSTEM - - - [TALENT 14/31: HEALTH POTIONS/POISON VIAL] Health Potion or Poison Vial Start Recharge":
    @Event eachPlayer
    @Hero soldier
    @Condition (eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0) == true
    @Condition eventPlayer.amount_of_potions_or_vials < 3
    
    if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
        if eventPlayer.health_potion_cooldown_memory > 0:
            eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - eventPlayer.health_potion_cooldown_memory
            eventPlayer.health_potion_cooldown_memory = 0
        else:
            eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        waitUntil(eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] + talent_base_cooldowns[Talent.HEALTH_POTIONS] <= eventPlayer.totalTimeElapsed, 99999)
    elif eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
        if eventPlayer.health_potion_cooldown_memory > 0:
            eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - eventPlayer.health_potion_cooldown_memory
            eventPlayer.health_potion_cooldown_memory = 0
        else:
            eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        waitUntil(eventPlayer.talent_trigger_times[Talent.POISON_VIALS] + talent_base_cooldowns[Talent.POISON_VIALS] <= eventPlayer.totalTimeElapsed, 99999)
    eventPlayer.amount_of_potions_or_vials += 1
    if eventPlayer.amount_of_potions_or_vials == 3:
        if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
            eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.HEALTH_POTIONS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        elif eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
            eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.POISON_VIALS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 100)
    if RULE_CONDITION:
        goto RULE_START


def health_potion_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Health Potions Stop Heal Over Time"
    
    waitUntil(eventPlayer.isDead() or eventPlayer.getMaxHealthOfType(Health.NORMAL) == eventPlayer.getHealthOfType(Health.NORMAL), 2)
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[4])
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[5])
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[6])


def already_at_full_health():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Health Potion Already At Full Health!"
    
    smallMessage(eventPlayer, "Already at full health!")
    playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 75)
    wait(3)

rule "TALENT SYSTEM - - - [TALENT 16: IGNITE] Ignite Effects":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.isFiringSecondaryFire() == true
    @Condition eventPlayer.talent_ranks[Talent.IGNITE] > 0
    
    eventPlayer.is_using_ability[Talent.IGNITE] = true
    eventPlayer.ignite_position = eventPlayer.getEyePosition()
    eventPlayer.talent_counter_or_position_etc[16] = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, null, getAllPlayers(), true).getHitPosition()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING, Color.TEAM_1, eventPlayer.ignite_position, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[70] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.TEAM_1, eventPlayer.ignite_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[72] = getLastCreatedEntity()
    chase(eventPlayer.ignite_position, eventPlayer.talent_counter_or_position_etc[16], rate=50 if eventPlayer.talent_ranks[Talent.BOMBARDMENT] == 0 else 35, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.is_using_ability[Talent.IGNITE] == false or eventPlayer.ignite_position == eventPlayer.talent_counter_or_position_etc[16], 5.984)
    stopChasingVariable(eventPlayer.ignite_position)
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_CONCUSSION_MINE_EXPLOSION, Color.TEAM_1, eventPlayer.ignite_position, 1)
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_ROCKET_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.ignite_position, 100)
    destroyEffect(eventPlayer.player_temp_effects[70])
    destroyEffect(eventPlayer.player_temp_effects[72])
    eventPlayer.is_using_ability[Talent.IGNITE] = false

rule "TALENT SYSTEM - - - [SHADOWSTEP] Use Shadowstep":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.SHADOWSTEP] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.dummy_var[0] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.talent_trigger_times[Talent.SHADOWSTEP] + talent_base_cooldowns[Talent.SHADOWSTEP] - eventPlayer.talent_ranks[Talent.SHADOWSTEP] * 2.5 <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), 0.25)
    if eventPlayer.isHoldingButton(Button.JUMP):
        return
    waitUntil(eventPlayer.isHoldingButton(Button.JUMP), 0.25)
    if not eventPlayer.isHoldingButton(Button.JUMP):
        return
    eventPlayer.is_using_ability[Talent.SHADOWSTEP] = true
    eventPlayer.talent_trigger_times[Talent.SHADOWSTEP] = eventPlayer.totalTimeElapsed
    createEffect(eventPlayer, Effect.SOMBRA_HACKING_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[6] = getLastCreatedEntity()
    playEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.STEALTH] == false else null, DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR, Color.TEAM_1, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATOR_DISAPPEAR_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 0.5)
    eventPlayer.setGravity(0)
    eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), 41.421 if eventPlayer.getVerticalFacingAngle() > 0 else (7.5 + ((178 + eventPlayer.getVerticalFacingAngle()) * 0.113)) * 1.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    if eventPlayer.talent_ranks[Talent.STEALTH] > 0 and eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.in_combat > 0:
        chase(eventPlayer.entering_stealth_timer, 0 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, rate=0.113 - eventPlayer.talent_ranks[Talent.STEALTH] * 0.013 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.entering_stealth_timer = 1
        async(in_stealth, AsyncBehavior.NOOP)
        wait(0.5)
        eventPlayer.setGravity(100)
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        eventPlayer.is_using_ability[Talent.SHADOWSTEP] = false
        destroyEffect(eventPlayer.player_temp_effects[6])
        return
    if eventPlayer.is_using_ability[Talent.STEALTH] == false:
        eventPlayer.setInvisibility(Invis.ALL)
    createEffect(eventPlayer, Effect.REAPER_WRAITH_FORM, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[7] = getLastCreatedEntity()
    wait(0.5)
    eventPlayer.setGravity(100)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.is_using_ability[Talent.SHADOWSTEP] = false
    destroyEffect(eventPlayer.player_temp_effects[6])
    playEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.STEALTH] == false else null, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
    if eventPlayer.is_using_ability[Talent.STEALTH] == false:
        eventPlayer.setInvisibility(Invis.NONE)
    destroyEffect(eventPlayer.player_temp_effects[7])

rule "TALENT SYSTEM - - - [TALENT 19: BURNING SOUL] Burning Soul Damage Aura":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition (len([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 8, Team.ALL, LosCheck.SURFACES) if player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and eventPlayer.is_using_ability[Talent.STEALTH] == false and player.browsing_shop == false and player.is_using_ability[Talent.STEALTH] == false])) > 0
    
    ([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 8, Team.ALL, LosCheck.SURFACES) if player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and player.is_using_ability[Talent.PURITY_FIELD] == false and player.browsing_shop == false and player.isAlive()]).setStatusEffect(eventPlayer, Status.BURNING, 1)
    eventPlayer.victims_in_burning_soul_radius = [player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 8, Team.ALL, LosCheck.SURFACES) if player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.STEALTH] == false and player.browsing_shop == false]
    for eventPlayer.fire_soul_loop in range(len(eventPlayer.victims_in_burning_soul_radius)):
        damage(eventPlayer.victims_in_burning_soul_radius[eventPlayer.fire_soul_loop], eventPlayer, BURNING_SOUL_DAMAGE)
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "TALENT SYSTEM - - - [TALENT 19: BURNING SOUL] Hit By Burning Soul Orb Explosion":
    @Event eachPlayer
    #@Condition eventPlayer.owner_of_picked_up_xp_orb != null
    @Condition eventPlayer.hit_by_talent[Talent.BURNING_SOUL] != null
    
    eventPlayer.applyImpulse(directionTowards(eventPlayer.hit_by_talent[Talent.BURNING_SOUL].getPosition() if eventPlayer.hit_by_talent[Talent.BURNING_SOUL].xp_orb_position_on_player == true else eventPlayer.hit_by_talent[Talent.BURNING_SOUL].xp_orb_location, eventPlayer.getEyePosition()), 12.5 * (eventPlayer.stats[9] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    damage(eventPlayer, eventPlayer.hit_by_talent[Talent.BURNING_SOUL], BURNING_SOUL_ORB_DAMAGE)
    wait()
    eventPlayer.hit_by_talent[Talent.BURNING_SOUL] = null


def dropped_burning_soul_orb():
    @Name "TALENT SYSTEM - - - [BURNING SOUL] Dropped Burning Soul Orb"
    
    waitUntil(eventPlayer.burning_soul_orb_timer == 0, 4)
    (((getPlayersInRadius(eventPlayer.getPosition() + Vector.UP * 0.25 if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location + Vector.UP * 0.25, 3, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS)).exclude(eventPlayer)).hit_by_talent)[18] = eventPlayer
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 100)
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 1)

rule "TALENT SYSTEM - - - [TALENT 20: BERSERKER] Use Berserker":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.BERSERKER] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.BERSERKER] + talent_base_cooldowns[Talent.BERSERKER] <= eventPlayer.totalTimeElapsed
    #Berserker
    @Condition eventPlayer.is_using_ability[Talent.BERSERKER] == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    #Juggernaut
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    #Dive Bomb
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    
    eventPlayer.is_using_ability[Talent.BERSERKER] = true
    eventPlayer.berserker_duration = 0
    chase(eventPlayer.berserker_duration, BERSERKER_DURATION, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.talent_trigger_times[Talent.BERSERKER] = eventPlayer.totalTimeElapsed
    eventPlayer.setDamageDealt(eventPlayer.stats[0] * 1.25)
    eventPlayer.setDamageReceived(110)
    wait(0.5)
    #BERSERKER_DURATION -0.5 to account for button mash protection
    waitUntil(eventPlayer.isDead() or eventPlayer.isHoldingButton(Button.ULTIMATE), BERSERKER_DURATION - 0.5)
    eventPlayer.setDamageDealt(eventPlayer.stats[0])
    eventPlayer.setDamageReceived(100)
    eventPlayer.is_using_ability[Talent.BERSERKER] = false
    stopChasingVariable(eventPlayer.berserker_duration)
    if eventPlayer.isAlive() and eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0 and eventPlayer.bloodthirst_remaining_heal_amount >= 1:
        if eventPlayer.berserker_duration < 1:
            eventPlayer.berserker_duration = 1
        eventPlayer.bloodthirst_remaining_heal_amount = eventPlayer.bloodthirst_remaining_heal_amount / eventPlayer.berserker_duration * 5
        async(bloodthirst_effects, AsyncBehavior.RESTART)
        eventPlayer.bloodthirst_total_heal_amount = eventPlayer.bloodthirst_remaining_heal_amount
        eventPlayer.bloodthirst_heal_amount_for_hud = eventPlayer.bloodthirst_remaining_heal_amount
        wait()
        smallMessage(eventPlayer, "{0} Bloodthirst Healing: {1}!".format(abilityIconString(Hero.SIGMA, Button.ABILITY_1), round(eventPlayer.bloodthirst_heal_amount_for_hud)))
        eventPlayer.bloodthirst_remaining_heal_amount -= eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)
        heal(eventPlayer, eventPlayer, min(eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL), eventPlayer.bloodthirst_total_heal_amount))
        eventPlayer.bloodthirst_decay_per_second = eventPlayer.bloodthirst_remaining_heal_amount / (45 - eventPlayer.berserker_duration)
        eventPlayer.is_using_ability[Talent.BLOODTHIRST] = true
        eventPlayer.addHealthPool(Health.NORMAL, eventPlayer.bloodthirst_remaining_heal_amount, false, true)
        eventPlayer.health_pool_id_or_hot_id[1] = getLastCreatedHealthPool()
        while eventPlayer.getHealthOfType(Health.NORMAL) > eventPlayer.stats[1] * 2 and eventPlayer.isAlive() and eventPlayer.bloodthirst_remaining_heal_amount >= 1:
            removeHealthPool(eventPlayer.health_pool_id_or_hot_id[1])
            eventPlayer.bloodthirst_remaining_heal_amount -= eventPlayer.bloodthirst_decay_per_second
            eventPlayer.addHealthPool(Health.NORMAL, eventPlayer.bloodthirst_remaining_heal_amount, false, true)
            eventPlayer.health_pool_id_or_hot_id[1] = getLastCreatedHealthPool()
            wait(1)
        removeHealthPool(eventPlayer.health_pool_id_or_hot_id[1])
        eventPlayer.is_using_ability[Talent.BLOODTHIRST] = false
        wait()
    eventPlayer.bloodthirst_remaining_heal_amount = 0

def spawned_with_fireball():
    @Name "TALENT SYSTEM - - - [TALENT 21: FIREBALL] [SUBROUTINE] Spawned With Fireball"
    
    eventPlayer.disallowButton(Button.INTERACT)
    wait(2)
    eventPlayer.allowButton(Button.INTERACT)


rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Use Fireball":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.FIREBALL] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition (not eventPlayer.hasStatusEffect(Status.PHASED_OUT) if eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false else eventPlayer.isAlive()) == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.fireball_in_air == false
    @Condition eventPlayer.dummy_var[0] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.fireball_position == vect(0, 0, 0)
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    eventPlayer.talent_trigger_times[Talent.FIREBALL] = eventPlayer.totalTimeElapsed
    async(fireball_casted, AsyncBehavior.NOOP)

def fireball_casted():
    @Name "TALENT SYSTEM - - - [TALENT 21: FIREBALL] [SUBROUTINE] Fireball Casted"
    
    eventPlayer.fireball_in_air = true
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    createEffect(getAllPlayers(), Effect.ORB, Color.ORANGE, eventPlayer.fireball_position, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.fireball_effects[0] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.RED, eventPlayer.fireball_position, 0.45, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.fireball_effects[1] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.RED, eventPlayer.fireball_position, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.fireball_effects[2] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.ORANGE, eventPlayer.fireball_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.fireball_effects[3] = getLastCreatedEntity()
    eventPlayer.fireball_destination = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
    eventPlayer.fireball_position = eventPlayer.getEyePosition()
    chase(eventPlayer.fireball_position, eventPlayer.fireball_destination, rate=15, ChaseReeval.DESTINATION_AND_RATE)
    while eventPlayer.fireball_in_air == true:
        playEffect(getAllPlayers(), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.ORANGE, eventPlayer.fireball_position, 0.75)
        playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION, Color.TEAM_2, eventPlayer.fireball_position, 0.75)
        wait(0.05)
    stopChasingVariable(eventPlayer.fireball_position)
    destroyEffect(eventPlayer.fireball_effects[0])
    destroyEffect(eventPlayer.fireball_effects[1])
    destroyEffect(eventPlayer.fireball_effects[2])
    destroyEffect(eventPlayer.fireball_effects[3])
    eventPlayer.fireball_position = vect(0, 0, 0)
    destroyEffect(eventPlayer.player_temp_effects[29])


rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Fireball Hit Something":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.FIREBALL] > 0
    @Condition eventPlayer.fireball_in_air == true
    @Condition (eventPlayer.fireball_position == eventPlayer.fireball_destination or eventPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= eventPlayer.totalTimeElapsed or any([player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and eventPlayer.fireball_position != vect(0, 0, 0) and player.isAlive() and player.browsing_shop == false for player in getPlayersInRadius(eventPlayer.fireball_position.getPosition(), 1.75, Team.ALL, LosCheck.SURFACES)])) == true
    
    #Impulse
    (([player for player in getPlayersInRadius(eventPlayer.fireball_position, 4, Team.ALL, LosCheck.SURFACES) if player.isAlive() and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).hit_by_talent)[20] = eventPlayer
    #Set Status Burning
    ([player for player in getPlayersInRadius(eventPlayer.fireball_position, 4, Team.ALL, LosCheck.SURFACES) if player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.isAlive()]).setStatusEffect(eventPlayer, Status.BURNING, 5)
    #Who should recieve full damage?
    eventPlayer.victims_in_fireball_radius = [player for player in getPlayersInRadius(eventPlayer.fireball_position, 4, Team.ALL, LosCheck.SURFACES) if player.browsing_shop == false and player.isAlive() and player != eventPlayer and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false]
    for eventPlayer.fireball_loop in range(len(eventPlayer.victims_in_fireball_radius)):
        damage(eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop], eventPlayer, FIREBALL_DAMAGE)
        eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].startDoT(eventPlayer, 5, FIREBALL_DAMAGE_OVER_TIME)
    #If the caster is within radius
    if ([player for player in getPlayersInRadius(eventPlayer.fireball_position, 4, Team.ALL, LosCheck.OFF) if player == eventPlayer and player.isAlive()]) == true:
        #deal friendly fire (33,333%)
        if eventPlayer.talent_ranks[Talent.PYROMANIAC] == 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false:
            damage(eventPlayer, eventPlayer, FIREBALL_DAMAGE_SELF)
            eventPlayer.startDoT(eventPlayer, FIREBALL_DAMAGE_SELF_OVER_TIME_DURATION, FIREBALL_DAMAGE_SELF_OVER_TIME)
        else:
            async(pyromaniac_heal_over_time, AsyncBehavior.NOOP)
            playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_WHIP_SHOT_HEAL_AREA, Color.TEAM_1, eventPlayer.getPosition(), 1)
            playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_WHIP_SHOT_HEAL_AREA_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
            playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
            createEffect(eventPlayer, Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.player_temp_effects[29] = getLastCreatedEntity()
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION, Color.TEAM_2, eventPlayer.fireball_position, 2)
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.fireball_position, 100)
    destroyEffect(eventPlayer.fireball_effects[0])
    destroyEffect(eventPlayer.fireball_effects[1])
    destroyEffect(eventPlayer.fireball_effects[2])
    destroyEffect(eventPlayer.fireball_effects[3])
    eventPlayer.fireball_in_air = false


rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Hit By Fireball":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.FIREBALL] != null
    
    eventPlayer.applyImpulse(directionTowards(eventPlayer.hit_by_talent[Talent.FIREBALL].fireball_position, eventPlayer.getEyePosition()), 15 * (eventPlayer.stats[9] / 100), Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    eventPlayer.hit_by_talent[Talent.FIREBALL] = null

rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] Ignore Pain Activated":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.IGNORE_PAIN] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition (eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.isReloading() or eventPlayer.isUsingAbility1()) == true
    
    eventPlayer.is_using_ability[Talent.IGNORE_PAIN] = true
    async(ignore_pain_volume, AsyncBehavior.RESTART)
    eventPlayer.ignore_pain_damage_resistance = IGNORE_PAIN_DAMAGE_RESISTANCE
    eventPlayer.setDamageReceived(IGNORE_PAIN_DAMAGE_RECEIVED)
    waitUntil(not eventPlayer.hasStatusEffect(Status.STUNNED) and not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) and not eventPlayer.isReloading() and not eventPlayer.isUsingAbility1() and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false or eventPlayer.isDead(), 99999)
    eventPlayer.ignore_pain_volume = 25
    eventPlayer.setDamageReceived(100)
    eventPlayer.is_using_ability[Talent.IGNORE_PAIN] = false


rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] Start Timer When Entering Combat":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.IGNORE_PAIN] > 0
    @Condition eventPlayer.in_combat > 0
    
    chase(eventPlayer.total_time_in_combat, 9999, rate=1, ChaseReeval.DESTINATION_AND_RATE)

rule "Exiting Combat":
    @Event eachPlayer
    @Hero soldier 
    @Condition eventPlayer.in_combat == 0
    
    if eventPlayer.talent_ranks[Talent.PREDATOR] > 0 and (eventPlayer.predator_damage_dealt > 0 or eventPlayer.predator_damage_resisted > 0):
        smallMessage(eventPlayer, "{0} Predator Damage: {1}, Predator Resisted: {2}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.predator_damage_dealt), round(eventPlayer.predator_damage_resisted)) if eventPlayer.predator_damage_dealt > 0 and eventPlayer.predator_damage_resisted > 0 else "{0} Predator Damage: {1}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.predator_damage_dealt)) if eventPlayer.predator_damage_dealt > 0 and eventPlayer.predator_damage_resisted == 0 else "{0} Predator Resisted: {1}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.predator_damage_resisted))) 
    if eventPlayer.talent_ranks[Talent.GIGACHAD] > 0 and eventPlayer.gigachad_damage_resisted > 0:
        smallMessage(eventPlayer, "{0} Gigachad Damage Resisted: {1}".format(abilityIconString(Hero.RAMATTRA, Button.ABILITY_1), round(eventPlayer.gigachad_damage_resisted)))
    wait()
    eventPlayer.predator_damage_dealt = 0
    eventPlayer.predator_damage_resisted = 0
    eventPlayer.gigachad_damage_resisted = 0


rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] How Much Damage Was Resisted Inside Combat?":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.IGNORE_PAIN] > 0
    @Condition eventPlayer.in_combat == 0
    
    stopChasingVariable(eventPlayer.total_time_in_combat)
    if eventPlayer.ignore_pain_damage_resisted[0] > 0:
        eventPlayer.ignore_pain_damage_resisted[1] = eventPlayer.ignore_pain_damage_resisted[0] * (0.333 + eventPlayer.talent_ranks[Talent.IGNORE_PAIN] * 0.333)
        ignore_pain_hps()
        smallMessage(eventPlayer, "{0} Total Damage Resisted: {1}".format(abilityIconString(Hero.ZARYA, Button.ABILITY_1), round(eventPlayer.ignore_pain_damage_resisted[1])))
        eventPlayer.ignore_pain_damage_resisted[0] = 0
    #return
    #Got Ignore Pain?
    #return
    #Add total damage resisted by Ignore Pain to the index number that matches the rank of Ignore Pain
    #return
    #Add time in combat to the index number that matches the rank of Ignore Pain
    #return
    eventPlayer.total_time_in_combat = 0


def ignore_pain_volume():
    @Name "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] [SUBROUTINE] Ignore Pain Volume"
    
    eventPlayer.ignore_pain_volume = 0
    wait(0.064, Wait.RESTART_WHEN_TRUE)
    eventPlayer.ignore_pain_volume = 75


/*
rule "TALENT SYSTEM - - - [TALENT 23: JAVELIN] Use Javelin [DISABLED: WORK IN PROGRESS]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    @Condition eventPlayer.is_using_ability[Talent.JAVELIN] == false
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    waitUntil(eventPlayer.isHoldingButton(Button.MELEE) == false, 99999)
    eventPlayer.is_using_ability[Talent.JAVELIN] = true
    eventPlayer.javelin_middle_position = eventPlayer.getEyePosition() + worldVector(vect(-1 * 1 * 1 * 0.25, 0, 0), eventPlayer, Transform.ROTATION)
    eventPlayer.talent_counter_or_position_etc[23] = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, null, getAllPlayers(), true).getHitPosition()
    createBeam(getAllPlayers(), Beam.GRAPPLE, eventPlayer.javelin_middle_position - evalOnce(directionTowards(eventPlayer.javelin_middle_position, eventPlayer.talent_counter_or_position_etc[23]) * 1), eventPlayer.javelin_middle_position + evalOnce(directionTowards(eventPlayer.javelin_middle_position, eventPlayer.talent_counter_or_position_etc[23]) * 1), Color.YELLOW, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[73] = getLastCreatedEntity()
    createBeam(getAllPlayers(), Beam.BAD, eventPlayer.javelin_middle_position - evalOnce(directionTowards(eventPlayer.javelin_middle_position, eventPlayer.talent_counter_or_position_etc[23]) * 1), eventPlayer.javelin_middle_position + evalOnce(directionTowards(eventPlayer.javelin_middle_position, eventPlayer.talent_counter_or_position_etc[23]) * 1), Color.YELLOW, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[74] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.ENERGY_SOUND, Color.WHITE, eventPlayer.javelin_middle_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[75] = getLastCreatedEntity()
    chase(eventPlayer.javelin_middle_position, eventPlayer.talent_counter_or_position_etc[23], rate=50, ChaseReeval.DESTINATION_AND_RATE)
    while eventPlayer.javelin_middle_position != eventPlayer.talent_counter_or_position_etc[23] and eventPlayer.is_using_ability[Talent.JAVELIN].hit_by_talent[Talent.JAVELIN] != eventPlayer:
        (((sorted([player for player in getPlayersInRadius(eventPlayer.javelin_middle_position, 3, Team.ALL, LosCheck.OFF) if distance(player.getPosition() + worldVector(vect(0, 1, 0), player, Transform.ROTATION), eventPlayer.javelin_middle_position) < 1 and player != eventPlayer and player.isAlive() == true and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false], lambda i: distance(eventPlayer.javelin_middle_position, i.getPosition() + worldVector(vect(0, 1, 0), i, Transform.ROTATION))))[0]).hit_by_talent)[23] = eventPlayer
        wait()
    if eventPlayer.is_using_ability[Talent.JAVELIN].hit_by_talent[Talent.JAVELIN] == eventPlayer:
        return
    else:
        waitUntil(eventPlayer.javelin_middle_position == eventPlayer.talent_counter_or_position_etc[23], 99999)
        eventPlayer.talent_counter_or_position_etc[23] = null
        eventPlayer.is_using_ability[Talent.JAVELIN] = false
*/

/*
rule "TALENT SYSTEM - - - [TALENT 23: JAVELIN] Hit By Javelin [DISABLED: WORK IN PROGRESS]":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.JAVELIN] != null
    
    eventPlayer.hit_by_talent[Talent.JAVELIN].is_using_ability[Talent.JAVELIN] = eventPlayer
    eventPlayer.startFacing(directionTowards(eventPlayer.hit_by_talent[Talent.JAVELIN].talent_counter_or_position_etc[23], eventPlayer.hit_by_talent[Talent.JAVELIN].talent_counter_or_position_etc[23] + directionTowards(eventPlayer.hit_by_talent[Talent.JAVELIN].talent_counter_or_position_etc[23], eventPlayer.hit_by_talent[Talent.JAVELIN].javelin_middle_position) * 200), 1000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 0.5)
    eventPlayer.setStatusEffect(null, Status.STUNNED, 0.5)
    eventPlayer.startForcingPosition(eventPlayer.hit_by_talent[Talent.JAVELIN].javelin_middle_position + worldVector(vect(0, -1 * 1 * 1 * 1, 0), eventPlayer, Transform.ROTATION), true)
    if eventPlayer.getAltitude() == 100:
        eventPlayer.teleport(nearestWalkablePosition(eventPlayer.hit_by_talent[Talent.JAVELIN].javelin_middle_position))
        eventPlayer.javelin_middle_position = eventPlayer.getPosition() + worldVector(vect(0, 1, 0), eventPlayer, Transform.ROTATION)
    while eventPlayer.hasStatusEffect(Status.PHASED_OUT) == true:
        if distance(eventPlayer.getPosition() + worldVector(vect(0, 1, 0), eventPlayer, Transform.ROTATION), eventPlayer.hit_by_talent[Talent.JAVELIN].talent_counter_or_position_etc[23]) < 2:
            eventPlayer.stopForcingPosition()
            eventPlayer.clearStatusEffect(Status.PHASED_OUT)
            eventPlayer.stopFacing()
            if eventPlayer.isOnGround() == true:
                eventPlayer.clearStatusEffect(Status.STUNNED)
                wait()
                eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
                wait(1.5)
            else:
                eventPlayer.startForcingPosition(eventPlayer.getPosition(), true)
                eventPlayer.clearStatusEffect(Status.STUNNED)
                wait()
                eventPlayer.setStatusEffect(null, Status.STUNNED, 1.5)
                wait(1.5)
                eventPlayer.stopForcingPosition()
        wait()
    eventPlayer.stopForcingPosition()
    eventPlayer.stopFacing()
    eventPlayer.hit_by_talent[Talent.JAVELIN].is_using_ability[Talent.JAVELIN] = false
    eventPlayer.hit_by_talent[Talent.JAVELIN].talent_counter_or_position_etc[23] = null
    eventPlayer.hit_by_talent[Talent.JAVELIN] = null
*/

/*
rule "TALENT SYSTEM - - - [TALENT 23: JAVELIN] Stop Using Javelin [DISABLED: WORK IN PROGRESS]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.is_using_ability[Talent.JAVELIN] == false
    
    stopChasingVariable(eventPlayer.javelin_middle_position)
    destroyEffect(eventPlayer.player_temp_effects[73])
    destroyEffect(eventPlayer.player_temp_effects[74])
    destroyEffect(eventPlayer.player_temp_effects[75])
*/
/*
rule "TALENT SYSTEM - - - [TALENT 29: SOUL SIPHON] Hit By Soul Siphon":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.BANDAGE] != null
    
    eventPlayer.hit_by_talent[Talent.BANDAGE].used_bandage_on = eventPlayer
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE], Effect.CLOUD, Color.PURPLE, eventPlayer.getPosition() + vect(0, -1 * 1 * 1 * 0.125, 0), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[20] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE], Effect.CLOUD, Color.VIOLET, eventPlayer.getPosition() + vect(0, -1 * 1 * 1 * 0.125, 0), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[25] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE], Effect.RING, Color.PURPLE, eventPlayer.getPosition() + Vector.DOWN, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[24] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE], Effect.BAD_AURA, Color.VIOLET, eventPlayer.getPosition() + vect(0, 0.25, 0), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[26] = getLastCreatedEntity()
    createBeam(getAllPlayers() if distance(eventPlayer.getPosition(), eventPlayer.hit_by_talent[Talent.BANDAGE].getPosition()) <= 2 else null, Beam.BAD, eventPlayer.getPosition() + vect(0, 0.25, 0), eventPlayer.hit_by_talent[Talent.BANDAGE], Color.PURPLE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[21] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE] if distance(eventPlayer.getPosition(), eventPlayer.hit_by_talent[Talent.BANDAGE].getPosition()) <= 2 else null, Effect.ENERGY_SOUND, Color.TEAM_1, eventPlayer.hit_by_talent[Talent.BANDAGE].getPosition(), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[22] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE] if distance(eventPlayer.getPosition(), eventPlayer.hit_by_talent[Talent.BANDAGE].getPosition()) <= 2 else null, Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer.hit_by_talent[Talent.BANDAGE], 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[27] = getLastCreatedEntity()
    createEffect(eventPlayer.hit_by_talent[Talent.BANDAGE] if distance(eventPlayer.getPosition(), eventPlayer.hit_by_talent[Talent.BANDAGE].getPosition()) <= 2 else null, Effect.HEAL_TARGET, Color.TEAM_1, eventPlayer.hit_by_talent[Talent.BANDAGE], 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[28] = getLastCreatedEntity()
    waitUntil(eventPlayer.hit_by_talent[Talent.BANDAGE].isDead() == true, 5)
    eventPlayer.hit_by_talent[Talent.BANDAGE].used_bandage_on = null
    eventPlayer.hit_by_talent[Talent.BANDAGE] = null
    destroyEffect(eventPlayer.player_temp_effects[20])
    destroyEffect(eventPlayer.player_temp_effects[21])
    destroyEffect(eventPlayer.player_temp_effects[22])
    destroyEffect(eventPlayer.player_temp_effects[24])
    destroyEffect(eventPlayer.player_temp_effects[25])
    destroyEffect(eventPlayer.player_temp_effects[26])
    destroyEffect(eventPlayer.player_temp_effects[27])
    destroyEffect(eventPlayer.player_temp_effects[28])
*/
/*
rule "TALENT SYSTEM - - - [TALENT 29: SOUL SIPHON] Used Soul Siphon":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.used_bandage_on != null
    @Condition distance(eventPlayer.getPosition(), eventPlayer.used_bandage_on.getPosition()) <= 2
    @Condition eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL)
    
    eventPlayer.bandage_progress = 5
    eventPlayer.startHoT(eventPlayer, 5, 30 + eventPlayer.talent_ranks[Talent.BANDAGE] * 10)
    eventPlayer.player_temp_effects[23] = getLastHoT()
    waitUntil(distance(eventPlayer.getPosition(), eventPlayer.used_bandage_on.getPosition()) > 2 or eventPlayer.used_bandage_on == null or eventPlayer.getHealthOfType(Health.NORMAL) >= eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.isDead() == true or eventPlayer.bandage_progress == 0, 5)
    stopHoT(eventPlayer.player_temp_effects[23])
    wait()
    if RULE_CONDITION:
        goto RULE_START
*/
def pyromaniac_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 30: PYROMANIAC] [SUBROUTINE] Pyromaniac Stop Healing Over Time"
    
    eventPlayer.pyromaniac_heal_duration = 5
    heal(eventPlayer, eventPlayer, min(PYROMANIAC_INSTANT_HEALING, eventPlayer.getMaxHealthOfType(Health.NORMAL) - eventPlayer.getHealthOfType(Health.NORMAL)))
    while eventPlayer.isAlive() and eventPlayer.pyromaniac_heal_duration > 0:
        eventPlayer.talent_counter_or_position_etc[30] = eventPlayer.pyromaniac_heal_duration
        eventPlayer.startHoT(eventPlayer, eventPlayer.talent_counter_or_position_etc[30], PYROMANIAC_HEALING_OVER_TIME)
        eventPlayer.health_pool_id_or_hot_id[3] = getLastHoT()
        waitUntil(eventPlayer.isDead() or eventPlayer.getMaxHealthOfType(Health.NORMAL) == eventPlayer.getHealthOfType(Health.NORMAL), eventPlayer.talent_counter_or_position_etc[30])
        stopHoT(eventPlayer.health_pool_id_or_hot_id[3])
        if eventPlayer.pyromaniac_heal_duration == 0 or eventPlayer.isDead():
            return
        eventPlayer.talent_counter_or_position_etc[30] = eventPlayer.pyromaniac_heal_duration
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL), eventPlayer.talent_counter_or_position_etc[30])

rule "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] accurateTime":
    chase(accurateTime, accurateTime + true, rate=true, ChaseReeval.DESTINATION_AND_RATE)

rule "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] Setup":
    @Event eachPlayer
    @Hero soldier
    
    #Customizable:
    eventPlayer.poison_vials_exitSpeed = 25
    eventPlayer.gravity = 9.8
    #Customizable (old setup):
    #return
    #////////////////////////////////
    eventPlayer.poison_vials_projData = []
    eventPlayer.poison_vials_cloudData = []
    while true:
        #Customizable (who should be affected? updates when players join):
        eventPlayer.interactablePlayers = getAllPlayers().exclude(eventPlayer)
        #///////////////////////////////
        waitUntil(getAllPlayers() != evalOnce(getAllPlayers()), 99999)

rule "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] projCollision":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0
    @Condition any([player[true] + (eventPlayer.poison_vials_exitSpeed * player[2] * (eventPlayer.totalTimeElapsed + 0.032 - player[0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed + 0.032 - player[0]) ** 2)) != raycast(player[true] + (eventPlayer.poison_vials_exitSpeed * player[2] * (eventPlayer.totalTimeElapsed - player[0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed - player[0]) ** 2)), player[true] + (eventPlayer.poison_vials_exitSpeed * player[2] * (eventPlayer.totalTimeElapsed + 0.032 - player[0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed + 0.032 - player[0]) ** 2)), eventPlayer.interactablePlayers, [], true).getHitPosition() for player in eventPlayer.poison_vials_projData]) == true
    
    eventPlayer.indexMemory = ((([i for i in [[player, i + true] for player, i in eventPlayer.poison_vials_projData] if i[0][true] + (eventPlayer.poison_vials_exitSpeed * i[0][2] * (eventPlayer.totalTimeElapsed + 0.032 - i[0][0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed + 0.032 - i[0][0]) ** 2)) != raycast(i[0][true] + (eventPlayer.poison_vials_exitSpeed * i[0][2] * (eventPlayer.totalTimeElapsed - i[0][0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed - i[0][0]) ** 2)), i[0][true] + (eventPlayer.poison_vials_exitSpeed * i[0][2] * (eventPlayer.totalTimeElapsed + 0.032 - i[0][0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed + 0.032 - i[0][0]) ** 2)), eventPlayer.interactablePlayers, [], true).getHitPosition()])[0]).last()) - true
    eventPlayer.poison_vials_projPos = eventPlayer.poison_vials_projData[eventPlayer.indexMemory][true] + (eventPlayer.poison_vials_exitSpeed * eventPlayer.poison_vials_projData[eventPlayer.indexMemory][2] * (eventPlayer.totalTimeElapsed - eventPlayer.poison_vials_projData[eventPlayer.indexMemory][0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed - eventPlayer.poison_vials_projData[eventPlayer.indexMemory][0]) ** 2))
    eventPlayer.poison_vials_projPosIn0032 = eventPlayer.poison_vials_projData[eventPlayer.indexMemory][true] + (eventPlayer.poison_vials_exitSpeed * eventPlayer.poison_vials_projData[eventPlayer.indexMemory][2] * (eventPlayer.totalTimeElapsed + 0.032 - eventPlayer.poison_vials_projData[eventPlayer.indexMemory][0])) + (eventPlayer.gravity / 2 * Vector.DOWN * ((eventPlayer.totalTimeElapsed + 0.032 - eventPlayer.poison_vials_projData[eventPlayer.indexMemory][0]) ** 2))
    #Customizable:
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.LIME_GREEN, eventPlayer.poison_vials_projPos, 3)
    playEffect(getAllPlayers(), DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION, Color.TEAM_2, eventPlayer.poison_vials_projPos, 1)
    playEffect(getAllPlayers(), DynamicEffect.DVA_MICRO_MISSILES_EXPLOSION, Color.TEAM_1, eventPlayer.poison_vials_projPos, 1)
    playEffect(getAllPlayers(), DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.poison_vials_projPos, 100)
    playEffect(getAllPlayers(), DynamicEffect.DVA_MICRO_MISSILES_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.poison_vials_projPos, 100)
    playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, Color.TEAM_1, eventPlayer.poison_vials_projPos, 1)
    playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.poison_vials_projPos, 100)
    damage([player for player in getPlayersInRadius(eventPlayer.poison_vials_projPos, 3, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS) if player != eventPlayer and player == eventPlayer.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false], eventPlayer, POISON_VIALS_DAMAGE)
    ([player for player in getPlayersInRadius(eventPlayer.poison_vials_projPos, 3, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS) if player != eventPlayer and player == eventPlayer.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).startDoT(eventPlayer, POISON_VIALS_DAMAGE_OVER_TIME)
    (([player for player in getPlayersInRadius(eventPlayer.poison_vials_projPos, 3, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS) if player != eventPlayer and player == eventPlayer.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).hit_by_talent)[31] = eventPlayer
    eventPlayer.poison_vials_effectMemory = []
    #////////////////////////////////
    destroyEffect(eventPlayer.poison_vials_projData[eventPlayer.indexMemory].last())
    del eventPlayer.poison_vials_projData[eventPlayer.indexMemory]
    wait()
    if RULE_CONDITION:
        goto RULE_START

rule "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] projTimeout":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0
    @Condition any([eventPlayer.totalTimeElapsed - player[0] > 9 for player in eventPlayer.poison_vials_projData]) == true
    
    eventPlayer.indexMemory = ((([i for i in [[player, i + true] for player, i in eventPlayer.poison_vials_projData] if eventPlayer.totalTimeElapsed - i[0][0] > 9])[0]).last()) - true
    destroyEffect(eventPlayer.poison_vials_projData[eventPlayer.indexMemory].last())
    del eventPlayer.poison_vials_projData[eventPlayer.indexMemory]
    wait()
    if RULE_CONDITION:
        goto RULE_START

rule "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] Hit By Poison Vials":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.POISON_VIALS] != null
    
    eventPlayer.hit_by_talent[Talent.POISON_VIALS] = null
    destroyEffect(eventPlayer.player_temp_effects[40])
    #Is affected by ability
    eventPlayer.is_using_ability[Talent.POISON_VIALS] = true
    createEffect(getAllPlayers(), Effect.WIDOWMAKER_VENOM_MINE_TARGET, Color.WHITE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[40] = getLastCreatedEntity()
    playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, Color.TEAM_1, eventPlayer, 1)
    playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer, 100)
    wait(5, Wait.RESTART_WHEN_TRUE)
    #Is affected by ability
    eventPlayer.is_using_ability[Talent.POISON_VIALS] = false
    destroyEffect(eventPlayer.player_temp_effects[40])

rule "TALENT SYSTEM - - - [BOMBARDMENT]":
    @Event eachPlayer
    @Hero soldier
    @Condition (eventPlayer.isFiringSecondaryFire() or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.talent_ranks[Talent.BOMBARDMENT] > 0) == true
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] == 0
    @Condition eventPlayer.rockets_cooldown == 0
    
    if eventPlayer.talent_ranks[Talent.BOMBARDMENT] == 0:
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.rockets_cooldown = 6
        waitUntil(eventPlayer.rockets_cooldown == 0 and eventPlayer.browsing_shop == false and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false, 99999)
        if eventPlayer.talent_ranks[Talent.RAILGUN] > 0:
            return
        eventPlayer.setSecondaryFireEnabled(true)
        return
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.talent_ranks[Talent.BOMBARDMENT] > 0:
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
    eventPlayer.rockets_cooldown = 1

/*
rule "TALENT SYSTEM - - - [BOMBARDMENT] Primary Fire = Secondary Fire":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.BOMBARDMENT] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    
    eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START
*/

rule "TALENT SYSTEM - - - [GUNSLINGER]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.GUNSLINGER] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAmmo(0) > 0
    @Condition eventPlayer.isReloading() == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    if eventPlayer.isFiringPrimaryFire():
        playEffect(getAllPlayers(), DynamicEffect.CASSIDY_FLASHBANG_EXPLOSION_SOUND, Color.TEAM_1, updateEveryTick(eventPlayer.getPosition()), 100)
        eventPlayer.is_using_ability[Talent.GUNSLINGER] = true
    wait(0.064)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.is_using_ability[Talent.GUNSLINGER] = false
    wait(0.436)
    if RULE_CONDITION:
        goto RULE_START

rule "TALENT SYSTEM - - - [SPRINTER]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.SPRINTER] > 0
    @Condition eventPlayer.isUsingAbility1() == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.browsing_shop == false
    
    eventPlayer.is_using_ability[Talent.SPRINTER] = true
    eventPlayer.setMoveSpeed(SPRINTER_MOVE_SPEED_MULTIPLIER)
    waitUntil(not eventPlayer.isUsingAbility1() or evalOnce(eventPlayer.stats[2]) != eventPlayer.stats[2], 99999)
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.is_using_ability[Talent.SPRINTER] = false
    #is charging railgun
    #if eventPlayer.is_charging_railgun == false:
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    async(player_slowed, AsyncBehavior.RESTART)
    
rule "TALENT SYSTEM - - - [BANDAGE] Use Bandage":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.talent_ranks[Talent.BANDAGE] > 0
    @Condition eventPlayer.talent_trigger_times[Talent.BANDAGE] + talent_base_cooldowns[Talent.BANDAGE] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.dummy_var[0] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), 0.25)
    if eventPlayer.isHoldingButton(Button.MELEE):
        return
    waitUntil(eventPlayer.isHoldingButton(Button.MELEE), 0.25)
    if not eventPlayer.isHoldingButton(Button.MELEE):
        return
    eventPlayer.is_using_ability[Talent.BANDAGE] = true
    eventPlayer.clearStatusEffect(Status.BURNING)
    eventPlayer.clearStatusEffect(Status.FROZEN)
    playEffect(getAllPlayers(), DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION, Color.TEAM_1, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    createEffect(getAllPlayers(), Effect.ANA_BIOTIC_GRENADE_INCREASED_HEALING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[78] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.BEACON_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[79] = getLastCreatedEntity()
    if eventPlayer.cryogenics_slow_amount < eventPlayer.stats[2]:
        eventPlayer.cryogenics_slow_amount = eventPlayer.stats[2]
    eventPlayer.stopAllDoT()
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2] * 0.25)
    async(player_slowed, AsyncBehavior.RESTART)
    eventPlayer.startHoT(eventPlayer, BANDAGE_HEAL_OVER_TIME_DURATION, BANDAGE_HEAL_OVER_TIME)
    eventPlayer.bandage_heal_over_time_id = getLastHoT()
    eventPlayer.bandage_progress = 0
    async(cancel_ability, AsyncBehavior.NOOP)
    chase(eventPlayer.bandage_progress, 10, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.is_using_ability[Talent.BANDAGE] == false or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.bandage_progress == 10, 9999)
    eventPlayer.is_using_ability[Talent.BANDAGE] = false
    destroyEffect(eventPlayer.player_temp_effects[78])
    destroyEffect(eventPlayer.player_temp_effects[79])
    stopChasingVariable(eventPlayer.bandage_progress)
    eventPlayer.bandage_progress = 0
    stopHoT(eventPlayer.bandage_heal_over_time_id)
    eventPlayer.talent_trigger_times[Talent.BANDAGE] = eventPlayer.totalTimeElapsed
    #if eventPlayer.cryogenics_slow_amount < eventPlayer.stats[2] or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
    #        return
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    