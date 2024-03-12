// Пример добавления руины.
/datum/map_template/ruin/space/example // Вместо "example" писать название руины.
	name = "example" // Имя руины
	id = "example_id" // ID руины
	description = "Пример описания" // Описание руины. Видно только админам.
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/" // Путь до карты, обязательно оставлять таким.
	suffix = "" // .dmm файл руины, вписывать название полностью, пример: suffix = "example.dmm". Саму карту закидывать в путь префикса.
	cost = 5 // Вес руины, чем он больше, тем меньше шанс что она заспавнится
	allow_duplicates = FALSE // Разрешает/Запрещает дубликаты руины. TRUE - могут быть дубликаты. FALSE - дубликатов не будет.
	always_place = TRUE // Если вписать эту строчку, руина будет спавнится всегда. Использовать ТОЛЬКО для теста! После удалить.
	ci_exclude = /datum/map_template/ruin/space/example // Это не использовать.

// Добавлять свои руины под этими комментариями. Делать это по примеру выше!
// Комментарии УДАЛИТЬ если копируешь пример.
/datum/map_template/ruin/space/mechtransport_new
	name = "Mechtransport"
	id = "mechtransport_new"
	description = "An abandoned unarmed transport ship, a perfect target for the bandit scum."
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "mechtransport_new.dmm"
	cost = 3
	allow_duplicates = FALSE

/datum/map_template/ruin/space/destroyed_infiltrator
	name = "Destroyed Infiltrator Ship"
	id = "destroyed_infiltrator"
	description = "They're loading BSA! But why? Ah, they're going to sho-..."
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "destroyed_infiltrator.dmm"
	cost = 3
	allow_duplicates = FALSE

/datum/map_template/ruin/space/transit_bar
	name = "Transit Bar"
	id = "transit_bar"
	description = "One of the trillion bars in this galaxy, this one looks especially homey and comfy."
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "transit_bar.dmm"
	cost = 1
	allow_duplicates = FALSE

/datum/map_template/ruin/space/infected_ship
	name = "Infected Ship"
	id = "infected_ship"
	description = "A lonely drifting ship showing no signs of life... What kind of black rubber substance is weaving around its shell?"
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "infected_ship.dmm"
	cost = 3
	allow_duplicates = FALSE

/datum/map_template/ruin/space/convoy_ambush
	name = "Convoy Ambush"
	id = "convoy_ambush"
	description = "I've been waiting for this for twuh years!"
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "convoy_ambush.dmm"
	cost = 3
	allow_duplicates = FALSE

/datum/map_template/ruin/space/whiteship
	name = "NT Medical Ship"
	id = "whiteship"
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "whiteship.dmm"
	description = "An old, abandoned NT medical ship. Its computer can navigate to other landmarks within space with ease."
	allow_duplicates = FALSE 
	always_place = TRUE 
	cost = 0 

/datum/map_template/ruin/space/voxraiders_1
	name = "Vox Raiders"
	id = "Vox_Raiders"
	description = "A small Vox skipjack near some space scrap. They will definitely not tolerate new rivals."
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "voxraiders_1.dmm"
	cost = 4
	allow_duplicates = FALSE

/datum/map_template/ruin/space/spacehotel
	name = "The Twin-Nexus Hotel"
	id = "spacehotel"
	description = "An interstellar hotel, where the weary spaceman can rest their head and relax, assured that the residental staff will not murder them in their sleep. Probably."
	prefix = "_maps/map_files220/RandomRuins/SpaceRuins/"
	suffix = "spacehotel.dmm"
	cost = 10
	allow_duplicates = FALSE
