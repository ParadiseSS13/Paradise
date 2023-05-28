/**
	*Rep Purchase - Contractor partner
*/
/datum/rep_purchase/item/contractor_partner
	name = "Reinforcements"
	description = "Upon purchase we'll give you a device, that contact available units in the area. Should there be an agent free, we'll send them down to assist you immediately. If no units are free, we give a full refund."
	stock = 1
	cost = 2
	item_type = /obj/item/antag_spawner/contractor_partner




/obj/item/antag_spawner/contractor_partner
	name = "Contractor communication device"
	desc = "Working as nuke ops teleporters, this device allows you to get your own support unit for your duties."
	icon = 'icons/obj/device.dmi'
	icon_state = "contractor_tool"
	var/checking = FALSE
	var/datum/mind/partner_mind = null

/obj/item/antag_spawner/contractor_partner/proc/before_candidate_search(user)
	return TRUE

/obj/item/antag_spawner/contractor_partner/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] is out of power!</span>")
		return FALSE
	if(!(user.mind.special_role))
		to_chat(user, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return FALSE
	if(checking)
		to_chat(user, "<span class='danger'>The device is already connecting to nearby off-station agents. Please wait.</span>")
		return FALSE
	return TRUE

/obj/item/antag_spawner/contractor_partner/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, "<span class='notice'>The uplink vibrates quietly, connecting to nearby agents...</span>")
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_sit")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as the Contractor Support Unit for [user.real_name]?", ROLE_TRAITOR, FALSE, 150, source = source)
	if(length(candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/C = pick(candidates)
		spawn_contractor_partner(user, get_turf(src), C.key)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		checking = FALSE
		to_chat(user, "<span class='notice'>No available agents at this time, please try again later or refund device by attaking uplink with device.</span>")

/obj/item/antag_spawner/contractor_partner/proc/spawn_contractor_partner(mob/living/user, turf/T, key)
	var/mob/living/carbon/human/partner = new(T)
	var/datum/outfit/contractor_partner/partner_outfit = new()
	//randomizing appearance
	var/datum/preferences/A = new()
	A.copy_to(partner)
	partner.dna.ready_dna(partner)

	partner_outfit.equip(partner)
	partner.ckey = key
	partner_mind = partner.mind
	partner_mind.make_contractor_support()
	to_chat(partner_mind.current, "<font size=4><span class='warning'>[user.real_name] - Ваш начальник. Выполняйте любые приказы, отданные им. Вы здесь только для того, чтобы помочь ему с его задачами.</span>")
	to_chat(partner_mind.current, "<span class='warning'>Если он погибнет или будет недоступен по другим причинам, вы должны помогать другим агентам в меру своих возможностей.</span>")

	var/datum/objective/protect/contractor/CT = new
	CT.owner = partner.mind
	CT.target = user.mind
	CT.explanation_text = "[user.real_name] - Ваш начальник. Его задачи являются первоочередными."
	partner.mind.objectives += CT

/datum/mind/proc/make_contractor_support()
	if(has_antag_datum(/datum/antagonist/contractor_support))
		return
	add_antag_datum(/datum/antagonist/contractor_support)

