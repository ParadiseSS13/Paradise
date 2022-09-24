#define ATTACK_LOG		"Attack"
#define DEFENSE_LOG		"Defense"
#define CONVERSION_LOG	"Conversion"
#define SAY_LOG			"Say"
#define EMOTE_LOG		"Emote"
#define MISC_LOG		"Misc"
#define DEADCHAT_LOG	"Deadchat"
#define OOC_LOG			"OOC"
#define LOOC_LOG		"LOOC"

#define ALL_LOGS list(ATTACK_LOG, DEFENSE_LOG, CONVERSION_LOG, SAY_LOG, EMOTE_LOG, DEADCHAT_LOG, OOC_LOG, LOOC_LOG, MISC_LOG)

//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")
