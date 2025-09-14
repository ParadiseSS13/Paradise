GLOBAL_LIST_EMPTY(occupants_by_key)

/obj/effect/mob_spawn/human/alive/ghost_bar
	name = "ghastly rejuvenator"
	role_name = "ghost bar occupant"
	permanent = TRUE
	icon = 'icons/obj/closet.dmi'
	icon_state = "coffin"
	important_info = "Don't randomly attack people in the ghost bar, stay inside the ghost bar. You will still be able to roll for ghost roles."
	description = "Relax, get a beer, watch the station destroy itself and burst into flames."
	flavour_text = "You are a ghost bar occupant. You've gotten sick of being dead and decided to meet up with some of your fellow haunting brothers. Take a seat, grab a beer, and chat it out."
	assignedrole = "Ghost Bar Occupant"
	death_cooldown = 1 MINUTES
	restrict_antagban = FALSE
	restrict_respawnability = FALSE
	restrict_ahud = FALSE
	outfit = /datum/outfit/ghost_bar

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
	var/mob/living/carbon/human/human = new(get_turf(src))
	human.speaks_ooc = TRUE

	save_to_load.copy_to(human)
	human.dna.species.before_equip_job(/datum/job/assistant, human)
	human.job = assignedrole
	if(outfit)
		human.equipOutfit(outfit)
	human.dna.species.remains_type = /obj/effect/decal/cleanable/ash
	for(var/gear in save_to_load.loadout_gear)
		var/datum/gear/G = GLOB.gear_datums[text2path(gear) || gear]
		if(isnull(G))
			continue
		if(G.allowed_roles) // Fix due to shitty HUD code
			continue
		if(G.slot)
			if(human.equip_to_slot_or_del(G.spawn_item(human, save_to_load.get_gear_metadata(G)), G.slot, TRUE))
				to_chat(human, "<span class='notice'>Equipping you with [G.display_name]!</span>")
		else
			human.equip_or_collect(G.spawn_item(null, save_to_load.get_gear_metadata(G)))

	human.dna.ready_dna(human)
	human.mind_initialize()
	human.mind.assigned_role = assignedrole
	human.mind.special_role = assignedrole
	human.mind.offstation_role = TRUE
	ADD_TRAIT(human, TRAIT_PACIFISM, GHOST_ROLE)
	if(isobserver(user))
		var/mob/dead/observer/ghost = user
		if(ghost.ghost_flags & GHOST_CAN_REENTER)
			ADD_TRAIT(human, TRAIT_RESPAWNABLE, GHOST_ROLE)

	human.key = ckey
	human.dna.species.after_equip_job(/datum/job/assistant, human)
	if(isgrey(human))
		var/obj/item/organ/internal/cyberimp/brain/speech_translator/implant = new
		implant.insert(human)
	log_game("[ckey] has entered the ghost bar")
	playsound(src, 'sound/machines/wooden_closet_open.ogg', 50)
	var/mob/old_mob = GLOB.occupants_by_key["[human.ckey]"]
	if(old_mob)
		qdel(old_mob)
	GLOB.occupants_by_key["[human.ckey]"] = human
	RegisterSignal(human, COMSIG_PARENT_QDELETING, PROC_REF(clear_references_to_owner))
	return human

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

// MARK: Ghost Bar outfit
/datum/outfit/ghost_bar
	name = "Ghost Bar Occupant"
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset/deadsay
	l_pocket = /obj/item/stack/spacecash/c1000
	id = /obj/item/card/id/syndicate/ghost_bar
	bio_chips = list(/obj/item/bio_chip/dust)
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon/ghost_bar)

/datum/outfit/ghost_bar/post_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	var/obj/item/card/id/card = human.wear_id
	card.assignment = human.job
	card.registered_name = human.real_name
	card.sex = capitalize(human.gender)
	card.age = human.age
	card.name = "[card.registered_name]'s ID Card ([card.assignment])"
	card.photo = get_id_photo(human)
	card.owner_uid = human.UID()
	card.owner_ckey = human.ckey

// MARK: Ghost Bar chameleon kit
/obj/item/storage/box/syndie_kit/chameleon/ghost_bar/populate_contents()
	. = ..()
	for(var/obj/item/pda/pda in contents)
		qdel(pda)
	for(var/obj/item/radio/headset/headset in contents)
		qdel(headset)
