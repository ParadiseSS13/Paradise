/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/black/greytide
	flags = NODROP

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"

/obj/item/clothing/shoes/leather/jump
	name = "boots of jumping"
	desc = "Boots with the sole purpose of jumping."

/obj/item/clothing/shoes/leather/jump/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_SHOES || !ishuman(user))
		return
	ADD_TRAIT(user, TRAIT_BOOTS_OF_JUMPING, "boots_of_jumping[UID()]")

/obj/item/clothing/shoes/leather/jump/dropped(mob/user, silent)
	. = ..()
	if(!ishuman(user) || !HAS_TRAIT(user, TRAIT_BOOTS_OF_JUMPING))
		return
	REMOVE_TRAIT(user, TRAIT_BOOTS_OF_JUMPING, "boots_of_jumping[UID()]")

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	var/obj/item/restraints/handcuffs/shackles

/obj/item/clothing/shoes/orange/Destroy()
	QDEL_NULL(shackles)
	return ..()

/obj/item/clothing/shoes/orange/attack_self__legacy__attackchain(mob/user)
	if(shackles)
		user.put_in_hands(shackles)
		shackles = null
		slowdown = SHOES_SLOWDOWN
		icon_state = "orange"

/obj/item/clothing/shoes/orange/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/restraints/handcuffs) && !shackles)
		if(user.drop_item())
			I.forceMove(src)
			shackles = I
			slowdown = 15
			icon_state = "orange1"
			return
	return ..()
