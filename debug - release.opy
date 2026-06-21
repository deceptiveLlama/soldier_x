#!mainFile "soldier_x.opy"

#--- Debug global defineMember (global_variable[100-105]) ---
#!defineMember debug_srv_load_sum global_variable[100]
#!defineMember debug_srv_load_timer global_variable[101]
#!defineMember debug_srv_load_sample_count global_variable[102]
#!defineMember debug_srv_load_avg global_variable[103]
#!defineMember debug_srv_load_avg_init global_variable[104]
#!defineMember debug_srv_load_avg_10s global_variable[105]

#--- Workshop Settings (only active when this file is included) ---
rule "DEBUG - - - Init Release Settings":
    faster_testing = createWorkshopSettingBool("02. Testing", "Faster Testing", false, 1)

#rule "DEBUG (For Spectator Only)":

    #hudText(hostPlayer, "Srv Load: {0} {1} {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), "Real Avg: Init: {0} | First Min: {1} | Last 10s: {2}".format(debug_srv_load_avg_init, debug_srv_load_avg, debug_srv_load_avg_10s), "Texts: {0} | Effects: {1}".format(getNumberOfTextIds(), getNumberOfEntityIds()), HudPosition.ACTUALLY_LEFT, 0, Color.RED if getAverageServerLoad() > 150 else Color.YELLOW if getAverageServerLoad() >= 100 else Color.LIME_GREEN if getAverageServerLoad() < 100 else null, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)


rule "DEBUG - - - Real Server Load Average":
    #--- Phase 1: Init (sample until all bots have respawned) ---
    while getNumberOfPlayers(Team.ALL) < amount_of_bots_and_players \
        or len([p for p in getAllPlayers() if p.isDummy() and not p.reaper_has_respawned_once]) > 0:
        debug_srv_load_sample_count += 1
        debug_srv_load_sum += getServerLoad()
        debug_srv_load_avg_init = round(debug_srv_load_sum / debug_srv_load_sample_count)
        wait()

    #--- Reset for phase 2 ---
    debug_srv_load_sum = 0
    debug_srv_load_sample_count = 0

    #--- Phase 2: Running (sample for 60 seconds) ---
    debug_srv_load_timer = getTotalTimeElapsed()
    while getTotalTimeElapsed() - debug_srv_load_timer < 60:
        debug_srv_load_sample_count += 1
        debug_srv_load_sum += getServerLoad()
        debug_srv_load_avg = round(debug_srv_load_sum / debug_srv_load_sample_count)
        wait()
    #--- Phase 3: Continuous rolling 10-second average ---
    while true:
        debug_srv_load_sum = 0
        debug_srv_load_sample_count = 0
        debug_srv_load_timer = getTotalTimeElapsed()
        while getTotalTimeElapsed() - debug_srv_load_timer < 10:
            debug_srv_load_sample_count += 1
            debug_srv_load_sum += getServerLoad()
            debug_srv_load_avg_10s = round(debug_srv_load_sum / debug_srv_load_sample_count)
            wait()
    debug_srv_load_timer = 0

globalvar debug_bandage = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Bandage", 0, 0, 5, 0)
globalvar debug_berserker = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Berserker", 0, 0, 5, 0)
#globalvar debug_bloodthirst = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Bloodthirst", 0, 0, 5, 0)
#globalvar debug_bombardment = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Bombardment", 0, 0, 5, 0)
globalvar debug_burning_soul = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Burning Soul", 0, 0, 5, 0)
globalvar debug_cryogenics = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Cryogenics", 0, 0, 5, 0)
globalvar debug_cybernetics = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Cybernetics", 0, 0, 5, 0)
globalvar debug_dive_bomb = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Dive Bomb", 0, 0, 5, 0)
globalvar debug_fireball = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Fireball", 0, 0, 5, 0)
globalvar debug_gigachad = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Gigachad", 0, 0, 5, 0)
#globalvar debug_gunslinger = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Gunslinger", 0, 0, 5, 0)
globalvar debug_health_potions = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Health Potions", 0, 0, 5, 0)
globalvar debug_health_regen = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Health Regen", 0, 0, 5, 0)
globalvar debug_ignite = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Ignite", 0, 0, 5, 0)
globalvar debug_ignore_pain = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Ignore Pain", 0, 0, 5, 0)
globalvar debug_jetpack = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Jetpack", 0, 0, 5, 0)
#globalvar debug_juggernaut = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Juggernaut", 0, 0, 5, 0)
globalvar debug_lifesteal_ammo = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Lifesteal Ammo", 0, 0, 5, 0)
globalvar debug_overclock = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Overclock", 0, 0, 5, 0)
globalvar debug_poisonous_dagger = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Poisonous Dagger", 0, 0, 5, 0)
globalvar debug_grim_reaper = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Grim_reaper", 0, 0, 5, 0)
globalvar debug_immunity = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Immunity", 0, 0, 5, 0)
globalvar debug_pyromaniac = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Pyromaniac", 0, 0, 5, 0)
globalvar debug_railgun = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Railgun", 0, 0, 5, 0)
#globalvar debug_adrenaline_rush = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Adrenaline Rush", 0, 0, 5, 0)
globalvar debug_stealth = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Stealth", 0, 0, 5, 0)
globalvar debug_shadowstep = createWorkshopSettingInt("03. Talents (Use at your own risk)", "Shadowstep", 0, 0, 5, 0)

globalvar debug_reload_for_xp = createWorkshopSettingBool("02. Testing", "Hold Reload for XP", false, 0)

rule "DEBUG - - - Hold Reload For XP [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    #@Condition hostPlayer == eventPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.can_enter_shop == false
    @Condition eventPlayer.browsing_shop == false
    @Condition debug_reload_for_xp == true
    
    if eventPlayer.experience_current < eventPlayer.experience_max:
        eventPlayer.experience_current += eventPlayer.experience_max/25
    wait(0.02)
    if RULE_CONDITION:
        goto RULE_START

rule "DEBUG - - - Activate Admin Rights [DEFAULT: OFF]":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    #@Condition hostPlayer == eventPlayer

    buy_debug_talents()

def buy_debug_talents():
    /*
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
        */
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
    /*
    if debug_adrenaline_rush > 0:
        eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] = 1
        eventPlayer.bought_talents.append(Talent.ADRENALINE_RUSH)
        buy_adrenaline_rush()
        
        eventPlayer.talent_ranks[Talent.ADRENALINE_RUSH] = debug_adrenaline_rush
        eventPlayer.amount_of_talents_purchased += debug_adrenaline_rush
        #Size
        eventPlayer.stats[Stat.SIZE] = 1 + (debug_adrenaline_rush * 0.035)
        eventPlayer.startScalingSize(eventPlayer.stats[Stat.SIZE], false)
        #Voice
        eventPlayer.stats[Stat.VOICE] = 1 + (debug_adrenaline_rush * 0.075)
        eventPlayer.startModifyingVoicelinePitch(eventPlayer.stats[Stat.VOICE], false)
    */
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
        /*
    if debug_bloodthirst > 0:
        eventPlayer.talent_ranks[Talent.BLOODTHIRST] = 1
        eventPlayer.bought_talents.append(Talent.BLOODTHIRST)
        buy_bloodthirst()
        eventPlayer.talent_ranks[Talent.BLOODTHIRST] = debug_bloodthirst
        eventPlayer.amount_of_talents_purchased += debug_bloodthirst
        */
    if debug_immunity > 0:
        eventPlayer.talent_ranks[Talent.IMMUNITY] = 1
        eventPlayer.bought_talents.append(Talent.IMMUNITY)
        buy_immunity()
        eventPlayer.talent_ranks[Talent.IMMUNITY] = debug_immunity
        eventPlayer.amount_of_talents_purchased += debug_immunity
        /*
    if debug_juggernaut > 0:
        eventPlayer.talent_ranks[Talent.JUGGERNAUT] = 1
        eventPlayer.bought_talents.append(Talent.JUGGERNAUT)
        buy_juggernaut()
        eventPlayer.talent_ranks[Talent.JUGGERNAUT] = debug_juggernaut
        eventPlayer.amount_of_talents_purchased += debug_juggernaut
        */
    if debug_fireball > 0:
        eventPlayer.talent_ranks[Talent.FIREBALL] = 1
        eventPlayer.bought_talents.append(Talent.FIREBALL)
        buy_fireball()
        eventPlayer.talent_ranks[Talent.FIREBALL] = debug_fireball
        eventPlayer.amount_of_talents_purchased += debug_fireball
    if debug_grim_reaper > 0:
        eventPlayer.talent_ranks[Talent.GRIM_REAPER] = 1
        eventPlayer.bought_talents.append(Talent.GRIM_REAPER)
        buy_grim_reaper()
        eventPlayer.talent_ranks[Talent.GRIM_REAPER] = debug_grim_reaper
        eventPlayer.amount_of_talents_purchased += debug_grim_reaper
    if debug_gigachad > 0:
        eventPlayer.bought_talents.append(Talent.GIGACHAD)
        for eventPlayer.i in range(debug_gigachad):
            eventPlayer.talent_ranks[Talent.GIGACHAD] += 1
            buy_gigachad()
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
    if debug_pyromaniac > 0:
        eventPlayer.talent_ranks[Talent.PYROMANIAC] = 1
        eventPlayer.bought_talents.append(Talent.PYROMANIAC)
        buy_pyromaniac()
        eventPlayer.talent_ranks[Talent.PYROMANIAC] = debug_pyromaniac
        eventPlayer.amount_of_talents_purchased += debug_pyromaniac
    if debug_health_potions > 0:
        eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] = 1
        eventPlayer.bought_talents.append(Talent.HEALTH_POTIONS)
        buy_health_potions()
        eventPlayer.talent_ranks[Talent.HEALTH_POTIONS] = debug_health_potions
        eventPlayer.amount_of_talents_purchased += debug_health_potions
    if debug_cybernetics > 0:
        eventPlayer.talent_ranks[Talent.CYBERNETICS] = 1
        eventPlayer.bought_talents.append(Talent.CYBERNETICS)
        buy_cybernetics()
        eventPlayer.talent_ranks[Talent.CYBERNETICS] = debug_cybernetics
        eventPlayer.amount_of_talents_purchased += debug_cybernetics
    if debug_shadowstep > 0:
        eventPlayer.talent_ranks[Talent.SHADOWSTEP] = 1
        eventPlayer.bought_talents.append(Talent.SHADOWSTEP)
        buy_shadowstep()
        eventPlayer.talent_ranks[Talent.SHADOWSTEP] = debug_shadowstep
        eventPlayer.amount_of_talents_purchased += debug_shadowstep
    if debug_health_regen > 0:
        eventPlayer.talent_ranks[Talent.HEALTH_REGEN] = 1
        eventPlayer.bought_talents.append(Talent.HEALTH_REGEN)
        buy_health_regen()
        eventPlayer.talent_ranks[Talent.HEALTH_REGEN] = debug_health_regen
        eventPlayer.amount_of_talents_purchased += debug_health_regen
        







    