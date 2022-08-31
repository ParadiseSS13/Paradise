// Dust implant, for CC officers. Prevents gear theft if they die.

/obj/item/implant/dust
	name = "duster implant"
	desc = "A remote controlled implant that will dust the user upon activation (or death of user)."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	trigger_causes = IMPLANT_TRIGGER_DEATH_ONCE | IMPLANT_TRIGGER_NOT_WHEN_GIBBED
	implant_data = /datum/implant_fluff/dust
	implant_state = "implant-nanotrasen"

/obj/item/implant/dust/death_trigger(mob/source, force)
	activate("death")

/obj/item/implant/dust/activate(cause)
	if(!cause || !imp_in || cause == "emp")
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your dusting implant? This will turn you to ash!", "Dusting Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	imp_in.visible_message("<span class = 'warning'>[imp_in] burns up in a flash!</span>")
	for(var/obj/item/I in imp_in.contents)
		if(I == src)
			continue
		if(I.flags & NODROP)
			qdel(I)
	imp_in.dust()

/obj/item/implant/dust/emp_act(severity)
	return

/obj/item/implanter/dust
	name = "implanter (Dust-on-death)"

/obj/item/implanter/dust/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/dust(src)

/obj/item/implantcase/dust
	name = "implant case - 'Dust'"
	desc = "A glass case containing a dust implant."

/obj/item/implantcase/dust/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/dust(src)
