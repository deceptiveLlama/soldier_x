#!mainFile "soldier_x.opy"

globalvar xp_received_message

subroutine activate_xp_boost

rule "XP SYSTEM - - - XP Orbs":
    @Condition len(xp_orbs) > 0 == true

    #debug_loop_count = 0
        while len(xp_orbs) > 7:
            #xp_orbs_current_index = 0
            xp_orbs_current_index = xp_orbs.index(sorted(xp_orbs, lambda orb: orb[Orb.TIMESTAMP])[0])
            #xp_orbs_current_index = sorted(xp_orbs)[Orb.TIMESTAMP].index(xp_orbs[0])
            #xp_orbs_current_index = sorted(xp_orbs).index
            #xp_orbs_current_index = sorted(xp_orbs, lambda current: xp_orbs[current][Orb.TIMESTAMP])[0]
            #xp_orb_to_remove_selector = sorted(xp_orbs, lambda current: xp_orbs[current][Orb.TIMESTAMP])[0]
            #for xp_orb_to_remove_selector in range(0, len(xp_orbs), 1):
                #if xp_orbs[xp_orb_to_remove_selector][Orb.TIMESTAMP] < xp_orbs[xp_orbs_current_index][Orb.TIMESTAMP]:
                    #xp_orbs_current_index = xp_orb_to_remove_selector
            destroyEffect(xp_orbs[xp_orbs_current_index][Orb.ORB_EFFECT_ID])
            destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_SOUND_EFFECT_ID])
            destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_EFFECT_ID])
            del xp_orbs[xp_orbs_current_index]
            wait()
    
        for xp_orbs_current_index in range(0, len(xp_orbs), 1):

            #debug_loop_count += 1

            if [player for player in getRealPlayersInRadius(xp_orbs[xp_orbs_current_index][Orb.POSITION], 2, Team.ALL, LosCheck.SURFACES) if player.isDummy() == false and player.browsing_shop == false and player != xp_orbs[xp_orbs_current_index][Orb.OWNING_PLAYER]] > 0:

                player_picking_up_orb = [player for player in getRealClosestPlayer(xp_orbs[xp_orbs_current_index][Orb.POSITION], Team.ALL) if player.isDummy() == false and player.browsing_shop == false and player != xp_orbs[xp_orbs_current_index][Orb.OWNING_PLAYER]] 
                
                destroyEffect(xp_orbs[xp_orbs_current_index][Orb.ORB_EFFECT_ID])
                playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, player_picking_up_orb, 75)
                playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, xp_orbs[xp_orbs_current_index][Orb.COLOR], xp_orbs[xp_orbs_current_index][Orb.POSITION], 1)

                if player_picking_up_orb.experience_current < player_picking_up_orb.experience_max:

                    xp_received_message = xp_orbs[xp_orbs_current_index][Orb.XP_AMOUNT]
                    smallMessage(player_picking_up_orb, "{0} +{1} XP!".format('<TXC0000000004C5D2>', xp_received_message))

                    player_picking_up_orb.experience_current += xp_orbs[xp_orbs_current_index][Orb.XP_AMOUNT] * player_picking_up_orb.stats[Stat.XP]

                else:

                    smallMessage(player_picking_up_orb, "{0} XP Full!".format(iconString(Icon.WARNING)))

                if xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE] == true and xp_orbs[xp_orbs_current_index][Orb.TIMESTAMP] >= getTotalTimeElapsed() - BURNING_SOUL_ORB_DURATION:

                    player_picking_up_orb.applyImpulse(angleToDirection(horizontalAngleOfDirection(directionTowards(xp_orbs[xp_orbs_current_index][Orb.POSITION], player_picking_up_orb.getEyePosition() + Vector.DOWN)), min(verticalAngleOfDirection(directionTowards(xp_orbs[xp_orbs_current_index][Orb.POSITION], player_picking_up_orb.getEyePosition() + Vector.DOWN)), -30)), 12.5 * (player_picking_up_orb.stats[Stat.KNOCKBACK_RECEIVED] / 100), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

                    #wait to see knockback effect before getting killed
                    wait(0.032)

                    damage(player_picking_up_orb, xp_orbs[xp_orbs_current_index][Orb.OWNING_PLAYER], BURNING_SOUL_ORB_DAMAGE)
                
                    xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE] = false
                    destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_SOUND_EFFECT_ID])
                    destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_EFFECT_ID])
                    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION, Color.TEAM_2, xp_orbs[xp_orbs_current_index][Orb.POSITION], 1)
                    playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_2, xp_orbs[xp_orbs_current_index][Orb.POSITION], 100)

                if player_picking_up_orb.talent_ranks[Talent.ALCHEMIST] > 0 and player_picking_up_orb.amount_of_health_potions < 3 and ALCHEMIST_PROC_CHANCE >= 66:
                    if player_picking_up_orb.is_hacked == true:
                        player_picking_up_orb.hack_error_pending = true
                    else:
                        if player_picking_up_orb.talent_ranks[Talent.HEALTH_POTIONS] > 0:
                            player_picking_up_orb.health_potion_cooldown_memory = getTotalTimeElapsed() - player_picking_up_orb.talent_trigger_times[Talent.HEALTH_POTIONS]
                            player_picking_up_orb.talent_trigger_times[Talent.HEALTH_POTIONS] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.HEALTH_POTIONS] - player_picking_up_orb.talent_ranks[Talent.ALCHEMIST]
                        #elif player_picking_up_orb.talent_ranks[Talent.POISON_VIALS] > 0:
                            #player_picking_up_orb.health_potion_cooldown_memory = getTotalTimeElapsed() - player_picking_up_orb.talent_trigger_times[Talent.POISON_VIALS]
                            #player_picking_up_orb.talent_trigger_times[Talent.POISON_VIALS] = getTotalTimeElapsed() - talent_base_cooldowns[Talent.POISON_VIALS] - player_picking_up_orb.talent_ranks[Talent.ALCHEMIST]
                        wait()
                        smallMessage(player_picking_up_orb, "{0} +1 {1}".format(iconString(Icon.RADIOACTIVE), "Health Potion!" if player_picking_up_orb.talent_ranks[Talent.HEALTH_POTIONS] > 0 else "Poison Vial!"))

                if player_picking_up_orb.talent_ranks[Talent.SOUL_HARVEST] > 0:
                    if player_picking_up_orb.is_hacked == true:
                        player_picking_up_orb.hack_error_pending = true
                    else:
                        heal(player_picking_up_orb, player_picking_up_orb, SOUL_HARVEST_HEALING)
                        playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_IMPACT_SOUND, Color.WHITE, player_picking_up_orb.getPosition(), 100)
                    
                if player_picking_up_orb.talent_ranks[Talent.SHADOWSTEP] > 0:
                    if player_picking_up_orb.is_hacked == true:
                        player_picking_up_orb.hack_error_pending = true
                    else:
                        player_picking_up_orb.talent_trigger_times[Talent.SHADOWSTEP] = player_picking_up_orb.talent_trigger_times[Talent.SHADOWSTEP] - player_picking_up_orb.talent_ranks[Talent.SHADOWSTEP] * 2

                destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_SOUND_EFFECT_ID])
                destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_EFFECT_ID])
                del xp_orbs[xp_orbs_current_index]
                if RULE_CONDITION:
                    wait()
                    goto RULE_START
            
            elif xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE] == true and xp_orbs[xp_orbs_current_index][Orb.TIMESTAMP] < getTotalTimeElapsed() - BURNING_SOUL_ORB_DURATION:
                #print("removed explosive property")
                xp_orbs[xp_orbs_current_index][Orb.EXPLOSIVE] = false
                destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_SOUND_EFFECT_ID])
                destroyEffect(xp_orbs[xp_orbs_current_index][Orb.BURNING_SOUL_EFFECT_ID])
                playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION, Color.TEAM_2, xp_orbs[xp_orbs_current_index][Orb.POSITION] + (Vector.DOWN * 0.25), 1)
                playEffect(getAllPlayers(), DynamicEffect.JUNKRAT_FRAG_LAUNCHER_EXPLOSION_SOUND, Color.TEAM_2, xp_orbs[xp_orbs_current_index][Orb.POSITION], 100)

            wait(0.12 / len(xp_orbs))
        if RULE_CONDITION:
            goto RULE_START

def activate_xp_boost():
    @Name "XP SYSTEM - - - [SUBROUTINE] Activate XP Boost"

    eventPlayer.xp_boost_is_active = true
    chase(eventPlayer.experience_current, eventPlayer.experience_max, rate=eventPlayer.experience_max / 60, ChaseReeval.DESTINATION_AND_RATE)
    waitUntil((eventPlayer.skipped_a_talent == false and eventPlayer.amount_of_talents_purchased > 0 and eventPlayer.amount_of_talents_purchased < 25 and eventPlayer.amount_of_talents_purchased > (player_with_most_talents.amount_of_talents_purchased - 5)) or eventPlayer.xp_boost_is_active == false, 99999)
    eventPlayer.xp_boost_is_active = false
    stopChasingVariable(eventPlayer.experience_current)

rule "XP SYSTEM - - - Level Up":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.experience_current >= eventPlayer.experience_max
    
    eventPlayer.can_enter_shop = true
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    if eventPlayer.amount_of_talents_purchased < 25:
        bigMessage(eventPlayer, "{0} Level Up!".format(('<TX00000004C5D2>')))

rule "XP SYSTEM - - - Earned Elimination":
    @Event playerEarnedElimination
    @Condition not eventPlayer.isDummy()
    
    if eventPlayer.experience_current < eventPlayer.experience_max:
        eventPlayer.experience_current += victim.experience_max * 0.075 * eventPlayer.stats[Stat.XP]
    #if eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] > 0 and attacker != victim:
        #eventPlayer.adrenaline_rush_value = ADRENALINE_RUSH_MAX_SPEED