/datum/vox_pack/bio
	name = "DEBUG Bio Vox Pack"
	category = VOX_PACK_BIO
	time_until_available = 45

// ============== GUNS ==============
/datum/vox_pack/bio/gun
	name = "Биомёт"
	desc = "Компактный метатель биоядер-снарядов. Вмещает в себя 3 острых биоядра одновременно, выстреливая их поочереди, вонзая в плоть цели, а после вылупляя, выпуская биомеханическую тварь для последующей помощи Воксам."
	reference = "B_G"
	cost = 2000
	contains = list(/obj/item/gun/throw/biogun)

// ============== AMMO ==============

/datum/vox_pack/bio/core
	name = "Биоядро (Потрошитель х3)"
	desc = "Переписанная машина синдиката на служении Воксам."
	reference = "B_B_VISC"
	cost = 400
	contains = list(/obj/item/biocore/viscerator)

/datum/vox_pack/bio/core/stamine
	name = "Биоядро (Стакикамка х3)"
	desc = "Биомеханизм изматывающий своих жертв."
	reference = "B_B_STAM"
	cost = 300
	contains = list(/obj/item/biocore/stamina)

/datum/vox_pack/bio/core/acid
	name = "Биоядро (Асикикид х1)"
	desc = "Кислотный жгущий биомеханизм."
	reference = "B_B_ACID"
	cost = 200
	contains = list(/obj/item/biocore/acid)

/datum/vox_pack/bio/core/kusaka
	name = "Биоядро (Кусакика х4)"
	desc = "Кусачий маленький биомеханизм."
	reference = "B_B_KUS"
	cost = 300
	contains = list(/obj/item/biocore/kusaka)

/datum/vox_pack/bio/core/taran
	name = "Биоядро (Таракикан х1)"
	desc = "Броневой биомеханизм, приспособленный для вышибания дверей."
	reference = "B_B_TAT"
	cost = 400
	contains = list(/obj/item/biocore/taran)

/datum/vox_pack/bio/core/tox
	name = "Биоядро (Токсикикик х3)"
	desc = "Иглоподобный биомеханизм для впрыскивания токсин."
	reference = "B_B_TOX"
	cost = 300
	contains = list(/obj/item/biocore/tox)
