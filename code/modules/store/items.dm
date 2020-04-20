/////////////////////////////
// Store Item
/////////////////////////////
/datum/storeitem
	var/name="Thing"
	var/desc="It's a thing."
	var/typepath=/obj/item/storage/box
	var/cost=0

/datum/storeitem/proc/deliver(var/mob/usr)
	if(!istype(typepath,/obj/item/storage))
		var/obj/item/storage/box/box=new(usr.loc)
		new typepath(box)
		box.name="[name] package"
		box.desc="A special gift for doing your job."
		usr.put_in_hands(box)
	else
		var/thing = new typepath(usr.loc)
		usr.put_in_hands(thing)


/////////////////////////////
// Shit for robotics/science
/////////////////////////////
/*
/datum/storeitem/robotnik_labcoat
	name = "Robotnik's Research Labcoat"
	desc = "Join the empire and display your hatred for woodland animals."
	typepath = /obj/item/clothing/suit/storage/labcoat/custom/N3X15/robotics
	cost = 350

/datum/storeitem/robotnik_jumpsuit
	name = "Robotics Interface Suit"
	desc = "A modern black and red design with reinforced seams and brass neural interface fittings."
	typepath = /obj/item/clothing/under/custom/N3X15/robotics
	cost = 500
*/

/////////////////////////////
// General
/////////////////////////////
/datum/storeitem/snap_pops
	name = "Snap-Pops"
	desc = "Fuegos artificiales chinos de diez mil anos: EN EL ESPACIO"
	typepath = /obj/item/storage/box/snappops
	cost = 200

/datum/storeitem/dnd
	name = "Set de Calabozos y dragones"
	desc = "Una caja que contiene minifiguras adecuadas para un buen juego de D&D."
	typepath = /obj/item/storage/box/characters
	cost = 200

/datum/storeitem/dice
	name = "Set de Dados"
	desc = "Una caja que contiene multiples tipos diferentes de dados."
	typepath = /obj/item/storage/box/dice
	cost = 200

/datum/storeitem/candle
	name = "Velas"
	desc = "Una caja de velas. Usalas para enganar a otros haciendoles creer que estas fuera para una cena romantica ... o algo asi."
	typepath = /obj/item/storage/fancy/candle_box/full
	cost = 200

/datum/storeitem/nanomob_booster
	name = "Cartas Nano-Mob Hunter Booster Pack"
	desc = "Contiene 6 cartas coleccionables de cazadores de nano-mobs al azar. Puede contener una tarjeta holografica!"
	typepath = /obj/item/storage/box/nanomob_booster_pack
	cost = 250

/datum/storeitem/crayons
	name = "Crayones"
	desc = "Hagale saber a seguridad como te sientes con notas de amor en sus pasillos."
	typepath = /obj/item/storage/fancy/crayons
	cost = 350

/datum/storeitem/pipe
	name = "Pipa para Fumar"
	desc = "Una pipa, para fumar. Probablemente hecho de espuma de mar o algo."
	typepath = /obj/item/clothing/mask/cigarette/pipe
	cost = 350

/datum/storeitem/minigibber
	name = "Gibber Miniatura"
	desc = "Una recreacion en miniatura del famoso molino de carne de Nanotrasen."
	typepath = /obj/item/toy/minigibber
	cost = 400

/datum/storeitem/katana
	name = "Replica de Katana"
	desc = "Lamentablemente poco poder en un D20."
	typepath = /obj/item/toy/katana
	cost = 500

/datum/storeitem/violin
	name = "Violin Espacial"
	desc = "Un instrumento musical de madera con cuatro cuerdas y un arco. \"El diablo bajo al espacio, estaba buscando un asistente para el dolor.\""
	typepath = /obj/item/instrument/violin
	cost = 500

/datum/storeitem/guitar
	name = "Guitarra"
	desc = "Esta hecho de madera y tiene cuerdas de bronce.."
	typepath = /obj/item/instrument/guitar
	cost = 500

/datum/storeitem/eguitar
	name = "Guitarra Electrica"
	desc = "Hace posible todas tus necesidades de trituracion."
	typepath = /obj/item/instrument/eguitar
	cost = 500

/datum/storeitem/piano_synth
	name = "Sintetizador de Piano"
	desc = "Un sintetizador electronico avanzado que puede emular varios instrumentos."
	typepath = /obj/item/instrument/piano_synth
	cost = 1000

/datum/storeitem/baby
	name = "Bebe"
	desc = "Este bebe se ve casi real. Espera, acaba de eructar?"
	typepath = /obj/item/toddler
	cost = 1000

/datum/storeitem/flag_slime
	name = "Bandera de Gente Slime"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Slime."
	typepath = /obj/item/flag/species/slime
	cost = 1000

/datum/storeitem/flag_skrell
	name = "Bandera de Gente Skrell"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Skrell."
	typepath = /obj/item/flag/species/skrell
	cost = 1000

/datum/storeitem/flag_vox
	name = "Bandera de Gente Vox"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Vox."
	typepath = /obj/item/flag/species/vox
	cost = 1000

/datum/storeitem/flag_machine
	name = "Bandera de Gente Sintetica"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Sinteticos."
	typepath = /obj/item/flag/species/machine
	cost = 1000

/datum/storeitem/flag_diona
	name = "Bandera de Gente Diona"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Diona."
	typepath = /obj/item/flag/species/diona
	cost = 1000

/datum/storeitem/flag_human
	name = "Bandera de Gente Humana"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Humanos."
	typepath = /obj/item/flag/species/human
	cost = 1000

/datum/storeitem/flag_greys
	name = "Bandera de Gente Grey"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Greys."
	typepath = /obj/item/flag/species/greys
	cost = 1000

/datum/storeitem/flag_kidan
	name = "Bandera de Gente Kidan"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Kidan."
	typepath = /obj/item/flag/species/kidan
	cost = 1000

/datum/storeitem/flag_taj
	name = "Bandera de Gente Tajaran"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Tajaran."
	typepath = /obj/item/flag/species/taj
	cost = 1000

/datum/storeitem/flag_unathi
	name = "Bandera de Gente Unathi"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Unathi."
	typepath = /obj/item/flag/species/unathi
	cost = 1000

/datum/storeitem/flag_vulp
	name = "Bandera de Gente Vulpkanin"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Vulpkanin."
	typepath = /obj/item/flag/species/vulp
	cost = 1000

/datum/storeitem/flag_drask
	name = "Bandera de Gente Drask"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Drask."
	typepath = /obj/item/flag/species/drask
	cost = 1000

/datum/storeitem/flag_plasma
	name = "Bandera de Gente Plasmaman"
	desc = "Una bandera que proclama con orgullo la herencia superior de los Plasmamen."
	typepath = /obj/item/flag/species/plasma
	cost = 1000

/datum/storeitem/flag_ian
	name = "Bandera Ian"
	desc = "Un banner de Ian, solo por que SQUEEEEE."
	typepath = /obj/item/flag/ian
	cost = 1500

/datum/storeitem/banhammer
	name = "Banhammer"
	desc = "A Banhammer."
	typepath = /obj/item/banhammer
	cost = 2000
