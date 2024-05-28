GLOBAL_LIST_EMPTY(occupants_by_key)

/obj/effect/mob_spawn/human/alive/ghost_bar
	name = "ghastly rejuvenator"
	mob_name = "ghost bar occupant"
	permanent = TRUE
	icon = 'icons/obj/closet.dmi'
	icon_state = "coffin"
	important_info = "Don't randomly attack people in the ghost bar, stay inside the ghost bar. You will still be able to roll for ghost roles."
	description = "Relax, get a beer, watch the station destroy itself and burst into flames."
	flavour_text = "You are a ghost bar occupant. You've gotten sick of being dead and decided to meet up with some of your fellow haunting brothers. Take a seat, grab a beer, and chat it out."
	assignedrole = "Ghost Bar Occupant"
	death_cooldown = 1 MINUTES

/obj/effect/mob_spawn/human/alive/ghost_bar/create(ckey, flavour = TRUE, name, mob/user = usr) // So divorced from the normal proc it's just being overriden
	var/datum/character_save/save_to_load
	if(tgui_alert(user, "Would you like to use one of your saved characters in your character creator?", "Ghost Bar", list("Yes", "No")) == "Yes")
		var/list/our_characters_names = list()
		var/list/our_character_saves = list()
		for(var/index in 1 to length(user.client.prefs.character_saves))
			var/datum/character_save/saves = user.client.prefs.character_saves[index]
			var/slot_name = "[saves.real_name] (Slot #[index])"
			our_characters_names += slot_name
			our_character_saves += list("[slot_name]" = saves)

		var/character_name = tgui_input_list(user, "Select a character", "Character selection", our_characters_names)
		if(!character_name)
			return
		if(QDELETED(user))
			return
		save_to_load = our_character_saves[character_name]
	else
		if(QDELETED(user))
			return
		save_to_load = new
		save_to_load.randomise()
	var/mob/living/carbon/human/H = new(get_turf(src))

	save_to_load.copy_to(H)
	if(!H.back)
		equip_item(H, /obj/item/storage/backpack, SLOT_HUD_BACK)
	equip_item(H, /obj/item/radio/headset/deadsay, SLOT_HUD_LEFT_EAR)
	H.dna.species.before_equip_job(/datum/job/assistant, H)
	H.dna.species.remains_type = /obj/effect/decal/cleanable/ash
	var/obj/item/bio_chip/dust/I = new
	I.implant(H, null)
	for(var/gear in save_to_load.loadout_gear)
		var/datum/gear/G = GLOB.gear_datums[text2path(gear) || gear]
		if(G.allowed_roles) // Fix due to shitty HUD code
			continue
		if(G.slot)
			if(H.equip_to_slot_or_del(G.spawn_item(H), G.slot, TRUE))
				to_chat(H, "<span class='notice'>Equipping you with [G.display_name]!</span>")
		else
			H.equip_or_collect(G.spawn_item(null, save_to_load.loadout_gear[G.display_name]))
	if(!H.w_uniform)
		equip_item(H, /obj/item/clothing/under/color/random, SLOT_HUD_JUMPSUIT)
	if(!H.shoes)
		equip_item(H, /obj/item/clothing/shoes/black, SLOT_HUD_SHOES)
	equip_item(H, /obj/item/stack/spacecash/c1000, SLOT_HUD_LEFT_STORE)

	var/obj/item/card/id/syndicate/our_id = equip_item(H, /obj/item/card/id/syndicate/ghost_bar, SLOT_HUD_WEAR_ID)
	our_id.assignment = assignedrole
	our_id.registered_name = H.real_name
	our_id.sex = capitalize(H.gender)
	our_id.age = H.age
	our_id.name = "[our_id.registered_name]'s ID Card ([our_id.assignment])"
	our_id.photo = get_id_photo(H)
	our_id.owner_uid = H.UID()
	our_id.owner_ckey = H.ckey
	H.job = assignedrole

	H.dna.ready_dna(H)
	H.mind_initialize()
	H.mind.assigned_role = assignedrole
	H.mind.special_role = assignedrole
	H.mind.offstation_role = TRUE
	ADD_TRAIT(H, TRAIT_PACIFISM, GHOST_ROLE)
	ADD_TRAIT(H, TRAIT_RESPAWNABLE, GHOST_ROLE)

	H.key = ckey
	H.dna.species.after_equip_job(/datum/job/assistant, H)
	if(isgrey(H))
		var/obj/item/organ/internal/cyberimp/brain/speech_translator/implant = new
		implant.insert(H)
	log_game("[ckey] has entered the ghost bar")
	playsound(src, 'sound/machines/wooden_closet_open.ogg', 50)
	var/mob/old_mob = GLOB.occupants_by_key["[H.ckey]"]
	if(old_mob)
		qdel(old_mob)
	GLOB.occupants_by_key["[H.ckey]"] = H
	RegisterSignal(H, COMSIG_PARENT_QDELETING, PROC_REF(clear_references_to_owner))

/obj/effect/mob_spawn/human/alive/ghost_bar/proc/equip_item(mob/living/carbon/human/H, path, slot)
	var/obj/item/I = new path(H)
	H.equip_or_collect(I, slot, TRUE)
	H.speaks_ooc = TRUE
	return I

/obj/effect/mob_spawn/human/alive/ghost_bar/proc/clear_references_to_owner(mob/mob_to_obliterate)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	GLOB.occupants_by_key -= mob_to_obliterate.ckey

/obj/structure/ghost_bar_cryopod
	name = "returning sarcophagus"
	desc = "Returns you back to the world of the dead."
	icon = 'icons/obj/closet.dmi'
	icon_state = "coffin_open"

/obj/structure/ghost_bar_cryopod/MouseDrop_T(mob/living/carbon/human/mob_to_delete, mob/living/user)
	if(!istype(mob_to_delete) || !istype(user) || !Adjacent(user))
		return
	if(mob_to_delete.client)
		if(tgui_alert(mob_to_delete, "Would you like to return to the realm of spirits? (This will delete your current character, but you can rejoin later)", "Ghost Bar", list("Yes", "No")) != "Yes")
			return
	mob_to_delete.visible_message("<span class='notice'>[mob_to_delete.name] climbs into [src]...</span>")
	playsound(src, 'sound/machines/wooden_closet_close.ogg', 50)
	qdel(mob_to_delete)

/proc/dust_if_respawnable(mob/M)
	if(isdrone(M))
		var/mob/living/silicon/robot/drone/drone = M
		drone.shut_down(TRUE)
		return
	if(HAS_TRAIT_FROM(M, TRAIT_RESPAWNABLE, GHOST_ROLE))
		M.dust()
