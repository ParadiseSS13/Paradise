// Used for create_log() Log Viewer
#define ATTACK_LOG		"Attack"
#define DEFENSE_LOG		"Defense"
#define CONVERSION_LOG	"Conversion"
#define SAY_LOG			"Say"
#define EMOTE_LOG		"Emote"
#define GAME_LOG		"Game"
#define MISC_LOG		"Misc"
#define DEADCHAT_LOG	"Deadchat"
#define OOC_LOG			"OOC"
#define LOOC_LOG		"LOOC"

#define ALL_LOGS list(ATTACK_LOG, DEFENSE_LOG, CONVERSION_LOG, SAY_LOG, EMOTE_LOG, GAME_LOG, DEADCHAT_LOG, OOC_LOG, LOOC_LOG, MISC_LOG)

//Investigate logging defines
#define INVESTIGATE_ACCESSCHANGES "id_card_changes"
#define INVESTIGATE_ATMOS "atmos"
#define INVESTIGATE_BOMB "bombs"
#define INVESTIGATE_BOTANY "botany"
#define INVESTIGATE_CARGO "cargo"
#define INVESTIGATE_CRAFTING "crafting"
#define INVESTIGATE_ENGINE "engine"
#define INVESTIGATE_EXPERIMENTOR "experimentor"
#define INVESTIGATE_GRAVITY "gravity"
#define INVESTIGATE_HALLUCINATIONS "hallucinations"
#define INVESTIGATE_TELEPORTATION "teleportation"
#define INVESTIGATE_RECORDS "records"
#define INVESTIGATE_RESEARCH "research"
#define INVESTIGATE_SYNDIE_CARGO "syndicate_cargo"
#define INVESTIGATE_WIRES "wires"

//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")
