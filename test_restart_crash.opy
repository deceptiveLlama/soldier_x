settings {
    "main": {
        "description": "Start Rule RESTART crash test"
    },
    "lobby": {
        "ffaSlots": 1,
        "spectatorSlots": 0
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": ["workshopChamber"],
            "scoreToWin": 100
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableKillFeed": false
        }
    },
    "heroes": {
        "allTeams": {
        }
    }
}


playervar test
playervar test_call_interval = 0.050
playervar test_blink = 0
playervar test_mode = 1
playervar test_restart_count = 0
playervar test_restart_count_2 = 0
playervar test_wait_duration = 0.05

subroutine sub_with_wait
subroutine sub_with_wait_2
subroutine sub_without_wait


def sub_with_wait():
    @Name "Subroutine WITH Wait (1)"
    wait(eventPlayer.test_wait_duration)

def sub_with_wait_2():
    @Name "Subroutine WITH Wait (2)"
    wait(eventPlayer.test_wait_duration)


def sub_without_wait():
    @Name "Subroutine WITHOUT Wait"
    eventPlayer.test = ""


rule "Setup":
    setMatchTime(0)

rule "Player Init + HUD":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()

    hudText(eventPlayer, \
        null, \
        "{0}".format("Calling [Start Rule], [If already executing]: [Restart Rule].\n(Subroutine only contains a 2 sec wait)" if eventPlayer.test_mode == 1 else "Calling [Start Rule], [If already executing]: [Restart Rule].\n(Subroutine does not contain a wait)"), \
        null, \
        HudPosition.LEFT, 0, \
        Color.WHITE, Color.WHITE, Color.WHITE, \
        HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, \
        "Server Load: {0} | Avg: {1} | Peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), \
        null, \
        HudPosition.TOP, 0, \
        Color.WHITE, \
        Color.RED if getServerLoad() > 200 else Color.YELLOW if getServerLoad() > 100 else Color.WHITE, \
        Color.WHITE, \
        HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, \
        "Mode {0}: {1} | Frequency: {2}s {3} | Time: {4}s".format( \
            eventPlayer.test_mode, \
            "RESTART + Wait({0})".format(eventPlayer.test_wait_duration) if eventPlayer.test_mode == 1 else "RESTART + No Wait", \
            eventPlayer.test_call_interval, \
            "(Will crash!)" if eventPlayer.test_mode == 1 else "", \
            round(getTotalTimeElapsed())), \
        null, \
        HudPosition.TOP, 1, \
        Color.WHITE, Color.WHITE, Color.WHITE, \
        HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, null, \
        "[INTERACT] Increase frequency | [CROUCH] Switch mode | [RELOAD] Change wait duration", \
        HudPosition.TOP, 2, \
        Color.WHITE, Color.WHITE, Color.YELLOW, \
        HudReeval.VISIBILITY, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, null, \
        "{0}".format("● Restart Subroutine" if eventPlayer.test_blink > 0 else ""), \
        HudPosition.TOP, 3, \
        Color.WHITE, Color.WHITE, Color.LIME_GREEN, \
        HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, \
        "{0}".format("This will crash!\n(Faster frequency = More likely)" if eventPlayer.test_mode == 1 else "This should not crash!"), \
        null, \
        HudPosition.LEFT, 1, \
        Color.WHITE, \
        Color.RED if eventPlayer.test_mode == 1 else Color.LIME_GREEN, \
        Color.WHITE, \
        HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        null, \
        "RESTART count: Sub1={0} | Sub2={1} | Total={2}".format(eventPlayer.test_restart_count, eventPlayer.test_restart_count_2, eventPlayer.test_restart_count + eventPlayer.test_restart_count_2), \
        null, \
        HudPosition.TOP, 2.3, \
        Color.WHITE, Color.AQUA, Color.WHITE, \
        HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    hudText(eventPlayer, \
        "{0}".format( \
            "We chillin :D" if eventPlayer.test_mode == 2 \
            else "DOOM APPROACHING D:" if eventPlayer.test_mode == 1 \
            else "We chillin :D"), \
        null, null, \
        HudPosition.TOP, 2.5, \
        Color.LIME_GREEN if eventPlayer.test_mode == 2 else Color.RED, \
        Color.WHITE, Color.WHITE, \
        HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)


rule "Blink decay":
    @Event eachPlayer
    @Condition eventPlayer.test_blink > 0

    wait(0.1)
    eventPlayer.test_blink = 0

rule "Switch test mode":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true

    eventPlayer.test_mode += 1
    if eventPlayer.test_mode > 2:
        eventPlayer.test_mode = 1
    if eventPlayer.test_mode == 1:
        bigMessage(eventPlayer, "Mode 1: RESTART + Wait(2)")
    else:
        bigMessage(eventPlayer, "Mode 2: RESTART + No Wait")
    wait(0.5)

rule "Change wait duration":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true

    if eventPlayer.test_wait_duration == 0.016:
        eventPlayer.test_wait_duration = 0.1
    elif eventPlayer.test_wait_duration == 0.1:
        eventPlayer.test_wait_duration = 0.5
    elif eventPlayer.test_wait_duration == 0.5:
        eventPlayer.test_wait_duration = 1
    elif eventPlayer.test_wait_duration == 1:
        eventPlayer.test_wait_duration = 2
    elif eventPlayer.test_wait_duration == 2:
        eventPlayer.test_wait_duration = 5
    elif eventPlayer.test_wait_duration == 5:
        eventPlayer.test_wait_duration = 10
    else:
        eventPlayer.test_wait_duration = 0.016
    eventPlayer.test_restart_count = 0
    bigMessage(eventPlayer, "Wait duration: {0}s".format(eventPlayer.test_wait_duration))
    wait(0.5)

rule "Increase frequency":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

    if eventPlayer.test_call_interval <= 0.016:
        return
    eventPlayer.test_call_interval = max(0.016, eventPlayer.test_call_interval / 2)
    bigMessage(eventPlayer, "Every {0}s".format(eventPlayer.test_call_interval))
    wait(1)

rule "RESTART caller":
    @Event eachPlayer
    @Condition getTotalTimeElapsed() > 5

    eventPlayer.test = "X"
    eventPlayer.test_blink = 1
    eventPlayer.test_restart_count += 1
    if eventPlayer.test_mode == 1:
        async(sub_with_wait, AsyncBehavior.RESTART)
    else:
        async(sub_without_wait, AsyncBehavior.RESTART)
    wait(eventPlayer.test_call_interval)
    if RULE_CONDITION:
        goto RULE_START

rule "RESTART caller 2":
    @Event eachPlayer
    @Condition getTotalTimeElapsed() > 5

    eventPlayer.test_restart_count_2 += 1
    if eventPlayer.test_mode == 1:
        async(sub_with_wait_2, AsyncBehavior.RESTART)
    else:
        async(sub_without_wait, AsyncBehavior.RESTART)
    wait(eventPlayer.test_call_interval)
    if RULE_CONDITION:
        goto RULE_START
