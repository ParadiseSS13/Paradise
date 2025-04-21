// Пример добавления руины.
/datum/map_template/ruin/lavaland/example // Вместо "example" писать название руины.
	name = "example" // Имя руины
	id = "example_id" // ID руины
	description = "Пример описания" // Описание руины. Видно только админам.
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/" // Путь до карты, обязательно оставлять таким.
	suffix = "" // .dmm файл руины, вписывать название полностью, пример: suffix = "example.dmm". Саму карту закидывать в "_maps\map_files\RandomRuins\LavaRuins"
	allow_duplicates = FALSE // Разрешает/Запрещает дубликаты руины. TRUE - могут быть дубликаты. FALSE - дубликатов не будет.
	always_place = TRUE // Если вписать эту строчку, руина будет спавнится всегда.
	ci_exclude = /datum/map_template/ruin/lavaland/example // Это не использовать.

// Добавлять свои руины под этими комментариями. Делать это по примеру выше!
// Комментарии УДАЛИТЬ если копируешь пример.
/datum/map_template/ruin/lavaland/scp_facility
	name = "Сдерживание Аномальных Объектов"
	id = "scp_facility"
	description = "Заброшенное место хранения опасных и паранормальных предметов а так же существ."
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/"
	suffix = "scp_facility.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/cheesus_temple
	name = "Церковь Чизуса"
	id = "cheesus_temple"
	description = "Перенесённая в результате БС аномалии церковь Чизуза."
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/"
	suffix = "cheesus_temple.dmm"
	always_place = FALSE
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/ash_old
	name = "Заброшенный лагерь Эшей"
	id = "ash_old"
	description = "Старый, заброшенный лагерь Эшей."
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/"
	suffix = "ash_old.dmm"
	always_place = FALSE
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/old_outpost
	name = "Заброшенный аванпост"
	id = "old_outpost"
	description = "Старый заброшенный аванпост. Его постигла участь разлома Лаваленда."
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/"
	suffix = "old_outpost.dmm"
	allow_duplicates = FALSE
	always_place = FALSE

/datum/map_template/ruin/lavaland/nt
	prefix = "_maps/map_files220/RandomRuins/LavaRuins/"

/datum/map_template/ruin/lavaland/nt/get_cost()
	return 0

/datum/map_template/ruin/lavaland/legiongate/get_cost()
	return 0
