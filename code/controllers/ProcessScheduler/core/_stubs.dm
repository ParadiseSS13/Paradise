/**
 * _stubs.dm
 *
 * This file contains constructs that the process scheduler expects to exist
 * in a standard ss13 fork.
 */
/*
/**
 * message_admins
 *
 * sends a message to admins
 */
/proc/message_admins(msg)
	world << msg
*/
/**
 * logTheThing
 *
 * In goonstation, this proc writes a message to either the world log or diary.
 *
 * Blame Keelin.
 */
/proc/logTheThing(type, source, target, text, diaryType)
	if(diaryType)
		world << "Diary: \[[diaryType]:[type]] [text]"
	else
		world << "Log: \[[type]] [text]"
