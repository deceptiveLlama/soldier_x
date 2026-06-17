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
                "blackForest",
                "eichenwalde",
                "hollywood",
                "castillo",
                "chateauGuillard",
                "ecopointAntarctica",
                "kanezaka",
                "malevento",
                "necropolis",
                "petra",
                "hanamura",
                "horizonLunarColony",
                "paris",
                "templeOfAnubis",
                "volskaya",
                "blizzWorld",
                "kingsRow",
                "dorado",
                "havana",
                "route66"
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
            "reaper": {
                "damageDealt%": 50,
                "ability2Cooldown%": 0,
                "enableUlt": false
            },
            "soldier": {
                "secondaryFireCooldown%": 100,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10
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