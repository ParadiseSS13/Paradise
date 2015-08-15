//NUCLEATION ORGAN
/obj/item/organ/nucleation
	name = "nucleation organ"
	icon = 'icons/obj/surgery.dmi'
	desc = "A crystalized human organ. /red It has a strangely iridescent glow."

/obj/item/organ/nucleation/resonant_crystal
	name = "resonant crystal"
	icon_state = "resonant-crystal"
	organ_tag = "resonant crystal"
	parent_organ = "head"

/obj/item/organ/nucleation/strange_crystal
	name = "strange crystal"
	icon_state = "strange-crystal"
	organ_tag = "strange crystal"
	parent_organ = "chest"

/obj/item/organ/eyes/luminescent_crystal
	name = "luminescent eyes"
	icon_state = "crystal-eyes"
	organ_tag = "luminescent eyes"
	light_color = "#1C1C00"
	parent_organ = "head"

	New()
		set_light(2)

/obj/item/organ/brain/crystal
	name = "crystalized brain"
	icon_state = "crystal-brain"
	organ_tag = "crystalized brain"
	