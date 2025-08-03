/obj/item/bio_chip/krav_maga
	name = "krav maga bio-chip"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	origin_tech = "materials=2;biotech=4;combat=5;syndicate=4"
	implant_data = /datum/implant_fluff/krav_maga

	var/datum/martial_art/krav_maga/style = new

/obj/item/bio_chip/krav_maga/activate()
	var/mob/living/carbon/human/H = imp_in
	if(!ishuman(H) || !H.mind)
		return
	if(istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		style.remove(H)
	else
		style.teach(H, TRUE)

/obj/item/bio_chip_implanter/krav_maga
	name = "bio-chip implanter (krav maga)"
	implant_type = /obj/item/bio_chip/krav_maga

/obj/item/bio_chip_case/krav_maga
	name = "bio-chip case - 'Krav Maga'"
	desc = "A glass case containing a bio-chip that can teach the user the art of Krav Maga."
	implant_type = /obj/item/bio_chip/krav_maga
