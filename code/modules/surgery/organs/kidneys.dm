/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"
	slot = "kidneys"

/obj/item/organ/internal/kidneys/cybernetic
	name = "cybernetic kidneys"
	icon_state = "kidneys-c"
	desc = "An electronic device designed to mimic the functions of human kidneys. It has no benefits over a pair of organic kidneys, but is easy to produce."
	origin_tech = "biotech=4"
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	status = ORGAN_ROBOT

/obj/item/organ/internal/kidneys/cybernetic/upgraded
	name = "upgraded cybernetic kidneys"
	icon_state = "kidneys-c-u"
	desc = "An electronic device designed to mimic the functions of human kidneys. It passively heals any toxin damage the user might have."
	origin_tech = "biotech=5"

/obj/item/organ/internal/kidneys/cybernetic/upgraded/on_life()
	if(!owner)
		return
	owner.adjustToxLoss(-0.4)
