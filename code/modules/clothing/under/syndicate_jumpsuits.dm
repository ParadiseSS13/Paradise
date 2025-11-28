/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "syndicate"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	inhand_icon_state = "bl_suit"
	has_sensor = FALSE
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 35)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/syndicate.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/syndicate.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/syndicate.dmi'
	)

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"

/obj/item/clothing/under/syndicate/greyman
	name = "greyman henley"
	desc = "Attire for someone who finds it hard to survive in the safest place known to man - urban environment."
	icon_state = "greyman"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 40, ACID = 35)

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 35)

/obj/item/clothing/under/syndicate/sniper
	name = "tactical suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "tactical_suit"

/obj/item/clothing/under/syndicate/silicon_cham
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. <b>This one has extra cybernetic modifications.</b>"
	blockTracking = TRUE

/obj/item/clothing/under/syndicate/silicon_cham/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_JUMPSUIT)
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, "silicon_cham[UID()]")
		user.set_invisible(SEE_INVISIBLE_LIVING)
		to_chat(user, "<span class='notice'>You feel a slight shiver as the cybernetic obfuscators activate.</span>")

/obj/item/clothing/under/syndicate/silicon_cham/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, "silicon_cham[UID()]")
		user.set_invisible(INVISIBILITY_MINIMUM)
		to_chat(user, "<span class='notice'>You feel a slight shiver as the cybernetic obfuscators deactivate.</span>")
