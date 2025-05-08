//corgi's stippable items

GLOBAL_LIST_INIT(strippable_corgi_items, create_strippable_list(list(
	/datum/strippable_item/corgi_head,
	/datum/strippable_item/corgi_back
)))

/datum/strippable_item/corgi_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/corgi_head/get_item(atom/source)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	return corgi_source.inventory_head

/datum/strippable_item/corgi_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/simple_animal/pet/dog/corgi, place_on_head), equipping, user)

/datum/strippable_item/corgi_head/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), corgi_source.inventory_head)
	corgi_source.inventory_head = null
	corgi_source.update_corgi_fluff()
	corgi_source.update_appearance(UPDATE_OVERLAYS)

/datum/strippable_item/pet_collar
	key = STRIPPABLE_ITEM_PET_COLLAR

/datum/strippable_item/pet_collar/get_item(atom/source)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	return (locate(/obj/item/petcollar) in source)

/datum/strippable_item/pet_collar/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(equipping, /obj/item/petcollar))
		to_chat(user, "<span class='warning'>That's not a collar.</span>")
		return FALSE

	return TRUE

/datum/strippable_item/pet_collar/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	user.transfer_item_to(equipping, source)

/datum/strippable_item/pet_collar/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet_source = source
	if(!istype(pet_source))
		return

	var/obj/item/petcollar/collar = locate() in source
	user.put_in_hands(collar)

/datum/strippable_item/corgi_back
	key = STRIPPABLE_ITEM_BACK

/datum/strippable_item/corgi_back/get_item(atom/source)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	return corgi_source.inventory_back

/datum/strippable_item/corgi_back/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return
	if(!ispath(equipping.dog_fashion, /datum/dog_fashion/back))
		var/mob/living/simple_animal/pet/dog/corgi/corgi = source
		to_chat(user, "<span class='warning'>You set [equipping] on [source]'s back, but it falls off!</span>")
		INVOKE_ASYNC(equipping, TYPE_PROC_REF(/atom/movable, forceMove), source.drop_location())
		if(prob(25))
			step_rand(equipping)
		var/old_dir = corgi.dir
		corgi.spin(7, 1)
		corgi.setDir(old_dir)
		return

	INVOKE_ASYNC(equipping, TYPE_PROC_REF(/atom/movable, forceMove), corgi_source)
	corgi_source.inventory_back = equipping
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/corgi_back/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), corgi_source.inventory_back)
	corgi_source.inventory_back = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()
