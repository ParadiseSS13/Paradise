// All global vars in this file require a different handler as we dont want their data to be exposed, not even to admins with permission to view globals
// They write as native BYOND globals, which means they cant be edited at all, and also use a format
// Please only throw absolutely crucial do-not-view shit in here please. -aa07

// MySQL configuration
GLOBAL_REAL_VAR(sqladdress) = "localhost"
GLOBAL_REAL_VAR(sqlport) = "3306"
GLOBAL_REAL_VAR(sqlfdbkdb) = "test"
GLOBAL_REAL_VAR(sqlfdbkdbutil) = "test"
GLOBAL_REAL_VAR(sqlfdbklogin) = "root"
GLOBAL_REAL_VAR(sqlfdbkpass) = ""
GLOBAL_REAL_VAR(sqlfdbktableprefix) = "erro_"
GLOBAL_REAL_VAR(sql_version) = 0

GLOBAL_REAL_VAR(tts_token_silero) = "" // Token we use to talk with text-to-speech service
