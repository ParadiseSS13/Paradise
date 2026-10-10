// SyndiChem
/obj/machinery/economy/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/cable_coil/random = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
					/obj/item/grenade/chem_grenade/large = 5,
					/obj/item/grenade/chem_grenade/pyro = 5,
					/obj/item/grenade/chem_grenade/cryo = 5,
					/obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/drinks/bottle/holywater = 1,
					/obj/item/pen/sleepy/undisguised = 1)
	slogan_list = list("It's not pyromania if you're getting paid!","You smell that? Plasma, son. Nothing else in the world smells like that.","I love the smell of Plasma in the morning.")
	resistance_flags = FIRE_PROOF

// Spawners
/obj/effect/mob_spawn/human/alive/spacebase_syndicate
	name = "Syndicate Researcher sleeper"
	role_name = "syndicate researcher"
	icon_state = "sleeper_s"
	important_info = "Do not work against traitors or nukies. Do not leave the base."
	description = "Experiment with deadly chems, plants, viruses, etc in peace."
	flavour_text = "You are a syndicate agent, employed in a top secret research facility developing biological weapons. Continue your research as best you can, and try to keep a low profile. Do not leave your base or let non-syndicate enter it."
	outfit = /datum/outfit/spacebase_syndicate
	assignedrole = "Syndicate Researcher"
	del_types = list() // Necessary to prevent del_types from removing radio!
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	faction = list("syndicate")
	var/use_saved_character = FALSE

/obj/effect/mob_spawn/human/alive/spacebase_syndicate/species_prompt(mob/user)
	use_saved_character = FALSE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	if(user?.client && length(user.client.prefs.character_saves))
		if(tgui_alert(user, "Would you like to use one of your saved characters in your character creator?", "Syndicate Researcher", list("Yes", "No")) == "Yes")
			use_saved_character = TRUE
			allow_species_pick = FALSE
			allow_gender_pick = FALSE
			return TRUE
	return ..()

/obj/effect/mob_spawn/human/alive/spacebase_syndicate/gender_prompt(mob/user)
	if(use_saved_character)
		return TRUE
	return ..()

/obj/effect/mob_spawn/human/alive/spacebase_syndicate/Destroy()
	var/obj/structure/fluff/empty_sleeper/syndicate/S = new /obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/alive/spacebase_syndicate/proc/delete_pais_recursive(atom/A)
	for(var/obj/item/paicard/pai in A.contents)
		qdel(pai)
	for(var/atom/B in A.contents)
		delete_pais_recursive(B)

/obj/effect/mob_spawn/human/alive/spacebase_syndicate/create(ckey, flavour = TRUE, name, mob/user = usr)
	if(!use_saved_character)
		return ..()

	var/list/our_characters_names = list()
	var/list/our_character_saves = list()
	for(var/index in 1 to length(user.client.prefs.character_saves))
		var/datum/character_save/saves = user.client.prefs.character_saves[index]
		var/slot_name = "[saves.real_name] (Slot #[index])"
		our_characters_names += slot_name
		our_character_saves += list("[slot_name]" = saves)

	var/character_name = tgui_input_list(user, "Select a character", "Character selection", our_characters_names)
	if(!character_name || QDELETED(user))
		return
	var/datum/character_save/save_to_load = our_character_saves[character_name]

	if(save_to_load.species == "Grey")
		to_chat(user, SPAN_WARNING("Greys are not permitted aboard the syndicate research base. Please choose a different character."))
		return

	var/mob/living/carbon/human/human = new(get_turf(src))
	save_to_load.copy_to(human)

	if(isgrey(human))
		to_chat(user, SPAN_WARNING("Greys are not permitted aboard the syndicate research base. Please choose a different character."))
		qdel(human)
		return

	var/has_pai = FALSE
	human.dna.species.before_equip_job(/datum/job/assistant, human)
	human.job = assignedrole
	if(outfit)
		human.equipOutfit(outfit)

	for(var/gear in save_to_load.loadout_gear)
		var/datum/gear/G = GLOB.gear_datums[text2path(gear) || gear]
		if(isnull(G))
			continue
		if(G.allowed_roles)
			continue
		if(ispath(G.path, /obj/item/paicard))
			has_pai = TRUE
			continue
		if(G.slot)
			if(human.equip_to_slot_or_del(G.spawn_item(human, save_to_load.get_gear_metadata(G)), G.slot, TRUE))
				to_chat(human, SPAN_NOTICE("Equipping you with [G.display_name]!"))
		else
			human.equip_or_collect(G.spawn_item(null, save_to_load.get_gear_metadata(G)))

	var/paicount_before = 0
	for(var/obj/item/paicard/pai in human.GetAllContents())
		paicount_before++
	delete_pais_recursive(human)
	if(paicount_before > 0)
		has_pai = TRUE

	human.dna.ready_dna(human)
	human.mind_initialize()
	human.mind.assigned_role = assignedrole
	human.mind.special_role = assignedrole
	human.mind.offstation_role = TRUE
	human.key = ckey

	if(has_pai)
		to_chat(human, SPAN_WARNING("pAI cards cannot be in here."))

	human.dna.species.after_equip_job(/datum/job/assistant, human)

	log_game("[ckey] has entered the syndicate research base as [human.real_name] (loaded from save)")
	return human

/datum/outfit/spacebase_syndicate
	name = "Syndicate Researcher"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset/syndicate/alt/nocommon // See del_types above
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/syndi_researcher
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/researcher
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/clothing/mask/gas/syndicate = 1,
		/obj/item/tank/internals/emergency_oxygen/engi/syndi = 1
	)

/datum/outfit/spacebase_syndicate/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.job = "Syndi Researcher" // ensures they show up right in player panel for admins
	if(isunathi(H) || isvulpkanin(H) || istajaran(H) || isskrell(H))
		H.change_skin_color("#B2B2B2")
	if(ismoth(H))
		H.change_markings("White Fly Head Markings", "head")
		H.change_markings("White Fly Markings", "body")
		H.change_head_accessory("White Fly Antennae")
		H.change_body_accessory("White Fly Wings")
	var/obj/item/card/id/card = H.wear_id
	if(istype(card))
		card.assignment = "Syndicate Researcher"
		card.registered_name = H.real_name
		card.sex = capitalize(H.gender)
		card.age = H.age
		card.name = "[card.registered_name]'s ID Card ([card.assignment])"
		card.photo = get_id_photo(H)
		card.owner_uid = H.UID()
		card.owner_ckey = H.ckey
	H.update_dna()
	H.regenerate_icons()
