
/obj/item/clothing/suit/big_chungus
	name = "funny rabbit suit"
	desc = "This large suit of armour, resembling a grotesquely obese form of the iconic Bugs Bunny is clearly miles above most modern body protection; still wouldn't wear it over your dead dignity."
	icon = 'modular_hispania/icons/mob/suit.dmi'
	icon_state = "chungus"
	item_state = "chungus"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hispania_icon = TRUE
	species_restricted = list("Human", "Slime", "Machine", "Kidan", "Skrell", "Diona" )

/obj/item/clothing/suit/chasuble
	name = "Christian Chasuble"
	desc = "A red Chasuble used by Christian priests in celebrations. Made by D&N Corp."
	icon = 'modular_hispania/icons/mob/suit.dmi'
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

