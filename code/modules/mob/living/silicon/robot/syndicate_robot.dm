/mob/living/silicon/robot/syndicate
	base_icon = "spidersyndi"
	icon_state = "spidersyndi"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	pdahide = TRUE
	faction = list("syndicate")
	bubble_icon = "syndibot"
	designation = "Syndicate Assault"
	modtype = "Syndicate"
	allow_resprite = TRUE
	req_access = list(ACCESS_SYNDICATE)
	ionpulse = TRUE
	damage_protection = 5
	brute_mod = 0.7 //30% less damage
	burn_mod = 0.7
	can_lock_cover = TRUE
	lawchannel = "State"
	var/playstyle_string = "<span class='userdanger'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/syndicate/New(loc)
	..()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/mob/living/silicon/robot/syndicate/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/syndicate_override
	module = new /obj/item/robot_module/syndicate(src)

	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/syndicate(src)
	radio.recalculateChannels()

	spawn(5)
		if(playstyle_string)
			to_chat(src, playstyle_string)

	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, 0)

/mob/living/silicon/robot/syndicate/air_push(direction, strength)
	// Syndicate borgs ignore airflow, because they're bloody expensive.
	// This should probably be revisited later, as part of a broader move_resist/move_force/pull_force rework.
	return

/mob/living/silicon/robot/syndicate/medical
	base_icon = "syndi-medi"
	icon_state = "syndi-medi"
	modtype = "Syndicate Medical"
	designation = "Syndicate Medical"
	brute_mod = 0.8 //20% less damage
	burn_mod = 0.8
	playstyle_string = "<span class='userdanger'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/syndicate/medical/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	..()
	module = new /obj/item/robot_module/syndicate_medical(src)

/mob/living/silicon/robot/syndicate/saboteur
	base_icon = "syndi-engi"
	icon_state = "syndi-engi"
	modtype = "Syndicate Saboteur"
	designation = "Syndicate Saboteur"
	brute_mod = 0.8
	burn_mod = 0.8
	var/obj/item/borg_chameleon/cham_proj = null
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/set_mail_tag,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager)
	playstyle_string = "<span class='userdanger'>You are a Syndicate saboteur cyborg!</span><br>\
						<b>You are equipped with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your built-in mail tagger will allow you to stealthily traverse the disposal network across the station. \
						Your cyborg chameleon projector allows you to assume the appearance of a Nanotrasen engineering cyborg, and undertake covert actions on the station. \
						You are able to hijack Nanotrasen cyborgs by emagging their internal components, make sure to flash them first. \
						You are armed with a standard energy sword, use it to ambush key targets if needed. Your pinpointer will let you locate fellow nuclear operatives to regroup.\
						Be aware that physical contact or taking damage will break your disguise. \
						<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/syndicate/saboteur/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	..()
	module = new /obj/item/robot_module/syndicate_saboteur(src)

	var/obj/item/borg/upgrade/selfrepair/SR = new /obj/item/borg/upgrade/selfrepair(src)
	SR.cyborg = src
	SR.icon_state = "selfrepair_off"

	var/datum/action/self_repair = new /datum/action/item_action/toggle(SR)
	self_repair.Grant(src)

	var/datum/action/thermals = new /datum/action/innate/robot_sight/thermal()
	thermals.Grant(src)

/mob/living/silicon/robot/syndicate/saboteur/verb/modify_name()
	set name = "Modify Name"
	set desc = "Change your systems' registered name to fool Nanotrasen systems. No cost."
	set category = "Saboteur"
	rename_self(braintype, TRUE, TRUE)

/mob/living/silicon/robot/syndicate/saboteur/verb/toggle_chameleon()
	set name = "Toggle Chameleon Projector"
	set desc = "Change your appearance to a Nanotrasen cyborg. Costs power to use and maintain."
	set category = "Saboteur"
	if(!cham_proj)
		for(var/obj/item/borg_chameleon/C in contents)
			cham_proj = C
		for(var/obj/item/borg_chameleon/C in module.contents)
			cham_proj = C
		if(!cham_proj)
			to_chat(src, "<span class='warning'>Error : No chameleon projector system found.</span>")
			return
	cham_proj.attack_self__legacy__attackchain(src)

/mob/living/silicon/robot/syndicate/saboteur/attack_by(obj/item/attacking, mob/living/user, params)
	. = ..()
	if(cham_proj)
		cham_proj.disrupt(src)

/mob/living/silicon/robot/syndicate/saboteur/attack_hand()
	if(cham_proj)
		cham_proj.disrupt(src)
	..()

/mob/living/silicon/robot/syndicate/saboteur/ex_act()
	if(cham_proj)
		cham_proj.disrupt(src)
	..()

/mob/living/silicon/robot/syndicate/saboteur/emp_act()
	..()
	if(cham_proj)
		cham_proj.disrupt(src)

/mob/living/silicon/robot/syndicate/saboteur/bullet_act()
	if(cham_proj)
		cham_proj.disrupt(src)
	..()
