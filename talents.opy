#!mainFile "soldier_x.opy"

#--- Talent-only defineMember (variable[100-115]) ---
#!defineMember bandage_heal_over_time_id variable[100]
#!defineMember bloodthirst_heal_amount_for_hud variable[101]
#!defineMember bloodthirst_remaining_heal_amount variable[102]
#!defineMember bloodthirst_total_heal_amount variable[103]
#!defineMember bloodthirst_decay_per_second variable[104]
#!defineMember purity_field_position variable[105]
#!defineMember health_potion_1_timestamp variable[106]
#!defineMember health_potion_2_timestamp variable[107]
#!defineMember health_potion_3_timestamp variable[108]
#!defineMember hit_by_dive_bomb_effect_counter variable[109]
#!defineMember ignite_raycast_hit_position variable[110]
#!defineMember potion_hot_id_1 variable[111]
#!defineMember potion_hot_id_2 variable[112]
#!defineMember potion_hot_id_3 variable[113]
#!defineMember poisonous_dagger_effect_id variable[114]
#!defineMember poisonous_dagger_sound_id variable[115]

#Global variables

globalvar accurateTime

#Player variables

#playervar poison_vials_effectMemory
playervar entering_stealth_timer
#playervar poison_vials_exitSpeed
playervar fire_soul_loop
playervar grim_reaper_selector
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
#playervar poison_vials_projData
playervar railgun_hit_someone
playervar railgun_projectile_destination
playervar railgun_projectile_is_in_air
playervar refresh_cryogenics_slow
/*playervar poisonous_dagger_enemies_hit*/
playervar cryogenics_slow_amount = 100
playervar cryogenics_slow_duration = 0
playervar time_since_freezing_rocket
playervar total_time_in_combat
/*playervar used_bandage_on*/
playervar victims_in_fireball_radius
#playervar xp_orb_location

#Subroutine names

subroutine purity_field_impulse
subroutine lifesteal_hps
subroutine railgun_projectile_is_in_air
subroutine already_at_full_health
subroutine health_potion_hps
#subroutine health_potion_heal_over_time
subroutine fireball_casted
subroutine pyromaniac_heal_over_time
subroutine ignore_pain_volume
subroutine ignore_pain_hps
subroutine continue_primary_fire
subroutine in_stealth
subroutine health_potion_heal_monitor

#!extension explosionSounds
#!extension buffStatusEffects
#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension debuffStatusEffects
#!extension kineticExplosionEffects

rule "TALENT SYSTEM - - - [Reset timeElapsed chase]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.PURITY_FIELD] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.PURITY_FIELD] + talent_base_cooldowns[Talent.PURITY_FIELD] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    #@Condition eventPlayer.is_using_ability[Talent.GUNSLINGER] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.railgun_charge == 0
    
    eventPlayer.talent_trigger_times[Talent.PURITY_FIELD] = eventPlayer.totalTimeElapsed
    eventPlayer.is_using_ability[Talent.PURITY_FIELD] = true
    eventPlayer.purity_field_duration = 100
    chase(eventPlayer.purity_field_duration, 0, rate=100 / PURITY_FIELD_DURATION, ChaseReeval.DESTINATION_AND_RATE)
    #A wait for juggernaut (and maybe more abilities) to run their "end code" first before this triggers
    wait()
    async(purity_field_impulse, AsyncBehavior.NOOP)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setDamageReceived(0.001)
    eventPlayer.poisonous_dagger_attackers = []
    eventPlayer.poisonous_dagger_timestamp = []
    eventPlayer.clearStatusEffect(Status.STUNNED)
    eventPlayer.clearStatusEffect(Status.BURNING)
    eventPlayer.clearStatusEffect(Status.FROZEN)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.ANA_BIOTIC_GRENADE_INCREASED_HEALING, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[53] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.SPHERE, Color.WHITE, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[47] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.SPHERE, Color.YELLOW, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[48] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.GOOD_AURA, Color.WHITE, updateEveryTick(eventPlayer.getPosition()) if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 2.5, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.player_temp_effects[49] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[50] = getLastCreatedEntity()
    createEffect(getAllPlayers() if eventPlayer.browsing_shop == false else null, Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED_SOUND, Color.TEAM_1, eventPlayer.getPosition() if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
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
    recalculate_player_speed()
    eventPlayer.stopForcingThrottle()
    eventPlayer.purity_field_position = eventPlayer.getPosition()
    waitUntil(distance(eventPlayer.getEyePosition(), eventPlayer.purity_field_position) > 2.75 or eventPlayer.isDead() or eventPlayer.browsing_shop == true, PURITY_FIELD_DURATION)
    stopChasingVariable(eventPlayer.purity_field_duration)
    eventPlayer.purity_field_duration = 0
    eventPlayer.purity_field_position = null
    destroyEffect(eventPlayer.player_temp_effects[47])
    destroyEffect(eventPlayer.player_temp_effects[48])
    destroyEffect(eventPlayer.player_temp_effects[49])
    destroyEffect(eventPlayer.player_temp_effects[50])
    destroyEffect(eventPlayer.player_temp_effects[51])
    eventPlayer.setDamageReceived(100)
    #if eventPlayer.talent_ranks[Talent.GUNSLINGER] == 0:
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    #if eventPlayer.talent_ranks[Talent.SPRINTER] > 0 and eventPlayer.isUsingAbility1() or eventPlayer.is_using_ability[Talent.BANDAGE]:
    #        goto lbl_0
    #eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    lbl_0:
    #destroyInWorldText(eventPlayer.player_temp_effects[52])
    eventPlayer.setHealingReceived(100)
    destroyEffect(eventPlayer.player_temp_effects[53])
    eventPlayer.setKnockbackReceived(GIGACHAD_KNOCKBACK_RECEIVED)
    eventPlayer.is_using_ability[Talent.PURITY_FIELD] = false
    waitUntil(eventPlayer.browsing_shop == false, 99999)
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    


def purity_field_impulse():
    @Name "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] [SUBROUTINE] Purity Field Impulse"
    
    while eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.victims_in_purity_field_radius = [player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 3.5, Team.ALL, LosCheck.OFF)) if player != eventPlayer and player.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]
        for eventPlayer.current_purity_field_target in range(len(eventPlayer.victims_in_purity_field_radius)):
            eventPlayer.victims_in_purity_field_radius[eventPlayer.fire_soul_loop].applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.purity_field_position, eventPlayer.victims_in_purity_field_radius[eventPlayer.fire_soul_loop].getEyePosition() + Vector.DOWN)), min(verticalAngleOfDirection(directionTowards(eventPlayer.purity_field_position, eventPlayer.victims_in_purity_field_radius[eventPlayer.fire_soul_loop].getEyePosition() + Vector.DOWN)), -30)), 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
        wait(0.125)
    /*
    while eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        #Impulse
        (([player for player in (getPlayersInRadius(eventPlayer.getPosition() if eventPlayer.has_hit_the_ground == false else eventPlayer.purity_field_position, 3.5, Team.ALL, LosCheck.OFF)) if player != eventPlayer and player.isAlive() and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).hit_by_talent)[1] = eventPlayer
        wait(0.125)
        


rule "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] Hit By Purity Field":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.PURITY_FIELD] != null
    
    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.hit_by_talent[Talent.PURITY_FIELD].purity_field_position, eventPlayer.getPosition())), -30), 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    eventPlayer.hit_by_talent[Talent.PURITY_FIELD] = null
*/
rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Use Stealth":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.talent_trigger_times[Talent.STEALTH] + talent_base_cooldowns[Talent.STEALTH] <= eventPlayer.totalTimeElapsed
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
    while eventPlayer.entering_stealth_timer > 0:
        eventPlayer.current_stealth_target = sorted([player for player in eventPlayer.getRealPlayersInViewAngle(Team.ALL, 45) if player != eventPlayer and player.isAlive() == true and player.is_using_ability[Talent.STEALTH] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.is_using_ability[Talent.PURITY_FIELD] == false and isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) == true], lambda player: distance(eventPlayer.getPosition(), player.getPosition()))[0]
        wait()
    waitUntil(eventPlayer.entering_stealth_timer == 0, 99999)
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        break_stealth()
    
rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Canceled Entering Stealth":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.STEALTH] > 0
    @Condition eventPlayer.entering_stealth == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    
    eventPlayer.entering_stealth = false
    stopChasingVariable(eventPlayer.entering_stealth_timer)
    eventPlayer.entering_stealth_timer = 0


rule "TALENT SYSTEM - - - [TALENT ##: POISONOUS DAGGER] Hit By Poisonous Dagger":
    @Event eachPlayer
    @Condition len(eventPlayer.poisonous_dagger_attackers) > 0

    createEffect(getAllPlayers(), Effect.ZENYATTA_ORB_OF_DISCORD_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.poisonous_dagger_effect_id = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.ZENYATTA_ORB_OF_DISCORD_TARGET_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.poisonous_dagger_sound_id = getLastCreatedEntity()

    while eventPlayer.poisonous_dagger_attackers[0] != null:
        waitUntil(eventPlayer.isDead() or eventPlayer.browsing_shop == true or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.is_using_ability[Talent.BANDAGE] == true or eventPlayer.poisonous_dagger_timestamp[0] < eventPlayer.totalTimeElapsed - POISONOUS_DAGGER_DURATION, 99999)

        if eventPlayer.poisonous_dagger_timestamp[0] < eventPlayer.totalTimeElapsed - POISONOUS_DAGGER_DURATION:
            damage(eventPlayer, eventPlayer.poisonous_dagger_attackers[0], POISONOUS_DAGGER_DAMAGE)
            playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, Color.TEAM_1, eventPlayer.getPosition() + Vector.UP, 1)
            playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR, Color.TEAM_1, eventPlayer.getPosition() + (Vector.UP * 1.4), 1)
            playEffect(getAllPlayers(), DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition() + Vector.UP, 100)

        del eventPlayer.poisonous_dagger_attackers[0]
        del eventPlayer.poisonous_dagger_timestamp[0]
        wait()

    eventPlayer.poisonous_dagger_attackers = []
    eventPlayer.poisonous_dagger_timestamp = []

    destroyEffect(eventPlayer.poisonous_dagger_effect_id)
    destroyEffect(eventPlayer.poisonous_dagger_sound_id)

rule "TALENT SYSTEM - - - [TALENT 5: STEALTH] Break Stealth If Being Loud":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.STEALTH] > 0
    @Condition eventPlayer.is_using_ability[Talent.STEALTH] == true
    @Condition (eventPlayer.isFiringPrimaryFire() or eventPlayer.isFiringSecondaryFire()) == true
    
    async(break_stealth, AsyncBehavior.NOOP)


def break_stealth():
    @Name "TALENT SYSTEM - - - [TALENT 5: STEALTH] [SUBROUTINE] Break Stealth"
    
    eventPlayer.current_stealth_target = null
    eventPlayer.is_using_ability[Talent.STEALTH] = false
    if not eventPlayer.is_using_ability[Talent.GRIM_REAPER]:
        eventPlayer.setInvisibility(Invis.NONE)
        playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_REAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
    eventPlayer.talent_trigger_times[Talent.STEALTH] = eventPlayer.totalTimeElapsed
    stopChasingVariable(eventPlayer.entering_stealth_timer)
    eventPlayer.entering_stealth_timer = 0
    if eventPlayer.talent_ranks[Talent.HEALTH_REGEN] > 0:
        stopHoT(eventPlayer.health_regen_in_stealth_id)

/*
rule "TALENT SYSTEM - - - [JUGGERNAUT] Use Juggernaut":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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
    @Condition eventPlayer.is_using_hearthstone == false
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
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 0, 0.333), eventPlayer, Transform.ROTATION) if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100 else eventPlayer.getEyePosition() + (worldVector(vect(0.5 if ((eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4) * 0.5 > 0.5 else (-0.5 if ((eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4) * 0.5 < -0.5 else eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(-1, 0, 0), eventPlayer, Transform.ROTATION)))) / 4, 0.333, 0), eventPlayer, Transform.ROTATION)), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection(), getAllPlayers(), eventPlayer, true).getHitPosition() if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100 else eventPlayer.getEyePosition() + worldVector(vect(0, 0.25, 3), eventPlayer, Transform.ROTATION), 30 if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100 else 12)
    eventPlayer.startFacing(angleToDirection(eventPlayer.getHorizontalFacingAngle() + 0.4 if eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1, 0, 0), eventPlayer, Transform.ROTATION))) > 3.9 * eventPlayer.stats[Stat.SPEED] / 100 else eventPlayer.getHorizontalFacingAngle() - 0.4 if eventPlayer.getSpeedInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(1, 0, 0), eventPlayer, Transform.ROTATION))) < -3.9 * eventPlayer.stats[Stat.SPEED] / 100 else eventPlayer.getHorizontalFacingAngle(), 0), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    #If the player lands on the ground too quick
    waitUntil(eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] <= eventPlayer.totalTimeElapsed + 59.4, eventPlayer.totalTimeElapsed + 59.4)
    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed
    eventPlayer.has_hit_the_ground = true
    if eventPlayer.isDead() or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        goto lbl_0
    async(cancel_ability, AsyncBehavior.NOOP)
    async(juggernaut_effects, AsyncBehavior.NOOP)
    eventPlayer.stopForcingThrottle()
    eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * 3)
    eventPlayer.startForcingThrottle(1, 1, 0, 0, 0, 0.25)
    eventPlayer.juggernaut_charge = 10
    waitUntil(eventPlayer.getSpeed() > 14 * eventPlayer.stats[Stat.SPEED] / 100, 1)
    while eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.talent_counter_or_position_etc[6] == null and (eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() > 14 * eventPlayer.stats[Stat.SPEED] / 100 or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 >= eventPlayer.totalTimeElapsed):
        #Pick up target
        (((sorted([player for player in getPlayersInRadius(eventPlayer.getPosition() + worldVector(vect(0, 1, 2.5), eventPlayer, Transform.ROTATION), 5, Team.ALL, LosCheck.OFF) if eventPlayer.isInViewAngle(player, 45) and isInLoS(eventPlayer.getEyePosition() + Vector.DOWN, player.getEyePosition() + Vector.DOWN, BarrierLos.PASS_THROUGH_BARRIERS) and player.getPosition().y < (eventPlayer.getEyePosition() + Vector.UP).y and player.getEyePosition().y > eventPlayer.getPosition().y and distance(eventPlayer.getPosition() + Vector.UP, player.getPosition() + Vector.UP) < 3 and player != eventPlayer and player.isAlive() and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false], lambda i: distance(eventPlayer.getPosition() + Vector.UP, i.getPosition() + Vector.UP)))[0]).hit_by_talent)[6] = eventPlayer
        wait()
        #If the player got a target
        if eventPlayer.talent_counter_or_position_etc[6] != null:
            while eventPlayer.talent_counter_or_position_etc[6] != null and eventPlayer.talent_counter_or_position_etc[6] != eventPlayer and eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and (eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() > 14 * eventPlayer.stats[Stat.SPEED] / 100 or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 >= eventPlayer.totalTimeElapsed):
                (([player for player in getPlayersInRadius(eventPlayer.getPosition() + worldVector(vect(0, 1, 2.5), eventPlayer, Transform.ROTATION), 5, Team.ALL, LosCheck.OFF) if eventPlayer.isInViewAngle(player, 45) and isInLoS(eventPlayer.talent_counter_or_position_etc[6].getEyePosition() + Vector.DOWN, player.getEyePosition() + Vector.DOWN, BarrierLos.PASS_THROUGH_BARRIERS) and player.getPosition().y < (eventPlayer.getEyePosition() + Vector.UP).y and player.getEyePosition().y > eventPlayer.getPosition().y and distance(eventPlayer.getPosition() + Vector.UP, player.getPosition() + Vector.UP) < 4 and player != eventPlayer and player.isAlive() and player != eventPlayer.talent_counter_or_position_etc[6] and player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.DIVE_BOMB] == false and player.hit_by_talent[Talent.CYBERNETICS] == null]).hit_by_talent)[2] = eventPlayer
                wait()
                waitUntil(eventPlayer.talent_counter_or_position_etc[6] == null or eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100, 0.048)
                if eventPlayer.talent_counter_or_position_etc[6] == null or eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100:
                    break
        if eventPlayer.talent_counter_or_position_etc[6] == eventPlayer or eventPlayer.isDead() or eventPlayer.juggernaut_charge <= 0 or eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] + 0.25 < eventPlayer.totalTimeElapsed and eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100:
            break
    if eventPlayer.getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100 and eventPlayer.isAlive() and eventPlayer.juggernaut_charge > 0 and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false:
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
    restore_ability1()
    eventPlayer.stopCamera()
    eventPlayer.setCrouchEnabled(true)
    eventPlayer.stopFacing()
    stopChasingVariable(eventPlayer.juggernaut_charge)
    eventPlayer.juggernaut_charge = 0
    eventPlayer.is_using_ability[Talent.JUGGERNAUT] = false
    recalculate_player_speed()
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
    waitUntil(eventPlayer.isDead() or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].isDead() or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].juggernaut_charge == 0 or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].is_using_ability[Talent.PURITY_FIELD] == true or eventPlayer.hit_by_talent[Talent.JUGGERNAUT].getSpeed() <= 14 * eventPlayer.stats[Stat.SPEED] / 100, 10)
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.DIVE_BOMB] > 0
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    #@Condition eventPlayer.is_using_ability[Talent.JETPACK] == false
    @Condition eventPlayer.is_using_ability[Talent.BANDAGE] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.talent_trigger_times[Talent.DIVE_BOMB] + talent_base_cooldowns[Talent.DIVE_BOMB] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.getAltitude() >= 3.5
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.is_charging_railgun == false
    
    eventPlayer.is_using_ability[Talent.DIVE_BOMB] = true
    eventPlayer.dive_bomb_damage = DIVE_BOMB_DAMAGE
    eventPlayer.setJumpEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    if eventPlayer.is_using_ability[Talent.STEALTH] == true:
        async(break_stealth, AsyncBehavior.NOOP)
    eventPlayer.talent_trigger_times[Talent.DIVE_BOMB] = eventPlayer.totalTimeElapsed
    playEffect(getAllPlayers(), DynamicEffect.SOLDIER_SPRINT_START_SOUND, Color.TEAM_1, eventPlayer, 100)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP, Color.TEAM_2, eventPlayer, 1)
    playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition() + Vector.UP, 100)
    eventPlayer.startForcingPosition(eventPlayer.getPosition(), true)
    wait()
    eventPlayer.stopForcingPosition()
    /*
    eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -3, getAllPlayers(), eventPlayer, true).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3, null, getAllPlayers(), true).getHitPosition(), 20)
    */
    eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -3 /*+ worldVector(vect(-0.35, 0, 0), eventPlayer, Transform.ROTATION)*/, getAllPlayers(), eventPlayer, false).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection(), null, getAllPlayers(), true).getHitPosition(), 20)

    eventPlayer.applyImpulse(Vector.UP, 7.5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    #wait(0.2)
    
    #createEffect(getAllPlayers(), Effect.ASHE_DYNAMITE_BURNING_PARTICLE, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    
    #createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #eventPlayer.player_temp_effects[1] = getLastCreatedEntity()
    #playEffect(getAllPlayers(), DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_2, eventPlayer, 100)
    wait(0.8)

    createEffect(getAllPlayers(), Effect.WRECKING_BALL_PILEDRIVER_FIRE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[0] = getLastCreatedEntity()

    chase(eventPlayer.dive_bomb_damage, 2 * DIVE_BOMB_DAMAGE, duration=1, ChaseReeval.DESTINATION_AND_DURATION)
    #eventPlayer.applyImpulse(eventPlayer.getFacingDirection() if eventPlayer.getVerticalFacingAngle() > 0 else worldVector(vect(0, 0, 1), eventPlayer, Transform.ROTATION), 98, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

    #eventPlayer.applyImpulse(Vector.DOWN, 25, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), max(eventPlayer.getVerticalFacingAngle(), 0)), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

    #eventPlayer.setStatusEffect(null, Status.PHASED_OUT, true)
    #createEffect(getAllPlayers(), Effect.ENERGY_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #eventPlayer.player_temp_effects[2] = getLastCreatedEntity()
    #while eventPlayer.isAlive() and eventPlayer.isInAir():
        #playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer, 1)
        #wait(0.25)
    
    
    waitUntil(not eventPlayer.isAlive() or not eventPlayer.isInAir())

    stopChasingVariable(eventPlayer.dive_bomb_damage)
    destroyEffect(eventPlayer.player_temp_effects[0])
    destroyEffect(eventPlayer.player_temp_effects[1])
    destroyEffect(eventPlayer.player_temp_effects[2])
    
    if eventPlayer.isAlive():
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
        /*
        #Impulse
        (([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 5, Team.ALL, LosCheck.SURFACES) if player.is_using_ability[1] == false and player.is_using_ability[17] == false and player != eventPlayer and player.browsing_shop == false and player.isAlive()]).hit_by_talent)[7] = eventPlayer
        */

        eventPlayer.victims_in_dive_bomb_radius = [player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, 5, Team.ALL, LosCheck.SURFACES) if player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player != eventPlayer and player.browsing_shop == false and player.isAlive()]
        eventPlayer.dive_bomb_damage_total = 0
        for eventPlayer.current_dive_bomb_target in range(len(eventPlayer.victims_in_dive_bomb_radius)):
            eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target].applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target].getEyePosition() + Vector.DOWN)), min(verticalAngleOfDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target].getEyePosition() + Vector.DOWN)), -22.5)), 40 * (eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target].stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            wait(0.032)
            damage(eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target], eventPlayer, eventPlayer.dive_bomb_damage)
            playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer.victims_in_dive_bomb_radius[eventPlayer.current_dive_bomb_target], 1)
            eventPlayer.dive_bomb_damage_total += eventPlayer.dive_bomb_damage
        wait()
        if eventPlayer.dive_bomb_damage_total > 0:
            smallMessage(eventPlayer, "{0} Dive Bomb: {1} damage".format(abilityIconString(Hero.HAMMOND, Button.CROUCH), round(eventPlayer.dive_bomb_damage_total)))


        #createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        #eventPlayer.player_temp_effects[3] = getLastCreatedEntity()
        #wait(0.125)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.BASTION_TANK_CANNON_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
        #destroyEffect(eventPlayer.player_temp_effects[3])
    eventPlayer.is_using_ability[7] = false
    #eventPlayer.setStatusEffect(null, Status.PHASED_OUT, false)
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setJumpEnabled(true)
    eventPlayer.stopCamera()
/*
rule "TALENT SYSTEM - - - [DIVE BOMB] Hit By Dive Bomb Effect":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_dive_bomb_effect_counter > 0

    while eventPlayer.hit_by_dive_bomb_effect_counter > 0 and eventPlayer.isAlive():
        playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer, 1)
        eventPlayer.hit_by_dive_bomb_effect_counter -= 1
        wait(0.5, Wait.RESTART_WHEN_TRUE)
*/
    /*
rule "TALENT SYSTEM - - - [DIVE BOMB] Hit By Dive Bomb":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.DIVE_BOMB] != null
    
    if eventPlayer.is_using_ability[Talent.PURITY_FIELD] == true:
        eventPlayer.hit_by_talent[Talent.DIVE_BOMB] = null
        return
    eventPlayer.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.hit_by_talent[Talent.DIVE_BOMB].getPosition(), eventPlayer.getPosition())), -22.5), eventPlayer.hit_by_talent[Talent.DIVE_BOMB].dive_bomb_damage / 10 * (eventPlayer.stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    wait()
    damage(eventPlayer, eventPlayer.hit_by_talent[Talent.DIVE_BOMB], eventPlayer.hit_by_talent[Talent.DIVE_BOMB].dive_bomb_damage)
    eventPlayer.hit_by_talent[Talent.DIVE_BOMB] = null
    eventPlayer.hit_by_dive_bomb_effect_counter = 3
    while eventPlayer.hit_by_dive_bomb_effect_counter > 0 and eventPlayer.hit_by_talent[Talent.DIVE_BOMB] == null and eventPlayer.isAlive():
        playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_2, eventPlayer, 1)
        eventPlayer.hit_by_dive_bomb_effect_counter -= 1
        wait(0.5, Wait.RESTART_WHEN_TRUE)
        */

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
    @Condition not eventPlayer.isDummy()
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] > 0
    @Condition eventPlayer.talent_trigger_times[Talent.RAILGUN] + talent_base_cooldowns[Talent.RAILGUN] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isReloading() == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    #Using hearthstone
    @Condition eventPlayer.is_using_hearthstone == false
    
    #is charging railgun
    eventPlayer.is_charging_railgun = true
    chase(eventPlayer.railgun_charge, 100, rate=100, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.setPrimaryFireEnabled(false)
    #eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * 0.5)
    recalculate_player_speed()
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isDead() or eventPlayer.browsing_shop == true or eventPlayer.isUsingAbility1() or eventPlayer.isMeleeing() or eventPlayer.is_using_ability[Talent.RAILGUN] == true or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN), 99999)
    eventPlayer.is_charging_railgun = false
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
        eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
        async(continue_primary_fire, AsyncBehavior.NOOP)
    wait()
    #eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.RAILGUN] > 0
    @Condition eventPlayer.is_using_hearthstone == false
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
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
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
    #if eventPlayer.getCurrentHero() != Hero.SOLDIER and eventPlayer.getCurrentHero() != Hero.REAPER:

def railgun_projectile_is_in_air():
    @Name "TALENT SYSTEM - - - [TALENT 9: RAILGUN] [SUBROUTINE] Railgun Projectile Is In Air"
    
    eventPlayer.railgun_projectile_is_in_air = true
    #createBeam(getAllPlayers() if eventPlayer.railgun_projectile_is_in_air == true else null, Beam.BAD, evalOnce(eventPlayer.getPosition() + worldVector(vect(-1 * 1 * 1 * 0.25, 1.375, 0), eventPlayer, Transform.ROTATION) if eventPlayer.isCrouching() == false e
    createBeam(getAllPlayers() if eventPlayer.railgun_projectile_is_in_air == true else null, Beam.BAD, evalOnce(eventPlayer.getPosition() + worldVector(vect(-0.25, 0.875, 0), eventPlayer, Transform.ROTATION) if eventPlayer.isCrouching() else eventPlayer.getPosition() + worldVector(vect(-0.25, 1.375, 0), eventPlayer, Transform.ROTATION)), eventPlayer.railgun_projectile_destination, Color.SKY_BLUE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[30] = getLastCreatedEntity()
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_PILEDRIVER_IMPACT_SOUND, Color.TEAM_2, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null/* and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)*/], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 100)
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_CONCUSSIVE_BLAST, Color.TEAM_1, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null/* and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)*/], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 1)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_1, ((sorted([player for player in eventPlayer.railgun_projectile_player_hit if player != null/* and (player.getCurrentHero() == Hero.SOLDIER or player.getCurrentHero() == Hero.REAPER)*/], lambda i: distance(eventPlayer.getPosition(), i.getPosition() + Vector.UP)))[0]).getPosition() if any([player != null for player in eventPlayer.railgun_projectile_player_hit]) else eventPlayer.railgun_projectile_destination, 1)
    wait(0.375)
    destroyEffect(eventPlayer.player_temp_effects[30])
    eventPlayer.railgun_projectile_is_in_air = false
    eventPlayer.railgun_projectile_start = []
    eventPlayer.railgun_projectile_player_hit = []

rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Use Jetpack":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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
    @Condition not (eventPlayer.is_using_ability[Talent.GRIM_REAPER] and eventPlayer.casting_success)
    @Condition eventPlayer.has_hit_the_ground == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.JUMP) == true

    if eventPlayer.using_gamepad == true:
        if not eventPlayer.isOnGround() and eventPlayer.jetpack_fuel > 0:
            eventPlayer.is_using_ability[Talent.JETPACK] = true
            waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isOnGround() or eventPlayer.jetpack_fuel == 0 or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.is_using_ability[Talent.DIVE_BOMB] or eventPlayer.browsing_shop, 9999)
            eventPlayer.is_using_ability[Talent.JETPACK] = false
        else:
            waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead() or eventPlayer.browsing_shop, 9999)
    else:
        if eventPlayer.jetpack_will_have_a_delay == true:
            wait(0.25, Wait.ABORT_WHEN_FALSE)
            eventPlayer.jetpack_will_have_a_delay = false
        eventPlayer.is_using_ability[Talent.JETPACK] = true
        waitUntil(not eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.jetpack_fuel == 0 or eventPlayer.is_using_ability[Talent.DIVE_BOMB] or eventPlayer.browsing_shop, 9999)
        eventPlayer.is_using_ability[Talent.JETPACK] = false

/*
rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Jetpack Effects":
    @Event eachPlayer
    @Condition eventPlayer.is_using_ability[Talent.JETPACK] == true
    @Condition (eventPlayer.getCurrentHero() == Hero.SOLDIER or eventPlayer.getCurrentHero() == Hero.BRIGITTE) == true
    
    playEffect(null if eventPlayer.is_using_ability[Talent.STEALTH] == true else getAllPlayers().exclude(eventPlayer), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition() + worldVector(vect(0, 1.5, -0.5), eventPlayer, Transform.ROTATION), 1)
    wait(0.125)
    if RULE_CONDITION:
        goto RULE_START
*/

rule "TALENT SYSTEM - - - [TALENT 11: JETPACK] Jetpack Will Have a Delay":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.JETPACK] > 0
    @Condition eventPlayer.isOnGround() == true
    #@Condition (eventPlayer.getCurrentHero() == Hero.SOLDIER or eventPlayer.getCurrentHero() == Hero.BRIGITTE) == true
    
    eventPlayer.jetpack_will_have_a_delay = true

def health_regen_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 13: HEALTH REGEN] [SUBROUTINE] Health Regen Heal Over Time"
    
    while eventPlayer.talent_ranks[Talent.HEALTH_REGEN] > 0:
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 0, 99999)
        eventPlayer.startHoT(eventPlayer, 99999, HEALTH_REGEN_HEALING_OVER_TIME)
        eventPlayer.health_pool_id_or_hot_id[2] = getLastHoT()
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) >= eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 0, 99999)
        stopHoT(eventPlayer.health_pool_id_or_hot_id[2])

        /*
rule "TALENT SYSTEM - - - [TALENT 14/31: HEALTH POTIONS/POISON VIAL] Use Health Potion or Poison Vial":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition (eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0) == true
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] == false
    @Condition eventPlayer.amount_of_health_potions > 0
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
        eventPlayer.health_pool_id_or_hot_id[7 - eventPlayer.amount_of_health_potions] = getLastHoT()
        eventPlayer.amount_of_health_potions -= 1
        async(health_potion_heal_over_time, AsyncBehavior.NOOP)
    if eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
        eventPlayer.amount_of_health_potions -= 1
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
*/
rule "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] Use Health Potion":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] == false
    @Condition eventPlayer.amount_of_health_potions > 0
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    
    wait()
    if eventPlayer.getHealthOfType(Health.NORMAL) == eventPlayer.getMaxHealthOfType(Health.NORMAL):
        async(already_at_full_health, AsyncBehavior.NOOP)
        return
    eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] = true
    #health_potion_hps()
    playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 100)
    playEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.STEALTH] == false else eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT, Color.TEAM_1, eventPlayer, 100)
    
    # Store expiry timestamp for this potion
    # amount_of_health_potions is 3/2/1 before decrement, so 7 - 3 = index 4, 7 - 2 = 5, 7 - 1 = 6
    if eventPlayer.amount_of_health_potions == 3:
        eventPlayer.health_potion_1_timestamp = eventPlayer.totalTimeElapsed + 2
    elif eventPlayer.amount_of_health_potions == 2:
        eventPlayer.health_potion_2_timestamp = eventPlayer.totalTimeElapsed + 2
    elif eventPlayer.amount_of_health_potions == 1:
        eventPlayer.health_potion_3_timestamp = eventPlayer.totalTimeElapsed + 2
    eventPlayer.amount_of_health_potions -= 1
    async(health_potion_heal_monitor, AsyncBehavior.NOOP)
    
    wait(0.5)
    eventPlayer.is_using_ability[Talent.HEALTH_POTIONS] = false  
/*
rule "TALENT SYSTEM - - - [TALENT 14/31: HEALTH POTIONS/POISON VIAL] Health Potion or Poison Vial Start Recharge":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition (eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0 or eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0) == true
    @Condition eventPlayer.amount_of_health_potions < 3
    
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
    eventPlayer.amount_of_health_potions += 1
    if eventPlayer.amount_of_health_potions == 3:
        if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0:
            eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.HEALTH_POTIONS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
        elif eventPlayer.talent_ranks[Talent.POISON_VIALS] > 0:
            eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.POISON_VIALS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 100)
    if RULE_CONDITION:
        goto RULE_START
*/
rule "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] Health Potion Start Recharge":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] > 0
    @Condition eventPlayer.amount_of_health_potions < 3
    
    if eventPlayer.health_potion_cooldown_memory > 0:
        eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - eventPlayer.health_potion_cooldown_memory
        eventPlayer.health_potion_cooldown_memory = 0
    else:
        eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - eventPlayer.talent_ranks[Talent.ALCHEMIST]
    waitUntil(eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] + talent_base_cooldowns[Talent.HEALTH_POTIONS] <= eventPlayer.totalTimeElapsed, 99999)
    eventPlayer.amount_of_health_potions += 1
    if eventPlayer.amount_of_health_potions == 3:
        eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.HEALTH_POTIONS] - eventPlayer.talent_ranks[Talent.ALCHEMIST]
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 100)
    if RULE_CONDITION:
        goto RULE_START
/*
def health_potion_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Health Potions Stop Heal Over Time"
    
    waitUntil(eventPlayer.isDead() or eventPlayer.getMaxHealthOfType(Health.NORMAL) == eventPlayer.getHealthOfType(Health.NORMAL), 2)
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[4])
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[5])
    removeHealthPool(eventPlayer.health_pool_id_or_hot_id[6])
*/

def health_potion_heal_monitor():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Heal Over Time Monitor"

    while (eventPlayer.health_potion_1_timestamp > eventPlayer.totalTimeElapsed or eventPlayer.health_potion_2_timestamp > eventPlayer.totalTimeElapsed or eventPlayer.health_potion_3_timestamp > eventPlayer.totalTimeElapsed) and eventPlayer.isAlive():
        # Wait until normal health needs healing, or all potions expired
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) or (eventPlayer.health_potion_1_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_2_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_3_timestamp <= eventPlayer.totalTimeElapsed) or eventPlayer.isDead(), 99999)
        if (eventPlayer.health_potion_1_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_2_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_3_timestamp <= eventPlayer.totalTimeElapsed) or eventPlayer.isDead():
            goto lbl_0

        # Start HoTs for each potion that still has time left
        if eventPlayer.health_potion_1_timestamp > eventPlayer.totalTimeElapsed:
            eventPlayer.startHoT(eventPlayer, eventPlayer.health_potion_1_timestamp - eventPlayer.totalTimeElapsed, HEALTH_POTIONS_HEALING_OVER_TIME)
            eventPlayer.potion_hot_id_1 = getLastHoT()
        if eventPlayer.health_potion_2_timestamp > eventPlayer.totalTimeElapsed:
            eventPlayer.startHoT(eventPlayer, eventPlayer.health_potion_2_timestamp - eventPlayer.totalTimeElapsed, HEALTH_POTIONS_HEALING_OVER_TIME)
            eventPlayer.potion_hot_id_2 = getLastHoT()
        if eventPlayer.health_potion_3_timestamp > eventPlayer.totalTimeElapsed:
            eventPlayer.startHoT(eventPlayer, eventPlayer.health_potion_3_timestamp - eventPlayer.totalTimeElapsed, HEALTH_POTIONS_HEALING_OVER_TIME)
            eventPlayer.potion_hot_id_3 = getLastHoT()

        # Wait until health is full, all expired, or dead
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) >= eventPlayer.getMaxHealthOfType(Health.NORMAL) or (eventPlayer.health_potion_1_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_2_timestamp <= eventPlayer.totalTimeElapsed and eventPlayer.health_potion_3_timestamp <= eventPlayer.totalTimeElapsed) or eventPlayer.isDead(), 99999)

        # Stop all HoTs before looping
        stopHoT(eventPlayer.potion_hot_id_1)
        stopHoT(eventPlayer.potion_hot_id_2)
        stopHoT(eventPlayer.potion_hot_id_3)

    lbl_0:
    stopHoT(eventPlayer.potion_hot_id_1)
    stopHoT(eventPlayer.potion_hot_id_2)
    stopHoT(eventPlayer.potion_hot_id_3)

def already_at_full_health():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Health Potion Already At Full Health!"
    
    smallMessage(eventPlayer, "Already at full health!")
    playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 75)
    wait(3)

rule "TALENT SYSTEM - - - [TALENT 16: IGNITE] Ignite Effects":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isFiringSecondaryFire() == true
    @Condition eventPlayer.talent_ranks[Talent.IGNITE] > 0
    
    eventPlayer.is_using_ability[Talent.IGNITE] = true
    eventPlayer.ignite_position = eventPlayer.getEyePosition()
    eventPlayer.ignite_raycast_hit_position = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200, null, getAllPlayers(), true).getHitPosition()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING, Color.TEAM_1, eventPlayer.ignite_position, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[70] = getLastCreatedEntity()
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.TEAM_1, eventPlayer.ignite_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[72] = getLastCreatedEntity()
    chase(eventPlayer.ignite_position, eventPlayer.ignite_raycast_hit_position, rate=50, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil(eventPlayer.is_using_ability[Talent.IGNITE] == false or eventPlayer.ignite_position == eventPlayer.ignite_raycast_hit_position, 5.984)
    stopChasingVariable(eventPlayer.ignite_position)
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_CONCUSSION_MINE_EXPLOSION, Color.TEAM_1, eventPlayer.ignite_position, 1)
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_ROCKET_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.ignite_position, 100)
    destroyEffect(eventPlayer.player_temp_effects[70])
    destroyEffect(eventPlayer.player_temp_effects[72])
    eventPlayer.is_using_ability[Talent.IGNITE] = false

rule "TALENT SYSTEM - - - [SHADOWSTEP] Use Shadowstep":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.SHADOWSTEP] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.is_using_hearthstone == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.talent_trigger_times[Talent.SHADOWSTEP] + talent_base_cooldowns[Talent.SHADOWSTEP] - eventPlayer.talent_ranks[Talent.SHADOWSTEP] * SHADOWSTEP_COOLDOWN_REDUCTION_PER_RANK <= eventPlayer.totalTimeElapsed
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
    /*if eventPlayer.talent_ranks[Talent.STEALTH] > 0 and eventPlayer.is_using_ability[Talent.STEALTH] == false and eventPlayer.in_combat > 0:
        chase(eventPlayer.entering_stealth_timer, 0 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, rate=0.113 - eventPlayer.talent_ranks[Talent.STEALTH] * 0.013 if eventPlayer.is_using_ability[Talent.STEALTH] == true else 1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.entering_stealth_timer = 1
        async(in_stealth, AsyncBehavior.NOOP)
        wait(0.5)
        eventPlayer.setGravity(100)
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        eventPlayer.is_using_ability[Talent.SHADOWSTEP] = false
        destroyEffect(eventPlayer.player_temp_effects[6])
        return*/
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.BURNING_SOUL] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    #are there more than one victim in burning soul radius?
    @Condition (len([player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, BURNING_SOUL_AURA_RADIUS, Team.ALL, LosCheck.SURFACES) 
        if 
            player != eventPlayer 
            and player.is_using_ability[Talent.SHADOWSTEP] == false 
            and player.is_using_ability[Talent.PURITY_FIELD] == false 
            and eventPlayer.is_using_ability[Talent.STEALTH] == false
            and player.is_using_ability[Talent.STEALTH] == false 
            and player.browsing_shop == false  
            and player.isAlive() == true])) > 0
    
    eventPlayer.victims_in_burning_soul_radius = [player for player in getPlayersInRadius(eventPlayer.getPosition() + Vector.UP, BURNING_SOUL_AURA_RADIUS, Team.ALL, LosCheck.SURFACES) 
        if 
            player != eventPlayer 
            and player.is_using_ability[Talent.SHADOWSTEP] == false 
            and player.is_using_ability[Talent.PURITY_FIELD] == false
            and eventPlayer.is_using_ability[Talent.STEALTH] == false 
            and player.is_using_ability[Talent.STEALTH] == false 
            and player.browsing_shop == false 
            and player.isAlive() == true]
    for eventPlayer.fire_soul_loop in range(len(eventPlayer.victims_in_burning_soul_radius)):
        #playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.ORANGE, updateEveryFrame(eventPlayer.getPosition() + Vector.UP / 2), BURNING_SOUL_AURA_RADIUS * 1.25)
        eventPlayer.victims_in_burning_soul_radius[eventPlayer.fire_soul_loop].setStatusEffect(eventPlayer, Status.BURNING, 1)
        damage(eventPlayer.victims_in_burning_soul_radius[eventPlayer.fire_soul_loop], eventPlayer, BURNING_SOUL_DAMAGE)
    wait(0.25, Wait.IGNORE_CONDITION)
    eventPlayer.victims_in_burning_soul_radius = []
    if RULE_CONDITION:
        goto RULE_START


/*rule "TALENT SYSTEM - - - [TALENT 19: BURNING SOUL] Hit By Burning Soul Orb Explosion":
    @Event eachPlayer
    #@Condition eventPlayer.owner_of_picked_up_xp_orb != null
    @Condition eventPlayer.hit_by_talent[Talent.BURNING_SOUL] != null
    
    eventPlayer.applyImpulse(directionTowards(eventPlayer.hit_by_talent[Talent.BURNING_SOUL].getPosition() if eventPlayer.hit_by_talent[Talent.BURNING_SOUL].xp_orb_position_on_player == true else eventPlayer.hit_by_talent[Talent.BURNING_SOUL].xp_orb_location, eventPlayer.getEyePosition()), 12.5 * (eventPlayer.stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
    damage(eventPlayer, eventPlayer.hit_by_talent[Talent.BURNING_SOUL], BURNING_SOUL_ORB_DAMAGE)
    wait()
    eventPlayer.hit_by_talent[Talent.BURNING_SOUL] = null


def dropped_burning_soul_orb():
    @Name "TALENT SYSTEM - - - [BURNING SOUL] Dropped Burning Soul Orb"
    
    waitUntil(eventPlayer.burning_soul_orb_timer == 0, 4)
    (((getPlayersInRadius(eventPlayer.getPosition() + Vector.UP * 0.25 if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location + Vector.UP * 0.25, 3, Team.ALL, LosCheck.SURFACES_AND_ENEMY_BARRIERS)).exclude(eventPlayer)).hit_by_talent)[18] = eventPlayer
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 100)
    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION, Color.TEAM_2, eventPlayer.getPosition() if eventPlayer.xp_orb_position_on_player == true else eventPlayer.xp_orb_location, 1)
*/
rule "TALENT SYSTEM - - - [TALENT 20: BERSERKER] Use Berserker":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    
    eventPlayer.is_using_ability[Talent.BERSERKER] = true
    eventPlayer.berserker_duration = 0
    chase(eventPlayer.berserker_duration, BERSERKER_DURATION, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.talent_trigger_times[Talent.BERSERKER] = eventPlayer.totalTimeElapsed
    eventPlayer.setDamageDealt(eventPlayer.stats[Stat.DAMAGE] * 1.25)
    eventPlayer.setDamageReceived(110)
    wait(0.5)
    #BERSERKER_DURATION -0.5 to account for button mash protection
    waitUntil(eventPlayer.isDead() or eventPlayer.isHoldingButton(Button.ULTIMATE), BERSERKER_DURATION - 0.5)
    eventPlayer.setDamageDealt(eventPlayer.stats[Stat.DAMAGE])
    eventPlayer.setDamageReceived(100)
    eventPlayer.is_using_ability[Talent.BERSERKER] = false
    stopChasingVariable(eventPlayer.berserker_duration)
    if eventPlayer.isAlive() and eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0 and eventPlayer.bloodthirst_remaining_heal_amount >= 1:
        if eventPlayer.berserker_duration < 1:
            eventPlayer.berserker_duration = 1
        eventPlayer.bloodthirst_remaining_heal_amount = eventPlayer.bloodthirst_remaining_heal_amount / eventPlayer.berserker_duration * 5
        async(bloodthirst_effects, AsyncBehavior.NOOP)
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
        while eventPlayer.getHealthOfType(Health.NORMAL) > eventPlayer.stats[Stat.HEALTH] * 2 and eventPlayer.isAlive() and eventPlayer.bloodthirst_remaining_heal_amount >= 1:
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
    
    eventPlayer.exit_shop_with_fireball = true
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) == false, 99999)
    eventPlayer.exit_shop_with_fireball = false
    /*
    eventPlayer.disallowButton(Button.INTERACT)
    wait(2)
    eventPlayer.allowButton(Button.INTERACT)
    */

rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Use Fireball":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.FIREBALL] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.exit_shop_with_fireball == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition (not eventPlayer.hasStatusEffect(Status.PHASED_OUT) if eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false else eventPlayer.isAlive()) == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.fireball_in_air == false
    @Condition eventPlayer.is_using_hearthstone == false
    @Condition eventPlayer.fireball_position == null
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= eventPlayer.totalTimeElapsed
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
    createEffect(getAllPlayers(), Effect.TORBJORN_OVERLOADING_SOUND, Color.ORANGE, eventPlayer.fireball_position, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.fireball_effects[0] = getLastCreatedEntity()
    eventPlayer.fireball_destination = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
    eventPlayer.fireball_position = eventPlayer.getEyePosition()
    chaseAtRate(eventPlayer.fireball_position, eventPlayer.fireball_destination, FIREBALL_SPEED, ChaseRateReeval.DESTINATION_AND_RATE)
    createProjectileEffect(getAllPlayers(), Projectile.REINHARDT_FIRE_STRIKE, Color.TEAM_1, eventPlayer.fireball_position, directionTowards(eventPlayer.fireball_position, eventPlayer.fireball_destination), 0, ProjectileEffectReeval.POSITION_DIRECTION_AND_SIZE)
    eventPlayer.fireball_effects[1] = getLastCreatedEntity()

    waitUntil(eventPlayer.fireball_position == eventPlayer.fireball_destination or eventPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= eventPlayer.totalTimeElapsed or any([player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and eventPlayer.fireball_position != null and player.isAlive() and player.browsing_shop == false for player in getPlayersInRadius(eventPlayer.fireball_position.getPosition(), FIREBALL_PROJECTILE_RADIUS, Team.ALL, LosCheck.SURFACES)]) == true, Math.INFINITY)

    eventPlayer.victims_in_fireball_radius = [player for player in getPlayersInRadius(eventPlayer.fireball_position, FIREBALL_EXPLOSION_RADIUS, Team.ALL, LosCheck.SURFACES) 
        if 
            player.browsing_shop == false 
            and player.isAlive() 
            #and player != eventPlayer 
            and player.is_using_ability[Talent.PURITY_FIELD] == false 
            and player.is_using_ability[Talent.SHADOWSTEP] == false]

    for eventPlayer.fireball_loop in range(len(eventPlayer.victims_in_fireball_radius)):

        #Impulse
        eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.fireball_position, eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].getEyePosition() + Vector.DOWN)), min(verticalAngleOfDirection(directionTowards(eventPlayer.fireball_position, eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].getEyePosition() + Vector.DOWN)), -30)), 15 * (eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

        wait(0.032)

        damage(eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop], eventPlayer, FIREBALL_DAMAGE if eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop] != eventPlayer else FIREBALL_DAMAGE_SELF if eventPlayer.talent_ranks[Talent.PYROMANIAC] == 0 else 0)
        eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].startDoT(eventPlayer, FIREBALL_DAMAGE_OVER_TIME_DURATION if eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop] != eventPlayer else FIREBALL_DAMAGE_SELF_OVER_TIME_DURATION, FIREBALL_DAMAGE_OVER_TIME if eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop] != eventPlayer else FIREBALL_DAMAGE_SELF_OVER_TIME if eventPlayer.talent_ranks[Talent.PYROMANIAC] == 0 else 0)

        #Set Status Burning
        eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop].setStatusEffect(eventPlayer, Status.BURNING, FIREBALL_DAMAGE_OVER_TIME_DURATION)
        if eventPlayer.talent_ranks[Talent.PYROMANIAC] > 0 and eventPlayer.victims_in_fireball_radius[eventPlayer.fireball_loop] == eventPlayer:
            async(pyromaniac_heal_over_time, AsyncBehavior.NOOP)
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION, Color.TEAM_2, eventPlayer.fireball_position, 2)
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.TEAM_2, eventPlayer.fireball_position, 100)
    eventPlayer.fireball_in_air = false
    stopChasingVariable(eventPlayer.fireball_position)
    destroyEffect(eventPlayer.fireball_effects[0])
    destroyEffect(eventPlayer.fireball_effects[1])
    wait()
    eventPlayer.fireball_position = null
/*
    #Impulse
    (([player for player in getPlayersInRadius(eventPlayer.fireball_position, FIREBALL_EXPLOSION_RADIUS, Team.ALL, LosCheck.SURFACES) if player.isAlive() and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.is_using_ability[Talent.PURITY_FIELD] == false]).hit_by_talent)[Talent.FIREBALL] = eventPlayer

    #Set Status Burning
    ([player for player in getPlayersInRadius(eventPlayer.fireball_position, FIREBALL_EXPLOSION_RADIUS, Team.ALL, LosCheck.SURFACES) if player.is_using_ability[Talent.PURITY_FIELD] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and player.browsing_shop == false and player.isAlive()]).setStatusEffect(eventPlayer, Status.BURNING, 5)
    
    #If the caster is within radius
    if ([player for player in getPlayersInRadius(eventPlayer.fireball_position, FIREBALL_EXPLOSION_RADIUS, Team.ALL, LosCheck.OFF) if player == eventPlayer and player.isAlive()]) == true:
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
    eventPlayer.fireball_in_air = false


    stopChasingVariable(eventPlayer.fireball_position)
    destroyEffect(eventPlayer.fireball_effects[0])
    destroyEffect(eventPlayer.fireball_effects[1])
    eventPlayer.fireball_position = null
    destroyEffect(eventPlayer.player_temp_effects[29])*/
/*
rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Fireball Hit Something":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.FIREBALL] > 0
    @Condition eventPlayer.fireball_in_air == true
    @Condition (eventPlayer.fireball_position == eventPlayer.fireball_destination or eventPlayer.talent_trigger_times[Talent.FIREBALL] + talent_base_cooldowns[Talent.FIREBALL] <= eventPlayer.totalTimeElapsed or any([player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and eventPlayer.fireball_position != null and player.isAlive() and player.browsing_shop == false for player in getPlayersInRadius(eventPlayer.fireball_position.getPosition(), FIREBALL_PROJECTILE_RADIUS, Team.ALL, LosCheck.SURFACES)])) == true
*/
/*
rule "TALENT SYSTEM - - - [TALENT 21: FIREBALL] Hit By Fireball":
    @Event eachPlayer
    @Condition eventPlayer.hit_by_talent[Talent.FIREBALL] != null

    eventPlayer.applyImpulse(directionTowards(eventPlayer.hit_by_talent[Talent.FIREBALL].fireball_position, eventPlayer.getEyePosition()), 15 * (eventPlayer.stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    eventPlayer.hit_by_talent[Talent.FIREBALL] = null
*/
rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] Ignore Pain Activated":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.IGNORE_PAIN] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition (eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.isReloading() or eventPlayer.isUsingAbility1() or eventPlayer.is_using_hearthstone == true or eventPlayer.is_using_ability[Talent.GRIM_REAPER] == true) == true
    
    eventPlayer.is_using_ability[Talent.IGNORE_PAIN] = true
    async(ignore_pain_volume, AsyncBehavior.NOOP)
    eventPlayer.ignore_pain_damage_resistance = IGNORE_PAIN_DAMAGE_RESISTANCE
    eventPlayer.setDamageReceived(IGNORE_PAIN_DAMAGE_RECEIVED)
    waitUntil(not eventPlayer.hasStatusEffect(Status.STUNNED) and not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) and not eventPlayer.isReloading() and not eventPlayer.isUsingAbility1() and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false and eventPlayer.is_using_hearthstone == false and eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false or eventPlayer.isDead(), 99999)
    eventPlayer.ignore_pain_volume = 25
    eventPlayer.setDamageReceived(100)
    eventPlayer.is_using_ability[Talent.IGNORE_PAIN] = false


rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] Start Timer When Entering Combat":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.IGNORE_PAIN] > 0
    @Condition eventPlayer.in_combat > 0
    
    chase(eventPlayer.total_time_in_combat, 9999, rate=1, ChaseReeval.DESTINATION_AND_RATE)

rule "Exiting Combat":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy() 
    @Condition eventPlayer.in_combat == 0
    
    /*
    if eventPlayer.talent_ranks[Talent.GRIM_REAPER] > 0 and (eventPlayer.grim_reaper_damage_dealt > 0 or eventPlayer.grim_reaper_damage_resisted > 0):
        smallMessage(eventPlayer, "{0} Grim Reaper Damage: {1}, Grim Reaper Resisted: {2}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.grim_reaper_damage_dealt), round(eventPlayer.grim_reaper_damage_resisted)) if eventPlayer.grim_reaper_damage_dealt > 0 and eventPlayer.grim_reaper_damage_resisted > 0 else "{0} Grim Reaper Damage: {1}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.grim_reaper_damage_dealt)) if eventPlayer.grim_reaper_damage_dealt > 0 and eventPlayer.grim_reaper_damage_resisted == 0 else "{0} Grim Reaper Resisted: {1}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), round(eventPlayer.grim_reaper_damage_resisted))) 
    */
    if eventPlayer.talent_ranks[Talent.GIGACHAD] > 0 and eventPlayer.gigachad_damage_resisted > 0:
        smallMessage(eventPlayer, "{0} Gigachad Damage Resisted: {1}".format(abilityIconString(Hero.RAMATTRA, Button.ABILITY_1), round(eventPlayer.gigachad_damage_resisted)))
    wait()
    #eventPlayer.grim_reaper_damage_dealt = 0
    #eventPlayer.grim_reaper_damage_resisted = 0
    eventPlayer.gigachad_damage_resisted = 0

def block_player_input():
    @Name "GENERAL - - - [SUBROUTINE] Remove Player Input"

    eventPlayer.disableHeroHud()
    eventPlayer.setCrouchEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setJumpEnabled(false)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 99999)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)

def resume_player_input():
    @Name "GENERAL - - - [SUBROUTINE] Resume Player Input"

    eventPlayer.enableHeroHud()
    eventPlayer.setCrouchEnabled(true)
    eventPlayer.setPrimaryFireEnabled(true)
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
        eventPlayer.setSecondaryFireEnabled(true)
    #if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] == 0:
    restore_ability1()
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.setJumpEnabled(true)
    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)

def casting_cancelled():
    @Name "GENERAL - - - [SUBROUTINE] Casting Cancelled?"

    # CASTING HEARTHSTONE
    if eventPlayer.is_using_hearthstone == true:
        waitUntil((eventPlayer.in_combat > 0 or not eventPlayer.isHoldingButton(Button.RELOAD) or eventPlayer.isDead()) == true or eventPlayer.casting_success)
        if eventPlayer.casting_success == true:
            return
    # SKIPPING TALENT
    elif eventPlayer.is_using_skip_talent == true:
        waitUntil(eventPlayer.isHoldingButton(Button.RELOAD) == false or eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) or eventPlayer.casting_success)

        if eventPlayer.casting_success == true:
            return

    # VOTING YES      
    elif eventPlayer.is_using_vote_yes == true:
        waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) == false or eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) or eventPlayer.casting_success)

        if eventPlayer.casting_success == true:
            return
    # VOTING NO
    elif eventPlayer.is_using_vote_no == true:
        waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) == false or eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) or eventPlayer.casting_success)

        if eventPlayer.casting_success == true:
            return
    
    # CASTING GRIM REAPER
    elif eventPlayer.is_using_ability[Talent.GRIM_REAPER] == true:
        #Tap to cast, tap again to cancel: first wait for the activation press to release so it isn't read as the cancel press
        waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.casting_success or eventPlayer.grim_reaper_target.isDead() or not entityExists(eventPlayer.grim_reaper_target), GRIM_REAPER_CAST_TIME)

        if eventPlayer.casting_success == true:
            return
        #A fresh press of Interact now cancels the cast (it runs hands-free until then)
        waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isDead() or eventPlayer.hasStatusEffect(Status.STUNNED) or eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.casting_success or eventPlayer.grim_reaper_target.isDead() or not entityExists(eventPlayer.grim_reaper_target), GRIM_REAPER_CAST_TIME)
        
        if eventPlayer.casting_success == true:
            return

    #Cancelled...
    end_cancel:
    if eventPlayer.is_using_ability[Talent.GRIM_REAPER] == true or eventPlayer.is_using_hearthstone == true:
        eventPlayer.setPrimaryFireEnabled(true)
        if eventPlayer.talent_ranks[Talent.RAILGUN] == 0:
            eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setMeleeEnabled(true)
        #if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] == 0:
        restore_ability1()
    eventPlayer.stopFacing()
    if eventPlayer.browsing_shop == false:
        eventPlayer.stopCamera()
    eventPlayer.is_using_ability[Talent.GRIM_REAPER] = false
    eventPlayer.using_one_of_the_hearthstones = false
    eventPlayer.is_using_hearthstone = false
    eventPlayer.is_using_skip_talent = false
    eventPlayer.is_using_vote_yes = false
    eventPlayer.is_using_vote_no = false
    stopChasingVariable(eventPlayer.casting_timer)
    eventPlayer.using_hearthstone_timer = 0
    destroyEffect(eventPlayer.casting_effect_id)
    destroyEffect(eventPlayer.casting_sound_effect_id)

def casting():
    @Name "GENERAL - - - [SUBROUTINE] Casting"

    # Reset from previous cast
    eventPlayer.casting_success = false

    #Cancelled?
    async(casting_cancelled, AsyncBehavior.NOOP)

    #Slow & Camera?
    if eventPlayer.is_using_hearthstone or eventPlayer.is_using_ability[Talent.GRIM_REAPER]:
        recalculate_player_speed()
        eventPlayer.startCamera(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1 /*+ worldVector(vect(-0.35, 0, 0), eventPlayer, Transform.ROTATION)*/, getAllPlayers(), eventPlayer, false).getHitPosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection(), null, getAllPlayers(), true).getHitPosition(), 20)

    # Block combat input during casting
    if eventPlayer.is_using_hearthstone or eventPlayer.is_using_ability[Talent.GRIM_REAPER]:
        eventPlayer.setPrimaryFireEnabled(false)
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.setMeleeEnabled(false)
        eventPlayer.setAbility1Enabled(false)

    eventPlayer.casting_timer = 0

    #SFX (Casting)
    if eventPlayer.is_using_hearthstone or eventPlayer.is_using_ability[Talent.GRIM_REAPER]:

        #Vector 0 Right, 1.8 Up, 1 Forward
        createEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.GOOD_AURA_SOUND, Color.WHITE, updateEveryFrame(eventPlayer.getPosition() + worldVector(vect(0, 1.8, 1), eventPlayer, Transform.ROTATION)), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    elif eventPlayer.is_using_skip_talent or eventPlayer.is_using_vote_yes or eventPlayer.is_using_vote_no:
        createEffect(eventPlayer, Effect.SOMBRA_HACKING_SOUND, Color.WHITE, shop_location if eventPlayer.browsing_shop == true else eventPlayer.getPosition(), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    eventPlayer.casting_sound_effect_id = getLastCreatedEntity()

    #VFX (Casting)

    if eventPlayer.is_using_hearthstone:
        createEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.GOOD_AURA, Color.GREEN, updateEveryTick(eventPlayer.getPosition() + Vector.UP), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    
    elif eventPlayer.is_using_ability[Talent.GRIM_REAPER]: 
        
        createEffect(getAllPlayers() if eventPlayer.casting_timer < GRIM_REAPER_CAST_TIME and not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.GOOD_AURA, Color.RED, updateEveryTick(eventPlayer.getPosition() + Vector.UP), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    eventPlayer.casting_effect_id = getLastCreatedEntity()

    #Chase
    chaseAtRate(eventPlayer.casting_timer, GRIM_REAPER_CAST_TIME if eventPlayer.is_using_ability[Talent.GRIM_REAPER] else 0.5 if faster_testing else 2.75, 1, ChaseRateReeval.DESTINATION_AND_RATE)

    #Wait
    if eventPlayer.is_using_ability[Talent.GRIM_REAPER]:
        waitUntil(eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false, GRIM_REAPER_CAST_TIME)
    else:
        wait(0.5 if faster_testing else 2.75, Wait.ABORT_WHEN_FALSE)

    #Result (Casting Complete)
    eventPlayer.casting_success = true
    if eventPlayer.is_using_hearthstone == true:
        playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION, Color.TEAM_1, eventPlayer.getPosition() + Vector.UP, 1)
        playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_DISAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            break_stealth()
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
        eventPlayer.stopFacing()
        async(open_shop, AsyncBehavior.NOOP)
        eventPlayer.browsing_shop = true
        casting_cancelled()
        eventPlayer.is_using_hearthstone = false

    elif eventPlayer.is_using_skip_talent == true:
        eventPlayer.is_using_skip_talent = false
        eventPlayer.browsing_shop = false
        eventPlayer.selected_talent_position = shop_talent_positions[1]
        eventPlayer.can_enter_shop = false
        eventPlayer.experience_current = 0
        eventPlayer.selected_talent_in_shop = 1
        eventPlayer.skipped_a_talent = true
        eventPlayer.is_respawning = true
        eventPlayer.respawn()
        casting_cancelled()

    elif eventPlayer.is_using_vote_yes and eventPlayer.replacing_talent_show_confirmation:
        eventPlayer.replacing_talent_show_bought_talents = true
        casting_cancelled()

    elif eventPlayer.is_using_vote_no and eventPlayer.replacing_talent_show_confirmation:
        eventPlayer.replacing_talent_cancelled = true
        casting_cancelled()

    elif eventPlayer.is_using_ability[Talent.GRIM_REAPER] == true:
        grim_reaper_casted()

    eventPlayer.is_using_hearthstone = false
    eventPlayer.is_using_skip_talent = false
    eventPlayer.is_using_vote_yes = false
    eventPlayer.is_using_vote_no = false
    stopChasingVariable(eventPlayer.casting_timer)
    eventPlayer.using_hearthstone_timer = 0
    destroyEffect(eventPlayer.casting_effect_id)
    destroyEffect(eventPlayer.casting_sound_effect_id)

rule "TALENT SYSTEM - - - [GRIM REAPER] Update Aim Indicator":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.GRIM_REAPER] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    
    eventPlayer.grim_reaper_aim_indicator = null
    while RULE_CONDITION:
        eventPlayer.grim_reaper_aim_indicator = sorted([player for player in getAllPlayers() if player != eventPlayer and player.isAlive() == true and player.getHealth() < player.getMaxHealth() * GRIM_REAPER_HEALTH_THRESHOLD and player.is_using_ability[Talent.STEALTH] == false and player.is_using_ability[Talent.SHADOWSTEP] == false and angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), player.getPosition() + Vector.UP)) < atan2Deg(1, distance(eventPlayer.getEyePosition(), player.getPosition() + Vector.UP))], lambda player: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), player.getPosition() + Vector.UP)))[0]
        wait(0.128)
    
#NEW GRIM REAPER    
rule "TALENT SYSTEM - - - [GRIM REAPER] Use Grim Reaper":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.GRIM_REAPER] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.BANDAGE] == false
    @Condition not (eventPlayer.is_using_ability[Talent.JETPACK] and
    eventPlayer.casting_success)
    @Condition eventPlayer.is_using_hearthstone == false
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.in_combat == 0
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition (eventPlayer.hasStatusEffect(Status.PHASED_OUT) == false and eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false) == true
    #@Condition eventPlayer.talent_trigger_times[Talent.GRIM_REAPER] + talent_base_cooldowns[Talent.GRIM_REAPER] <= eventPlayer.totalTimeElapsed
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.grim_reaper_aim_indicator != null
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

    eventPlayer.grim_reaper_target = eventPlayer.grim_reaper_aim_indicator

    eventPlayer.is_using_ability[Talent.GRIM_REAPER] = true
    eventPlayer.grim_reaper_camera_destination = eventPlayer.grim_reaper_target.getEyePosition()
    eventPlayer.grim_reaper_feet_destination = eventPlayer.grim_reaper_target.getPosition()
    
    casting()

def grim_reaper_casted():
    @Name "TALENT SYSTEM - - - [GRIM REAPER] Grim Reaper Casted"

    # FLIGHT START
    block_player_input()

    eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)

    if eventPlayer.grim_reaper_target.isDead() or not entityExists(eventPlayer.grim_reaper_target):
        goto lbl_0

    eventPlayer.grim_reaper_camera_destination = eventPlayer.grim_reaper_target.getEyePosition()
    eventPlayer.grim_reaper_feet_destination = eventPlayer.grim_reaper_target.getPosition()

    # DISAPPEAR
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)

    # CAMERA START POSITION (IS CHASED)
    eventPlayer.grim_reaper_camera_position = eventPlayer.getEyePosition()

    # CREATE EFFECTS
    createProjectileEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Projectile.MOIRA_DAMAGE_ORB, null, eventPlayer.grim_reaper_camera_position + Vector.DOWN, eventPlayer.grim_reaper_camera_destination, 0, ProjectileEffectReeval.POSITION_DIRECTION_AND_SIZE)
    eventPlayer.grim_reaper_effect_id = getLastCreatedEntity()
    createEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.LUCIO_SOUND_BARRIER_PROTECTED_SOUND, Color.WHITE, eventPlayer.grim_reaper_camera_position + Vector.DOWN, 100, EffectReeval.POSITION_AND_RADIUS)
    eventPlayer.grim_reaper_sound_id = getLastCreatedEntity()

    eventPlayer.grim_reaper_ramp_up = 0
    chaseOverTime(eventPlayer.grim_reaper_ramp_up, GRIM_REAPER_FLIGHT_SPEED, 1 **4, ChaseTimeReeval.DESTINATION_AND_DURATION)
    chaseAtRate(eventPlayer.grim_reaper_camera_position, eventPlayer.grim_reaper_camera_destination, eventPlayer.grim_reaper_ramp_up, ChaseRateReeval.DESTINATION_AND_RATE)

    eventPlayer.stopFacing()
    eventPlayer.startCamera(eventPlayer.grim_reaper_camera_position, eventPlayer.grim_reaper_target.getPosition() + Vector.UP if eventPlayer.grim_reaper_target.isAlive() else eventPlayer.grim_reaper_camera_destination, 30)

    waitUntil(distance(eventPlayer.grim_reaper_camera_position, eventPlayer.grim_reaper_camera_destination) < GRIM_REAPER_RADIUS * 2 or eventPlayer.isDead() or eventPlayer.grim_reaper_target.isDead() or not entityExists(eventPlayer.grim_reaper_target), Math.INFINITY)

    if not eventPlayer.isDead() and (eventPlayer.grim_reaper_target.isDead() or not entityExists(eventPlayer.grim_reaper_target)):
        eventPlayer.grim_reaper_camera_destination = eventPlayer.grim_reaper_target.getEyePosition()
        eventPlayer.grim_reaper_feet_destination = eventPlayer.grim_reaper_target.getPosition()

    if eventPlayer.isDead():
        goto lbl_0

    waitUntil(distance(eventPlayer.grim_reaper_camera_position, eventPlayer.grim_reaper_camera_destination) < GRIM_REAPER_RADIUS or eventPlayer.isDead(), Math.INFINITY)

    if eventPlayer.isDead():
        goto lbl_0

    # WHO WILL GET HIT?
    eventPlayer.victims_in_grim_reaper_radius = [player for player in getPlayersInRadius(eventPlayer.grim_reaper_camera_destination + Vector.DOWN, GRIM_REAPER_RADIUS, Team.ALL, LosCheck.OFF) if player != eventPlayer and player.is_using_ability[Talent.SHADOWSTEP] == false and player.is_using_ability[Talent.PURITY_FIELD] == false and player.browsing_shop == false and player.isAlive() == true]
    
    # EFFECTS - PLAYED ONCE
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR, Color.TEAM_2, eventPlayer.grim_reaper_camera_destination + Vector.DOWN, 1)
    
    if eventPlayer.victims_in_grim_reaper_radius != []:

        playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION_SOUND, Color.WHITE, eventPlayer.grim_reaper_camera_destination + Vector.DOWN, 100)

            for eventPlayer.grim_reaper_selector in range(len(eventPlayer.victims_in_grim_reaper_radius)):

                # APPLY IMPULSE
                eventPlayer.victims_in_grim_reaper_radius[eventPlayer.grim_reaper_selector].applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(eventPlayer.grim_reaper_camera_position + Vector.DOWN, eventPlayer.victims_in_grim_reaper_radius[eventPlayer.grim_reaper_selector].getEyePosition() + Vector.DOWN)), min(verticalAngleOfDirection(directionTowards(eventPlayer.grim_reaper_camera_position + Vector.DOWN, eventPlayer.victims_in_grim_reaper_radius[eventPlayer.grim_reaper_selector].getEyePosition() + Vector.DOWN)), -30)), 7.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

                # EFFECT - FOR EACH PLAYER
                playEffect(getAllPlayers(), DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_2, eventPlayer.victims_in_grim_reaper_radius[eventPlayer.grim_reaper_selector], 1)

    # WAIT UNTIL AT DESTINATION
    waitUntil(eventPlayer.grim_reaper_camera_position == eventPlayer.grim_reaper_camera_destination or eventPlayer.isDead(), Math.INFINITY)

    if eventPlayer.isDead():
        goto lbl_0

    # EFFECT - PLAYER REAPPEARING
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.BAD_PICKUP_EFFECT, Color.RED, eventPlayer.grim_reaper_camera_destination + Vector.DOWN, 1)

    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.MOIRA_FADE_REAPPEAR, Color.TEAM_2, eventPlayer.getPosition(), 1)

    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.MOIRA_FADE_REAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)

    eventPlayer.teleport(eventPlayer.grim_reaper_feet_destination)

    lbl_0:
    # CLEANUP - always runs (success or death)
    stopChasingVariable(eventPlayer.grim_reaper_camera_position)
    stopChasingVariable(eventPlayer.grim_reaper_ramp_up)
    destroyEffect(eventPlayer.grim_reaper_effect_id)
    destroyEffect(eventPlayer.grim_reaper_sound_id)
    eventPlayer.casting_success = false
    eventPlayer.stopForcingPosition()
    wait()
    
    # Teleport BEFORE resuming input
    eventPlayer.stopCamera()
    if eventPlayer.isAlive():
        eventPlayer.teleport(eventPlayer.grim_reaper_feet_destination)
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.grim_reaper_target.getEyePosition() if entityExists(eventPlayer.grim_reaper_target) and eventPlayer.grim_reaper_target.isAlive() else eventPlayer.grim_reaper_camera_destination), Relativity.TO_WORLD)

    # FLIGHT END
    resume_player_input()

    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isDead(), 99999)
    eventPlayer.grim_reaper_target = null

    eventPlayer.is_using_ability[Talent.GRIM_REAPER] = false

rule "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] How Much Damage Was Resisted Inside Combat?":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
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

def pyromaniac_heal_over_time():
    @Name "TALENT SYSTEM - - - [TALENT 30: PYROMANIAC] [SUBROUTINE] Pyromaniac Stop Healing Over Time"
    
    heal(eventPlayer, eventPlayer, PYROMANIAC_INSTANT_HEALING)
    playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_WHIP_SHOT_HEAL_AREA, Color.TEAM_1, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_WHIP_SHOT_HEAL_AREA_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    createEffect(eventPlayer, Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[29] = getLastCreatedEntity()
    
    # Record start time — remaining duration is always:
    # PYROMANIAC_HEALING_DURATION - (eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30])
    eventPlayer.talent_counter_or_position_etc[30] = eventPlayer.totalTimeElapsed
    
    while eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30] < PYROMANIAC_HEALING_DURATION and eventPlayer.isAlive():
        # Wait until normal health needs healing
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30] >= PYROMANIAC_HEALING_DURATION or eventPlayer.isDead(), 99999)
        if eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30] >= PYROMANIAC_HEALING_DURATION or eventPlayer.isDead():
            goto lbl_0
        # Start HoT with remaining duration
        eventPlayer.startHealingOverTime(eventPlayer, PYROMANIAC_HEALING_DURATION - (eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30]), PYROMANIAC_HEALING_OVER_TIME)
        eventPlayer.health_pool_id_or_hot_id[3] = getLastHoT()
        # Stop when normal health is full again
        waitUntil(eventPlayer.getHealthOfType(Health.NORMAL) >= eventPlayer.getMaxHealthOfType(Health.NORMAL) or eventPlayer.totalTimeElapsed - eventPlayer.talent_counter_or_position_etc[30] >= PYROMANIAC_HEALING_DURATION or eventPlayer.isDead(), 99999)
        stopHoT(eventPlayer.health_pool_id_or_hot_id[3])
    
    lbl_0:
    stopHoT(eventPlayer.health_pool_id_or_hot_id[3])
    destroyEffect(eventPlayer.player_temp_effects[29])
/*
rule "TALENT SYSTEM - - - [BOMBARDMENT]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition (eventPlayer.isFiringSecondaryFire() or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.talent_ranks[Talent.BOMBARDMENT] > 0) == true
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
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
*/
/*
rule "TALENT SYSTEM - - - [GUNSLINGER]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.GUNSLINGER] > 0
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAmmo(0) > 0
    @Condition eventPlayer.isReloading() == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    
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
*/
/*
rule "TALENT SYSTEM - - - [SPRINTER]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.SPRINTER] > 0
    @Condition eventPlayer.isUsingAbility1() == true
    @Condition eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.browsing_shop == false
    
    eventPlayer.is_using_ability[Talent.SPRINTER] = true
    eventPlayer.setMoveSpeed(SPRINTER_MOVE_SPEED_MULTIPLIER)
    waitUntil(not eventPlayer.isUsingAbility1() or evalOnce(eventPlayer.stats[Stat.SPEED]) != eventPlayer.stats[Stat.SPEED], 99999)
    if RULE_CONDITION:
        goto RULE_START
    eventPlayer.is_using_ability[Talent.SPRINTER] = false
    #is charging railgun
    #if eventPlayer.is_charging_railgun == false:
    #eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
    recalculate_player_speed()
*/    
/*
rule "TALENT SYSTEM - - - [ADRENALINE RUSH] Damage Tracking":
    @Event playerDealtDamage
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] > 0
    @Condition attacker != victim
    
    eventPlayer.adrenaline_rush_damage_dealt += eventDamage
    while eventPlayer.adrenaline_rush_damage_dealt >= ADRENALINE_RUSH_DAMAGE_THRESHOLD and eventPlayer.adrenaline_rush_value < 300:
        eventPlayer.adrenaline_rush_damage_dealt -= ADRENALINE_RUSH_DAMAGE_THRESHOLD
        eventPlayer.adrenaline_rush_value = min(eventPlayer.adrenaline_rush_value + 100, 300)
        wait()
*/ 
/*
rule "TALENT SYSTEM - - - [ADRENALINE RUSH] Apply Speed":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] > 0
    @Condition eventPlayer.adrenaline_rush_value > 100
    @Condition eventPlayer.browsing_shop == false
    
    while eventPlayer.adrenaline_rush_value > 100 and eventPlayer.browsing_shop == false and eventPlayer.isAlive():
        if not eventPlayer.is_using_ability[Talent.CRYOGENICS]:
            eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * eventPlayer.adrenaline_rush_value / 100)
        wait(1)
    if eventPlayer.is_using_ability[Talent.BANDAGE] == false and eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false and eventPlayer.is_using_hearthstone == false and eventPlayer.is_using_ability[Talent.PURITY_FIELD] == false and eventPlayer.is_charging_railgun == false and eventPlayer.is_using_ability[Talent.CRYOGENICS] == false:
        eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED])
*/ 
/*
rule "TALENT SYSTEM - - - [ADRENALINE RUSH] Death Reset":
    @Event playerDied
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] > 0
    
    eventPlayer.adrenaline_rush_value = 0
    eventPlayer.adrenaline_rush_damage_dealt = 0
*/
rule "TALENT SYSTEM - - - [BANDAGE] Use Bandage":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.talent_ranks[Talent.BANDAGE] > 0
    @Condition eventPlayer.talent_trigger_times[Talent.BANDAGE] + talent_base_cooldowns[Talent.BANDAGE] <= eventPlayer.totalTimeElapsed
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.isCommunicatingEmote() == false
    @Condition "{0}".format(eventPlayer.isCommunicatingEmote()) == "0"
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.is_using_hearthstone == false
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.SHADOWSTEP] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), 0.25)
    if eventPlayer.isHoldingButton(Button.MELEE):
        return
    waitUntil(eventPlayer.isHoldingButton(Button.MELEE), 0.25)
    if not eventPlayer.isHoldingButton(Button.MELEE):
        return
    eventPlayer.is_using_ability[Talent.BANDAGE] = true
    eventPlayer.poisonous_dagger_attackers = []
    eventPlayer.poisonous_dagger_timestamp = []
    eventPlayer.clearStatusEffect(Status.BURNING)
    eventPlayer.clearStatusEffect(Status.FROZEN)
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION, Color.TEAM_1, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, DynamicEffect.ANA_BIOTIC_GRENADE_EXPLOSION_SOUND, Color.TEAM_1, eventPlayer.getPosition(), 100)
    createEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.ANA_BIOTIC_GRENADE_INCREASED_HEALING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[78] = getLastCreatedEntity()
    createEffect(getAllPlayers() if not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.BEACON_SOUND, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.player_temp_effects[79] = getLastCreatedEntity()
    if eventPlayer.cryogenics_slow_amount < eventPlayer.stats[Stat.SPEED]:
        eventPlayer.cryogenics_slow_amount = eventPlayer.stats[Stat.SPEED]
    eventPlayer.stopAllDoT()
    #eventPlayer.setMoveSpeed(eventPlayer.stats[Stat.SPEED] * 0.25)
    recalculate_player_speed()
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
    