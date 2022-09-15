/obj/item/implant/chem
	name = "chem implant"
	desc = "Injects things."
	icon_state = "reagents"
	origin_tech = "materials=3;biotech=4"
	container_type = OPENCONTAINER
	trigger_causes = IMPLANT_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/chem
	implant_state = "implant-nanotrasen"

/obj/item/implant/chem/Initialize(mapload)
	. = ..()
	create_reagents(50)
	GLOB.tracked_implants += src

/obj/item/implant/chem/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implant/chem/death_trigger(mob/victim, gibbed)
	activate(reagents.total_volume)

/obj/item/implant/chem/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	var/mob/living/carbon/R = imp_in
	var/injectamount
	if(cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	to_chat(R, "<span class='italics'>You hear a faint beep.</span>")
	if(!reagents.total_volume)
		to_chat(R, "<span class='italics'>You hear a faint click from your chest.</span>")
		qdel(src)

/obj/item/implanter/chem
	name = "implanter (chem)"
	implant_type = /obj/item/implant/chem

/obj/item/implantcase/chem
	name = "implant case - 'Remote Chemical'"
	desc = "A glass case containing a remote chemical implant."
	implant_type = /obj/item/implant/chem
