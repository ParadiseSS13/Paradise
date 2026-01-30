RESTRICT_TYPE(/obj/item/autochef_remote)

/obj/item/autochef_remote
	name = "autochef remote"
	icon = 'icons/obj/cooking/misc.dmi'
	icon_state = "autochef_remote"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 3000)
	new_attack_chain = TRUE

	var/list/linkable_machine_uids = list()
	VAR_PRIVATE/static/list/valid_machines = list(
		/obj/item/reagent_containers/cooking,
		/obj/machinery/cooking,
		/obj/machinery/smartfridge,
	)

/obj/item/autochef_remote/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("Use [src] on cooking utensils and machines to store them in the buffer.")
	. += SPAN_NOTICE("Use [src] on an autochef to register all the stored utensils and machines to the autochef.")
	. += SPAN_NOTICE("Register food and drink carts and smart fridges to give the autochef access to ingredients.")
	. += SPAN_NOTICE("Use [src] in-hand to clear its buffer, which can then be used to unlink everything from autochefs.")

/obj/item/autochef_remote/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	linkable_machine_uids.Cut()
	to_chat(user, SPAN_NOTICE("You clear all items stored in [src]'s buffer."))

/obj/item/autochef_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/target_uid = interacting_with.UID()
	if(is_type_in_list(interacting_with, valid_machines))
		linkable_machine_uids |= target_uid
	else
		return

	var/obj/machinery/cooking/cooking_machine = interacting_with
	if(istype(cooking_machine))
		for(var/datum/cooking_surface/surface in cooking_machine.surfaces)
			if(surface.container)
				interact_with_atom(surface.container, user)

	to_chat(user, SPAN_NOTICE("You add [interacting_with] to [src]'s buffer."))

	return ITEM_INTERACT_COMPLETE
