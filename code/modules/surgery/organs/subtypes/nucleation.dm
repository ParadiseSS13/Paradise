//NUCLEATION ORGAN
/obj/item/organ/internal/nucleation
	name = "nucleation organ"
	icon = 'icons/obj/surgery.dmi'
	desc = "A crystalized human organ. /red It has a strangely iridescent glow."

/obj/item/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	icon_state = "resonant-crystal"
	organ_tag = "resonant crystal"
	parent_organ = "head"
	slot = "res_crystal"

/obj/item/organ/internal/nucleation/strange_crystal
	name = "strange crystal"
	icon_state = "strange-crystal"
	organ_tag = "strange crystal"
	parent_organ = "chest"
	slot = "heart"

/obj/item/organ/internal/eyes/luminescent_crystal
	name = "luminescent eyes"
	icon_state = "crystal-eyes"
	organ_tag = "luminescent eyes"
	light_color = "#1C1C00"

/obj/item/organ/internal/eyes/luminescent_crystal/New()
	set_light(2)
	..()

/obj/item/organ/internal/brain/crystal
	name = "crystallized brain"
	icon_state = "crystal-brain"
	organ_tag = "crystallized brain"
