/*
=== Перенос мобов ===
Компонент для переноса мобов на мобах. Срабатывает в случае граб-интента, драг-энд-дропа моба на модель (аля стул)
*/

/datum/component/gadom_living
	var/mob/living/carbon/human/carrier = null

/datum/component/gadom_living/Initialize()
	carrier = parent
	START_PROCESSING(SSprojectiles, src)

/datum/component/gadom_living/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GADOM_LOAD, PROC_REF(try_load_mob))
	RegisterSignal(parent, COMSIG_GADOM_UNLOAD, PROC_REF(try_unload_mob))
	RegisterSignal(parent, COMSIG_GADOM_CAN_GRAB, PROC_REF(block_operation))

/datum/component/gadom_living/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_GADOM_LOAD)
	UnregisterSignal(parent, COMSIG_GADOM_UNLOAD)
	UnregisterSignal(parent, COMSIG_GADOM_CAN_GRAB)

/datum/component/gadom_living/proc/block_operation(datum/component_holder)
	SIGNAL_HANDLER
	return carrier.a_intent == "grab" ? GADOM_CAN_GRAB : FALSE

/datum/component/gadom_living/proc/try_load_mob(datum/component_holder, mob/user, mob/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(pre_load), component_holder, user, target)

/datum/component/gadom_living/proc/pre_load(datum/component_holder, mob/user, mob/target)
	var/mob/living/carbon/human/puppet = user
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || get_dist(target, user) > 1)
		return
	if(!istype(target))
		return
	if((do_after(puppet, GADOM_BASIC_LOAD_TIMER * puppet.dna.species.action_mult, FALSE, target))) //Асинх не помогает (?!)
		load(puppet, target)

/datum/component/gadom_living/proc/load(mob/living/carbon/human/puppet, atom/movable/AM)
	if(puppet.loaded || puppet.passenger || AM.anchored || get_dist(puppet, AM) > 1 || puppet.incapacitated() || HAS_TRAIT(puppet, TRAIT_HANDS_BLOCKED))
		return

	if(!isitem(AM) && !ismachinery(AM) && !isstructure(AM) && !ismob(AM))
		return

	if(!isturf(AM.loc))
		return

	if(!load_mob(puppet, AM))
		return

	puppet.loaded = AM
	puppet.update_icon()
	puppet.throw_alert("serpentid_holding", /atom/movable/screen/alert/carrying)
	puppet.visible_message(span_warning("[carrier] водружает на себя [AM]!"))

/datum/component/gadom_living/proc/load_mob(mob/living/carbon/human/puppet, mob/living/M)
	puppet.can_buckle = TRUE
	puppet.buckle_lying = FALSE
	if(puppet.buckle_mob(M))
		puppet.passenger = M
		puppet.can_buckle = FALSE

		return TRUE
	return FALSE

/datum/component/gadom_living/process()
	. = ..()
	if(carrier.incapacitated() || HAS_TRAIT(carrier, TRAIT_HANDS_BLOCKED))
		try_unload_mob()

/datum/component/gadom_living/proc/try_unload_mob(mob/user)
	SIGNAL_HANDLER
	if(!carrier.passenger)
		return

	carrier.loaded = null
	carrier.passenger = null
	carrier.unbuckle_all_mobs()
	carrier.can_buckle = TRUE
	carrier.update_icon(UPDATE_OVERLAYS)
	carrier.clear_alert("serpentid_holding")

//Обновление при отстегивании для восстановления слоя моба
/mob/living/carbon/human/post_unbuckle_mob(mob/living/M)
	. = ..()
	loaded = null
	passenger = null
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)
