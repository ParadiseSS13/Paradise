/obj/item/clothing/under/plasmaman/engineering
	name = "engineering plasma envirosuit"
	desc = "An airtight suit designed to be used by plasmamen employed as engineers, the usual purple stripes being replaced by engineering's orange. It protects the user from fire and acid damage."
	icon_state = "engineer_envirosuit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/under/plasmaman/engineering/ce
	name = "chief engineer's plasma envirosuit"
	desc = "An airtight suit designed to be used by plasmamen employed as the chief engineer."
	icon_state = "ce_envirosuit"

/obj/item/clothing/under/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit"
	desc = "An airtight suit designed to be used by plasmamen employed as atmos technicians, the usual purple stripes being replaced by atmos' blue."
	icon_state = "atmos_envirosuit"

/obj/item/clothing/under/plasmaman/atmospherics/contortionist
	desc = "An airtight suit designed to be used by plasmemen for squeezing through narrow vents."
	resistance_flags = FIRE_PROOF

/obj/item/clothing/under/plasmaman/atmospherics/contortionist/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_JUMPSUIT)
		return
	if(!user.ventcrawler)
		user.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/clothing/under/plasmaman/atmospherics/contortionist/dropped(mob/living/carbon/human/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_JUMPSUIT) != src)
		return
	if(!user.get_int_organ(/obj/item/organ/internal/heart/gland/ventcrawling)) // This is such a snowflaky check
		user.ventcrawler = VENTCRAWLER_NONE

/obj/item/clothing/under/plasmaman/atmospherics/contortionist/proc/check_clothing(mob/user)
	//Allowed to wear: glasses, shoes, gloves, pockets, mask, jumpsuit (obviously), and helmet (obviously)
	var/list/slot_must_be_empty = list(ITEM_SLOT_BACK, ITEM_SLOT_HANDCUFFED, ITEM_SLOT_LEGCUFFED, ITEM_SLOT_LEFT_HAND, ITEM_SLOT_RIGHT_HAND, ITEM_SLOT_BELT, ITEM_SLOT_OUTER_SUIT)
	for(var/slot_id in slot_must_be_empty)
		if(user.get_item_by_slot(slot_id))
			to_chat(user,"<span class='warning'>You can't fit inside while wearing [user.get_item_by_slot(slot_id)].</span>")
			return FALSE
	return TRUE
