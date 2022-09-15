
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
#define CREW_MEMBER_STARTING_BALANCE    500
#define COMMAND_MEMBER_STARTING_BALANCE 1000
#define CC_OFFICER_STARTING_BALANCE     50000
#define DEPARTMENT_STARTING_BALANCE     5000
#define STATION_STARTING_BALANCE        75000

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
