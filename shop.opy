#!mainFile "soldier_x.opy"

#--- Shop-only defineMember (variable[200-217]) ---
#!defineMember jetpack_sound_id variable[200]
#!defineMember ignore_pain_effect_id variable[201]
#!defineMember ignore_pain_sound_id variable[202]
#!defineMember lifesteal_sound_id variable[203]
#!defineMember lifesteal_target_effect_id variable[204]
#!defineMember lifesteal_self_effect_id variable[205]
#!defineMember health_regen_sound_id variable[206]
#!defineMember health_regen_effect_id variable[207]
#!defineMember burning_soul_particle_effect_id variable[208]
#!defineMember burning_soul_material_effect_id variable[209]
#!defineMember berserker_team1_effect_id variable[210]
#!defineMember berserker_team2_effect_id variable[211]
#!defineMember berserker_sound_id variable[212]
#!defineMember railgun_charge_sound variable[213]
#!defineMember adrenaline_rush_effect_id variable[214]
#!defineMember adrenaline_rush_effect_id2 variable[215]
#!defineMember adrenaline_rush_effect_id3 variable[216]
#!defineMember jetpack_beam_effect_id variable[217]
#--- Scratch for validate_talent_removal's dependent loop (atomic, no waits) ---
#!defineMember current_removal_dependent variable[218]

#Global variables
globalvar talent_dependent_index

#Player variables
playervar health_pool_id_or_hot_id
playervar entering_stealth
playervar railgun_discharge
playervar railgun_projectile_start
playervar railgun_projectile_player_hit
playervar jetpack_fuel = 100
playervar is_lifestealing
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
playervar burning_soul_orb_volume
playervar burning_soul_orb_drop_position

#Subroutine names

subroutine health_regen_heal_over_time
subroutine open_shop
subroutine update_player_with_most_talent
subroutine buy_or_upgrade_talent
subroutine validate_talent_removal
subroutine buy_bloodthirst
subroutine buy_immunity
subroutine buy_cybernetics
subroutine buy_soul_harvest
subroutine buy_poisonous_dagger
subroutine buy_stealth
subroutine buy_juggernaut
subroutine buy_dive_bomb
subroutine buy_cryogenics
subroutine buy_helix
subroutine buy_railgun
subroutine buy_grim_reaper
subroutine buy_jetpack
subroutine buy_lifesteal_ammo
subroutine buy_health_regen
subroutine buy_health_potions
subroutine buy_explosive_ammo
subroutine buy_overclock
subroutine buy_shadowstep
subroutine buy_burning_soul
subroutine buy_berserker
subroutine buy_fireball
subroutine buy_ignore_pain
subroutine buy_bandage
subroutine buy_pyromaniac
#subroutine buy_poison_vials
subroutine buy_alchemist
#subroutine buy_bombardment
subroutine buy_gigachad
#subroutine buy_gunslinger
#subroutine buy_adrenaline_rush

rule "SHOP - - - Using Hearthstone":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == false
    @Condition eventPlayer.can_enter_shop == true
    #@Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.is_using_ability[Talent.JUGGERNAUT] == false
    @Condition eventPlayer.is_using_ability[Talent.DIVE_BOMB] == false
    @Condition eventPlayer.is_using_ability[Talent.GRIM_REAPER] == false
    @Condition eventPlayer.railgun_charge == 0
    @Condition eventPlayer.in_combat == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_hearthstone = true
    #eventPlayer.startFacing(eventPlayer.getFacingDirection(), 1, Relativity.TO_WORLD, FacingReeval.NONE)
    casting()

rule "SHOP - - - Skip Talents & Exit Shop":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.replacing_talent_show_confirmation == false
    @Condition eventPlayer.replacing_talent_show_bought_talents == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) == false

    wait(0.75 if faster_testing == false else 0.425, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_skip_talent = true
    casting()

rule "SHOP - - - Using Yes":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.replacing_talent_show_confirmation == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) == false

    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_vote_yes = true
    casting()

rule "SHOP - - - Using No":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.replacing_talent_show_confirmation == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) == true

    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.is_using_vote_no = true
    casting()

def open_shop():
    @Name "SHOP - - - [SUBROUTINE] Open Shop"

    #empty and refill possible talents
    eventPlayer.possible_talents = []

    /*if len(eventPlayer.bought_talents) == 5:
        eventPlayer.possible_talents_selector = 4*/
    eventPlayer.possible_talents_selector = len(eventPlayer.bought_talents) - 1
    while eventPlayer.possible_talents_selector >= 0:
        if eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.possible_talents_selector]] < 5:
            eventPlayer.possible_talents.append(eventPlayer.bought_talents[eventPlayer.possible_talents_selector])
        eventPlayer.possible_talents_selector -= 1
    /*else:
        eventPlayer.possible_talents_selector = len(eventPlayer.bought_talents) - 1
        while eventPlayer.possible_talents_selector >= 0:
            if eventPlayer.talent_ranks[eventPlayer.bought_talents[eventPlayer.possible_talents_selector]] < 5:
                eventPlayer.possible_talents.append(eventPlayer.bought_talents[eventPlayer.possible_talents_selector])
            eventPlayer.possible_talents_selector -= 1*/
    if len(eventPlayer.bought_talents) < 5:
        eventPlayer.possible_talents_selector = len(eventPlayer.talents_you_do_not_have)
        while eventPlayer.possible_talents_selector >= 0:
            if eventPlayer.talents_you_do_not_have[eventPlayer.possible_talents_selector] != null:
                eventPlayer.possible_talents.append(eventPlayer.talents_you_do_not_have[eventPlayer.possible_talents_selector])
            eventPlayer.possible_talents_selector -= 1

    eventPlayer.is_using_hearthstone = false
    eventPlayer.skipped_a_talent = false

    block_player_input()
    
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
    #if eventPlayer.amount_of_bonus_talents > 0:
        #eventPlayer.startCamera(shop_location, shop_talent_positions[1], 0.5)
    playEffect(eventPlayer, DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR_SOUND, Color.TEAM_1, shop_location.getPosition(), 100)

rule "SHOP - - - Toggle Controller Layout":
    @Disabled
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    eventPlayer.using_gamepad = not eventPlayer.using_gamepad
    #bigMessage(eventPlayer, "Controller layout: {0}".format("ON" if eventPlayer.using_gamepad else "OFF"))
    waitUntil(eventPlayer.isHoldingButton(Button.ULTIMATE) == false, 99999)

rule "SHOP - - - Shop Left":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) == false
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) == false
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
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.using_one_of_the_hearthstones == false
    @Condition eventPlayer.replacing_talent_show_confirmation == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) == true

    if eventPlayer.selected_talent_in_shop == 0:
        eventPlayer.startCamera(shop_talent_positions[0], shop_talent_positions[0], 4.125 if faster_testing == false else 8.25)
    elif eventPlayer.selected_talent_in_shop == 1:
        eventPlayer.startCamera(shop_talent_positions[1], shop_talent_positions[1], 4.125 if faster_testing == false else 8.25)
    elif eventPlayer.selected_talent_in_shop == 2:
        eventPlayer.startCamera(shop_talent_positions[2], shop_talent_positions[2], 4.125 if faster_testing == false else 8.25)
    waitUntil(not eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) or eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE), 0.85 if faster_testing == false else 0.425)
    if not eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) or eventPlayer.isHoldingButton(Button.ABILITY_1 if eventPlayer.using_gamepad else Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.ABILITY_2 if eventPlayer.using_gamepad else Button.SECONDARY_FIRE):
        wait(0.25)
        return
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.current_talent_replace_or_buy = eventPlayer.bought_talents[eventPlayer.selected_bought_talent]
        validate_talent_removal()
        if eventPlayer.replacing_talent_cancelled == true:
            eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.TEAM_1, shop_location.getPosition(), 100)
            eventPlayer.replacing_talent_show_confirmation = false
            eventPlayer.replacing_talent_show_bought_talents = false
            eventPlayer.replacing_talent_cancelled = false
            return
        buy_or_upgrade_talent()
        eventPlayer.amount_of_talents_purchased -= eventPlayer.talent_ranks[eventPlayer.current_talent_replace_or_buy]
        update_player_with_most_talent()
        #Remove the talent from talent_ranks
        eventPlayer.talent_ranks[eventPlayer.current_talent_replace_or_buy] = 0
        eventPlayer.talent_on_cooldown[eventPlayer.current_talent_replace_or_buy] = false
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
    update_player_with_most_talent()
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
    /*
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
    */
    eventPlayer.browsing_shop = false
    eventPlayer.can_enter_shop = false
    eventPlayer.experience_current = 0
    eventPlayer.experience_max = max_experience_per_level[eventPlayer.amount_of_talents_purchased]
    #if eventPlayer.talent_ranks[Talent.FIREBALL] > 0 or eventPlayer.talent_ranks[Talent.JUGGERNAUT] > 0:
        #async(spawned_with_fireball, AsyncBehavior.RESTART)
    eventPlayer.is_respawning = true
    eventPlayer.respawn()
    eventPlayer.selected_talent_in_shop = 1

#Triggers after removing or buying a talent:
def update_player_with_most_talent():
    @Name "SHOP - - - [SUBROUTINE] Update Player With Most Talents"

    #If (start of the game, or the leading player have left the match) or eventplayer has less than leading player, update who in the lobby has most
    if (player_with_most_talents.amount_of_talents_purchased == null) or (eventPlayer.amount_of_talents_purchased > player_with_most_talents.amount_of_talents_purchased):
        player_with_most_talents = sorted([p for p in getAllPlayers() if not p.isDummy()], lambda player: player.amount_of_talents_purchased).last()

def replace_talent():
    @Name "SHOP - - - [SUBROUTINE] Replace Talent"
    
    eventPlayer.replacing_talent_show_confirmation = true
    eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 12)
    playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, shop_location, 100)
    waitUntil(eventPlayer.replacing_talent_show_bought_talents == true or eventPlayer.replacing_talent_cancelled == true, 99999)

rule "SHOP - - - Reset Shop Camera":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.browsing_shop == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT) == false
    @Condition (eventPlayer.is_using_skip_talent == true or not eventPlayer.isHoldingButton(Button.JUMP if eventPlayer.using_gamepad else Button.INTERACT)) == true

    eventPlayer.startCamera(shop_location, eventPlayer.selected_talent_position, 0)

def validate_talent_removal():
    @Name "TALENT SYSTEM - - - [SUBROUTINE] Validate Talent Removal (prerequisites)"
    #--- Block replacing a talent with one that needs it (the new talent would have no owned prerequisite left) ---
    if eventPlayer.current_talent_replace_or_buy in talent_requirements[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] and len([req for req in talent_requirements[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]] if req != eventPlayer.current_talent_replace_or_buy and eventPlayer.talent_ranks[req] > 0]) == 0:
        smallMessage(eventPlayer, "You need {0} for {1}!".format(talent_names[eventPlayer.current_talent_replace_or_buy], talent_names[eventPlayer.talents_offered_in_shop[eventPlayer.selected_talent_in_shop]]))
        eventPlayer.replacing_talent_cancelled = true
        return
    #--- Block removing a talent an owned talent still depends on (its last owned prerequisite) ---
    for talent_dependent_index in range(len(talent_dependents[eventPlayer.current_talent_replace_or_buy])):
        eventPlayer.current_removal_dependent = talent_dependents[eventPlayer.current_talent_replace_or_buy][talent_dependent_index]
        if eventPlayer.talent_ranks[eventPlayer.current_removal_dependent] > 0 and len([req for req in talent_requirements[eventPlayer.current_removal_dependent] if req != eventPlayer.current_talent_replace_or_buy and eventPlayer.talent_ranks[req] > 0]) == 0:
            smallMessage(eventPlayer, "Need to remove {0} first!".format(talent_names[eventPlayer.current_removal_dependent]))
            eventPlayer.replacing_talent_cancelled = true
            return

def buy_or_upgrade_talent():
    @Name "SHOP - - - [SUBROUTINE] Buy Or Upgrade Talent"
    
    if eventPlayer.current_talent_replace_or_buy == [Talent.BLOODTHIRST]:
        buy_bloodthirst()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.IMMUNITY]:
        buy_immunity()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.CYBERNETICS]:
        buy_cybernetics()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.SOUL_HARVEST]:
        buy_soul_harvest()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.POISONOUS_DAGGER]:
        buy_poisonous_dagger()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.STEALTH]:
        buy_stealth()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.JUGGERNAUT]:
        buy_juggernaut()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.DIVE_BOMB]:
        buy_dive_bomb()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.CRYOGENICS]:
        buy_cryogenics()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.RAILGUN]:
        buy_railgun()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.GRIM_REAPER]:
        buy_grim_reaper()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.JETPACK]:
        buy_jetpack()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.LIFESTEAL_AMMO]:
        buy_lifesteal_ammo()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.HEALTH_REGEN]:
        buy_health_regen()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.HEALTH_POTIONS]:
        if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] == 1:
            eventPlayer.amount_of_health_potions = 3
        buy_health_potions()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.EXPLOSIVE_AMMO]:
        buy_explosive_ammo()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.OVERCLOCK]:
        buy_overclock()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.SHADOWSTEP]:
        buy_shadowstep()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.BURNING_SOUL]:
        buy_burning_soul()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.BERSERKER]:
        buy_berserker()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.FIREBALL]:
        buy_fireball()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.IGNORE_PAIN]:
        buy_ignore_pain()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.BANDAGE]:
        buy_bandage()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.PYROMANIAC]:
        buy_pyromaniac()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.ALCHEMIST]:
        buy_alchemist()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.GIGACHAD]:
        buy_gigachad()
    elif eventPlayer.current_talent_replace_or_buy == [Talent.HELIX]:
        buy_helix()
    #elif eventPlayer.current_talent_replace_or_buy == [Talent.GUNSLINGER]:
        #buy_gunslinger()
    #elif eventPlayer.current_talent_replace_or_buy == [Talent.ADRENALINE_RUSH]:
        #buy_adrenaline_rush()

def buy_bloodthirst():
    @Name "TALENT SYSTEM - - - [TALENT 0: BLOODTHIRST] [SUBROUTINE] Buy Bloodthirst"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.BLOODTHIRST)
        return
    if eventPlayer.talent_ranks[Talent.BLOODTHIRST] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.BLOODTHIRST)

def buy_immunity():
    @Name "TALENT SYSTEM - - - [TALENT 1: IMMUNITY] [SUBROUTINE] Buy Immunity"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.IMMUNITY)
        #Group A exclusivity: removing Immunity frees the Ultimate button, so Berserker becomes available again
        eventPlayer.talents_you_do_not_have.append(Talent.BERSERKER)
        stopChasingVariable(eventPlayer.immunity_duration)
        eventPlayer.immunity_duration = 0
        return
    if eventPlayer.talent_ranks[Talent.IMMUNITY] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.IMMUNITY)
        #Group A exclusivity: Immunity and Berserker share the Ultimate button, so owning one removes the other from the pool
        eventPlayer.talents_you_do_not_have.remove(Talent.BERSERKER)
        eventPlayer.talent_trigger_times[Talent.IMMUNITY] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.IMMUNITY]

def buy_cybernetics():
    @Name "TALENT SYSTEM - - - [TALENT 2: CYBERNETICS] [SUBROUTINE] Buy Cybernetics (hit_by_ability[2] is borrowed by talent: juggernaut)"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.CYBERNETICS)
        #Shields
        eventPlayer.stats[Stat.SHIELDS] = 0
        removeHealthPool(eventPlayer.cybernetics_health_pool_id)
        return
    if eventPlayer.talent_ranks[Talent.CYBERNETICS] > 0:
        eventPlayer.stats[Stat.SHIELDS] = CYBERNETICS_SHIELD_AMOUNT
        eventPlayer.talents_you_do_not_have.remove(Talent.CYBERNETICS)
    #Shields
    #eventPlayer.stats[Stat.SHIELDS] += 18.75

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
        eventPlayer.talent_trigger_times[Talent.POISONOUS_DAGGER] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.POISONOUS_DAGGER]
        eventPlayer.talents_you_do_not_have.remove(Talent.POISONOUS_DAGGER)

def buy_stealth():
    @Name "TALENT SYSTEM - - - [TALENT 5: STEALTH] [SUBROUTINE] Buy Stealth"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        break_stealth()
        eventPlayer.entering_stealth = false
        destroyEffect(eventPlayer.stealth_effect_id)
        destroyEffect(eventPlayer.stealth_effect_id2)
        destroyEffect(eventPlayer.stealth_sound_id)
        destroyEffect(eventPlayer.stealth_hack_text_id)
        eventPlayer.talents_you_do_not_have.append(Talent.STEALTH)
        eventPlayer.talents_you_do_not_have.remove(Talent.POISONOUS_DAGGER)
        return
    if eventPlayer.talent_ranks[Talent.STEALTH] == 1:
        eventPlayer.current_stealth_target = null
        eventPlayer.talent_trigger_times[Talent.STEALTH] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.STEALTH]
        eventPlayer.entering_stealth = false
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true else null, Effect.REAPER_WRAITH_FORM, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.stealth_effect_id = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true else null, Effect.SIGMA_GRAVITIC_FLUX_TARGET_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.stealth_sound_id = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true else null, Effect.ECHO_CLONING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.stealth_effect_id2 = getLastCreatedEntity()

        createInWorldText(eventPlayer if eventPlayer.is_using_ability[Talent.STEALTH] == true and eventPlayer.current_stealth_target != null and distance(eventPlayer.getPosition(), eventPlayer.current_stealth_target.getPosition()) < 10 else null, "{0}{1}".format("{0}: ".format(buttonString(Button.MELEE)) if eventPlayer.using_gamepad else "[{0}]: ".format(buttonString(Button.MELEE)), "Hack!" if eventPlayer.talent_ranks[Talent.POISONOUS_DAGGER] == 0 else "Poison & Hack!"), updateEveryFrame(eventPlayer.current_stealth_target.getPosition() + Vector.UP), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

        eventPlayer.stealth_hack_text_id = getLastCreatedEntity()

        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.POISONOUS_DAGGER)
        eventPlayer.talents_you_do_not_have.remove(Talent.STEALTH)
        eventPlayer.talents_you_do_not_have.append(Talent.POISONOUS_DAGGER)

#if (sorted([player for player in eventPlayer.getPlayersInViewAngle(Team.ALL, 45) if player.is_using_ability == 0], lambda i: distance(eventPlayer.getPosition(), i.getPosition()) < 10))[0] == true:


/*
def buy_juggernaut():
    @Name "TALENT SYSTEM - - - [TALENT 6: JUGGERNAUT] [SUBROUTINE] Buy Juggernaut [DISABLED: JUGGERNAUT NOT WORKING AS INTENDED]"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.juggernaut_charge)
        destroyEffect(eventPlayer.railgun_charge_effect_id)
        eventPlayer.talents_you_do_not_have.append(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        return
    if eventPlayer.talent_ranks[Talent.JUGGERNAUT] == 1:
        chase(eventPlayer.juggernaut_charge, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.JUGGERNAUT] == true else null, Effect.SOLDIER_SPRINTING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.railgun_charge_effect_id = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        eventPlayer.talent_trigger_times[Talent.JUGGERNAUT] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.JUGGERNAUT]
*/

def buy_dive_bomb():
    @Name "TALENT SYSTEM - - - [DIVE BOMB] [SUBROUTINE] Buy Dive Bomb"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.DIVE_BOMB)
        return
    if eventPlayer.talent_ranks[Talent.DIVE_BOMB] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.DIVE_BOMB)
        eventPlayer.talent_trigger_times[Talent.DIVE_BOMB] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.DIVE_BOMB]

def buy_cryogenics():
    @Name "TALENT SYSTEM - - - [TALENT 8: CRYOGENICS] [SUBROUTINE] Buy Cryogenics"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.CRYOGENICS)
        return
    if eventPlayer.talent_ranks[Talent.CRYOGENICS] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.CRYOGENICS)

def buy_helix():
    @Name "TALENT SYSTEM - - - [TALENT 28: HELIX ROCKETS] [SUBROUTINE] Buy Helix Rockets"

    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.talents_you_do_not_have.append(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.append(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.remove(Talent.CRYOGENICS)
        return
    if eventPlayer.talent_ranks[Talent.HELIX] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.remove(Talent.RAILGUN)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.CRYOGENICS)
        eventPlayer.talents_you_do_not_have.append(Talent.CRYOGENICS)
        eventPlayer.talent_trigger_times[Talent.HELIX] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.HELIX]
        eventPlayer.setSecondaryFireEnabled(true)

def buy_railgun():
    @Name "TALENT SYSTEM - - - [TALENT 9: RAILGUN] [SUBROUTINE] Buy Railgun"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.railgun_discharge)
        destroyEffect(eventPlayer.railgun_charge_effect_id)
        destroyEffect(eventPlayer.railgun_charge_sound)
        eventPlayer.railgun_discharge = 0
        eventPlayer.railgun_charge = 0
        recalculate_secondary_fire()
        eventPlayer.railgun_projectile_start = []
        eventPlayer.railgun_projectile_player_hit = []
        eventPlayer.talents_you_do_not_have.append(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.append(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        #eventPlayer.talents_you_do_not_have.append(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.remove(Talent.OVERCLOCK)
        eventPlayer.talents_you_do_not_have.remove(Talent.CRYOGENICS)
        return
    if eventPlayer.talent_ranks[Talent.RAILGUN] == 1:
        eventPlayer.talent_trigger_times[Talent.RAILGUN] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.RAILGUN]
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.OVERCLOCK)
            eventPlayer.possible_talents.append(Talent.CRYOGENICS)
        eventPlayer.railgun_projectile_start = []
        eventPlayer.railgun_projectile_player_hit = []
        chase(eventPlayer.railgun_discharge, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.railgun_charge = 0
        eventPlayer.setSecondaryFireEnabled(false)
        createEffect(getAllPlayers() if eventPlayer.railgun_charge == 100 else null, Effect.ANA_NANO_BOOSTED, Color.TEAM_1, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.railgun_charge_effect_id = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.railgun_charge == 100 else null, Effect.WINSTON_TESLA_CANNON_TARGET_SOUND, Color.TEAM_1, eventPlayer, 75, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.railgun_charge_sound = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.remove(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        #eventPlayer.talents_you_do_not_have.remove(Talent.BOMBARDMENT)
        eventPlayer.talents_you_do_not_have.append(Talent.OVERCLOCK)
        eventPlayer.talents_you_do_not_have.append(Talent.CRYOGENICS)

def buy_grim_reaper():
    @Name "TALENT SYSTEM - - - [TALENT 10: GRIM REAPER] [SUBROUTINE] Buy Grim Reaper"
    
    async(which_players_have_grim_reaper, AsyncBehavior.RESTART)
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.GRIM_REAPER)
        #Group B exclusivity: re-add Juggernaut here when it is re-enabled (kept commented while Juggernaut is disabled, to avoid offering an unbuyable talent)
        #eventPlayer.talents_you_do_not_have.append(Talent.JUGGERNAUT)
        return
    if eventPlayer.talent_ranks[Talent.GRIM_REAPER] == 1:
        eventPlayer.talent_trigger_times[Talent.GRIM_REAPER] = -talent_base_cooldowns[Talent.GRIM_REAPER]
        eventPlayer.talents_you_do_not_have.remove(Talent.GRIM_REAPER)
        #Group B exclusivity: harmless no-op while Juggernaut is disabled; keeps it out of the pool once re-enabled (mirrors buy_fireball)
        eventPlayer.talents_you_do_not_have.remove(Talent.JUGGERNAUT)
    if eventPlayer.talent_ranks[Talent.GRIM_REAPER] > 1:

    /*
    if eventPlayer.talent_ranks[Talent.GRIM_REAPER] > highest_grim_reaper_rank_in_match:
        highest_grim_reaper_rank_in_match = eventPlayer.talent_ranks[Talent.GRIM_REAPER]
    */

def buy_jetpack():
    @Name "TALENT SYSTEM - - - [TALENT 11: JETPACK] [SUBROUTINE] Buy Jetpack"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.stopAcceleration()
        stopChasingVariable(eventPlayer.jetpack_fuel)
        eventPlayer.jetpack_fuel = 100
        destroyEffect(eventPlayer.jetpack_sound_id)
        eventPlayer.talents_you_do_not_have.append(Talent.JETPACK)
        destroyEffect(eventPlayer.jetpack_beam_effect_id)
        return
    if eventPlayer.talent_ranks[Talent.JETPACK] == 1:
        eventPlayer.startAcceleration(Vector.UP, 10 + 0.275 * eventPlayer.jetpack_fuel if eventPlayer.is_using_ability[Talent.JETPACK] == true else 0, 3, Relativity.TO_PLAYER, AccelReeval.DIRECTION_RATE_AND_MAX_SPEED)
        eventPlayer.jetpack_fuel = 100
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.JETPACK] == true and eventPlayer.is_using_ability[Talent.STEALTH] == false else null, Effect.WRECKING_BALL_PILEDRIVER_FIRE_SOUND, Color.WHITE, eventPlayer, 25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.jetpack_sound_id = getLastCreatedEntity()
        
        createProjectileEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.JETPACK] == true and eventPlayer.is_using_ability[Talent.STEALTH] == false else null, Projectile.LUCIO_SONIC_AMPLIFIER, null, updateEveryFrame(eventPlayer.getEyePosition() + worldVector(vect(0, -0.5, -0.1), eventPlayer, Transform.ROTATION)), updateEveryFrame(directionTowards(eventPlayer.getEyePosition() + worldVector(vect(0, -0.5, -0.1), eventPlayer, Transform.ROTATION) + Vector.DOWN + vect(-1 * eventPlayer.getVelocity().x * 0.1, 0, -1 * eventPlayer.getVelocity().z * 0.1), eventPlayer.getEyePosition() + worldVector(vect(0, -0.5, -0.1), eventPlayer, Transform.ROTATION))), 0, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)

        eventPlayer.jetpack_beam_effect_id = getLastCreatedEntity()

        chase(eventPlayer.jetpack_fuel, 0 if eventPlayer.is_using_ability[Talent.JETPACK] == true else 100, rate=JETPACK_FUEL_DRAIN if eventPlayer.is_using_ability[Talent.JETPACK] == true else 10, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.talents_you_do_not_have.remove(Talent.JETPACK)

def buy_lifesteal_ammo():
    @Name "TALENT SYSTEM - - - [TALENT 12: LIFESTEAL AMMO] [SUBROUTINE] Buy Lifesteal Ammo"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.is_lifestealing)
        eventPlayer.is_lifestealing = 0
        destroyEffect(eventPlayer.lifesteal_sound_id)
        destroyEffect(eventPlayer.lifesteal_target_effect_id)
        destroyEffect(eventPlayer.lifesteal_self_effect_id)
        eventPlayer.talents_you_do_not_have.append(Talent.LIFESTEAL_AMMO)
        return
    if eventPlayer.talent_ranks[Talent.LIFESTEAL_AMMO] == 1:
        eventPlayer.is_lifestealing = 0
        chase(eventPlayer.is_lifestealing, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        createEffect(eventPlayer if eventPlayer.is_lifestealing > 0 else null, Effect.BAD_AURA_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.lifesteal_sound_id = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_lifestealing > 0 else null, Effect.HEAL_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.lifesteal_target_effect_id = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_lifestealing > 0 else null, Effect.HEAL_TARGET_ACTIVE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.lifesteal_self_effect_id = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.LIFESTEAL_AMMO)

def buy_health_regen():
    @Name "TALENT SYSTEM - - - [TALENT 13: HEALTH REGEN] [SUBROUTINE] Buy Health Regen"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_REGEN)
        destroyEffect(eventPlayer.health_regen_sound_id)
        destroyEffect(eventPlayer.player_temp_effects[64])
        stopHoT(eventPlayer.health_pool_id_or_hot_id[2])
        return
    if eventPlayer.talent_ranks[Talent.HEALTH_REGEN] == 1:
        createEffect(eventPlayer if eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) and eventPlayer.isAlive() else null, Effect.SPARKLES_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.health_regen_sound_id = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.getHealthOfType(Health.NORMAL) < eventPlayer.getMaxHealthOfType(Health.NORMAL) and eventPlayer.isAlive() else null, Effect.SPARKLES, Color.PURPLE if eventPlayer.is_using_ability[Talent.STEALTH] == true else Color.ORANGE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.player_temp_effects[64] = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_REGEN)
        async(health_regen_heal_over_time, AsyncBehavior.NOOP)

def buy_health_potions():
    @Name "TALENT SYSTEM - - - [TALENT 14: HEALTH POTIONS] [SUBROUTINE] Buy Health Potions"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.amount_of_health_potions = 0
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_POTIONS)
        #disabled because poison vials are disabled
        /*eventPlayer.talents_you_do_not_have.append(Talent.POISON_VIALS)*/
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] == 1:
        eventPlayer.talent_trigger_times[Talent.HEALTH_POTIONS] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.HEALTH_POTIONS]
        eventPlayer.amount_of_health_potions = 3
        eventPlayer.possible_talents.remove(Talent.POISON_VIALS)
        #eventPlayer.talents_you_do_not_have.remove(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.ALCHEMIST)

def buy_explosive_ammo():
    @Name "TALENT SYSTEM - - - [TALENT 16: EXPLOSIVE_AMMO] [SUBROUTINE] Buy Explosive Ammo"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.EXPLOSIVE_AMMO)
        return
    if eventPlayer.talent_ranks[Talent.EXPLOSIVE_AMMO] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.EXPLOSIVE_AMMO)

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
        eventPlayer.talent_trigger_times[Talent.SHADOWSTEP] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.SHADOWSTEP]
        eventPlayer.talents_you_do_not_have.remove(Talent.SHADOWSTEP)

def buy_burning_soul():
    @Name "TALENT SYSTEM - - - [TALENT 19: BURNING SOUL] [SUBROUTINE] Buy Burning Soul"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.burning_soul_orb_timer)
        eventPlayer.burning_soul_orb_timer = 0
        eventPlayer.talents_you_do_not_have.append(Talent.BURNING_SOUL)
        destroyEffect(eventPlayer.burning_soul_particle_effect_id)
        destroyEffect(eventPlayer.burning_soul_material_effect_id)
        return
    if eventPlayer.talent_ranks[Talent.BURNING_SOUL] == 1:
        createEffect(getAllPlayers() if "{0}".format(eventPlayer.isCommunicatingEmote()) == "false" else null if eventPlayer.isUsingAbility1() else getAllPlayers().exclude(eventPlayer), Effect.ASHE_DYNAMITE_BURNING_PARTICLE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.burning_soul_particle_effect_id = getLastCreatedEntity()
        createEffect(null if eventPlayer.isUsingAbility1() or eventPlayer.is_using_ability[Talent.STEALTH] else getAllPlayers(), Effect.ASHE_DYNAMITE_BURNING_MATERIAL, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.burning_soul_material_effect_id = getLastCreatedEntity()
        chase(eventPlayer.burning_soul_orb_timer, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        eventPlayer.talents_you_do_not_have.remove(Talent.BURNING_SOUL)

def buy_berserker():
    @Name "TALENT SYSTEM - - - [TALENT 20: BERSERKER] [SUBROUTINE] Buy Berserker"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.BERSERKER)
        eventPlayer.talents_you_do_not_have.remove(Talent.BLOODTHIRST)
        #Group A exclusivity: removing Berserker frees the Ultimate button, so Immunity becomes available again
        eventPlayer.talents_you_do_not_have.append(Talent.IMMUNITY)
        destroyEffect(eventPlayer.berserker_team1_effect_id)
        destroyEffect(eventPlayer.berserker_team2_effect_id)
        destroyEffect(eventPlayer.berserker_sound_id)
        return
    if eventPlayer.talent_ranks[Talent.BERSERKER] == 1:
        eventPlayer.talent_trigger_times[Talent.BERSERKER] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.BERSERKER]
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.BLOODTHIRST)
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.berserker_team1_effect_id = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE, Color.TEAM_2, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.berserker_team2_effect_id = getLastCreatedEntity()
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.BERSERKER] == true else null, Effect.WINSTON_PRIMAL_RAGE_SOUND, Color.WHITE, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.berserker_sound_id = getLastCreatedEntity()
        eventPlayer.talents_you_do_not_have.remove(Talent.BERSERKER)
        #Group A exclusivity: Berserker and Immunity share the Ultimate button, so owning one removes the other from the pool
        eventPlayer.talents_you_do_not_have.remove(Talent.IMMUNITY)
        eventPlayer.talents_you_do_not_have.append(Talent.BLOODTHIRST)

def buy_fireball():
    @Name "TALENT SYSTEM - - - [TALENT 21: FIREBALL] [SUBROUTINE] Buy Fireball"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.fireball_position = null
        #Disabled because Juggernaut disabled
        #eventPlayer.talents_you_do_not_have.append(Talent.JUGGERNAUT)
        eventPlayer.talents_you_do_not_have.append(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.append(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.append(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.remove(Talent.PYROMANIAC)
        return
    if eventPlayer.talent_ranks[Talent.FIREBALL] == 1:
        eventPlayer.talent_trigger_times[Talent.FIREBALL] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.FIREBALL]
        eventPlayer.fireball_position = null
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.PYROMANIAC)
        eventPlayer.talents_you_do_not_have.remove(Talent.FIREBALL)
        eventPlayer.talents_you_do_not_have.remove(Talent.HELIX)
        eventPlayer.talents_you_do_not_have.remove(Talent.RAILGUN)
        eventPlayer.talents_you_do_not_have.append(Talent.PYROMANIAC)

def buy_ignore_pain():
    @Name "TALENT SYSTEM - - - [TALENT 22: IGNORE PAIN] [SUBROUTINE] Buy Ignore Pain"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.ignore_pain_damage_resisted = 0
        #eventPlayer.talents_you_do_not_have.append(Talent.ADRENALINE_RUSH)
        eventPlayer.talents_you_do_not_have.append(Talent.IGNORE_PAIN)
        destroyEffect(eventPlayer.ignore_pain_effect_id)
        destroyEffect(eventPlayer.ignore_pain_sound_id)
        return
    if eventPlayer.talent_ranks[Talent.IGNORE_PAIN] == 1:
        eventPlayer.possible_talents.remove(Talent.IGNORE_PAIN)
        eventPlayer.talents_you_do_not_have.remove(Talent.IGNORE_PAIN)
        #eventPlayer.talents_you_do_not_have.remove(Talent.ADRENALINE_RUSH)
        eventPlayer.ignore_pain_damage_resisted = 0
        createEffect(getAllPlayers() if eventPlayer.is_using_ability[Talent.IGNORE_PAIN] == true else null, Effect.WRECKING_BALL_ADAPTIVE_SHIELD_TARGET, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.ignore_pain_effect_id = getLastCreatedEntity()
        createEffect(eventPlayer if eventPlayer.is_using_ability[Talent.IGNORE_PAIN] == true else null, Effect.WRECKING_BALL_ADAPTIVE_SHIELD_TARGET_SOUND, Color.TEAM_1, eventPlayer.getPosition(), eventPlayer.ignore_pain_volume, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.ignore_pain_sound_id = getLastCreatedEntity()

def buy_bandage():
    @Name "TALENT SYSTEM - - - [Bandage] [SUBROUTINE] Buy Bandage"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        stopChasingVariable(eventPlayer.bandage_progress)
        eventPlayer.bandage_progress = 0
        eventPlayer.talents_you_do_not_have.append(Talent.BANDAGE)
        return
    if eventPlayer.talent_ranks[Talent.BANDAGE] == 1:
        eventPlayer.talent_trigger_times[Talent.BANDAGE] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.BANDAGE]
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
/*
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
        eventPlayer.amount_of_health_potions = 0
        eventPlayer.talents_you_do_not_have.append(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.append(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.POISON_VIALS] == 1:
        eventPlayer.talent_trigger_times[Talent.POISON_VIALS] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.POISON_VIALS]
        eventPlayer.talents_you_do_not_have.remove(Talent.HEALTH_POTIONS)
        eventPlayer.talents_you_do_not_have.remove(Talent.POISON_VIALS)
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        eventPlayer.amount_of_health_potions = 3
        eventPlayer.possible_talents.remove(14)
        if len(eventPlayer.bought_talents) < 5:
            eventPlayer.possible_talents.append(Talent.ALCHEMIST)
        eventPlayer.poison_vial_effects = []
        eventPlayer.poison_vial_clouds_spawned = 0
        chase(eventPlayer.time_since_poison_vial_exploded, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
*/
def buy_alchemist():
    @Name "TALENT SYSTEM - - - [TALENT 32: CRAZY ALCHEMIST] [SUBROUTINE] Buy Crazy Alchemist"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.ALCHEMIST)
        return
    if eventPlayer.talent_ranks[Talent.ALCHEMIST] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.ALCHEMIST)
/*
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
        eventPlayer.possible_talents.remove(Talent.BOMBARDMENT)
        eventPlayer.setMaxAmmo(0, 0)
        eventPlayer.setProjectileSpeed(70)
*/
def buy_gigachad():
    @Name "TALENT SYSTEM - - - [GIGACHAD] [SUBROUTINE] Buy GIGACHAD"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.GIGACHAD)
        #if eventPlayer.talent_ranks[Talent.IGNORE_PAIN] == 0:
            #eventPlayer.talents_you_do_not_have.append(Talent.ADRENALINE_RUSH)
        #Health
        eventPlayer.stats[Stat.HEALTH] = 200
        #Speed
        #eventPlayer.stats[Stat.SPEED] = 100
        #Size
        eventPlayer.stats[Stat.SIZE] = 1
        #Knockback Received
        eventPlayer.stats[Stat.KNOCKBACK_RECEIVED] = 100
        eventPlayer.startScalingSize(eventPlayer.stats[Stat.SIZE], false)
        #Voice
        eventPlayer.stats[Stat.VOICE] = 1
        eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[Stat.VOICE], false)
        return
    if eventPlayer.talent_ranks[Talent.GIGACHAD] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.GIGACHAD)
        #eventPlayer.talents_you_do_not_have.remove(Talent.ADRENALINE_RUSH)
    #Health
    eventPlayer.stats[Stat.HEALTH] += 40
    #Speed
    #eventPlayer.stats[Stat.SPEED] -= 2
    #Size
    eventPlayer.stats[Stat.SIZE] += 0.07
    eventPlayer.startScalingSize(eventPlayer.stats[Stat.SIZE], false)
    #Voice
    eventPlayer.stats[Stat.VOICE] -= 0.05
    eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[Stat.VOICE], false)
    #Knockback Received
    #eventPlayer.stats[Stat.KNOCKBACK_RECEIVED] -= 20

/*    
def buy_gunslinger():
    @Name "TALENT SYSTEM - - - [GUNSLINGER] [SUBROUTINE] Buy GUNSLINGER"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.talents_you_do_not_have.append(Talent.GUNSLINGER)
        #eventPlayer.talents_you_do_not_have.append(Talent.BOMBARDMENT)
        eventPlayer.setMaxAmmo(0, 30)
        return
    if eventPlayer.talent_ranks[Talent.GUNSLINGER] == 1:
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.talents_you_do_not_have.remove(Talent.GUNSLINGER)
        #eventPlayer.talents_you_do_not_have.remove(Talent.BOMBARDMENT)
        #eventPlayer.possible_talents.remove(Talent.BOMBARDMENT)
        eventPlayer.setMaxAmmo(0, 6)
        eventPlayer.setAmmo(0, 6)
*/

#def buy_adrenaline_rush():
    #@Name "TALENT SYSTEM - - - [ADRENALINE_RUSH] [SUBROUTINE] Buy ADRENALINE_RUSH"
/*    
def buy_adrenaline_rush():
    @Name "TALENT SYSTEM - - - [ADRENALINE RUSH] [SUBROUTINE] Buy Adrenaline Rush"
    
    if eventPlayer.replacing_talent_show_bought_talents == true:
        eventPlayer.talents_you_do_not_have.append(Talent.ADRENALINE_RUSH)
        eventPlayer.talents_you_do_not_have.append(Talent.GIGACHAD)
        eventPlayer.talents_you_do_not_have.append(Talent.IGNORE_PAIN)
        stopChasingVariable(eventPlayer.adrenaline_rush_value)
        eventPlayer.adrenaline_rush_value = 100
        destroyEffect(eventPlayer.adrenaline_rush_effect_id)
        destroyEffect(eventPlayer.adrenaline_rush_effect_id2)
        destroyEffect(eventPlayer.adrenaline_rush_effect_id3)
        eventPlayer.setAbility1Enabled(true)
        return
    if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] == 1:
        eventPlayer.talents_you_do_not_have.remove(Talent.ADRENALINE_RUSH)
        eventPlayer.talents_you_do_not_have.remove(Talent.GIGACHAD)
        eventPlayer.talents_you_do_not_have.remove(Talent.IGNORE_PAIN)
        eventPlayer.adrenaline_rush_value = 100
        eventPlayer.setAbility1Enabled(false)
        chase(eventPlayer.adrenaline_rush_value, 100, rate=ADRENALINE_RUSH_DECAY_RATE, ChaseReeval.DESTINATION_AND_RATE)
        #Stage 1 effect
        createEffect(getAllPlayers() if eventPlayer.adrenaline_rush_value > 100 and not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.SOLDIER_SPRINTING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.adrenaline_rush_effect_id = getLastCreatedEntity()
        #Stage 2 effect
        createEffect(getAllPlayers() if eventPlayer.adrenaline_rush_value > 120 and not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.SOLDIER_SPRINTING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.adrenaline_rush_effect_id2 = getLastCreatedEntity()
        #Stage 3 effect
        createEffect(getAllPlayers() if eventPlayer.adrenaline_rush_value > 140 and not eventPlayer.is_using_ability[Talent.STEALTH] else null, Effect.SOLDIER_SPRINTING, Color.TEAM_1, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.adrenaline_rush_effect_id3 = getLastCreatedEntity()
*/