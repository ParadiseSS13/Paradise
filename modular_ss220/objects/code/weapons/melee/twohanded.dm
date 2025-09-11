/obj/item/butcher_chainsaw/gateway
	w_class = WEIGHT_CLASS_HUGE
	var/available = FALSE

/obj/item/butcher_chainsaw/gateway/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/butchers_humans)
	on_changed_z_level(new_turf = loc)

/obj/item/butcher_chainsaw/gateway/on_changed_z_level(turf/old_turf, turf/new_turf)
	. = ..()
	if(is_away_level(new_turf.z))
		available = TRUE
		AddElement(/datum/element/butchers_humans)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		var/mob/user = loc
		attack_self__legacy__attackchain(user)
		var/message = pick("How strange!", "Interesting.", "Or that was me?", "Pffft..")
		to_chat(user, span_notice("[src]'s chain stops moving all of a sudden. [message]"))
	RemoveElement(/datum/element/butchers_humans)
	available = FALSE

/obj/item/butcher_chainsaw/gateway/attack_self__legacy__attackchain(mob/user)
	if(available)
		return ..()
	to_chat(user, span_warning("[src]'s cord handle is tough to pull..."))
