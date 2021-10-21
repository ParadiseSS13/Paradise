/obj/item/clothing/head/hooded/ablative
	name = "ablative hood"
	desc = "Hood hopefully belonging to an ablative trenchcoat. Includes a visor for cool-o-vision."
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "ablativehood"
	hispania_icon = TRUE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	strip_delay = 30
	var/hit_reflect_chance = 50
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/hooded/ablative/IsReflect(def_zone)
	if(!(def_zone in BODY_ZONE_HEAD)) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/hooded/ablative
	name = "ablative trenchcoat"
	desc = "Experimental trenchcoat specially crafted to reflect and absorb laser and disabler shots. Don't expect it to do all that much against an axe or a shotgun, however."
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "ablativecoat"
	item_state = "ablativecoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	hoodtype = /obj/item/clothing/head/hooded/ablative
	strip_delay = 30
	put_on_delay = 40
	var/hit_reflect_chance = 50
	hispania_icon = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/hooded/ablative/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/big_chungus
	name = "funny rabbit suit"
	desc = "This large suit of armour, resembling a grotesquely obese form of the iconic Bugs Bunny is clearly miles above most modern body protection; still wouldn't wear it over your dead dignity."
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "chungus"
	item_state = "chungus"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hispania_icon = TRUE
	species_restricted = list("Human", "Slime", "Machine", "Kidan", "Skrell", "Diona" )

/obj/item/clothing/suit/chasuble	
	name = "Christian Chasuble"
	desc = "A red Chasuble used by Christian priests in celebrations. Made by D&N Corp."
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "christianchasuble"
	item_state = "christianchasuble"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS
	strip_delay = 50
	put_on_delay = 60
	species_restricted = list("exclude", "Grey", "Vox")
	hispania_icon = TRUE

/obj/item/clothing/suit/chasuble/elzra
	name = "Elzra Chasuble"	
	desc = "A red Chasuble used by Lady Elzra priests in celebrations. Made by D&N Corp."
	icon_state = "elzrachasuble"
	item_state = "elzrachasuble"

/obj/item/clothing/suit/chasuble/bishop
	name = "Bishop's Christian Chasuble"
	desc = "A red Chasuble used by Christian Bishops for special celebrations. Made by D&N Corp."
	icon_state = "christianchasuble2"
	item_state = "christianchasuble2"
	
