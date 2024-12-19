#define SOUND_EFFECT_NONE 0
#define SOUND_EFFECT_RADIO 1
#define SOUND_EFFECT_ROBOT 2
#define SOUND_EFFECT_RADIO_ROBOT 3
#define SOUND_EFFECT_MEGAPHONE 4
#define SOUND_EFFECT_MEGAPHONE_ROBOT 5

#define TTS_TRAIT_PITCH_WHISPER (1<<1)
#define TTS_TRAIT_RATE_FASTER (1<<2)
#define TTS_TRAIT_RATE_MEDIUM (1<<3)

#define TTS_TRAIT_ROBOTIZE "tts_trait_robotize"

#define TTS_CATEGORY_OTHER "Другое"
#define TTS_CATEGORY_WARCRAFT3 "WarCraft 3"
#define TTS_CATEGORY_HALFLIFE2 "Half-Life 2"
#define TTS_CATEGORY_HALFLIFE_ALYX "Half-Life Alyx"
#define TTS_CATEGORY_STARCRAFT "StarCraft"
#define TTS_CATEGORY_PORTAL2 "Portal 2"
#define TTS_CATEGORY_STALKER "STALKER"
#define TTS_CATEGORY_DOTA2 "Dota 2"
#define TTS_CATEGORY_LOL "League of Legends"
#define TTS_CATEGORY_FALLOUT "Fallout"
#define TTS_CATEGORY_FALLOUT2 "Fallout 2"
#define TTS_CATEGORY_POSTAL2 "Postal 2"
#define TTS_CATEGORY_TEAMFORTRESS2 "Team Fortress 2"
#define TTS_CATEGORY_ATOMIC_HEART "Atomic Heart"
#define TTS_CATEGORY_OVERWATCH "Overwatch"
#define TTS_CATEGORY_SKYRIM "Skyrim"
#define TTS_CATEGORY_RITA "Rita"
#define TTS_CATEGORY_METRO "Metro"
#define TTS_CATEGORY_HEROESOFTHESTORM "Heroes of the Storm"
#define TTS_CATEGORY_HEARTHSTONE "Hearthstone"
#define TTS_CATEGORY_VALORANT "Valorant"
#define TTS_CATEGORY_EVILISLANDS "Evil Islands"
#define TTS_CATEGORY_WITCHER "Witcher"
#define TTS_CATEGORY_LEFT4DEAD "Left 4 Dead"
#define TTS_CATEGORY_SPONGEBOB "SpongeBob"
#define TTS_CATEGORY_TINYBUNNY "Tiny Bunny"
#define TTS_CATEGORY_BALDURS_GATE_3 "Baldur's gate 3"
#define TTS_CATEGORY_PORTAL "Portal"
#define TTS_CATEGORY_TMNT "Teenage mutant ninja turtle"
#define TTS_CATEGORY_STAR_WARS "Star Wars"
#define TTS_CATEGORY_TRANSFORMERS "Transformers"
#define TTS_CATEGORY_LOTR "The Lord of the rings"
#define TTS_CATEGORY_SHREK "Shrek"
#define TTS_CATEGORY_POTC "Pirates of the Caribbean"
#define TTS_CATEGORY_HARRY_POTTER "Harry Potter"
#define TTS_CATEGORY_HOGWARTS "Hogwarts legacy"
#define TTS_CATEGORY_X3 "X3"
#define TTS_CATEGORY_OVERLORD2 "The Overlord 2"
#define TTS_CATEGORY_MARVEL "Marvel"
#define TTS_CATEGORY_WOW "World of Warcraft"
#define TTS_CATEGORY_TREASURE_ISLAND "Treasure Island"
#define TTS_CATEGORY_BOYS_WORD "Слово пацана"
#define TTS_CATEGORY_STRONGHOLD "Stronghold Crusade"
#define TTS_CATEGORY_CYBERPUNK "Киберпанк 2077"
#define TTS_CATEGORY_TLOU "The Last of Us"
#define TTS_CATEGORY_DEEP_ROCK_GALACTIC "Deep Rock Galactic"
#define TTS_CATEGORY_SUNBOY "Пророк Санбой"
#define TTS_CATEGORY_WH40k "Warhammer 40k"


#define TTS_GENDER_ANY "Любой"
#define TTS_GENDER_MALE "Мужской"
#define TTS_GENDER_FEMALE "Женский"

#define TTS_PHRASES list(\
		"Так звучит мой голос.",\
		"Так я звучу.",\
		"Я.",\
		"Поставьте свою подпись.",\
		"Пора за работу.",\
		"Дело сделано.",\
		"Станция Нанотрейзен.",\
		"Офицер СБ.",\
		"Капитан.",\
		"Вульпканин.",\
		"Съешь же ещё этих мягких французских булок, да выпей чаю.",\
		"Клоун, прекрати разбрасывать банановые кожурки офицерам под ноги!",\
		"Капитан, вы уверены что хотите назначить клоуна на должность главы персонала?",\
	)

//from base of atom/change_tts_seed(): (mob/chooser, override, fancy_voice_input_tgui)
#define COMSIG_ATOM_TTS_SEED_CHANGE "atom_tts_seed_change"
//called for tts_component: (mob/listener, message, atom/location, is_local, effect, traits, preSFX, postSFX)
#define COMSIG_ATOM_TTS_CAST "atom_tts_cast"
//from base of atom/tts_trait_add(): (atom/user, trait)
#define COMSIG_ATOM_TTS_TRAIT_ADD "atom_tts_trait_add"
//from base of atom/tts_trait_remove(): (atom/user, trait)
#define COMSIG_ATOM_TTS_TRAIT_REMOVE "atom_tts_trait_remove"
//from base of atom/cast_tts(): (mob/listener, message, atom/location, is_local, effect, traits, preSFX, postSFX)
#define COMSIG_ATOM_PRE_TTS_CAST "atom_pre_tts_cast"
	#define COMPONENT_TTS_INTERRUPT (1<<0)
