/obj/effect/mob_spawn/ghost_role/human/virtual_domain
	outfit = /datum/outfit/virtual_pirate
	prompt_name = "a virtual domain debug entity"
	flavour_text = "You probably shouldn't be seeing this, contact a coder!"
	you_are_text = "You are NOT supposed to be here. How did you let this happen?"
	important_text = "Bitrunning is a crime, and your primary threat."
	temp_body = TRUE


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/special(mob/living/spawned_mob, mob/mob_possessor)
	var/datum/mind/ghost_mind = mob_possessor.mind
	if(ghost_mind?.current) // Preserves any previous bodies before making the switch
		spawned_mob.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)

	..()

	spawned_mob.mind.add_antag_datum(/datum/antagonist/domain_ghost_actor)


/// Simulates a ghost role spawn without calling special(), ie a bitrunner spawn instead of a ghost.
/obj/effect/mob_spawn/ghost_role/human/virtual_domain/proc/artificial_spawn(mob/living/runner)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SPAWNED, runner)


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate
	name = "Virtual Pirate Remains"
	desc = "Some inanimate bones. They feel like they could spring to life at any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "a virtual skeleton pirate"
	you_are_text = "You are a virtual pirate. Yarrr!"
	flavour_text = " There's a LANDLUBBER after yer booty. Stop them!"

/datum/outfit/virtual_pirate
	name = "Virtual Pirate"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/pirate
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate/armored
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana/armored
	shoes = /obj/item/clothing/shoes/pirate/armored


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/pirate/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, "[pick(strings(PIRATE_NAMES_FILE, "generic_beginnings"))][pick(strings(PIRATE_NAMES_FILE, "generic_endings"))]")


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/syndie
	name = "Virtual Syndicate Sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a virtual syndicate operative"
	you_are_text = "You are a virtual syndicate operative."
	flavour_text = "Alarms blare! We are being boarded!"
	outfit = /datum/outfit/virtual_syndicate
	spawner_job_path = /datum/job/space_syndicate


/datum/outfit/virtual_syndicate
	name = "Virtual Syndie"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	shoes = /obj/item/clothing/shoes/combat
	implants = list(/obj/item/implant/weapons_auth)


/datum/outfit/virtual_syndicate/post_equip(mob/living/carbon/human/user, visuals_only)
	user.faction |= ROLE_SYNDICATE
