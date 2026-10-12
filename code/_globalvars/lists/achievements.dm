GLOBAL_LIST_EMPTY(commendations)
///A list of the current achievement categories supported by the UI and checked by the achievement unit test
GLOBAL_LIST_INIT(achievement_categories, list(
	ACHIEVEMENT_CATEGORY_BOSSES,
	ACHIEVEMENT_CATEGORY_JOBS,
	//ACHIEVEMENT_CATEGORY_SKILLS, // haha funny
	ACHIEVEMENT_CATEGORY_MISC,
	//ACHIEVEMENT_CATEGORY_MAFIA,  // joke
	ACHIEVEMENT_CATEGORY_SCORES
))

GLOBAL_LIST_EMPTY(achievements_unlocked)

///A list of sounds that can be played when unlocking an achievement, set in the preferences.
GLOBAL_LIST_INIT(achievement_sounds, list(
	CHEEVO_SOUND_PING = sound('sound/effects/achievement/glockenspiel_ping.ogg', volume = 70),
	CHEEVO_SOUND_JINGLE = sound('sound/effects/achievement/beeps_jingle.ogg', volume = 70),
	CHEEVO_SOUND_TADA = sound('sound/effects/achievement/tada_fanfare.ogg', volume = 30),
))
