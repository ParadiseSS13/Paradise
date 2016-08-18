//MISC WEAPONS

//This file contains /obj/item/weapon's that do not fit in any other category and are not big enough to warrant individual files.
/*CURRENT CONTENTS
	Ball Toy
	Cane
	Cardboard Tube
	Fan
	Gaming Kit
	Gift
	Kidan Globe
	Lightning
	Newton Cradle
	PAI cable
	Red Phone
*/

/obj/item/weapon/balltoy
	name = "ball toy"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "rollball"
	desc = "A device bored paper pushers use to remind themselves that the time did not stop yet."

/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2
	materials = list(MAT_METAL=50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/cane/is_crutch()
	return 1

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = 1
	throw_speed = 4
	throw_range = 5



/obj/item/weapon/fan
	name = "desk fan"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "fan"
	desc = "A smal desktop fan. Button seems to be stuck in the 'on' position."

/*
/obj/item/weapon/game_kit
	name = "Gaming Kit"
	icon = 'icons/obj/items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5
*/

/obj/item/weapon/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = 4

/obj/item/weapon/kidanglobe
	name = "Kidan homeworld globe"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "kidanglobe"
	desc = "A globe of the Kidan homeworld."

/obj/item/weapon/lightning
	name = "lightning"
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	desc = "test lightning"

	New()
		icon = midicon
		icon_state = "1"

	afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
		var/angle = get_angle(A, user)
//		to_chat(world, angle)
		angle = round(angle) + 45
		if(angle > 180)
			angle -= 180
		else
			angle += 180

		if(!angle)
			angle = 1
//		to_chat(world, "adjusted [angle]")
		icon_state = "[angle]"
//		to_chat(world, "[angle] [(get_dist(user, A) - 1)]")
		user.Beam(A, "lightning", 'icons/obj/zap.dmi', 50, 15)

/obj/item/weapon/newton
	name = "newton cradle"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "newton"
	desc = "A device bored paper pushers use to remind themselves that the time did not stop yet. Contains gravity."

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

	var/obj/machinery/machine

/obj/item/weapon/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	flags = CONDUCT
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = 2
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'
	var/cooldown = 0

/obj/item/weapon/phone/attack_self(mob/user)
	if(cooldown < world.time - 20)
		playsound(user.loc, 'sound/weapons/ring.ogg', 50, 1)
		cooldown = world.time