/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	slot = "liver"
	var/alcohol_intensity = 1

/obj/item/organ/internal/liver/on_life()


/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. It has no benefits over an organic liver, but is easy to produce."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
