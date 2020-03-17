
#define DISPLAY_FREQ 1435 //status displays
#define ATMOS_FIRE_FREQ 1437 //air alarms
#define ENGINE_FREQ 1438 //engine components
#define ATMOS_VENTSCRUB 1439 //vents, scrubbers, atmos control
#define ATMOS_DISTRO_FREQ 1443 //distro loop
#define ATMOS_TANKS_FREQ 1441 //atmos supply tanks
#define BOT_BEACON_FREQ 1445 //bot navigation beacons
#define AIRLOCK_FREQ 1449 //airlock controls, electropack, magnets

#define RSD_FREQ 1457 //radio signal device
#define IMPL_FREQ 1451 //tracking implant

#define RADIO_LOW_FREQ 1200 //minimum radio freq
#define PUBLIC_LOW_FREQ 1441 //minimum radio chat freq
#define PUBLIC_HIGH_FREQ 1489 //maximum radio chat freq
#define RADIO_HIGH_FREQ 1600 //maximum radio freq

#define SYND_FREQ 1213
#define SYNDTEAM_FREQ 1244
#define DTH_FREQ 1341 //Special Operations
#define AI_FREQ 1343
#define ERT_FREQ 1345
#define COMM_FREQ 1353 //Command
#define BOT_FREQ 1447 //mulebot, secbot, ed209


// Department channels
#define PUB_FREQ 1459 //standard radio chat
#define SEC_FREQ 1359 //security
#define ENG_FREQ 1357 //engineering
#define SCI_FREQ 1351 //science
#define MED_FREQ 1355 //medical
#define SUP_FREQ 1347 //cargo
#define SRV_FREQ 1349 //service

// Internal department channels
#define MED_I_FREQ 1485
#define SEC_I_FREQ 1475

// Transmission methods
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

//This filter is special because devices belonging to default also recieve signals sent to any other filter.
#define RADIO_DEFAULT "radio_default"
#define RADIO_TO_AIRALARM "radio_airalarm" //air alarms
#define RADIO_FROM_AIRALARM "radio_airalarm_rcvr" //devices interested in recieving signals from air alarms
#define RADIO_CHAT "radio_telecoms"
#define RADIO_ATMOSIA "radio_atmos"
#define RADIO_NAVBEACONS "radio_navbeacon"
#define RADIO_AIRLOCK "radio_airlock"
#define RADIO_SECBOT "radio_secbot"
#define RADIO_HONKBOT "radio_honkbot"
#define RADIO_MULEBOT "radio_mulebot"
#define RADIO_CLEANBOT "10"
#define RADIO_FLOORBOT "11"
#define RADIO_MEDBOT "12"
#define RADIO_MAGNETS "radio_magnet"
#define RADIO_LOGIC "radio_logic"
