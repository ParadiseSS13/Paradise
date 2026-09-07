// Wire defines for all machines/items.

// Miscellaneous
#define WIRE_DUD_PREFIX "__dud"

// General
#define WIRE_IDSCAN "ID Scan"
#define WIRE_MAIN_POWER1 "Primary Power"
#define WIRE_MAIN_POWER2 "Secondary Power"
#define WIRE_AI_CONTROL "AI Control"
#define WIRE_ELECTRIFY "Electrification"
#define WIRE_SAFETY "Safety"

// Vendors and smartfridges
#define WIRE_THROW_ITEM "Item Throw"
#define WIRE_CONTRABAND "Contraband"

// Airlock
#define WIRE_DOOR_BOLTS "Door Bolts"
#define WIRE_BACKUP_POWER1 "Primary Backup Power"
#define WIRE_OPEN_DOOR "Door State"
#define WIRE_SPEED "Door Timing"
#define WIRE_BOLT_LIGHT "Bolt Lights"

// Air alarm
#define WIRE_SIPHON "Siphon"
#define WIRE_AALARM "Atmospherics Alarm"

// Camera
#define WIRE_FOCUS "Focus"

// Mulebot
#define WIRE_MOB_AVOIDANCE "Mob Avoidance"
#define WIRE_LOADCHECK "Load Checking"
#define WIRE_MOTOR1 "Primary Motor"
#define WIRE_MOTOR2 "Secondary Motor"
#define WIRE_REMOTE_RX "Signal Receiver"
#define WIRE_REMOTE_TX "Signal Sender"
#define WIRE_BEACON_RX "Beacon Receiver"

// Explosives, bombs
#define WIRE_EXPLODE "Explode" // Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut.
#define WIRE_BOMB_UNBOLT "Unbolt" // Unbolts the bomb if cut, hint on pulsed.
#define WIRE_BOMB_DELAY "Delay" // Raises the timer on pulse, does nothing on cut.
#define WIRE_BOMB_PROCEED "Proceed" // Lowers the timer, explodes if cut while the bomb is active.
#define WIRE_BOMB_ACTIVATE "Activate" // Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut.

// Nuclear bomb
#define WIRE_NUKE_SAFETY "Safety"
#define WIRE_NUKE_DETONATOR "Detonator"
#define WIRE_NUKE_DISARM "Disarm"
#define WIRE_NUKE_LIGHT "Lights"
#define WIRE_NUKE_CONTROL "Control Panel"

// Particle accelerator
#define WIRE_PARTICLE_POWER "Power Toggle" // Toggles whether the PA is on or not.
#define WIRE_PARTICLE_STRENGTH "Strength" // Determines the strength of the PA.
#define WIRE_PARTICLE_INTERFACE "Interface" // Determines the interface showing up.
#define WIRE_PARTICLE_POWER_LIMIT "Maximum Power" // Determines how strong the PA can be.

// Autolathe
#define WIRE_AUTOLATHE_HACK "Hack"
#define WIRE_AUTOLATHE_DISABLE "Disable"

// Radio
#define WIRE_RADIO_SIGNAL "Signal"
#define WIRE_RADIO_RECEIVER "Receiver"
#define WIRE_RADIO_TRANSMIT "Transmitter"

// Cyborg
#define WIRE_BORG_LOCKED "Lockdown"
#define WIRE_BORG_CAMERA "Camera"
#define WIRE_BORG_LAWCHECK "Law Check"

// Suit storage unit
#define WIRE_SSU_UV "UV wire"

// Tesla coil
#define WIRE_TESLACOIL_ZAP "Zap"

// MODsuits
#define WIRE_HACK "Hack"
#define WIRE_DISABLE "Disable"
#define WIRE_INTERFACE "Interface"

#define ZLVL_BASED_WIRES "Zlvl_based_wires"
