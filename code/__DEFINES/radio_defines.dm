// VALUES NOT ACTUALLY USED WITH SSRADIO
#define RSD_FREQ 1457 // remote signal device
#define ELECTROPACK_FREQ 1449 // electropack

// Things actually using SSradio

// Random devices
#define INTERROGATION_FREQ 1441 // interrogation intercoms
#define MAGNET_FREQ 1445 // target practice magnets // kill this PLEASE

// Base limits
#define RADIO_LOW_FREQ 1200 //minimum radio freq
#define PUBLIC_LOW_FREQ 1441 //minimum radio chat freq
#define PUBLIC_HIGH_FREQ 1489 //maximum radio chat freq
#define RADIO_HIGH_FREQ 1600 //maximum radio freq

// Special channels
#define SYND_FREQ 1213
#define SYNDTEAM_FREQ 1244
#define DTH_FREQ 1341 //Special Operations
#define AI_FREQ 1343
#define ERT_FREQ 1345
#define STARLINE_FREQ 1337 // Private starline


// Department channels
#define PROC_FREQ 1339 //Procedure
#define SUP_FREQ  1347 //cargo
#define SRV_FREQ  1349 //service
#define SCI_FREQ  1351 //science
#define COM_FREQ  1353 //Command
#define MED_FREQ  1355 //medical
#define ENG_FREQ  1357 //engineering
#define SEC_FREQ  1359 //security
#define PUB_FREQ  1459 //standard radio chat

// Internal department channels
#define SEC_I_FREQ 1475
#define MED_I_FREQ 1485

//This filter is special because devices belonging to default also receive signals sent to any other filter.
#define RADIO_DEFAULT "radio_default"
#define RADIO_CHAT "radio_telecoms" // actual radio devices
#define RADIO_MAGNETS "radio_magnet" // KILL THIS

// Signal types
#define SIGNALTYPE_NORMAL       0
#define SIGNALTYPE_INTERCOM     (1<<0) // Will only broadcast to intercoms
#define SIGNALTYPE_INTERCOM_SBR (1<<1) // Will only broadcast to intercoms and station-bounced radios
#define SIGNALTYPE_AINOTRACK    (1<<2) // AI can't track down this person. Useful for imitation broadcasts where you can't find the actual mob

