
/obj/effect/proc_holder/spell/disguise_self
	name = "Disguise Self"
	desc = "Disguise yourself as a crewmember, based on your current location. Also changes your voice. \
		The disguise will not hold up to being examined directly, and will break if you're damaged."

	school = "illusion"
	base_cooldown = 100
	clothes_req = FALSE
	invocation = "YUTAKE YUTENDES"
	invocation_type = "whisper"
	cooldown_min = 20 //20 deciseconds reduction per rank
	action_icon_state = "chameleon_skin"
	sound = null

	var/upgraded = FALSE //Upgrading the spell lets you speak as the disguised

/obj/effect/proc_holder/spell/disguise_self/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/disguise_self/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE))
		return TRUE
	else
		to_chat(H, "<span class='warning'>Your spell fails to find a disguise!</span>")
		return FALSE

/datum/status_effect/magic_disguise
	id = "magic_disguise"
	duration = -1
	tick_interval = -1
	alert_type = /obj/screen/alert/status_effect/magic_disguise
	status_type = STATUS_EFFECT_REPLACE
	var/datum/icon_snapshot/disguise
	var/disguise_clown_shoes = FALSE
	var/obj/item/saved_shoes

/obj/screen/alert/status_effect/magic_disguise
	name = "Disguised"
	desc = "You are disguised as a crewmember."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "chameleon_skin"

/datum/status_effect/magic_disguise/on_creation(mob/living/new_owner, mob/living/disguise_mob)
	. = ..()
	if(!ishuman(new_owner))
		return FALSE
	var/mob/living/carbon/human/H = new_owner
	if(disguise_mob && ishuman(disguise_mob))
		create_disguise(disguise_mob)
	else
		select_disguise(H)
	if(disguise)
		apply_disguise(H)
		return TRUE
	else
		return FALSE


/datum/status_effect/magic_disguise/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(remove_disguise))

/datum/status_effect/magic_disguise/proc/select_disguise(mob/living/carbon/human/H)
	var/obj/machinery/door/airlock/AL
	var/area/caster_area

	caster_area = get_area(H)
	for(var/obj/machinery/door/airlock/tmp in view(H))
		if(get_area(tmp) == caster_area)
			AL = tmp
			break
	for(var/mob/living/carbon/human/disguise_source in shuffle(GLOB.human_list)) //If this mob is crew and has access to this place, use it as disguise
		if((!AL || AL.allowed(disguise_source))/*&& !disguise_source.mind.offstation_role*/ && disguise_source != H)
			if((AL && !(ACCESS_CAPTAIN in AL.req_one_access) && !(ACCESS_CAPTAIN in AL.req_access)) && (ACCESS_CAPTAIN in disguise_source.get_access()))
				continue //We don't want the cap as a disguise unless we're in the cap office/bedroom
			create_disguise(disguise_source)
			break
	if(!disguise) //Pick a random crewmember if there's no one with access to the current room or it's public
		for(var/mob/living/carbon/human/backup_source in shuffle(GLOB.human_list))
			if(/*!backup_source.mind.offstation_role &&*/backup_source != H)
				create_disguise(backup_source)
				break
	if(disguise)
		return TRUE
	else
		return FALSE

/datum/status_effect/magic_disguise/proc/create_disguise(mob/living/carbon/human/disguise_source)
	var/datum/icon_snapshot/temp = new
	temp.name = disguise_source.name
	temp.icon = disguise_source.icon
	temp.icon_state = disguise_source.icon_state
	temp.overlays = disguise_source.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	if(istype(disguise_source.shoes, /obj/item/clothing/shoes/clown_shoes))
		disguise_clown_shoes = TRUE
	disguise = temp

/datum/status_effect/magic_disguise/proc/apply_disguise(mob/living/carbon/human/H)
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(H), H.dir)
	H.name_override = disguise.name
	H.icon = disguise.icon
	H.icon_state = disguise.icon_state
	H.overlays = disguise.overlays
	H.update_inv_r_hand()
	H.update_inv_l_hand()
	if(disguise_clown_shoes)
		if(H.shoes)
			saved_shoes = H.shoes
			H.unEquip(H.shoes, TRUE, TRUE)
			H.shoes.forceMove(src)
		var/obj/item/clothing/shoes/clown_shoes/magic_disguise/C = new
		H.equip_to_slot_if_possible(C, SLOT_HUD_SHOES, TRUE, TRUE)
	to_chat(H, "<span class='notice'>You disguise yourself as [disguise.name].</span>")

/datum/status_effect/magic_disguise/proc/remove_disguise()
	to_chat(owner, "remove_disguise called")
	SIGNAL_HANDLER  // COMSIG_MOB_APPLY_DAMAGE
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(H), H.dir)
	H.name_override = null
	H.overlays.Cut()

	INVOKE_ASYNC(src, PROC_REF(finish_removal))

/datum/status_effect/magic_disguise/proc/finish_removal()
	to_chat(owner, "finish_removal called")
	var/mob/living/carbon/human/H = owner
	if(saved_shoes)
		if(H.shoes)
			H.unEquip(H.shoes, TRUE, TRUE)
		H.equip_to_slot_if_possible(saved_shoes, SLOT_HUD_SHOES, TRUE, TRUE)
	H.regenerate_icons()
	qdel(src)
