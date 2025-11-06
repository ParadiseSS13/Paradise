/obj/item/clothing/gloves/color
	dyeable = TRUE

/obj/item/clothing/gloves/color/yellow
	name = "insulated gloves"
	desc = "A pair of rubber-lined industrial gloves. They'll protect the wearer from electrical shocks."
	icon_state = "yellow"
	siemens_coefficient = 0
	permeability_coefficient = 0.01
	resistance_flags = NONE

/obj/item/clothing/gloves/color/yellow/fake
	siemens_coefficient = 1

/// Cheap Chinese Crap
/obj/item/clothing/gloves/color/fyellow
	name = "budget insulated gloves"
	desc = "A pair of knock-off insulated gloves. They might stop a shock, but it'll be a gamble."
	icon_state = "yellow"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.01
	resistance_flags = NONE

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0, 0.5, 0.5, 0.5, 0.5, 0.75, 1.5)

/obj/item/clothing/gloves/color/fyellow/old
	name = "worn out insulated gloves"
	desc = "An old pair of insulated gloves. While a lot of the rubber is worn away, enough should be left to at least reduce any electrical shocks. Probably."

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0, 0, 0, 0.5, 0.5, 0.5, 0.75)

/obj/item/clothing/gloves/color/black
	name = "black gloves"
	desc = "A pair of black gloves made of fire-resistant fabric."
	icon_state = "black"
	inhand_icon_state = "bgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	var/can_be_cut = 1
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)
	permeability_coefficient = 0.1

/obj/item/clothing/gloves/color/black/thief
	pickpocket = 1

/obj/item/clothing/gloves/color/black/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wirecutters))
		if(can_be_cut && icon_state == initial(icon_state))//only if not dyed
			var/confirm = tgui_alert(user, "Do you want to cut off the gloves fingertips? Warning: It might destroy their functionality.", "Cut tips?", list("Yes","No"))
			if(get_dist(user, src) > 1)
				to_chat(user, "You have moved too far away.")
				return
			if(confirm == "Yes")
				to_chat(user, "<span class='notice'>You snip the fingertips off of [src].</span>")
				playsound(user.loc, W.usesound, rand(10,50), 1)
				var/obj/item/clothing/gloves/fingerless/F = new/obj/item/clothing/gloves/fingerless(user.loc)
				if(pickpocket)
					F.pickpocket = FALSE
				qdel(src)
				return
	..()

/obj/item/clothing/gloves/color/black/poisoner
	desc = "A pair of thick black gloves. They're coated with a hydrophobic material that repels liquids."
	safe_from_poison = TRUE

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"

/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "A pair of rubber-lined industrial gloves. They'll protect the wearer from electrical shocks."
	siemens_coefficient = 0
	permeability_coefficient = 0.01
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"

/obj/item/clothing/gloves/color/rainbow/clown

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	inhand_icon_state = "bgloves"

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "A pair of thin sterile gloves made from latex. The material's thin enough that fingerprints can still be transferred to objects you touch."
	icon_state = "latex"
	inhand_icon_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	transfer_prints = TRUE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "A pair of high-quality sterile gloves made from thick nitrile material. "
	icon_state = "nitrile"
	transfer_prints = FALSE

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "A pair of white silk gloves for individuals of class and discerning taste."
	icon_state = "white"
	inhand_icon_state = "lgloves"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)

/obj/item/clothing/gloves/color/captain
	name = "captain's gloves"
	desc = "A pair of very expensive gloves made of reinforced blue & gold fabric. They're insulated against both electrical shocks and extreme temperatures."
	icon_state = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.01
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 115, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)

/obj/item/clothing/gloves/furgloves
	desc = "These gloves are warm and furry."
	name = "fur gloves"
	icon_state = "furglovesico"
	transfer_prints = TRUE
