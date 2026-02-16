#!mainFile "soldier_x.opy"
#Global variables

globalvar shop_location
globalvar leave_shop_messages = ["Latest patch notes at: workshop.codes/ZEKK3", "Got any feedback? Join the Discord!", "Got an idea for a new talent? Join the Discord!", "Want to show your support? Click the {0} at: workshop.codes/ZEKK3".format(iconString(Icon.HEART)), "Found a bug? Join the Discord!", "Want to help the community grow? Join the Discord!"]
globalvar shop_talent_positions
globalvar max_experience_per_level = [250, 275, 303, 333, 366, 403, 443, 487, 536, 589, 648, 713, 785, 863, 949, 1044, 1149, 1264, 1390, 1529, 1682, 1850, 2035, 2239, 2462, 2709]

#Player variables

playervar bloodthirst_shield
playervar talent_trigger_times
playervar health_pool_id_or_hot_id
playervar entering_stealth
playervar railgun_discharge
playervar railgun_charge
playervar railgun_projectile_start
playervar railgun_projectile_player_hit
playervar jetpack_fuel = 100
playervar is_lifestealing
playervar ignite_position
playervar fireball_position
playervar ignore_pain_damage_resisted
playervar ignore_pain_volume
playervar bandage_progress
playervar pyromaniac_heal_duration
playervar current_talent_replace_or_buy
playervar hearthstone_effects_id
playervar is_respawning = false
playervar selected_talent_position = shop_talent_positions[1]
playervar selected_talent_will_replace
playervar using_hearthstone_timer = 0
playervar burning_soul_orb_timer

#Subroutine names

subroutine health_regen_heal_over_time
subroutine open_shop
subroutine leave_shop_messages
subroutine buy_or_upgrade_talent
subroutine buy_bloodthirst
subroutine buy_purity_field
subroutine buy_cybernetics
subroutine buy_soul_harvest
subroutine buy_poisonous_dagger
subroutine buy_stealth
subroutine buy_juggernaut
subroutine buy_dive_bomb
subroutine buy_cryogenics
subroutine buy_railgun
subroutine buy_predator
subroutine buy_jetpack
subroutine buy_lifesteal_ammo
subroutine buy_health_regen
subroutine buy_health_potions
subroutine buy_ignite
subroutine buy_overclock
subroutine buy_shadowstep
subroutine buy_burning_soul
subroutine buy_berserker
subroutine buy_fireball
subroutine buy_ignore_pain
subroutine buy_bandage
subroutine buy_pyromaniac
subroutine buy_poison_vials
subroutine buy_alchemist
subroutine buy_bombardment
subroutine buy_gigachad
subroutine buy_gunslinger
subroutine buy_sprinter

#Activated extensions

#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension explosionSounds

rule "SHOP - - - Using Hearthstone":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.can_enter_shop == true
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.in_combat == 0
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.railgun_charge == 0
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.dummy_var[0] = true
    using_one_of_the_hearthstones()


rule "SHOP - - - Canceled Hearthstone":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.dummy_var[0] == true
    @Condition (eventPlayer.in_combat > 0 or not eventPlayer.isHoldingButton(Button.RELOAD) or eventPlayer.isDead()) == true
    
    stopped_using_hearthstone()

rule "SHOP - - - Skip Talents & Exit Shop":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.replacing_talent_show_bought_talents == false
    @Condition eventPlayer.replacing_talent_show_confirmation == false
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.replacing_talent_show_bought_talents == false
    @Condition eventPlayer.replacing_talent_show_confirmation == false
    
    wait(0.75 if debugging == false else 0.425, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_skip_talent = true
    using_one_of_the_hearthstones()

rule "SHOP - - - Canceled Skip Talent & Exit Shop":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.is_using_skip_talent == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    
    stopped_using_hearthstone()

rule "SHOP - - - Using Yes":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.replacing_talent_show_confirmation == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_vote_yes = true
    using_one_of_the_hearthstones()

rule "SHOP - - - Using No":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.replacing_talent_show_confirmation == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_vote_no = true
    using_one_of_the_hearthstones()

rule "SHOP - - - Canceled Using Yes / No":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition (eventPlayer.is_using_vote_yes or eventPlayer.is_using_vote_no) == true
    @Condition eventPlayer.replacing_talent_show_confirmation == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    
    stopped_using_hearthstone()

def using_one_of_the_hearthstones():
    @Name "SHOP - - - [SUBROUTINE] Using One of the Hearthstones"
    
    if eventPlayer.dummy_var[0] == true:
        #eventPlayer.setMoveSpeed(eventPlayer.stats[2] * 0.25)
        async(player_slowed, AsyncBehavior.RESTART)
        createEffect(getAllPlayers(), Effect.GOOD_AURA_SOUND, Color.WHITE, updateEveryTick(eventPlayer.getPosition() + Vector.UP), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.hearthstone_effects_id[0] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.STEALTH] == false else null, Effect.GOOD_AURA, Color.GREEN, updateEveryTick(eventPlayer.getPosition() + Vector.UP), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.hearthstone_effects_id[1] = getLastCreatedEntity()
    elif eventPlayer.is_using_skip_talent or eventPlayer.is_using_vote_yes or eventPlayer.is_using_vote_no:
        createEffect(eventPlayer, Effect.SOMBRA_HACKING_SOUND, Color.WHITE, shop_location if eventPlayer.browsing_shop == true else eventPlayer.getPosition(), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.hearthstone_effects_id[0] = getLastCreatedEntity()
    chase(eventPlayer.using_hearthstone_timer, 2.75 if debugging == false else 0.5, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    if eventPlayer.is_using_vote_yes or eventPlayer.is_using_vote_no:
        goto lbl_0
    wait(2.75 if debugging == false else 0.5, Wait.ABORT_WHEN_FALSE)
    lbl_0:
    eventPlayer.using_one_of_the_hearthstones = true
    if eventPlayer.dummy_var[0] == true:
        playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION, Color.TEAM_1, eventPlayer.getPosition() + Vector.UP, 1)
        playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_DISAPPEAR_SOUND, Color.TEAM_2, eventPlayer.getPosition(), 100)
        if eventPlayer.is_using_ability[Talent.STEALTH] == true:
            break_stealth()
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
        eventPlayer.dummy_var[0] = false
        async(open_shop, AsyncBehavior.NOOP)
        eventPlayer.browsing_shop = true
        async(stopped_using_hearthstone, AsyncBehavior.RESTART)
        return
    elif eventPlayer.is_using_skip_talent == true:
        goto lbl_1
    elif eventPlayer.is_using_vote_yes == true:
        waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 2.75 if debugging == false else 0.5)
        if not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
            goto lbl_2
        if eventPlayer.replacing_talent_show_confirmation == true:
            eventPlayer.replacing_talent_show_bought_talents = true
            goto lbl_3
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, shop_location, 100)
        lbl_2:
        lbl_3:
        async(stopped_using_hearthstone, AsyncBehavior.RESTART)
        return
    elif eventPlayer.is_using_vote_no == true:
        waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 2.75 if debugging == false else 0.5)
        if not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
            goto lbl_4
        if eventPlayer.replacing_talent_show_confirmation == true:
            eventPlayer.replacing_talent_cancelled = true
            goto lbl_5
        playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, shop_location, 100)
        lbl_4:
        lbl_5:
        async(stopped_using_hearthstone, AsyncBehavior.RESTART)
        return
    lbl_1:
    async(stopped_using_hearthstone, AsyncBehavior.RESTART)
    if eventPlayer.amount_of_bonus_talents > 0:
        eventPlayer.amount_of_bonus_talents -= 1
    if eventPlayer.is_using_skip_talent == true and eventPlayer.amount_of_bonus_talents > 0:
        eventPlayer.is_using_skip_talent = false
        bigMessage(eventPlayer, "{0} Bonus Talent Left!".format(eventPlayer.amount_of_bonus_talents))
        open_shop()
        eventPlayer.selected_talent_in_shop = 1
        eventPlayer.selected_talent_position = shop_talent_positions[1]
        eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
        wait(1)
        return
    eventPlayer.is_using_skip_talent = false
    eventPlayer.browsing_shop = false
    eventPlayer.selected_talent_position = shop_talent_positions[1]
    eventPlayer.can_enter_shop = false
    eventPlayer.experience_current = 0
    if eventPlayer.talent_ranks[Talent.FIREBALL] > 0 or eventPlayer.talent_ranks[Talent.JUGGERNAUT] > 0:
        async(spawned_with_fireball, AsyncBehavior.RESTART)
    eventPlayer.is_respawning = true
    eventPlayer.respawn()
    #Reset selection of a talent to the middle
    eventPlayer.selected_talent_in_shop = 1
    eventPlayer.skipped_a_talent = true
    eventPlayer.xp_boost_is_active = true

def stopped_using_hearthstone():
    @Name "SHOP - - - [SUBROUTINE] Stopped Using Hearthstone"
    
    eventPlayer.using_one_of_the_hearthstones = false
    eventPlayer.dummy_var[0] = false
    eventPlayer.is_using_skip_talent = false
    eventPlayer.is_using_vote_yes = false
    eventPlayer.is_using_vote_no = false
    stopChasingVariable(eventPlayer.using_hearthstone_timer)
    eventPlayer.using_hearthstone_timer = 0
    #if eventPlayer.is_using_ability[Talent.CRYOGENICS] == false:
    #eventPlayer.setMoveSpeed(eventPlayer.stats[2])
    #__end__()
    destroyEffect(eventPlayer.hearthstone_effects_id[0])
    destroyEffect(eventPlayer.hearthstone_effects_id[1])

def open_shop():
    @Name "SHOP - - - [SUBROUTINE] Open Shop"

    eventPlayer.possible_talents = []
    if len(eventPlayer.bought_talents) == 5:
        eventPlayer.talent_counter_or_position_etc[15] = 4
        while eventPlayer.talent_counter_or_position_etc[15] >= 0:
            if eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.talent_counter_or_position_etc[15]]] < 5:
                eventPlayer.possible_talents.append(eventPlayer.bought_talents[eventPlayer.talent_counter_or_position_etc[15]])
            eventPlayer.talent_counter_or_position_etc[15] -= 1
    else:
        eventPlayer.talent_counter_or_position_etc[15] = len(eventPlayer.bought_talents) - 1
        while eventPlayer.talent_counter_or_position_etc[15] >= 0:
            if eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.talent_counter_or_position_etc[15]]] < 5:
                eventPlayer.possible_talents.append(eventPlayer.bought_talents[eventPlayer.talent_counter_or_position_etc[15]])
            eventPlayer.talent_counter_or_position_etc[15] -= 1
        eventPlayer.talent_counter_or_position_etc[15] = len(eventPlayer.talents_you_do_not_have)
        while eventPlayer.talent_counter_or_position_etc[15] >= 0:
            if eventPlayer.talents_you_do_not_have[eventPlayer.talent_counter_or_position_etc[15]] != null:
                eventPlayer.possible_talents.append(eventPlayer.talents_you_do_not_have[eventPlayer.talent_counter_or_position_etc[15]])
            eventPlayer.talent_counter_or_position_etc[15] -= 1
    eventPlayer.dummy_var[0] = false
    eventPlayer.skipped_a_talent = false
    eventPlayer.disableHeroHud()
    eventPlayer.setMoveSpeed(0)
    eventPlayer.setCrouchEnabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.browsing_shop = true
    #Will the left talent replace a talent if taken?
    #return
    if len(eventPlayer.bought_talents) == 5 and len(eventPlayer.possible_talents.exclude(null)) == 0:
        eventPlayer.selected_talent_will_replace[0] = true
    else:
        eventPlayer.selected_talent_will_replace[0] = false
    #Set left talent to a random choice in talents_you_do_not_have if selected_talent_will_replace = true, else random choice in possible_talents
    eventPlayer.talents_offered_in_shop[0] = random.choice(eventPlayer.talents_you_do_not_have.exclude(null)) if eventPlayer.selected_talent_will_replace[0] == true else random.choice(eventPlayer.possible_talents.exclude(null))
    #Remove the left talent
    if len(eventPlayer.possible_talents.exclude(null)) > 2:
        eventPlayer.possible_talents.remove(eventPlayer.talents_offered_in_shop[0])
    else:
        eventPlayer.possible_talents.remove(eventPlayer.talents_offered_in_shop[0])
    #Will the middle talent replace a talent if taken?
    #return
    if len(eventPlayer.bought_talents) == 5:
        eventPlayer.selected_talent_will_replace[1] = true
    else:
        eventPlayer.selected_talent_will_replace[1] = false
    #Set middle talent to a random choice in talents_you_do_not_have if selected_talent_will_replace = true, else random choice in possible_talents
    eventPlayer.talents_offered_in_shop[1] = random.choice([player for player in eventPlayer.talents_you_do_not_have if player != null and player != eventPlayer.talents_offered_in_shop[0]]) if eventPlayer.selected_talent_will_replace[1] == true else random.choice(eventPlayer.possible_talents.exclude(null))
    #Remove the middle talent
    if len(eventPlayer.possible_talents.exclude(null)) > 1:
        eventPlayer.possible_talents.remove(eventPlayer.talents_offered_in_shop[1])
    else:
        eventPlayer.possible_talents.remove(eventPlayer.talents_offered_in_shop[1])
    #Will the right talent replace a talent if taken?
    #return
    if len(eventPlayer.bought_talents) == 5 and len(eventPlayer.possible_talents.exclude(null)) == 0:
        eventPlayer.selected_talent_will_replace[2] = true
    else:
        eventPlayer.selected_talent_will_replace[2] = false
    #Set right talent to a random choice in talents_you_do_not_have if selected_talent_will_replace = true, else random choice in possible_talents
    eventPlayer.talents_offered_in_shop[2] = random.choice([player for player in eventPlayer.talents_you_do_not_have if player != null and player != eventPlayer.talents_offered_in_shop[0] and player != eventPlayer.talents_offered_in_shop[1]]) if eventPlayer.selected_talent_will_replace[2] == true else random.choice(eventPlayer.possible_talents.exclude(null))
    if eventPlayer.amount_of_bonus_talents > 0:
        eventPlayer.startCamera(shop_location, shop_talent_positions[1], 0.5)
    playEffect(eventPlayer, DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR_SOUND, Color.TEAM_1, shop_location.getPosition(), 100)

rule "SHOP - - - Shop Left":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.selected_bought_talent == 0:
            eventPlayer.selected_bought_talent = 4
            eventPlayer.startCamera(shop_location, shop_talent_positions[eventPlayer.selected_talent_in_shop], 15)
        else:
            eventPlayer.selected_bought_talent -= 1
            eventPlayer.startCamera(shop_location, shop_talent_positions[eventPlayer.selected_talent_in_shop], 15)
        return
    if eventPlayer.replacing_talent_show_confirmation == true:
        waitUntil(eventPlayer.replacing_talent_show_bought_talents == true or eventPlayer.replacing_talent_show_confirmation == false, 99999)
        wait(0.33)
        return
    if eventPlayer.selected_talent_in_shop >= 1:
        if eventPlayer.selected_talent_in_shop == 2:
            eventPlayer.selected_talent_position = shop_talent_positions[1]
            eventPlayer.selected_talent_in_shop = 1
            eventPlayer.startCamera(shop_location, shop_talent_positions[1], 15)
        elif eventPlayer.selected_talent_in_shop == 1:
            eventPlayer.selected_talent_position = shop_talent_positions[0]
            eventPlayer.selected_talent_in_shop = 0
            eventPlayer.startCamera(shop_location, shop_talent_positions[0], 15)


rule "SHOP - - - Shop Right":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.selected_bought_talent == 4:
            eventPlayer.selected_bought_talent = 0
            eventPlayer.startCamera(shop_location, shop_talent_positions[eventPlayer.selected_talent_in_shop], 15)
        else:
            eventPlayer.selected_bought_talent += 1
            eventPlayer.startCamera(shop_location, shop_talent_positions[eventPlayer.selected_talent_in_shop], 15)
        return
    if eventPlayer.replacing_talent_show_confirmation == true:
        waitUntil(eventPlayer.replacing_talent_show_bought_talents == true or eventPlayer.replacing_talent_show_confirmation == false, 99999)
        wait(0.33)
        return
    if eventPlayer.selected_talent_in_shop <= 1:
        if eventPlayer.selected_talent_in_shop == 1:
            eventPlayer.selected_talent_position = shop_talent_positions[2]
            eventPlayer.selected_talent_in_shop = 2
            eventPlayer.startCamera(shop_location, shop_talent_positions[2], 15)
        elif eventPlayer.selected_talent_in_shop == 0:
            eventPlayer.selected_talent_position = shop_talent_positions[1]
            eventPlayer.selected_talent_in_shop = 1
            eventPlayer.startCamera(shop_location, shop_talent_positions[1], 15)

rule "SHOP - - - Buy Talent":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.replacing_talent_show_confirmation == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    if eventPlayer.selected_talent_in_shop == 0:
        eventPlayer.startCamera(shop_talent_positions[0], shop_talent_positions[0], 4.125 if debugging == false else 8.25)
    elif eventPlayer.selected_talent_in_shop == 1:
        eventPlayer.startCamera(shop_talent_positions[1], shop_talent_positions[1], 4.125 if debugging == false else 8.25)
    elif eventPlayer.selected_talent_in_shop == 2:
        eventPlayer.startCamera(shop_talent_positions[2], shop_talent_positions[2], 4.125 if debugging == false else 8.25)
    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 0.85 if debugging == false else 0.425)
    if not eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
        wait(0.25)
        return
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.current_talent_replace_or_buy = eventPlayer.bought_talents[eventPlayer.selected_bought_talent]
        buy_or_upgrade_talent()
        if eventPlayer.replacing_talent_cancelled == true:
            eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.TEAM_1, shop_location.getPosition(), 100)
            eventPlayer.replacing_talent_show_confirmation = false
            eventPlayer.replacing_talent_show_bought_talents = false
            eventPlayer.replacing_talent_cancelled = false
            return
        eventPlayer.amount_of_talents_purchased -= eventPlayer.talent_ranks[eventPlayer.current_talent_replace_or_buy]
        #Remove the talent from talent_ranks
        eventPlayer.talent_ranks[eventPlayer.current_talent_replace_or_buy] = 0
        #Remove the talent you removed from bought_talents
        eventPlayer.bought_talents = eventPlayer.bought_talents.exclude(eventPlayer.bought_talents[eventPlayer.selected_bought_talent])
        eventPlayer.bought_talents.append(eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop])
        goto lbl_0
    if eventPlayer.selected_talent_in_shop == 0:
        if eventPlayer.selected_talent_will_replace[0] == true:
            goto lbl_1
    elif eventPlayer.selected_talent_in_shop == 1:
        if eventPlayer.selected_talent_will_replace[1] == true:
            goto lbl_2
    elif eventPlayer.selected_talent_in_shop == 2:
        if eventPlayer.selected_talent_will_replace[2] == true:
            lbl_1:
            lbl_2:
            replace_talent()
            if eventPlayer.replacing_talent_cancelled == true:
                eventPlayer.replacing_talent_show_confirmation = false
                eventPlayer.replacing_talent_cancelled = false
                return
            if eventPlayer.replacing_talent_show_bought_talents == true:
                eventPlayer.replacing_talent_show_confirmation = false
                return
    lbl_0:
    if len(eventPlayer.bought_talents) < 5 and not eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] in eventPlayer.bought_talents:
        eventPlayer.bought_talents.append(eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop])
    eventPlayer.selected_talent_position = shop_talent_positions[1]
    eventPlayer.amount_of_talents_purchased += 1
    if eventPlayer.amount_of_talents_purchased > leading_player_talents_purchased:
        leading_player_talents_purchased = eventPlayer.amount_of_talents_purchased
    #Add +1 to "talent_ranks" in the correct index
    eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] += 1
    #If the talent being purchased has reached 5...
    if eventPlayer.talent_ranks[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] == 5:
        #...remove it from possible talents.
        eventPlayer.possible_talents[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] = null
    eventPlayer.replacing_talent_show_bought_talents = false
    eventPlayer.current_talent_replace_or_buy = eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]
    eventPlayer.possible_talents[eventPlayer.current_talent_replace_or_buy] = eventPlayer.current_talent_replace_or_buy
    buy_or_upgrade_talent()
    if eventPlayer.amount_of_bonus_talents > 0:
        eventPlayer.amount_of_bonus_talents -= 1
    if eventPlayer.amount_of_bonus_talents > 0:
        bigMessage(eventPlayer, "{0} Bonus Talent Left!".format(eventPlayer.amount_of_bonus_talents))
        open_shop()
        eventPlayer.selected_talent_in_shop = 1
        eventPlayer.selected_talent_position = shop_talent_positions[1]
        eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
        wait(1)
        return
    eventPlayer.browsing_shop = false
    eventPlayer.can_enter_shop = false
    eventPlayer.experience_current = 0
    eventPlayer.experience_max = max_experience_per_level[eventPlayer.amount_of_talents_purchased]
    if eventPlayer.talent_ranks[Talent.FIREBALL] > 0 or eventPlayer.talent_ranks[Talent.JUGGERNAUT] > 0:
        async(spawned_with_fireball, AsyncBehavior.RESTART)
    eventPlayer.is_respawning = true
    eventPlayer.respawn()
    eventPlayer.selected_talent_in_shop = 1

def replace_talent():
    @Name "SHOP - - - [SUBROUTINE] Replace Talent"
    
    eventPlayer.replacing_talent_show_confirmation = true
    eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
    playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, shop_location, 100)
    waitUntil(eventPlayer.replacing_talent_show_bought_talents == true or eventPlayer.replacing_talent_cancelled == true, 99999)

rule "SHOP - - - Reset Shop Camera":
    @Event eachPlayer
    @Hero soldier
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition (eventPlayer.is_using_skip_talent == true or not eventPlayer.isHoldingButton(Button.INTERACT)) == true
    
    eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)

def buy_or_upgrade_talent():
    @Name "SHOP - - - [SUBROUTINE] Buy Or Upgrade Talent"
    
    if eventPlayer.current_talent_replace_or_buy == 0:
        buy_bloodthirst()
    elif eventPlayer.current_talent_replace_or_buy == 1:
        buy_purity_field()
    elif eventPlayer.current_talent_replace_or_buy == 2:
        buy_cybernetics()
    elif eventPlayer.current_talent_replace_or_buy == 3:
        buy_soul_harvest()
    elif eventPlayer.current_talent_replace_or_buy == 4:
        buy_poisonous_dagger()
    elif eventPlayer.current_talent_replace_or_buy == 5:
        buy_stealth()
    elif eventPlayer.current_talent_replace_or_buy == 6:
        buy_juggernaut()
    elif eventPlayer.current_talent_replace_or_buy == 7:
        buy_dive_bomb()
    elif eventPlayer.current_talent_replace_or_buy == 8:
        buy_cryogenics()
    elif eventPlayer.current_talent_replace_or_buy == 9:
        buy_railgun()
    elif eventPlayer.current_talent_replace_or_buy == 10:
        buy_predator()
    elif eventPlayer.current_talent_replace_or_buy == 11:
        buy_jetpack()
    elif eventPlayer.current_talent_replace_or_buy == 12:
        buy_lifesteal_ammo()
    elif eventPlayer.current_talent_replace_or_buy == 13:
        buy_health_regen()
    elif eventPlayer.current_talent_replace_or_buy == 14:
        if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] == 1:
            eventPlayer.amount_of_potions_or_vials = 3
        buy_health_potions()
    elif eventPlayer.current_talent_replace_or_buy == 15:
        buy_ignite()
    elif eventPlayer.current_talent_replace_or_buy == 16:
        buy_overclock()
    elif eventPlayer.current_talent_replace_or_buy == 17:
        buy_shadowstep()
    elif eventPlayer.current_talent_replace_or_buy == 18:
        buy_burning_soul()
    elif eventPlayer.current_talent_replace_or_buy == 19:
        buy_berserker()
    elif eventPlayer.current_talent_replace_or_buy == 20:
        buy_fireball()
    elif eventPlayer.current_talent_replace_or_buy == 21:
        buy_ignore_pain()
    elif eventPlayer.current_talent_replace_or_buy == 22:
        return
    elif eventPlayer.current_talent_replace_or_buy == 23:
        buy_bandage()
    elif eventPlayer.current_talent_replace_or_buy == 24:
        buy_pyromaniac()
    elif eventPlayer.current_talent_replace_or_buy == 25:
        if eventPlayer.talent_ranks[Talent.POISON_VIALS] == 1:
            eventPlayer.amount_of_potions_or_vials = 3
        buy_poison_vials()
    elif eventPlayer.current_talent_replace_or_buy == 26:
        buy_alchemist()
    elif eventPlayer.current_talent_replace_or_buy == 27:
        buy_bombardment()
    elif eventPlayer.current_talent_replace_or_buy == 28:
        buy_gigachad()
    elif eventPlayer.current_talent_replace_or_buy == 29:
        buy_gunslinger()
    elif eventPlayer.current_talent_replace_or_buy == 30:
        buy_sprinter()

/*
def leave_shop_messages():
    @Name "SHOP - - - [SUBROUTINE] Exit Shop Messages"
        
    eventPlayer.random_integer_between_0_to_5 = random.randint(0, 5)
    createInWorldText(eventPlayer, "{0}".format(leave_shop_messages[eventPlayer.random_integer_between_0_to_5]), updateEveryTick(eventPlayer.getEyePosition() + (100 * (0 * worldVector(Vector.RIGHT, eventPlayer, Transform.ROTATION) + ((0 - 1) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 *eventPlayer.getFacingDirection()))), 1.75, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.ORANGE, SpecVisibility.DEFAULT)
    eventPlayer.player_temp_effects[43] = getLastCreatedText()
    wait(5)
    destroyInWorldText(eventPlayer.player_temp_effects[43])
*/
def buy_bloodthirst():
    @Name "TALENT SYSTEM - - - [TALENT 0: BLOODTHIRST] [SUBROUTINE] Buy Bloodthirst"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.BLOODTHIRST)
        return
    if eventPlayer.talent_ranks[Talent.BLOODTHIRST] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.BLOODTHIRST)

def buy_purity_field():
    @Name "TALENT SYSTEM - - - [TALENT 1: PURITY FIELD] [SUBROUTINE] Buy Purity Field"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.PURITY_FIELD)
        return
    if eventPlayer.talent_ranks[Talent.PURITY_FIELD] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.PURITY_FIELD)
        eventPlayer.talent_trigger_times[Talent.PURITY_FIELD] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.PURITY_FIELD]

def buy_cybernetics():
    @Name "TALENT SYSTEM - - - [TALENT 2: CYBERNETICS] [SUBROUTINE] Buy Cybernetics (hit_by_ability[2] is borrowed by talent: juggernaut)"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.CYBERNETICS)
        #Shields
        eventPlayer.stats[4] = 0
        removeHealthPool(eventPlayer.health_pool_id_or_hot_id[7])
        return
    if eventPlayer.talent_ranks[Talent.CYBERNETICS] == 1:
        eventPlayer.stats[4] = 56.25
        eventPlayer.talents_you_do_not_have.remove(Talent.CYBERNETICS)
    #Shields
    eventPlayer.stats[4] += 18.75

def buy_soul_harvest():
    @Name "TALENT SYSTEM - - - [TALENT 3: SOUL_HARVEST] [SUBROUTINE] Buy Soul Harvest"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.SOUL_HARVEST)
        return
    if eventPlayer.talent_ranks[Talent.SOUL_HARVEST] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.SOUL_HARVEST)

def buy_poisonous_dagger():
    @Name "TALENT SYSTEM - - - [Poisonous Dagger] [SUBROUTINE] Buy Poisonous Dagger"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.POISONOUS_DAGGER)
        return
    if eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] == 1:
        eventPlayer.talent_trigger_times[Talent.POISONOUS_DAGGER] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.POISONOUS_DAGGER]
        eventPlayer.talents_you_do_not_have.remove(Talent.POISONOUS_DAGGER)


def buy_stealth():
    @Name "TALENT SYSTEM - - - [TALENT 5: STEALTH] [SUBROUTINE] Buy Stealth"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        break_stealth()
        eventPlayer.entering_stealth = false
        destroyEffect(eventPlayer.player_temp_effects[57])
        destroyEffect(eventPlayer.player_temp_effects[58])
        #If you are trying to replace stealth with poisonous dagger
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == [4]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[5], talent_names[Talent.POISONOUS_DAGGER]))
            goto lbl_0
        #If you are trying to remove stealth when you have poisonous dagger
        if eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] > 0:
            smallMessage(eventPlayer, "Need to remove {0} first!".format(talent_names[5]))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        eventPlayer.talents_you_do_not_have.append(Talent.STEALTH)
        eventPlayer.talents_you_do_not_have.remove(Talent.POISONOUS_DAGGER)
        return
    if eventPlayer.talent_ranks[Talent.STEALTH] == 1:
        eventPlayer.talent_trigger_times[Talent.STEALTH] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.STEALTH]
        eventPlayer.entering_stealth = false
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true else null, Effect.REAPER_WRAITH_FORM, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[57] = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true else null, Effect.SIGMA_GRAVITIC_FLUX_TARGET_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[58] = getLastCreatedEntity()
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.POISONOUS_DAGGER)
        eventPlayer.talents_you_do_not_have.remove(Talent.STEALTH)
        eventPlayer.talents_you_do_not_have.append(Talent.POISONOUS_DAGGER)

/*
def buy_juggernaut():
    @Name "TALENT SYSTEM - - - [TALENT 6: JUGGERNAUT] [SUBROUTINE] Buy Juggernaut [DISABLED: JUGGERNAUT NOT WORKING AS INTENDED]"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.juggernaut_charge)
        destroyEffect(eventPlayer.player_temp_effects[59])
        eventPlayer.talents_you_do_not_have.append(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        return
    if eventPlayer.talent_ranks[Talent.JUGGERNAUT] == 1:
        chase(eventPlayer.juggernaut_charge, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true else null, Effect.SOLDIER_SPRINTING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[59] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.JUGGERNAUT]
*/

def buy_dive_bomb():
    @Name "TALENT SYSTEM - - - [DIVE BOMB] [SUBROUTINE] Buy Dive Bomb"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.DIVE_BOMB)
        return
    if eventPlayer.talent_ranks[Talent.DIVE_BOMB] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.DIVE_BOMB)
        eventPlayer.talent_trigger_times[Talent.DIVE_BOMB] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.DIVE_BOMB]

def buy_cryogenics():
    @Name "TALENT SYSTEM - - - [TALENT 8: CRYOGENICS] [SUBROUTINE] Buy Cryogenics"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.CRYOGENICS)
        return
    if eventPlayer.talent_ranks[Talent.CRYOGENICS] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.CRYOGENICS)

def buy_railgun():
    @Name "TALENT SYSTEM - - - [TALENT 9: RAILGUN] [SUBROUTINE] Buy Railgun"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == [16]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[Talent.RAILGUN], talent_names[Talent.OVERCLOCK]))
            goto lbl_0
        if eventPlayer.talent_ranks[Talent.OVERCLOCK] > 0:
            smallMessage(eventPlayer, "Need to remove {0} first!".format(talent_names[Talent.OVERCLOCK]))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        stopChasingVariable(eventPlayer.railgun_discharge)
        destroyEffect(eventPlayer.player_temp_effects[59])
        destroyEffect(eventPlayer.player_temp_effects[76])
        eventPlayer.railgun_discharge = 0
        eventPlayer.railgun_charge = 0
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.railgun_projectile_start = []
        eventPlayer.railgun_projectile_player_hit = []
        eventPlayer.talents_you_do_not_have.append(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.append(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.remove(Talent.OVERCLOCK)
        return
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 1:
        eventPlayer.talent_trigger_times[Talent.RAILGUN] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.RAILGUN]
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.OVERCLOCK)
        eventPlayer.railgun_projectile_start = []
        eventPlayer.railgun_projectile_player_hit = []
        chase(eventPlayer.railgun_discharge, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.railgun_charge = 0
        eventPlayer.setSecondaryFireEnabled(false)
        createEffect(getAllPlayers() if eventPlayer.railgun_charge == 100 else null, Effect.ANA_NANO_BOOSTED, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[59] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.railgun_charge == 100 else null, Effect.WINSTON_TESLA_CANNON_TARGET_SOUND, Color.TEAM_1, eventPlayer, 75, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[76] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.remove(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.append(Talent.OVERCLOCK)

def buy_predator():
    @Name "TALENT SYSTEM - - - [TALENT 10: PREDATOR] [SUBROUTINE] Buy Predator"
    
    async(which_players_have_predator, AsyncBehavior.RESTART)
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.PREDATOR)
        return
    if eventPlayer.talent_ranks[Talent.PREDATOR] == 1:
        #Old
        #someone_in_match_have_predator = true
        eventPlayer.talents_you_do_not_have.remove(Talent.PREDATOR)
    if eventPlayer.talent_ranks[Talent.PREDATOR] > 1:
        #Old
        #players_with_predator_rank[eventPlayer.talent_ranks[Talent.PREDATOR] - 1] -= 1
    #Old
    #players_with_predator_rank[eventPlayer.talent_ranks[Talent.PREDATOR]] += 1
    if eventPlayer.talent_ranks[Talent.PREDATOR] > highest_predator_rank_in_match:
        highest_predator_rank_in_match = eventPlayer.talent_ranks[Talent.PREDATOR]

def buy_jetpack():
    @Name "TALENT SYSTEM - - - [TALENT 11: JETPACK] [SUBROUTINE] Buy Jetpack"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.stopAcceleration()
        stopChasingVariable(eventPlayer.jetpack_fuel)
        eventPlayer.jetpack_fuel = 100
        destroyEffect(eventPlayer.player_temp_effects[14])
        eventPlayer.talents_you_do_not_have.append(Talent.JETPACK)
        return
    if eventPlayer.talent_ranks[Talent.JETPACK] == 1:
        eventPlayer.startAcceleration(Vector.UP, 10 + 0.275 * eventPlayer.jetpack_fuel if eventPlayer.is_using_ability[Talent.JETPACK] == true else 0, 3, Relativity.TO_PLAYER, AccelReeval.DIRECTION_RATE_AND_MAX_SPEED)
        eventPlayer.jetpack_fuel = 100
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.JETPACK] == true and eventPlayer.is_using_ability[Talent.STEALTH] == false else null, Effect.WRECKING_BALL_PILEDRIVER_FIRE_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[14] = getLastCreatedEntity()
        chase(eventPlayer.jetpack_fuel, 0 if eventPlayer.is_using_ability[Talent.JETPACK] == true else 100, rate=25 - eventPlayer.talent_ranks[Talent.JETPACK] * 3 if eventPlayer.is_using_ability[Talent.JETPACK] == true else 10, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.talents_you_do_not_have.remove(Talent.JETPACK)

def buy_lifesteal_ammo():
    @Name "TALENT SYSTEM - - - [TALENT 12: LIFESTEAL AMMO] [SUBROUTINE] Buy Lifesteal Ammo"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.is_lifestealing)
        eventPlayer.is_lifestealing = 0
        destroyEffect(eventPlayer.player_temp_effects[60])
        destroyEffect(eventPlayer.player_temp_effects[61])
        destroyEffect(eventPlayer.player_temp_effects[62])
        eventPlayer.talents_you_do_not_have.append(Talent.LIFESTEAL_AMMO)
        return
    if eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] == 1:
        eventPlayer.is_lifestealing = 0
        chase(eventPlayer.is_lifestealing, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        createEffect(eventPlayer if eventPlayer.is_lifestealing > 0 else null, Effect.BAD_AURA_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[60] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_lifestealing > 0 else null, Effect.HEAL_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[61] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_lifestealing > 0 else null, Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[62] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.LIFESTEAL_AMMO)

def buy_health_regen():
    @Name "TALENT SYSTEM - - - [TALENT 13: HEALTH REGEN] [SUBROUTINE] Buy Health Regen"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_REGEN)
        destroyEffect(eventPlayer.player_temp_effects[63])
        destroyEffect(eventPlayer.player_temp_effects[64])
        stopHoT(eventPlayer.health_pool_id_or_hot_id[2])
        return
    if eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 1:
        createEffect(eventPlayer if eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) and eventPlayer.isAlive() else null, Effect.SPARKLES_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.player_temp_effects[63] = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) and eventPlayer.isAlive() else null, Effect.SPARKLES, Color.PURPLE if eventPlayer.is_using_ability[Talent.STEALTH] == true else Color.ORANGE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.player_temp_effects[64] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_REGEN)
        async(health_regen_heal_over_time, AsyncBehavior.RESTART)

def buy_health_potions():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Buy Health Potions"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == [26]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[Talent.HEALTH_POTIONS], talent_names[Talent.ALCHEMIST]))
            goto lbl_0
        if eventPlayer.talent_ranks[Talent.ALCHEMIST] > 0:
            smallMessage(eventPlayer, "Need to remove {0} Crazy Alchemist first!".format(iconString(Icon.RADIOACTIVE)))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        eventPlayer.amount_of_potions_or_vials = 0
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_POTIONS)
        #disabled because poison vials are disabled
        /*eventPlayer.talents_you_do_not_have.append(Talent.POISON_VIALS)*/
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] == 1:
        eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.HEALTH_POTIONS]
        eventPlayer.amount_of_potions_or_vials = 3
        eventPlayer.possible_talents.remove(25)
        eventPlayer.talents_you_do_not_have.remove(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.ALCHEMIST)

def buy_ignite():
    @Name "TALENT SYSTEM - - - [TALENT 16: IGNITE] [SUBROUTINE] Buy Ignite"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.ignite_position = eventPlayer.getEyePosition()
        eventPlayer.talents_you_do_not_have.append(Talent.IGNITE)
        return
    if eventPlayer.talent_ranks[Talent.IGNITE] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.IGNITE)

def buy_overclock():
    @Name "TALENT SYSTEM - - - [TALENT 17: OVERCLOCK] [SUBROUTINE] Buy Overclock"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.OVERCLOCK)
        return
    if eventPlayer.talent_ranks[Talent.OVERCLOCK] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.OVERCLOCK)

def buy_shadowstep():
    @Name "TALENT SYSTEM - - - [TALENT 18: SHADOWSTEP] [SUBROUTINE] Buy Shadowstep"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.SHADOWSTEP)
        return
    if eventPlayer.talent_ranks[Talent.SHADOWSTEP] == 1:
        eventPlayer.talent_trigger_times[Talent.SHADOWSTEP] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.SHADOWSTEP]
        eventPlayer.talents_you_do_not_have.remove(Talent.SHADOWSTEP)

def buy_burning_soul():
    @Name "TALENT SYSTEM - - - [TALENT 19: BURNING SOUL] [SUBROUTINE] Buy Burning Soul"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.burning_soul_orb_timer)
        eventPlayer.burning_soul_orb_timer = 0
        eventPlayer.talents_you_do_not_have.append(Talent.BURNING_SOUL)
        destroyEffect(eventPlayer.player_temp_effects[65])
        destroyEffect(eventPlayer.player_temp_effects[66])
        return
    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] == 1:
        createEffect(getAllPlayers() if "{0}".format(eventPlayer.isCommunicatingEmote()) == "false" else null if eventPlayer.isUsingAbility1() else getAllPlayers().exclude(eventPlayer), Effect.ASHE_DYNAMITE_BURNING_PARTICLE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[65] = getLastCreatedEntity()
        createEffect(null if eventPlayer.isUsingAbility1() else getAllPlayers(), Effect.ASHE_DYNAMITE_BURNING_MATERIAL, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[66] = getLastCreatedEntity()
        chase(eventPlayer.burning_soul_orb_timer, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.talents_you_do_not_have.remove(Talent.BURNING_SOUL)

def buy_berserker():
    @Name "TALENT SYSTEM - - - [TALENT 20: BERSERKER] [SUBROUTINE] Buy Berserker"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == [0]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[Talent.BERSERKER], talent_names[Talent.BLOODTHIRST]))
            goto lbl_0
        if eventPlayer.talent_ranks[Talent.BLOODTHIRST] > 0:
            smallMessage(eventPlayer, "Need to remove {0} Bloodthirst first!".format(abilityIconString(Hero.SIGMA, Button.ABILITY_1)))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        eventPlayer.talents_you_do_not_have.append(Talent.BERSERKER)
        eventPlayer.talents_you_do_not_have.remove(Talent.BLOODTHIRST)
        destroyEffect(eventPlayer.player_temp_effects[67])
        destroyEffect(eventPlayer.player_temp_effects[68])
        destroyEffect(eventPlayer.player_temp_effects[69])
        return
    if eventPlayer.talent_ranks[Talent.BERSERKER] == 1:
        eventPlayer.talent_trigger_times[Talent.BERSERKER] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.BERSERKER]
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.BLOODTHIRST)
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[67] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[68] = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[69] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.BERSERKER)
        eventPlayer.talents_you_do_not_have.append(Talent.BLOODTHIRST)

def buy_fireball():
    @Name "TALENT SYSTEM - - - [TALENT 21: FIREBALL] [SUBROUTINE] Buy Fireball"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == [24]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[Talent.FIREBALL], talent_names[Talent.PYROMANIAC]))
            goto lbl_0
        if eventPlayer.talent_ranks[Talent.PYROMANIAC] > 0:
            smallMessage(eventPlayer, "Need to remove {0} Pyromaniac first!".format(abilityIconString(Hero.REAPER, Button.ULTIMATE)))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        eventPlayer.fireball_position = vect(0, 0, 0)
        #Disabled because Juggernaut disabled
        #eventPlayer.talents_you_do_not_have.append(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.remove(Talent.PYROMANIAC)
        return
    if eventPlayer.talent_ranks[Talent.FIREBALL] == 1:
        eventPlayer.talent_trigger_times[Talent.FIREBALL] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.FIREBALL]
        eventPlayer.fireball_position = vect(0, 0, 0)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.PYROMANIAC)
        eventPlayer.talents_you_do_not_have.remove(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.append(Talent.PYROMANIAC)

def buy_ignore_pain():
    @Name "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] [SUBROUTINE] Buy Ignore Pain"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.ignore_pain_damage_resisted = 0
        eventPlayer.talents_you_do_not_have.append(Talent.SPRINTER)
        eventPlayer.talents_you_do_not_have.append(Talent.IGNORE_PAIN)
        destroyEffect(eventPlayer.player_temp_effects[55])
        destroyEffect(eventPlayer.player_temp_effects[56])
        return
    if eventPlayer.talent_ranks[Talent.IGNORE_PAIN] == 1:
        eventPlayer.possible_talents.remove(21)
        eventPlayer.talents_you_do_not_have.remove(Talent.IGNORE_PAIN)
        eventPlayer.talents_you_do_not_have.remove(Talent.SPRINTER)
        eventPlayer.ignore_pain_damage_resisted = 0
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.IGNORE_PAIN] == true else null, Effect.WRECKING_BALL_ADAPTIVE_SHIELD_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[55] = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.IGNORE_PAIN] == true else null, Effect.WRECKING_BALL_ADAPTIVE_SHIELD_TARGET_SOUND, Color.TEAM_1, eventPlayer.getPosition(), eventPlayer.ignore_pain_volume, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.player_temp_effects[56] = getLastCreatedEntity()

def buy_bandage():
    @Name "TALENT SYSTEM - - - [Bandage] [SUBROUTINE] Buy Bandage"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.bandage_progress)
        eventPlayer.bandage_progress = 0
        eventPlayer.talents_you_do_not_have.append(Talent.BANDAGE)
        return
    if eventPlayer.talent_ranks[Talent.BANDAGE] == 1:
        eventPlayer.talent_trigger_times[Talent.BANDAGE] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.BANDAGE]
        eventPlayer.talents_you_do_not_have.remove(Talent.BANDAGE)

def buy_pyromaniac():
    @Name "TALENT SYSTEM - - - [TALENT 30: PYROMANIAC] [SUBROUTINE] Buy Pyromaniac"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.pyromaniac_heal_duration)
        eventPlayer.pyromaniac_heal_duration = 0
        eventPlayer.talents_you_do_not_have.append(Talent.PYROMANIAC)
        return
    if eventPlayer.talent_ranks[Talent.PYROMANIAC] == 1:
        eventPlayer.pyromaniac_heal_duration = 0
        chase(eventPlayer.pyromaniac_heal_duration, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.talents_you_do_not_have.remove(Talent.PYROMANIAC)

def buy_poison_vials():
    @Name "TALENT SYSTEM - - - [TALENT 31: POISON VIALS] [SUBROUTINE] Buy Poison Vials [DISABLED: POISON VIALS NOT WORKING AS INTENDED]"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        if eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop] == talent_names[Talent.ALCHEMIST]:
            smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[Talent.POISON_VIALS], talent_names[Talent.ALCHEMIST]))
            goto lbl_0
        if eventPlayer.talent_ranks[Talent.ALCHEMIST] > 0:
            smallMessage(eventPlayer, "Need to remove {0} Crazy Alchemist first!".format(iconString(Icon.RADIOACTIVE)))
            lbl_0:
            eventPlayer.replacing_talent_cancelled = true
            return
        stopChasingVariable(eventPlayer.time_since_poison_vial_exploded)
        eventPlayer.poison_vial_effects = []
        eventPlayer.poison_vial_clouds_spawned = 0
        eventPlayer.time_since_poison_vial_exploded = 0
        eventPlayer.amount_of_potions_or_vials = 0
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.append(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.POISON_VIALS] == 1:
        eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = eventPlayer.totalTimeElapsed - talent_base_cooldowns[Talent.POISON_VIALS]
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.remove(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        eventPlayer.amount_of_potions_or_vials = 3
        eventPlayer.possible_talents.remove(14)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.ALCHEMIST)
        eventPlayer.poison_vial_effects = []
        eventPlayer.poison_vial_clouds_spawned = 0
        chase(eventPlayer.time_since_poison_vial_exploded, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)

def buy_alchemist():
    @Name "TALENT SYSTEM - - - [TALENT 32: CRAZY ALCHEMIST] [SUBROUTINE] Buy Crazy Alchemist"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.ALCHEMIST] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)

def buy_bombardment():
    @Name "TALENT SYSTEM - - - [BOMBARDMENT] [SUBROUTINE] Buy Bombardment"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.append(Talent.GUNSLINGER)
        eventPlayer.talents_you_do_not_have.append(Talent.RAILGUN)
        eventPlayer.setMaxAmmo(0, 30)
        eventPlayer.setProjectileSpeed(100)
        return
    if eventPlayer.talent_ranks[Talent.BOMBARDMENT] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.remove(Talent.GUNSLINGER)
        eventPlayer.talents_you_do_not_have.remove(Talent.RAILGUN)
        eventPlayer.possible_talents.remove(27)
        eventPlayer.setMaxAmmo(0, 0)
        eventPlayer.setProjectileSpeed(70)

def buy_gigachad():
    @Name "TALENT SYSTEM - - - [GIGACHAD] [SUBROUTINE] Buy GIGACHAD"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.GIGACHAD)
        if eventPlayer.talent_ranks[Talent.IGNORE_PAIN] == 0:
            eventPlayer.talents_you_do_not_have.append(Talent.SPRINTER)
        #Health
        eventPlayer.stats[1] = 200
        #Speed
        #eventPlayer.stats[2] = 100
        #Size
        eventPlayer.stats[8] = 1
        #Knockback Received
        eventPlayer.stats[9] = 100
        eventPlayer.startScalingSize(eventPlayer.stats[8], false)
        #Voice
        eventPlayer.stats[6] = 1
        eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[6], false)
        return
    if eventPlayer.talent_ranks[Talent.GIGACHAD] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.GIGACHAD)
        eventPlayer.talents_you_do_not_have.remove(Talent.SPRINTER)
    #Health
    eventPlayer.stats[1] += 40
    #Speed
    #eventPlayer.stats[2] -= 2
    #Size
    eventPlayer.stats[8] += 0.07
    eventPlayer.startScalingSize(eventPlayer.stats[8], false)
    #Voice
    eventPlayer.stats[6] -= 0.05
    eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[6], false)
    #Knockback Received
    eventPlayer.stats[9] -= 20

def buy_gunslinger():
    @Name "TALENT SYSTEM - - - [GUNSLINGER] [SUBROUTINE] Buy GUNSLINGER"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.talents_you_do_not_have.append(Talent.GUNSLINGER)
        eventPlayer.talents_you_do_not_have.append(Talent.BOMBARDMENT)
        eventPlayer.setMaxAmmo(0, 30)
        return
    if eventPlayer.talent_ranks[Talent.GUNSLINGER] == 1:
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.talents_you_do_not_have.remove(Talent.GUNSLINGER)
        eventPlayer.talents_you_do_not_have.remove(Talent.BOMBARDMENT)
        eventPlayer.possible_talents.remove(27)
        eventPlayer.setMaxAmmo(0, 6)
        eventPlayer.setAmmo(0, 6)

def buy_sprinter():
    @Name "TALENT SYSTEM - - - [SPRINTER] [SUBROUTINE] Buy SPRINTER"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.SPRINTER)
        eventPlayer.talents_you_do_not_have.append(Talent.GIGACHAD)
        eventPlayer.talents_you_do_not_have.append(Talent.IGNORE_PAIN)
        #Size
        eventPlayer.stats[8] = 1
        eventPlayer.startScalingSize(eventPlayer.stats[8], false)
        #Voice
        eventPlayer.stats[6] = 1
        eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[6], false)
        return
    if eventPlayer.talent_ranks[Talent.SPRINTER] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.SPRINTER)
        eventPlayer.talents_you_do_not_have.remove(Talent.GIGACHAD)
        eventPlayer.talents_you_do_not_have.remove(Talent.IGNORE_PAIN)
    #Size
    eventPlayer.stats[8] -= 0.035
    eventPlayer.startScalingSize(eventPlayer.stats[8], false)
    #Voice
    eventPlayer.stats[6] += 0.075
    eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[6], false)