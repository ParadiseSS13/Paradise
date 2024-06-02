/obj/item/bio_chip/chem
	name = "chem bio-chip"
	desc = "Injects things."
	icon_state = "reagents"
	origin_tech = "materials=3;biotech=4"
	container_type = OPENCONTAINER
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/chem
	implant_state = "implant-nanotrasen"

/obj/item/bio_chip/chem/Initialize(mapload)
	. = ..()
	create_reagents(50)
	GLOB.tracked_implants += src

/obj/item/bio_chip/chem/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/bio_chip/chem/death_trigger(mob/victim, gibbed)
	activate(reagents.total_volume)

/obj/item/bio_chip/chem/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	var/mob/living/carbon/R = imp_in
	var/injectamount

	var/list/implant_chems = list()
	for(var/datum/reagent/chems in reagents.reagent_list)
		implant_chems += chems.name
	var/contained_chemicals = english_list(implant_chems)

	if(cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	add_attack_logs(usr, R, "Chem bio-chip activated injecting [injectamount]u of [contained_chemicals]")
	to_chat(R, "<span class='italics'>You hear a faint beep.</span>")
	if(!reagents.total_volume)
		to_chat(R, "<span class='italics'>You hear a faint click from your chest.</span>")
		qdel(src)

/obj/item/bio_chip_implanter/chem
	name = "bio-chip implanter (chem)"
	implant_type = /obj/item/bio_chip/chem

/obj/item/bio_chip_case/chem
	name = "bio-chip case - 'Remote Chemical'"
	desc = "A glass case containing a remote chemical bio-chip."
	implant_type = /obj/item/bio_chip/chem
