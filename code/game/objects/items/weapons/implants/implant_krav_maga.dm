/obj/item/implant/krav_maga
	name = "krav maga implant"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	activated = IMPLANT_ACTIVATED_ACTIVE
	origin_tech = "materials=2;biotech=4;combat=5;syndicate=4"
	implant_data = /datum/implant_fluff/krav_maga
	implant_state = "implant-default"

	var/datum/martial_art/krav_maga/style = new

/obj/item/implant/krav_maga/activate()
	var/mob/living/carbon/human/H = imp_in
	if(!ishuman(H) || !H.mind)
		return
	if(istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		style.remove(H)
	else
		style.teach(H, TRUE)

/obj/item/implanter/krav_maga
	name = "implanter (krav maga)"

/obj/item/implanter/krav_maga/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/krav_maga(src)

/obj/item/implantcase/krav_maga
	name = "implant case - 'Krav Maga'"
	desc = "A glass case containing an implant that can teach the user the art of Krav Maga."

/obj/item/implantcase/krav_maga/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/krav_maga(src)
