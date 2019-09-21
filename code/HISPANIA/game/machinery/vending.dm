///Hispania Civilians Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//code by Danaleja2005

/obj/machinery/vending/walldrobe
	name = "\improper WallDrobe"
	desc = "Wall-mounted Clothes dispenser. Made by D&N Corp."
	product_ads = "Dress up in fashion and wear our amazing uniforms, hats, suits made of the best material, only with us N&D Corp!."
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "WallDrobe"
	icon_deny = "WallDrobe-deny"
	icon_vend = "WallDrobe-vend"
	density = FALSE //It is wall-mounted, and thus, not dense. --SuperxpdudeS
	vend_delay = 12

/obj/machinery/vending/walldrobe/cap
	name = "\improper Captain's WallDrobe"
	req_access = list(access_captain)
	products = list(/obj/item/clothing/under/rank/command/captain/formal/light = 2,
					/obj/item/clothing/under/rank/command/captain/formal/dark = 2,
					/obj/item/clothing/head/caphat/dark = 2,
					/obj/item/clothing/head/caphat/light = 2,
					/obj/item/clothing/suit/armor/vest/captrenchcoat = 2)

/obj/machinery/vending/walldrobe/rd
	name = "\improper Research Director's WallDrobe"
	req_access = list(access_rd)
	products = list(/obj/item/clothing/suit/storage/labcoat/RDlargedark = 2,
					/obj/item/clothing/suit/storage/labcoat/RDlargeroundcutdark = 2)


