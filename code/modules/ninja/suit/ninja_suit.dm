
/*

Contents:
- The Ninja Space Suit
- Ninja Space Suit Procs

*/

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/melee/baton, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	slowdown = 0
	flags_inv = HIDEJUMPSUIT|HIDETAIL
	armor = list(MELEE = 75, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 15, FIRE = INFINITY, ACID = INFINITY)

	var/suitActive = 0
	var/suitBusy = 0

	var/obj/item/stock_parts/cell/suitCell
	var/obj/item/clothing/head/helmet/space/space_ninja/suitHood
	var/obj/item/clothing/gloves/space_ninja/suitGloves
	var/obj/item/clothing/shoes/space_ninja/suitShoes
	var/obj/item/clothing/mask/gas/space_ninja/suitMask
	var/mob/living/carbon/human/suitOccupant

/obj/item/clothing/suit/space/space_ninja/get_cell()
	return suitCell

/obj/item/clothing/suit/space/space_ninja/proc/toggle_suit_lock(mob/living/carbon/human/user)
	if(!suitActive)
		if(!istype(user.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate user.\nABORTING...</span>")
			return 0
		if(!istype(user.head, /obj/item/clothing/head/helmet/space/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate hood.\nABORTING...</span>")
			return 0
		if(!istype(user.gloves, /obj/item/clothing/gloves/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate gloves.\nABORTING...</span>")
			return 0
		if(!istype(user.shoes, /obj/item/clothing/shoes/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate foot gear.\nABORTING...</span>")
			return 0
		if(!istype(user.wear_mask, /obj/item/clothing/mask/gas/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate mask.\nABORTING...</span>")
			return 0

		suitHood = user.head
		suitMask = user.wear_mask
		suitGloves = user.gloves
		suitShoes = user.shoes
		suitOccupant = user

		set_nodrop(TRUE)
		suitHood.set_nodrop(TRUE)
		suitMask.set_nodrop(TRUE)
		suitGloves.set_nodrop(TRUE)
		suitGloves.pickpocket = 1
		suitShoes.set_nodrop(TRUE)
		suitShoes.slowdown = -2

		icon_state = (user.gender == MALE ? "s-ninjan" : "s-ninjanf")
		suitGloves.icon_state = "s-ninjan"

		return 1

	else
		set_nodrop(FALSE)
		suitHood.set_nodrop(FALSE)
		suitMask.set_nodrop(FALSE)
		suitGloves.set_nodrop(FALSE)
		suitGloves.pickpocket = 0
		suitShoes.set_nodrop(FALSE)
		suitShoes.slowdown = -1
		icon_state = "s-ninja"
		suitGloves.icon_state = "s-ninja"

		suitHood = null
		suitMask = null
		suitGloves = null
		suitShoes = null
		suitOccupant = null

		return 1
