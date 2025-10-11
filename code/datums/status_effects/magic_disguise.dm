/datum/status_effect/magic_disguise
	id = "magic_disguise"
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/magic_disguise
	status_type = STATUS_EFFECT_REPLACE
	var/mob/living/disguise_mob
	var/datum/icon_snapshot/disguise

/atom/movable/screen/alert/status_effect/magic_disguise
	name = "Disguised"
	desc = "You are disguised as a crewmember."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "chameleon_outfit"

/datum/status_effect/magic_disguise/on_creation(mob/living/new_owner, mob/living/_disguise_mob)
	disguise_mob = _disguise_mob
	. = ..()

/datum/status_effect/magic_disguise/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE
	if(!disguise_mob)
		disguise_mob = select_disguise()
	if(ishuman(disguise_mob))
		create_disguise(disguise_mob)
	if(disguise)
		apply_disguise(owner)
	else
		to_chat(owner, "<span class='warning'>Your spell fails to find a disguise!</span>")
		return FALSE

	RegisterSignal(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_HUMAN_ATTACKED, COMSIG_SPECIES_HITBY), PROC_REF(remove_disguise))
	return TRUE

/datum/status_effect/magic_disguise/on_remove()
	owner.regenerate_icons()
	..()

/datum/status_effect/magic_disguise/proc/select_disguise()
	var/obj/machinery/door/airlock/AL
	var/area/caster_area

	caster_area = get_area(owner)
	for(var/obj/machinery/door/airlock/tmp in view(owner))
		if(get_area(tmp) == caster_area && (length(tmp.req_access) || length(tmp.req_one_access))) //Ignore airlocks that arent in area or are public airlocks
			AL = tmp
			break
	for(var/mob/living/carbon/human/disguise_source in shuffle(GLOB.player_list)) //Pick a random crewmember with access to this room
		if((ACCESS_CAPTAIN in disguise_source.get_access()) || (ACCESS_HOP in disguise_source.get_access()) || (ACCESS_CLOWN in disguise_source.get_access()))
			continue //We don't want the cap, HOP or clown as a disguise, too remarkable. If you're spotted by the Cap or HOP in their own office, disguising as them wont help you either
		if((!AL || AL.allowed(disguise_source)) && !disguise_source.mind.offstation_role && disguise_source != owner)
			return disguise_source
	for(var/mob/living/carbon/human/backup_source in shuffle(GLOB.player_list)) //Pick a random crewmember if there's no one with access to the current room
		if((ACCESS_CAPTAIN in backup_source.get_access()) || (ACCESS_HOP in backup_source.get_access()) || (ACCESS_CLOWN in backup_source.get_access()))
			continue //ditto
		if(!backup_source.mind.offstation_role && backup_source != owner)
			return backup_source
	return

/datum/status_effect/magic_disguise/proc/create_disguise(mob/living/carbon/human/disguise_source)
	var/datum/icon_snapshot/temp = new
	temp.name = disguise_source.name
	temp.icon = disguise_source.icon
	temp.icon_state = disguise_source.icon_state
	temp.overlays = disguise_source.get_overlays_copy(list(L_HAND_LAYER, R_HAND_LAYER))
	disguise = temp

/datum/status_effect/magic_disguise/proc/apply_disguise(mob/living/carbon/human/H)
	H.name_override = disguise.name
	H.icon = disguise.icon
	H.icon_state = disguise.icon_state
	H.overlays = disguise.overlays
	H.update_inv_r_hand()
	H.update_inv_l_hand()
	H.sec_hud_set_ID()
	SEND_SIGNAL(H, COMSIG_CARBON_REGENERATE_ICONS)
	to_chat(H, "<span class='notice'>You disguise yourself as [disguise.name].</span>")

/datum/status_effect/magic_disguise/proc/remove_disguise()
	SIGNAL_HANDLER  // COMSIG_MOB_APPLY_DAMAGE + COMSIG_HUMAN_ATTACKED + COMSIG_SPECIES_HITBY
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.name_override = null
	H.overlays.Cut()
	H.sec_hud_set_ID()
	qdel(src)
