/datum/element/wears_collar
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///our icon's pathfile
	var/collar_icon
	///our collar's icon state
	var/collar_icon_state
	///iconstate of our collar while resting
	var/collar_resting_icon_state

	var/datum/strippable_item/pet_collar/pet_collar

/datum/element/wears_collar/Attach(datum/target, collar_icon_ = 'icons/mob/pets.dmi', collar_icon_state_, collar_resting_icon_state_ = FALSE)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	collar_icon = collar_icon_
	collar_icon_state = collar_icon_state_
	collar_resting_icon_state = collar_resting_icon_state_
	pet_collar = new

	RegisterSignal(target, COMSIG_ATTACK_BY, PROC_REF(attach_collar))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_content_exit))
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_content_enter))
	RegisterSignal(target, COMSIG_LIVING_RESTING, PROC_REF(on_rest))
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(target, COMSIG_STRIPPABLE_REQUEST_ITEMS, PROC_REF(on_strippable_request_items))

/datum/element/wears_collar/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_ATTACK_BY,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_ENTERED,
		COMSIG_LIVING_RESTING,
		COMSIG_MOB_STATCHANGE,
		COMSIG_STRIPPABLE_REQUEST_ITEMS,
	))

/datum/element/wears_collar/proc/on_strippable_request_items(datum/source, list/items)
	SIGNAL_HANDLER // COMSIG_STRIPPABLE_REQUEST_ITEMS
	items[STRIPPABLE_ITEM_PET_COLLAR] = pet_collar

/datum/element/wears_collar/proc/on_stat_change(mob/living/source)
	SIGNAL_HANDLER // COMSIG_MOB_STATCHANGE

	if(collar_icon_state)
		source.update_icon(UPDATE_OVERLAYS)

/datum/element/wears_collar/proc/on_content_exit(mob/living/source, atom/moved)
	SIGNAL_HANDLER // COMSIG_ATOM_EXITED

	var/obj/item/petcollar/collar = moved
	if(!istype(collar))
		return

	if(collar.tagname)
		source.name = collar.original_name
		source.real_name = collar.original_real_name

	collar.original_name = null
	collar.original_real_name = null

	if(collar_icon_state)
		source.update_appearance()

/datum/element/wears_collar/proc/on_content_enter(mob/living/source, obj/item/petcollar/new_collar)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(!istype(new_collar))
		return

	if(new_collar.tagname)
		new_collar.original_name = source.name
		new_collar.original_real_name = source.real_name
		source.name = new_collar.tagname
		source.real_name = new_collar.tagname

	if(collar_icon_state)
		source.update_appearance()

/datum/element/wears_collar/proc/attach_collar(atom/source, atom/movable/attacking_item, mob/user, params)
	SIGNAL_HANDLER // COMSIG_ATTACK_BY

	if(!istype(attacking_item, /obj/item/petcollar))
		return NONE
	if(locate(/obj/item/petcollar) in source)
		to_chat(user, "<span class='warning'>[source] is already wearing a collar!</span>")
		return COMPONENT_SKIP_AFTERATTACK

	if(user.drop_item())
		attacking_item.forceMove(source)
		to_chat(user, "<span class='notice'>You put [attacking_item] around [source]'s neck.</span>")
	else
		to_chat(user, "<span class='warning'>[attacking_item] is stuck to your hand!</span>")

	return COMPONENT_SKIP_AFTERATTACK

/datum/element/wears_collar/proc/on_overlays_updated(mob/living/source, list/overlays)
	SIGNAL_HANDLER // COMSIG_ATOM_UPDATE_OVERLAYS

	if(!locate(/obj/item/petcollar) in source)
		return

	var/icon_tag = ""

	if(source.stat == DEAD || HAS_TRAIT(source, TRAIT_FAKEDEATH))
		icon_tag = "_dead"
	else if(collar_resting_icon_state && source.resting)
		icon_tag =  "_rest"

	overlays += mutable_appearance(collar_icon, "[collar_icon_state][icon_tag]collar")
	overlays += mutable_appearance(collar_icon, "[collar_icon_state][icon_tag]tag")

/datum/element/wears_collar/proc/on_rest(atom/movable/source)
	SIGNAL_HANDLER // COMSIG_LIVING_RESTING

	source.update_icon(UPDATE_OVERLAYS)
