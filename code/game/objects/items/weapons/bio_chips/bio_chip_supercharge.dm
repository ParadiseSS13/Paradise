/obj/item/bio_chip/supercharge
	name = "supercharge bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=3;combat=5;syndicate=4"
	uses = 3
	implant_data = /datum/implant_fluff/adrenaline
	implant_state = "implant-syndicate"

/obj/item/bio_chip/supercharge/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel an electric sensation as your components enter overdrive!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.stand_up(TRUE)
	SEND_SIGNAL(imp_in, COMSIG_LIVING_CLEAR_STUNS)

	imp_in.reagents.add_reagent("recal", 10)
	imp_in.reagents.add_reagent("surge_plus", 10)
	imp_in.reagents.add_reagent("synthetic_omnizine_no_addiction", 10)
	if(!uses)
		qdel(src)

/obj/item/bio_chip_implanter/supercharge
	name = "bio-chip implanter (supercharge)"
	implant_type = /obj/item/bio_chip/supercharge

/obj/item/bio_chip_case/supercharge
	name = "bio-chip case - 'supercharge'"
	desc = "A glass case containing a supercharge bio-chip."
	implant_type = /obj/item/bio_chip/supercharge
