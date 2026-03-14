#!mainFile "soldier_x.opy"

settings {
    "main": {
        "description": GAME_MODE_DESCRIPTION,
        "modeName": GAME_MODE_NAME
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "ffaSlots": 7,
        "spectatorSlots": 1,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "blackForestWinter",
                "blizzWorldWinter",
                "castillo",
                "chateauGuillard",
                "dorado",
                "eichenwalde",
                "hanamuraWinter",
                "havana",
                "hollywood",
                "horizonLunarColony",
                "kanezaka",
                "kingsRowWinter",
                "malevento",
                "necropolis",
                "paris",
                "petra",
                "templeOfAnubis",
                "volskaya"
            ],
                "scoreToWin": 100,
            /*"disabledMaps": [
                "ecopointAntarcticaWinter",
                "castillo",
                "havana",
                "lijiangControlCenter",
                "lijiangGarden",
                "lijiangNightMarket",
                "route66",
                "workshopChamber",
                "workshopExpanse",
                "workshopGreenScreen",
                "workshopIsland"
            ]*/
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableKillFeed": false,
            "spawnHealthPacks": "disabled"
        }
    },
    "heroes": {
        "allTeams": {
            "brigitte": {
                "enableAbility2": false,
                "combatUltGen%": 175,
                "passiveUltGen%": 175,
                "ultGen%": 175,
                "ability1Kb%": 25
            },
            "reaper": {
                "damageDealt%": 50,
                "enableUlt": false
            },
            "reinhardt": {
                "secondaryFireCooldown%": 50,
                "ability1Cooldown%": 25,
                "combatUltGen%": 180,
                "passiveUltGen%": 180,
                "ultGen%": 180
            },
            "soldier": {
                "secondaryFireCooldown%": 100,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
            },
            "winston": {
                "ultDuration%": 500,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
            },
            "hammond": {
                "ability3Cooldown%": 25,
                "enableRollOnly": true
            },
            "zarya": {
                "enableAbility1": false,
                "combatUltGen%": 250,
                "passiveUltGen%": 250,
                "ultGen%": 250
            },
            "enabledHeroes": [
                "soldier"
            ],
            "general": {
                # Due to a bug the following is false
                "passiveHealthRegen": true
            }
        }
    }
}