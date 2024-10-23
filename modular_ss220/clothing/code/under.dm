/obj/item/clothing/under/costume/katarina_cybersuit
	name = "кибер-костюм Катарины"
	desc = "Кибер-костюм так называемой Катарины."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "katarina_cybersuit"
	icon_override = 'modular_ss220/clothing/icons/mob/under.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	item_color = "katarina_cybersuit"
	sprite_sheets = null

/obj/item/clothing/under/costume/katarina_suit
	name = "костюм Катарины"
	desc = "Костюм так называемой Катарины."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "katarina_suit"
	icon_override = 'modular_ss220/clothing/icons/mob/under.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	item_color = "katarina_suit"
	sprite_sheets = null

/obj/item/clothing/under/rank/civilian/chef/red
	name = "chef's red uniform"
	desc = "Униформа повара с пуговицами на одну сторону."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "chef_red"
	item_color = "chef_red"
	sprite_sheets = list(
		"Abductor" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Ancient Skeleton" 	= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Diona" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Drask" 			= 	'modular_ss220/clothing/icons/mob/species/drask/under.dmi',
		"Golem" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Grey" 				= 	'modular_ss220/clothing/icons/mob/species/grey/under.dmi',
		"Human" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Kidan" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Machine"			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Monkey" 			= 	'modular_ss220/clothing/icons/mob/species/monkey/under.dmi',
		"Nian" 				= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Plasmaman" 		= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Shadow" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Skrell" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Slime People" 		= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Tajaran" 			= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Unathi" 			= 	'modular_ss220/clothing/icons/mob/species/unathi/under.dmi',
		"Vox" 				= 	'modular_ss220/clothing/icons/mob/species/vox/under.dmi',
		"Vulpkanin" 		= 	'modular_ss220/clothing/icons/mob/under.dmi',
		"Nucleation"		=	'modular_ss220/clothing/icons/mob/under.dmi',
		)

/obj/item/clothing/under/towel
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Plasmaman" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/under.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/under.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/under.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/under.dmi',
		"Monkey" = 'modular_ss220/clothing/icons/mob/species/monkey/under.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Adbuctor" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Ancient Skeleton" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/under.dmi'
	)
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	has_sensor = 0

/obj/item/clothing/under/towel/attackby(obj/item/S, mob/user, params)
	. = ..()
	if(istype(S, /obj/item/toy/crayon/spraycan))
		var/obj/item/toy/crayon/spraycan/spcan = S
		var/list/hsl = rgb2hsl(hex2num(copytext(spcan.colour, 2, 4)), hex2num(copytext(spcan.colour, 4, 6)), hex2num(copytext(spcan.colour, 6, 8)))
		hsl[3] = max(hsl[3], 0.4)
		var/list/rgb = hsl2rgb(arglist(hsl))
		var/new_color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"
		color = new_color
		to_chat(user, "<span class='notice'>Вы перекрашиваете [src.name].</span>")
		return

/obj/item/clothing/under/towel/long
	name = "полотенце"
	desc = "Полотенце, сотканное из синтетической ткани. Можно обмотать вокруг тела."
	icon_state = "towel_long"
	item_color = "towel_long"

/obj/item/clothing/under/towel/long/alt
	name = "махровое полотенце"
	desc = "Полотенце, сотканное из синтетической ткани, на взгляд шершавое. Можно обмотать вокруг тела."
	icon_state = "towel_long_alt"
	item_color = "towel_long_alt"

/obj/item/clothing/under/towel/short
	name = "маленькое полотенце"
	desc = "Полотенце, сотканное из синтетической ткани, но маленькое. Можно обмотать вокруг тела."
	icon_state = "towel_short"
	item_color = "towel_short"

/obj/item/clothing/under/towel/short/alt
	name = "маленькое махровое полотенце"
	desc = "Полотенце, сотканное из синтетической ткани, на взгляд шершавое и маленькое. Можно обмотать вокруг тела."
	icon_state = "towel_short_alt"
	item_color = "towel_short_alt"

// Длинное полотенце
/obj/item/clothing/under/towel/long/red
	name = "красное полотенце"
	color = "#EE204D"

/obj/item/clothing/under/towel/long/green
	name = "зелёное полотенце"
	color = "#32CD32"

/obj/item/clothing/under/towel/long/blue
	name = "синее полотенце"
	color = "#1E90FF"

/obj/item/clothing/under/towel/long/orange
	name = "оранжевое полотенце"
	color = "#FFA500"

/obj/item/clothing/under/towel/long/purple
	name = "фиолетовое полотенце"
	color = "#DA70D6"

/obj/item/clothing/under/towel/long/cyan
	name = "голубое полотенце"
	color = "#40E0D0"

/obj/item/clothing/under/towel/long/brown
	name = "коричневое полотенце"
	color = "#DEB887"

// Длинное махровое полотенце
/obj/item/clothing/under/towel/long/alt/red
	name = "красное махровое полотенце"
	color = "#EE204D"

/obj/item/clothing/under/towel/long/alt/green
	name = "зелёное махровое полотенце"
	color = "#32CD32"

/obj/item/clothing/under/towel/long/alt/blue
	name = "синее махровое полотенце"
	color = "#1E90FF"

/obj/item/clothing/under/towel/long/alt/orange
	name = "оранжевое махровое полотенце"
	color = "#FFA500"

/obj/item/clothing/under/towel/long/alt/purple
	name = "фиолетовое махровое полотенце"
	color = "#DA70D6"

/obj/item/clothing/under/towel/long/alt/cyan
	name = "голубое махровое полотенце"
	color = "#40E0D0"

/obj/item/clothing/under/towel/long/alt/brown
	name = "коричневое махровое полотенце"
	color = "#DEB887"

// Маленькое полотенце
/obj/item/clothing/under/towel/short/red
	name = "красное маленькое полотенце"
	color = "#EE204D"

/obj/item/clothing/under/towel/short/green
	name = "зелёное маленькое полотенце"
	color = "#32CD32"

/obj/item/clothing/under/towel/short/blue
	name = "синее маленькое полотенце"
	color = "#1E90FF"

/obj/item/clothing/under/towel/short/orange
	name = "оранжевое маленькое полотенце"
	color = "#FFA500"

/obj/item/clothing/under/towel/short/purple
	name = "фиолетовое маленькое полотенце"
	color = "#DA70D6"

/obj/item/clothing/under/towel/short/cyan
	name = "голубое маленькое полотенце"
	color = "#40E0D0"

/obj/item/clothing/under/towel/short/brown
	name = "коричневое маленькое полотенце"
	color = "#DEB887"

// Маленькое махровое полотенце
/obj/item/clothing/under/towel/short/alt/red
	name = "красное махровое маленькое полотенце"
	color = "#EE204D"

/obj/item/clothing/under/towel/short/alt/green
	name = "зелёное махровое маленькое полотенце"
	color = "#32CD32"

/obj/item/clothing/under/towel/short/alt/blue
	name = "синее махровое маленькое полотенце"
	color = "#1E90FF"

/obj/item/clothing/under/towel/short/alt/orange
	name = "оранжевое махровое маленькое полотенце"
	color = "#FFA500"

/obj/item/clothing/under/towel/short/alt/purple
	name = "фиолетовое махровое маленькое полотенце"
	color = "#DA70D6"

/obj/item/clothing/under/towel/short/alt/cyan
	name = "голубое махровое маленькое полотенце"
	color = "#40E0D0"

/obj/item/clothing/under/towel/short/alt/brown
	name = "коричневое махровое маленькое полотенце"
	color = "#DEB887"

/* EI uniform */
/obj/item/clothing/under/ei_combat
	name = "тактическая водолазка Gold on Black"
	desc = "Все то же удобство, но в прекрасной гамме угольных оттенков."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "ei_combat"
	item_color = "ei_combat"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/under.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/under.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/under.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/under.dmi',
	)

/obj/item/clothing/under/ei_skirt
	name = "блузка с юбкой Gold on Black"
	desc = "Не волнуйтесь, запачкать её будет крайне сложно, так что вы всегда будете прелестны и очаровательны. Даже если руки по локоть в крови."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "ei_skirt"
	item_color = "ei_skirt"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/under.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/under.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/under.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/under.dmi',
	)

/obj/item/clothing/under/ei_skirt_alt
	name = "юбка «Солнце» от EI"
	desc = "Юбка «Солнце» в классических цветах корпорации EI."
	icon = 'modular_ss220/clothing/icons/object/under.dmi'
	icon_state = "ei_skirt_alt"
	item_color = "ei_skirt_alt"
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/under.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/under.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/under.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/under.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/under.dmi',
	)
