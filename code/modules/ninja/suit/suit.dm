
/*

Contents:
- The Ninja Space Suit
- Ninja Space Suit Procs

*/

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/melee/baton, /obj/item/tank, /obj/item/stock_parts/cell)
	slowdown = 0
	unacidable = 1
	armor = list(melee = 60, bullet = 60, laser = 45, energy = 15, bomb = 30, bio = 30, rad = 30)

	var/suitActive = 0
	var/suitBusy = 0

	var/obj/item/stock_parts/cell/suitCell
	var/obj/item/clothing/head/helmet/space/space_ninja/suitHood
	var/obj/item/clothing/gloves/space_ninja/suitGloves
	var/obj/item/clothing/shoes/space_ninja/suitShoes
	var/obj/item/clothing/mask/gas/voice/space_ninja/suitMask
	var/mob/living/carbon/human/suitOccupant

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
		if(!istype(user.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
			to_chat(user, "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate mask.\nABORTING...</span>")
			return 0

		suitHood = user.head
		suitMask = user.wear_mask
		suitGloves = user.gloves
		suitShoes = user.shoes
		suitOccupant = user

		flags |= NODROP
		suitHood.flags |= NODROP
		suitMask.flags |= NODROP
		suitGloves.flags |= NODROP
		suitGloves.pickpocket = 1
		suitShoes.flags |= NODROP
		suitShoes.slowdown = -2

		icon_state = (user.gender == MALE ? "s-ninjan" : "s-ninjanf")
		suitGloves.icon_state = "s-ninjan"
		suitGloves.item_state = "s-ninjan"

		return 1

	else
		flags &= ~NODROP
		suitHood.flags &= ~NODROP
		suitMask.flags &= ~NODROP
		suitGloves.flags &= ~NODROP
		suitGloves.pickpocket = 0
		suitShoes.flags &= ~NODROP
		suitShoes.slowdown = -1
		icon_state = "s-ninja"
		suitGloves.icon_state = "s-ninja"
		suitGloves.item_state = "s-ninja"

		suitHood = null
		suitMask = null
		suitGloves = null
		suitShoes = null
		suitOccupant = null

		return 1