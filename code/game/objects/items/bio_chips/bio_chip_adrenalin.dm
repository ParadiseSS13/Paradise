/obj/item/bio_chip/adrenalin
	name = "adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3
	implant_data = /datum/implant_fluff/adrenaline
	implant_state = "implant-syndicate"

/obj/item/bio_chip/adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.stand_up(TRUE)
	SEND_SIGNAL(imp_in, COMSIG_LIVING_CLEAR_STUNS)

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine_no_addiction", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	if(!uses)
		qdel(src)

/obj/item/bio_chip_implanter/adrenalin
	name = "bio-chip implanter (adrenalin)"
	implant_type = /obj/item/bio_chip/adrenalin

/obj/item/bio_chip_case/adrenaline
	name = "bio-chip case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline bio-chip."
	implant_type = /obj/item/bio_chip/adrenalin

/obj/item/bio_chip/basic_adrenalin
	name = "basic adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=3"
	uses = 1
	implant_data = /datum/implant_fluff/basic_adrenalin
	implant_state = "implant-syndicate"

/obj/item/bio_chip/basic_adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.stand_up(TRUE)
	SEND_SIGNAL(imp_in, COMSIG_LIVING_CLEAR_STUNS)

	imp_in.reagents.add_reagent("synaptizine", 7.5)
	imp_in.reagents.add_reagent("weak_omnizine", 7.5)
	imp_in.reagents.add_reagent("stimulative_agent", 7.5)
	if(!uses)
		qdel(src)

/obj/item/bio_chip_implanter/basic_adrenalin
	name = "bio-chip implanter (basic adrenalin)"
	implant_type = /obj/item/bio_chip/basic_adrenalin

/obj/item/bio_chip_case/basic_adrenalin
	name = "bio-chip case - 'Basic Adrenaline'"
	desc = "A glass case containing an smaller than normal adrenaline bio-chip."
	implant_type = /obj/item/bio_chip/basic_adrenalin

/obj/item/bio_chip/proto_adrenalin
	name = "proto-adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	uses = 1
	implant_data = /datum/implant_fluff/proto_adrenaline
	implant_state = "implant-syndicate"

/obj/item/bio_chip/proto_adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0) //Since it doesn't have a good followup like adrenals, and getting batoned the moment after triggering it will stamina crit you, will set to zero over - 75
	imp_in.stand_up(TRUE)
	SEND_SIGNAL(imp_in, COMSIG_LIVING_CLEAR_STUNS)
	imp_in.reagents.add_reagent("stimulative_cling", 1)
	if(!uses)
		qdel(src)

/obj/item/bio_chip_implanter/proto_adrenalin
	name = "bio-chip implanter (proto-adrenalin)"
	implant_type = /obj/item/bio_chip/proto_adrenalin

/obj/item/bio_chip_case/proto_adrenalin
	name = "bio-chip case - 'proto-adrenalin'"
	desc = "A glass case containing an proto-adrenalin bio-chip."
	implant_type = /obj/item/bio_chip/proto_adrenalin
