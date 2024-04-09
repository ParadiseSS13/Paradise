/obj/item/clothing/gloves/color
	dyeable = TRUE

/obj/item/clothing/gloves/color/yellow
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/yellow/fake
	siemens_coefficient = 1

/// Cheap Chinese Crap
/obj/item/clothing/gloves/color/fyellow
	name = "budget insulated gloves"
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05
	item_color="yellow"
	resistance_flags = NONE

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	name = "worn out insulated gloves"
	desc = "Old and worn out insulated gloves, hopefully they still work."

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/color/black
	name = "black gloves"
	desc = "These gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	item_color="black"
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


/obj/item/clothing/gloves/color/black/hos
	item_color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/ce
	item_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/color/black/thief
	pickpocket = 1

/obj/item/clothing/gloves/color/black/attackby(obj/item/W as obj, mob/user as mob, params)
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
	desc = "These gloves are fire-resistant. They seem thicker than usual."
	safe_from_poison = TRUE

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	item_color="orange"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	item_color = "red"

/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	item_color = "rainbow"

/obj/item/clothing/gloves/color/rainbow/clown
	item_color = "clown"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	item_color="blue"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	item_color="purple"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	item_color="green"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	item_color="grey"

/obj/item/clothing/gloves/color/grey/rd
	item_color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/grey/hop
	item_color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	item_color="light brown"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	item_color="brown"

/obj/item/clothing/gloves/color/brown/cargo
	item_color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	item_color="white"
	transfer_prints = TRUE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are stronger than latex."
	icon_state = "nitrile"
	item_state = "nitrilegloves"
	transfer_prints = FALSE
	item_color = "medical"

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "wgloves"
	item_color="mime"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)

/obj/item/clothing/gloves/color/white/redcoat
	item_color = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.


/obj/item/clothing/gloves/color/captain
	name = "captain's gloves"
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	icon_state = "captain"
	item_state = "captain"
	item_color = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
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
	item_state = "furgloves"
	transfer_prints = TRUE
	transfer_blood = TRUE
