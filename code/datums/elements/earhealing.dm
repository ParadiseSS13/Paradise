/datum/element/earhealing
	element_flags = ELEMENT_DETACH
	var/list/user_by_item = list()

/datum/element/earhealing/New()
	START_PROCESSING(SSdcs, src)

/datum/element/earhealing/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)

/datum/element/earhealing/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	user_by_item -= target

/datum/element/earhealing/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(((slot == slot_l_ear) || (slot == slot_r_ear)) && istype(user))
		user_by_item[source] = user
	else
		user_by_item -= source

/datum/element/earhealing/process()
	for(var/i in user_by_item)
		var/mob/living/carbon/user = user_by_item[i]
		var/obj/item/organ/internal/ears/ears = user.get_int_organ(/obj/item/organ/internal/ears)
		if(!ears || HAS_TRAIT_NOT_FROM(user, TRAIT_DEAF, EAR_DAMAGE))
			continue
		ears.deaf = max(ears.deaf - 0.25, (ears.ear_damage < 100 ? 0 : 1)) // Do not clear deafness if our ears are too damaged
		ears.ear_damage = max(ears.ear_damage - 0.025, 0)
		CHECK_TICK
