/datum/map_template/ruin/dababy
	prefix = "_maps/map_files/RandomRuins/DababyRuins/"
	placement_weight = 20
	var/max_duplictates = -1
	ci_exclude = /datum/map_template/ruin/dababy

/datum/map_template/ruin/dababyprincipal
	prefix = "_maps/map_files/RandomRuins/DababyRuins/Principal/"
	ci_exclude = /datum/map_template/ruin/dababyprincipal

/datum/map_template/ruin/dababy/inodoro
	name = "Inodoro Solitario"
	id = "inodoro-solitario"
	description = "Para que es la desc."
	suffix = "inodororeal.dmm"
	allow_duplicates = FALSE
	destroy_grilles = TRUE
	placement_weight = 1

/datum/map_template/ruin/dababy/mesas
	name = "Mesas Gang"
	id = "las-mesas"
	description = "Le dieron una paliza a uno, una pena."
	suffix = "mesas_locas.dmm"
	placement_weight = 18
	allow_duplicates = FALSE
	destroy_grilles = TRUE
	cost = 3

/datum/map_template/ruin/dababy/guillo
	name = "Guillotina"
	id = "guillotina-desastre"
	description = "Verdugo."
	suffix = "guillotina.dmm"
	allow_duplicates = FALSE
	destroy_grilles = TRUE
	cost = 1

/datum/map_template/ruin/dababy/derecha
	name = "Giro a la Derecha"
	id = "derecha-sala"
	description = "Derecha."
	suffix = "vuelta_derecha.dmm"
	cost = 3

/datum/map_template/ruin/dababy/pasillo_horizontal
	name = "Pasillo Horizontal"
	id = "pasillo-hor"
	description = "Arriba y Abajo."
	suffix = "pasillo_vertical.dmm"

/datum/map_template/ruin/dababy/pasillo_vertical
	name = "Pasillo Vertical"
	id = "pasillo-vert"
	description = "Izquierda y Derecha."
	suffix = "pasillo_horizontal.dmm"

/datum/map_template/ruin/dababy/yeehaw
	name = "Sheriff"
	id = "sherrif-yeehaw"
	description = "Revolver vaquero, ulala."
	suffix = "sheriff.dmm"
	destroy_grilles = TRUE
	placement_weight = 12 // tampoco para que salga siempre, eh
	cost = 18 // Me pregunto por que costara tanto...

/datum/map_template/ruin/dababy/hiddenbase
	name = "Base Abandonada Ilicita" // Es muy grande, quita mucho espacio para mas ruinas
	id = "hidden-base"
	description = "A minar y un ejercito de borgs saldra."
	suffix = "hiddenbase.dmm"
	destroy_grilles = TRUE
	allow_duplicates = FALSE
	placement_weight = 19 // Ligera desventaja para la ruina
	cost = 2 // el precio se lo lleva el espacio que ocupara

/datum/map_template/ruin/dababy/leclown
	name = "Le Clown Horde"
	id = "horde-clown"
	description = "HOOOOOOONG"
	suffix = "leclown.dmm"
	destroy_grilles = TRUE
	placement_weight = 5
	max_duplictates = 2 // Tampoco es para llenar todo de payasos. Y son 3 no 2.
	cost = 3

/datum/map_template/ruin/dababy/pyromain
	name = "Pyro"
	id = "fire-lovers"
	description = ";Plasmafire en maint!!!"
	suffix = "pyromain.dmm"
	destroy_grilles = TRUE
	allow_duplicates = FALSE
	max_duplictates = 1
	cost = 4

/datum/map_template/ruin/dababy/vendinghole
	name = "Vending Realm"
	id = "vending-lovers"
	description = "Todas las vendings que quisieras tener."
	suffix = "vendinghole.dmm"
	destroy_grilles = TRUE
	allow_duplicates = FALSE
	placement_weight = 10
	cost = 5

/datum/map_template/ruin/dababyprincipal/abracho
	name = "Laberinto del Abismo"
	id = "principal-facehugger"
	description = "Un camino muy facil de resolver si tienes botas de salto."
	suffix = "abrazitos.dmm"

/datum/map_template/ruin/dababyprincipal/chamqueta
	name = "El Valhalla de las Chaquetas"
	id = "principal-chamqueta"
	description = "Un monton de chaquetas en una sala dorada y mistica, un par de floor safes y armaduras poderosas aguardan adentro."
	suffix = "chaquetas.dmm"

/datum/map_template/ruin/dababyprincipal/wizard
	name = "Puente Magico del Abismo"
	id = "principal-wizard"
	description = "Un puente a dos varitas, ¿lograras salir con vida?"
	suffix = "twoofthem.dmm"
