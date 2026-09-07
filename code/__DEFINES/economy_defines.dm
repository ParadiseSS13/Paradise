
/////ACOUNT SECURITY LEVELS////
///There is no security on this account, it can be accessed through someone's ID card/account number
#define ACCOUNT_SECURITY_ID          1
///Before accessing this account, the pin number must be provided
#define ACCOUNT_SECURITY_PIN         2
///This account can only be accessed through restricted terminals
#define ACCOUNT_SECURITY_RESTRICTED  3
///This acount can only be accessed by admins/CC characters
#define ACCOUNT_SECURITY_CC          4
///This account is only accessible to NPCs and Vendors (aka, only through code)
#define ACCOUNT_SECURITY_VENDOR      5

/////STARTING CASH AMOUNTS/////
#define CREW_MEMBER_STARTING_BALANCE    450
#define COMMAND_MEMBER_STARTING_BALANCE 600
#define CC_OFFICER_STARTING_BALANCE     50000

#define DEPARTMENT_BALANCE_REALLY_LOW   500 //enjoy your scraps, assistant department
#define DEPARTMENT_BALANCE_LOW     		750
#define DEPARTMENT_BALANCE_MEDIUM		1000
#define DEPARTMENT_BALANCE_HIGH			1500

/////BASE PAY AMOUNTS///
#define CREW_PAY_ASSISTANT	100
#define CREW_PAY_LOW		150
#define CREW_PAY_MEDIUM		200
#define CREW_PAY_HIGH		250

#define DEPARTMENT_BASE_PAY_NONE	0
#define DEPARTMENT_BASE_PAY_LOW    250
#define DEPARTMENT_BASE_PAY_MEDIUM 500
#define DEPARTMENT_BASE_PAY_HIGH   750

#define ACCOUNT_TYPE_PERSONAL		"Personal"
#define ACCOUNT_TYPE_DEPARTMENT		"Department"

///Transactions on money accounts will automatically be logged if they involve over 2500 space credits
#define DATABASE_LOG_THRESHHOLD 2500
/////CASH LIMITS/CAPS/////
///The total amount of space cash that can be stacked
#define MAX_STACKABLE_CASH    10000

#define STATION_CREATION_DATE "2 April, 2555"
#define STATION_CREATION_TIME "11:24:30"
#define STATION_SOURCE_TERMINAL "Biesel GalaxyNet Terminal #227"

///merch computer categories
#define MERCH_CAT_APPAREL     "apparel"
#define MERCH_CAT_TOY         "toy"
#define MERCH_CAT_DECORATION  "decoration"

///supply packs

#define SUPPLY_EMERGENCY 	1
#define SUPPLY_SECURITY 	2
#define SUPPLY_ENGINEER 	3
#define SUPPLY_MEDICAL 		4
#define SUPPLY_SCIENCE 		5
#define SUPPLY_ORGANIC 		6
#define SUPPLY_MATERIALS 	7
#define SUPPLY_MISC 		8
#define SUPPLY_VEND 		9
#define SUPPLY_SHUTTLE		10

#define DEFAULT_CRATE_VALUE 15

/// mail deliveries
#define MAIL_DELIVERY_BONUS	100
