/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// How many chat payloads to keep in history
#define CHAT_RELIABILITY_HISTORY_SIZE 5
/// How many resends to allow before giving up
#define CHAT_RELIABILITY_MAX_RESENDS 3

#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_MENTORPM "mentorpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_MENTORCHAT "mentorchat"
#define MESSAGE_TYPE_DEVCHAT "devchat"
#define MESSAGE_TYPE_STAFFCHAT "staffchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"

// Used to calculate delay between BLOOPERs, any BLOOPER speeds below this feature higher BLOOPER density, any speeds above feature lower BLOOPER density. Keeps BLOOPERing length consistent
#define BLOOPER_DEFAULT_MINPITCH 0.4
#define BLOOPER_DEFAULT_MAXPITCH 2
#define BLOOPER_DEFAULT_MINVARY 0.1
#define BLOOPER_DEFAULT_MAXVARY 0.8
#define BLOOPER_DEFAULT_MINSPEED 2
#define BLOOPER_DEFAULT_MAXSPEED 16
#define BLOOPER_SPEED_BASELINE 4

#define BLOOPER_MAX_BLOOPERS 24
#define BLOOPER_MAX_TIME (1.5 SECONDS) // More or less the amount of time the above takes to process through with a BLOOPER speed of 2.

// Macro for handling pitch variations using parameters.
#define BLOOPER_DO_VARY(pitch, variance) (rand(((pitch * 100) - (variance * 50)), ((pitch * 100) + (variance * 50))) / 100)
