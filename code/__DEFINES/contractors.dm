// Contract Statuses
/// The contract is invalid for some reason and cannot be taken. It may be made valid later.
#define CONTRACT_STATUS_INVALID -1
/// The contract hasn't been started yet.
#define CONTRACT_STATUS_INACTIVE 0
/// The contract is in progress.
#define CONTRACT_STATUS_ACTIVE 1
/// The contract has been completed successfully.
#define CONTRACT_STATUS_COMPLETED 2
/// The contract failed for some reason.
#define CONTRACT_STATUS_FAILED 3

// Difficulties. Note that they follow each other numerically and should stay that way as some code relies on that.
/// Easy difficulty area to extract the kidnapee. Low rewards.
#define EXTRACTION_DIFFICULTY_EASY 1
/// Medium difficulty area to extract the kidnapee. Moderate rewards.
#define EXTRACTION_DIFFICULTY_MEDIUM 2
/// Hard difficulty area to extract the kidnapee. High rewards.
#define EXTRACTION_DIFFICULTY_HARD 3

/// The name of the strings file containing data to use for contract fluff texts.
#define CONTRACT_STRINGS_WANTED "syndicate_wanted_messages.json"

// UI page numbers.
#define HUB_PAGE_CONTRACTS 1
#define HUB_PAGE_SHOP 2

GLOBAL_DATUM(prisoner_belongings, /obj/structure/closet/secure_closet/contractor)
