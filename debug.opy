#!mainFile "soldier_x.opy"
/*
rule "DEBUG - - - Host HUD Texts [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition hostPlayer == eventPlayer
    #@Condition eventPlayer.player_name == "Psyrius"
  
   
    hudText(hostPlayer, "selected_talent_in_shop: {0}".format(hostPlayer.selected_talent_in_shop), "", "", HudPosition.RIGHT, 99, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "selected_talent_position: {0}".format(hostPlayer.selected_talent_position), "", "", HudPosition.RIGHT, 99.1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #hudText(hostPlayer, "Leading Player Talents: {0}".format(leading_player_talents_purchased), "", "", HudPosition.RIGHT, 99.3, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    #hudText(hostPlayer, "Srv Load: {0} {1} {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), "", "", HudPosition.RIGHT, 105, Color.RED, Color.RED, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    hudText(hostPlayer, null, null, ("DPS:"), HudPosition.RIGHT, 106, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Lifesteal Ammo:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(lifesteal_total_healing[1] / lifesteal_time_in_combat[1], lifesteal_total_healing[2] / lifesteal_time_in_combat[2], lifesteal_total_healing[3] / lifesteal_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(lifesteal_total_healing[4] / lifesteal_time_in_combat[4], lifesteal_total_healing[5] / lifesteal_time_in_combat[5])), null, HudPosition.LEFT, 100, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Health Regen:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(health_regen_total_healing[1] / health_regen_time_in_combat[1], health_regen_total_healing[2] / health_regen_time_in_combat[2], health_regen_total_healing[3] / health_regen_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(health_regen_total_healing[4] / health_regen_time_in_combat[4], health_regen_total_healing[5] / health_regen_time_in_combat[5])), null, HudPosition.LEFT, 101, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Health Potions:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(health_potions_total_healing[1] / health_potions_time_in_combat[1], health_potions_total_healing[2] / health_potions_time_in_combat[2], health_potions_total_healing[3] / health_potions_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(health_potions_total_healing[4] / health_potions_time_in_combat[4], health_potions_total_healing[5] / health_potions_time_in_combat[5])), null, HudPosition.LEFT, 102, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(hostPlayer, "Ignore Pain:", "In Combat Avg: {0} {1}".format("[Rank 1: {0}] [Rank 2: {1}] [Rank 3: {2}]".format(ignore_pain_total_resisted[1] / ignore_pain_time_in_combat[1], ignore_pain_total_resisted[2] / ignore_pain_time_in_combat[2], ignore_pain_total_resisted[3] / ignore_pain_time_in_combat[3]), "[Rank 4: {0}] [Rank 5: {1}]".format(ignore_pain_total_resisted[4] / ignore_pain_time_in_combat[4], ignore_pain_total_resisted[5] / ignore_pain_time_in_combat[5])), null, HudPosition.LEFT, 103, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/

/*
rule "DEBUG - - - Hold Reload For XP [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.can_enter_shop == false
    @Condition eventPlayer.browsing_shop == false
    
    if eventPlayer.experience_current < eventPlayer.experience_max:
        eventPlayer.experience_current += eventPlayer.experience_max/25
    wait(0.02)
    if RULE_CONDITION:
        goto RULE_START

/*
rule "DEBUG - - - Activate Admin Rights [DEFAULT: OFF]":
    @Event eachPlayer
    @Hero soldier
    @Condition hostPlayer == eventPlayer

    debugging = true
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
def buy_debug_talents():
    if debug_gunslinger > 0:
        eventPlayer.talent_ranks[Talent.GUNSLINGER] = 1
        eventPlayer.bought_talents.append(Talent.GUNSLINGER)
        buy_gunslinger()
        eventPlayer.talent_ranks[Talent.GUNSLINGER] = debug_gunslinger
        eventPlayer.amount_of_talents_purchased += debug_gunslinger
    if debug_bombardment > 0:
        eventPlayer.talent_ranks[Talent.BOMBARDMENT] = 1
        eventPlayer.bought_talents.append(Talent.BOMBARDMENT)
        buy_bombardment()
        eventPlayer.talent_ranks[Talent.BOMBARDMENT] = debug_bombardment
        eventPlayer.amount_of_talents_purchased += debug_bombardment
    if debug_railgun > 0:
        eventPlayer.talent_ranks[Talent.RAILGUN] = 1
        eventPlayer.bought_talents.append(Talent.RAILGUN)
        buy_railgun()
        eventPlayer.talent_ranks[Talent.RAILGUN] = debug_railgun
        eventPlayer.amount_of_talents_purchased += debug_railgun
    if debug_lifesteal_ammo > 0:
        eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] = 1
        eventPlayer.bought_talents.append(Talent.LIFESTEAL_AMMO)
        buy_lifesteal_ammo()
        eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] = debug_lifesteal_ammo
        eventPlayer.amount_of_talents_purchased += debug_lifesteal_ammo
    if debug_cryogenics > 0:
        eventPlayer.talent_ranks[Talent.CRYOGENICS] = 1
        eventPlayer.bought_talents.append(Talent.CRYOGENICS)
        buy_cryogenics()
        eventPlayer.talent_ranks[Talent.CRYOGENICS] = debug_cryogenics
        eventPlayer.amount_of_talents_purchased += debug_cryogenics
    if debug_ignite > 0:
        eventPlayer.talent_ranks[Talent.IGNITE] = 1
        eventPlayer.bought_talents.append(Talent.IGNITE)
        buy_ignite()
        eventPlayer.talent_ranks[Talent.IGNITE] = debug_ignite
        eventPlayer.amount_of_talents_purchased += debug_ignite
    if debug_overclock > 0:
        eventPlayer.talent_ranks[Talent.OVERCLOCK] = 1
        eventPlayer.bought_talents.append(Talent.OVERCLOCK)
        buy_overclock()
        eventPlayer.talent_ranks[Talent.OVERCLOCK] = debug_overclock
        eventPlayer.amount_of_talents_purchased += debug_overclock
    if debug_ignore_pain > 0:
        eventPlayer.talent_ranks[Talent.IGNORE_PAIN] = 1
        eventPlayer.bought_talents.append(Talent.IGNORE_PAIN)
        buy_ignore_pain()
        eventPlayer.talent_ranks[Talent.IGNORE_PAIN] = debug_ignore_pain
        eventPlayer.amount_of_talents_purchased += debug_ignore_pain
    if debug_burning_soul > 0:
        eventPlayer.talent_ranks[Talent.BURNING_SOUL] = 1
        eventPlayer.bought_talents.append(Talent.BURNING_SOUL)
        buy_burning_soul()
        eventPlayer.talent_ranks[Talent.BURNING_SOUL] = debug_burning_soul
        eventPlayer.amount_of_talents_purchased += debug_burning_soul
    if debug_sprinter > 0:
        eventPlayer.talent_ranks[Talent.SPRINTER] = 1
        eventPlayer.bought_talents.append(Talent.SPRINTER)
        buy_sprinter()
        eventPlayer.talent_ranks[Talent.SPRINTER] = debug_sprinter
        eventPlayer.amount_of_talents_purchased += debug_sprinter
        #Size
        eventPlayer.stats[8] = 1 + (debug_sprinter * 0.035)
        eventPlayer.startScalingSize(eventPlayer.stats[8], false)
        #Voice
        eventPlayer.stats[6] = 1 + (debug_sprinter * 0.075)
        eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[6], false)
    if debug_dive_bomb > 0:
        eventPlayer.talent_ranks[Talent.DIVE_BOMB] = 1
        eventPlayer.bought_talents.append(Talent.DIVE_BOMB)
        buy_dive_bomb()
        eventPlayer.talent_ranks[Talent.DIVE_BOMB] = debug_dive_bomb
        eventPlayer.amount_of_talents_purchased += debug_dive_bomb
    if debug_jetpack > 0:
        eventPlayer.talent_ranks[Talent.JETPACK] = 1
        eventPlayer.bought_talents.append(Talent.JETPACK)
        buy_jetpack()
        eventPlayer.talent_ranks[Talent.JETPACK] = debug_jetpack
        eventPlayer.amount_of_talents_purchased += debug_jetpack
    if debug_bandage > 0:
        eventPlayer.talent_ranks[Talent.BANDAGE] = 1
        eventPlayer.bought_talents.append(Talent.BANDAGE)
        buy_bandage()
        eventPlayer.talent_ranks[Talent.BANDAGE] = debug_bandage
        eventPlayer.amount_of_talents_purchased += debug_bandage
    if debug_berserker > 0:
        eventPlayer.talent_ranks[Talent.BERSERKER] = 1
        eventPlayer.bought_talents.append(Talent.BERSERKER)
        buy_berserker()
        eventPlayer.talent_ranks[Talent.BERSERKER] = debug_berserker
        eventPlayer.amount_of_talents_purchased += debug_berserker
    if debug_bloodthirst > 0:
        eventPlayer.talent_ranks[Talent.BLOODTHIRST] = 1
        eventPlayer.bought_talents.append(Talent.BLOODTHIRST)
        buy_bloodthirst()
        eventPlayer.talent_ranks[Talent.BLOODTHIRST] = debug_bloodthirst
        eventPlayer.amount_of_talents_purchased += debug_bloodthirst
    if debug_purity_field > 0:
        eventPlayer.talent_ranks[Talent.PURITY_FIELD] = 1
        eventPlayer.bought_talents.append(Talent.PURITY_FIELD)
        buy_purity_field()
        eventPlayer.talent_ranks[Talent.PURITY_FIELD] = debug_purity_field
        eventPlayer.amount_of_talents_purchased += debug_purity_field
    if debug_juggernaut > 0:
        eventPlayer.talent_ranks[Talent.JUGGERNAUT] = 1
        eventPlayer.bought_talents.append(Talent.JUGGERNAUT)
        buy_juggernaut()
        eventPlayer.talent_ranks[Talent.JUGGERNAUT] = debug_juggernaut
        eventPlayer.amount_of_talents_purchased += debug_juggernaut
    if debug_fireball > 0:
        eventPlayer.talent_ranks[Talent.FIREBALL] = 1
        eventPlayer.bought_talents.append(Talent.FIREBALL)
        buy_fireball()
        eventPlayer.talent_ranks[Talent.FIREBALL] = debug_fireball
        eventPlayer.amount_of_talents_purchased += debug_fireball
    if debug_predator > 0:
        eventPlayer.talent_ranks[Talent.PREDATOR] = 1
        eventPlayer.bought_talents.append(Talent.PREDATOR)
        buy_predator()
        eventPlayer.talent_ranks[Talent.PREDATOR] = debug_predator
        eventPlayer.amount_of_talents_purchased += debug_predator
    if debug_gigachad > 0:
        eventPlayer.talent_ranks[Talent.GIGACHAD] = 1
        eventPlayer.bought_talents.append(Talent.GIGACHAD)
        buy_gigachad()
        eventPlayer.talent_ranks[Talent.GIGACHAD] = debug_gigachad
        eventPlayer.amount_of_talents_purchased += debug_gigachad
    if debug_stealth > 0:
        eventPlayer.talent_ranks[Talent.STEALTH] = 1
        eventPlayer.bought_talents.append(Talent.STEALTH)
        buy_stealth()
        eventPlayer.talent_ranks[Talent.STEALTH] = debug_stealth
        eventPlayer.amount_of_talents_purchased += debug_stealth
    if debug_poisonous_dagger > 0:
        eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] = 1
        eventPlayer.bought_talents.append(Talent.POISONOUS_DAGGER)
        buy_poisonous_dagger()
        eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] = debug_poisonous_dagger
        eventPlayer.amount_of_talents_purchased += debug_poisonous_dagger
    
#*/

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

/*
rule "DEBUG - - - Activate Slow Motion With Melee & Cancel Slow Motion With Interact [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    setSlowMotion(15)
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) == false and eventPlayer.isHoldingButton(Button.MELEE) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.INTERACT) == true and eventPlayer.isHoldingButton(Button.MELEE) == true, 99999)
    setSlowMotion(100)
*/

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
    @Hero soldier
    
    createEffect(eventPlayer, Effect.SPHERE, Color.GRAY, eventPlayer.getPosition() + worldVector(vect(0, 1, 3), eventPlayer, Transform.ROTATION), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer, Effect.SPHERE, Color.GRAY, eventPlayer.getPosition() + worldVector(vect(0, 1, 1), eventPlayer, Transform.ROTATION), 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer, Effect.SPHERE, Color.RED, eventPlayer.getPosition() + worldVector(vect(0, 1, 1), eventPlayer, Transform.ROTATION), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
*/

/*
rule "DEBUG - - - Activate Third Person Camera With Secondary Fire [DEFAULT: OFF]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 1, 4), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true, 99999)
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(4, 2, -1 * 1 * 1 * 3), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true, 99999)
    eventPlayer.startCamera(eventPlayer.getEyePosition() + worldVector(vect(0, 1, -1 * 1 * 1 * 4), eventPlayer, Transform.ROTATION), eventPlayer.getEyePosition(), 12)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false, 99999)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true, 99999)
    eventPlayer.stopCamera()
*/

/*
def new_reaper_pathfinding():
    @Name "DEBUG - - - [SUBROUTINE] Bot Pathfinding Test [DEFAULT: OFF]"
    
    while eventPlayer.reaper_aggro_list == []:
        eventPlayer.stopFacing()
        eventPlayer.startFacing(angleToDirection(random.randint(-1 * 1 * 1 * 180, 180), random.randint(-1 * 1 * 1 * 45, 45)), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
        wait(3)
        if nearestWalkablePosition(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, getAllPlayers(), true).getHitPosition()) == raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, getAllPlayers(), true).getHitPosition():
            eventPlayer.reaper_brain_information[5] = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, getAllPlayers(), true).getHitPosition()
            eventPlayer.startThrottleInDirection(eventPlayer.reaper_brain_information[5], 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
            waitUntil(distance(eventPlayer.getPosition(), eventPlayer.reaper_brain_information[5]) < 2 or eventPlayer.reaper_aggro_list != [] or eventPlayer.isDead() == true, 99999)
            if eventPlayer.reaper_aggro_list != [] or eventPlayer.isDead() == true:
                return
*/

/*
rule "DEBUG - - - Activate Inspector Recording When Server Load Average Is Above 110 [DEFAULT: OFF]":
    @Condition getAverageServerLoad() > 110
    
    enableInspector()
    waitUntil(getAverageServerLoad() < 110, 99999)
    disableInspector()
*/

/*
rule "DEBUG - - - Reset [Talent: Juggernaut] Cooldown With Reload [DEFAULT: OFF]":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    
    eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.JUGGERNAUT]
*/
