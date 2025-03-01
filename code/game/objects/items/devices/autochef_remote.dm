RESTRICT_TYPE(/obj/item/autochef_remote)

/obj/item/autochef_remote
	name = "autochef remote"
	icon = 'icons/obj/cooking/misc.dmi'
	icon_state = "autochef_remote"

	new_attack_chain = TRUE

	var/list/linkable_machine_uids = list()
	VAR_PRIVATE/static/list/valid_machines = list(
		/obj/item/reagent_containers/cooking,
		/obj/machinery/cooking,
		/obj/machinery/smartfridge,
	)

/obj/item/autochef_remote/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use [src] on cooking utensils and machines to store them in the buffer.</span>"
	. += "<span class='notice'>Use [src] on an autochef to register all the stored utensils and machines to the autochef.</span>"
	. += "<span class='notice'>Register food and drink carts and smart fridges to give the autochef access to ingredients.</span>"

/obj/item/autochef_remote/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	linkable_machine_uids.Cut()
	to_chat(user, "<span class='notice'>You clear the autochef remote of all the items in its link buffer.</span>")

/obj/item/autochef_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/target_uid = interacting_with.UID()
	if(target_uid in linkable_machine_uids)
		to_chat(user, "<span class='notice'>[interacting_with] is already linked to [src]!</span>")
		return ITEM_INTERACT_COMPLETE

	if(is_type_in_list(interacting_with, valid_machines))
		linkable_machine_uids |= target_uid
	else
		return

	to_chat(user, "<span class='notice'>You add [interacting_with] to [src]'s buffer.</span>")

	return ITEM_INTERACT_COMPLETE
