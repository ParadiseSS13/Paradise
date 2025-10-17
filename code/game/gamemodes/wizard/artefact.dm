/////////Apprentice Contract//////////

/obj/item/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/contract/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/contract/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WizardApprenticeContract", name)
		ui.open()

/obj/item/contract/ui_data(mob/user)
	var/list/data = list()
	data["used"] = used
	return data

/obj/item/contract/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(used)
		return
	INVOKE_ASYNC(src, PROC_REF(async_find_apprentice), action, ui.user)
	SStgui.close_uis(src)

/obj/item/contract/proc/async_find_apprentice(action, user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	used = TRUE

	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [H.real_name]?", ROLE_WIZARD, TRUE, source = source)

	if(!length(candidates))
		used = FALSE
		to_chat(H, "<span class='warning'>Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.</span>")
		return
	new /obj/effect/particle_effect/smoke(get_turf(H))

	var/mob/C = pick(candidates)
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(get_turf(H))
	M.key = C.key

	var/datum/antagonist/wizard/apprentice/apprentice = new /datum/antagonist/wizard/apprentice()
	apprentice.my_teacher = H
	apprentice.class_type = action
	M.mind.add_antag_datum(apprentice)

	dust_if_respawnable(C)

/obj/item/contract/attack_self__legacy__attackchain(mob/user as mob)
	if(..())
		return

	if(used)
		to_chat(user, "<span class='warning'>You've already summoned an apprentice or you are in process of summoning one.</span>")
		return

	ui_interact(user)


///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 15
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charged = 1
	var/spawn_type = /obj/singularity/narsie/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."

/obj/item/veilrender/attack_self__legacy__attackchain(mob/user as mob)
	if(charged)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc)
		charged = 0
		user.visible_message("<span class='userdanger'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = TRUE
	var/spawn_path = /mob/living/basic/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20

/obj/effect/rend/New(loc, spawn_type, spawn_amt, desc)
	..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc

	START_PROCESSING(SSobj, src)
	//return

/obj/effect/rend/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/rend/process()
	for(var/mob/M in loc)
		return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [used].</span>")
		qdel(src)
		return ITEM_INTERACT_COMPLETE

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/basic/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/basic/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"

/obj/item/veilrender/crabrender
	name = "crab render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast aquarium."
	spawn_type = /mob/living/basic/crab
	spawn_amt = 10
	activate_descriptor = "sea life"
	rend_desc = "Gently wafting with the sounds of endless clacking."

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means. Also works well as a throwing weapon."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scrying_orb"
	throw_speed = 7
	throw_range = 15
	throwforce = 25
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'
	var/mob/current_owner
	var/mob/dead/observer/ghost // owners ghost when active

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/boomerang, throw_range, TRUE)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	current_owner = null
	return ..()

/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, "<span class='notice'>Your otherworldly vision fades...</span>")

		REMOVE_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		REMOVE_TRAIT(current_owner, TRAIT_NIGHT_VISION, SCRYING_ORB)
		current_owner.update_sight()
		current_owner.update_icons()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, "<span class='notice'>You can see...everything!</span>")

		ADD_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		ADD_TRAIT(current_owner, TRAIT_NIGHT_VISION, SCRYING_ORB)
		current_owner.update_sight()
		current_owner.update_icons()

/obj/item/scrying/attack_self__legacy__attackchain(mob/user as mob)
	if(in_use)
		return
	in_use = TRUE
	ADD_TRAIT(user, SCRYING, SCRYING_ORB)
	user.visible_message("<span class='notice'>[user] stares into [src], [user.p_their()] eyes glazing over.</span>",
					"<span class='danger'>You stare into [src], you can see the entire universe!</span>")
	ghost = user.ghostize(ghost_name = "Magic Spirit of [user.name]", ghost_color = COLOR_BLUE)
	while(!QDELETED(user))
		if(user.key || QDELETED(src))
			user.visible_message("<span class='notice'>[user] blinks, returning to the world around [user.p_them()].</span>",
								"<span class='danger'>You look away from [src].</span>")
			break
		if(user.get_active_hand() != src)
			user.grab_ghost()
			user.visible_message("<span class='notice'>[user]'s focus is forced away from [src].</span>",
								"<span class='userdanger'>Your vision is ripped away from [src].</span>")
			break
		sleep(5)
	in_use = FALSE
	if(QDELETED(user))
		return
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY, COLOR_BLUE)
	REMOVE_TRAIT(user, SCRYING, SCRYING_ORB)

/obj/item/scrying/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!ishuman(hit_atom) || !throwingdatum || iswizard(hit_atom))
		return
	var/mob/living/carbon/human/crushee = hit_atom
	var/zone = ran_zone(throwingdatum.target_zone) // Base 80% to hit the zone you're aiming for
	var/obj/item/organ/external/hit_limb = crushee.get_organ(zone)
	if(hit_limb)
		hit_limb.fracture()


/////////////////////Multiverse Blade////////////////////
GLOBAL_LIST_EMPTY(multiverse)

/obj/item/multisword
	name = "multiverse sword"
	desc = "A weapon capable of conquering the universe and beyond. Activate it to summon copies of yourself from others dimensions to fight by your side."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 20
	throwforce = 10
	sharp = TRUE
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/faction = list("unassigned")
	var/cooldown = 0
	var/cooldown_between_uses = 400 //time in deciseconds between uses--default of 40 seconds.
	var/assigned = "unassigned"
	var/evil = TRUE
	var/probability_evil = 30 //what's the probability this sword will be evil when activated?
	var/duplicate_self = 0 //Do we want the species randomized along with equipment should the user be duplicated in their entirety?
	var/sword_type = /obj/item/multisword //type of sword to equip.

/obj/item/multisword/New()
	..()
	GLOB.multiverse |= src


/obj/item/multisword/Destroy()
	GLOB.multiverse.Remove(src)
	return ..()

/obj/item/multisword/attack__legacy__attackchain(mob/living/M as mob, mob/living/user as mob)  //to prevent accidental friendly fire or out and out grief.
	if(M.real_name == user.real_name)
		to_chat(user, "<span class='warning'>[src] detects benevolent energies in your target and redirects your attack!</span>")
		return
	..()

/obj/item/multisword/attack_self__legacy__attackchain(mob/user)
	if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		to_chat(user, "<span class='warning'>You know better than to touch your teacher's stuff.</span>")
		return
	if(cooldown < world.time)
		var/faction_check = 0
		for(var/F in faction)
			if(F in user.faction)
				faction_check = 1
				break
		if(faction_check == 0)
			faction = list("[user.real_name]")
			assigned = "[user.real_name]"
			user.faction = list("[user.real_name]")
			to_chat(user, "You bind the sword to yourself. You can now use it to summon help.")
			if(!usr.mind.special_role)
				if(prob(probability_evil))
					to_chat(user, "<span class='warning'><B>With your new found power you could easily conquer the station!</B></span>")

					var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
					hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
					usr.mind.add_mind_objective(hijack_objective)
					var/list/messages = user.mind.prepare_announce_objectives(FALSE)
					to_chat(user, chat_box_red(messages.Join("<br>")))

					SSticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = TRUE
				else
					to_chat(user, "<span class='warning'><B>With your new found power you could easily defend the station!</B></span>")

					var/datum/objective/survive/new_objective = new /datum/objective/survive
					new_objective.explanation_text = "Survive, and help defend the innocent from the mobs of multiverse clones."
					usr.mind.add_mind_objective(new_objective)
					var/list/messages = user.mind.prepare_announce_objectives(FALSE)
					to_chat(user, chat_box_red(messages.Join("<br>")))

					SSticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = FALSE
		else
			cooldown = world.time + cooldown_between_uses
			for(var/obj/item/multisword/M in GLOB.multiverse)
				if(M.assigned == assigned)
					M.cooldown = cooldown

			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [user.real_name]?", ROLE_WIZARD, TRUE, 10 SECONDS, source = source)
			if(length(candidates))
				var/mob/C = pick(candidates)
				spawn_copy(C.client, get_turf(user.loc), user)
				to_chat(user, "<span class='warning'><B>The sword flashes, and you find yourself face to face with...you!</B></span>")
				dust_if_respawnable(C)

			else
				to_chat(user, "You fail to summon any copies of yourself. Perhaps you should try again in a bit.")
	else
		to_chat(user, "<span class='warning'><B>[src] is recharging! Keep in mind it shares a cooldown with the swords wielded by your copies.</span>")


/obj/item/multisword/proc/spawn_copy(client/C, turf/T, mob/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	if(duplicate_self)
		user.client.prefs.active_character.copy_to(M)
	else
		C.prefs.active_character.copy_to(M)
	M.key = C.key
	M.mind.name = user.real_name
	to_chat(M, "<B>You are an alternate version of [user.real_name] from another universe! Help [user.p_them()] accomplish [user.p_their()] goals at all costs.</B>")
	M.faction = list("[user.real_name]")
	if(duplicate_self)
		M.set_species(user.dna.species.type) //duplicate the sword user's species.
	else
		if(prob(50))
			var/list/list_all_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell, /datum/species/tajaran, /datum/species/kidan, /datum/species/golem, /datum/species/diona, /datum/species/machine, /datum/species/slime, /datum/species/grey, /datum/species/vulpkanin)
			M.set_species(pick(list_all_species))
	M.real_name = user.real_name //this is clear down here in case the user happens to become a golem; that way they have the proper name.
	M.name = user.real_name
	if(duplicate_self)
		M.dna = user.dna.Clone()
		M.UpdateAppearance()
		domutcheck(M)
	M.update_body()
	M.update_hair()
	M.update_fhair()

	equip_copy(M)

	if(evil)
		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
		M.mind.add_mind_objective(hijack_objective)
		var/list/messages = M.mind.prepare_announce_objectives(FALSE)
		to_chat(M, chat_box_red(messages.Join("<br>")))

		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] hijack.")
	else
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.target = usr.mind
		new_objective.explanation_text = "Protect [usr.real_name], your copy, and help [usr.p_them()] defend the innocent from the mobs of multiverse clones."
		M.mind.add_mind_objective(new_objective)
		var/list/messages = M.mind.prepare_announce_objectives(FALSE)
		to_chat(M, chat_box_red(messages.Join("<br>")))

		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] protect the station.")

/obj/item/multisword/proc/equip_copy(mob/living/carbon/human/M)

	var/obj/item/multisword/sword = new sword_type
	sword.assigned = assigned
	sword.faction = list("[assigned]")
	sword.evil = evil

	if(duplicate_self)
		//Duplicates the user's current equipent
		var/mob/living/carbon/human/H = usr

		var/obj/head = H.get_item_by_slot(ITEM_SLOT_HEAD)
		if(head)
			M.equip_to_slot_or_del(new head.type(M), ITEM_SLOT_HEAD)

		var/obj/mask = H.get_item_by_slot(ITEM_SLOT_MASK)
		if(mask)
			M.equip_to_slot_or_del(new mask.type(M), ITEM_SLOT_MASK)

		var/obj/glasses = H.get_item_by_slot(ITEM_SLOT_EYES)
		if(glasses)
			M.equip_to_slot_or_del(new glasses.type(M), ITEM_SLOT_EYES)

		var/obj/left_ear = H.get_item_by_slot(ITEM_SLOT_LEFT_EAR)
		if(left_ear)
			M.equip_to_slot_or_del(new left_ear.type(M), ITEM_SLOT_LEFT_EAR)

		var/obj/right_ear = H.get_item_by_slot(ITEM_SLOT_RIGHT_EAR)
		if(right_ear)
			M.equip_to_slot_or_del(new right_ear.type(M), ITEM_SLOT_RIGHT_EAR)

		var/obj/uniform = H.get_item_by_slot(ITEM_SLOT_JUMPSUIT)
		if(uniform)
			M.equip_to_slot_or_del(new uniform.type(M), ITEM_SLOT_JUMPSUIT)

		var/obj/suit = H.get_item_by_slot(ITEM_SLOT_OUTER_SUIT)
		if(suit)
			M.equip_to_slot_or_del(new suit.type(M), ITEM_SLOT_OUTER_SUIT)

		var/obj/gloves = H.get_item_by_slot(ITEM_SLOT_GLOVES)
		if(gloves)
			M.equip_to_slot_or_del(new gloves.type(M), ITEM_SLOT_GLOVES)

		var/obj/shoes = H.get_item_by_slot(ITEM_SLOT_SHOES)
		if(shoes)
			M.equip_to_slot_or_del(new shoes.type(M), ITEM_SLOT_SHOES)

		var/obj/belt = H.get_item_by_slot(ITEM_SLOT_BELT)
		if(belt)
			M.equip_to_slot_or_del(new belt.type(M), ITEM_SLOT_BELT)

		var/obj/pda = H.get_item_by_slot(ITEM_SLOT_PDA)
		if(pda)
			M.equip_to_slot_or_del(new pda.type(M), ITEM_SLOT_PDA)

		var/obj/back = H.get_item_by_slot(ITEM_SLOT_BACK)
		if(back)
			M.equip_to_slot_or_del(new back.type(M), ITEM_SLOT_BACK)

		var/obj/suit_storage = H.get_item_by_slot(ITEM_SLOT_SUIT_STORE)
		if(suit_storage)
			M.equip_to_slot_or_del(new suit_storage.type(M), ITEM_SLOT_SUIT_STORE)

		var/obj/left_pocket = H.get_item_by_slot(ITEM_SLOT_LEFT_POCKET)
		if(left_pocket)
			M.equip_to_slot_or_del(new left_pocket.type(M), ITEM_SLOT_LEFT_POCKET)

		var/obj/right_pocket = H.get_item_by_slot(ITEM_SLOT_RIGHT_POCKET)
		if(right_pocket)
			M.equip_to_slot_or_del(new right_pocket.type(M), ITEM_SLOT_RIGHT_POCKET)

		M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND) //Don't duplicate what's equipped to hands, or else duplicate swords could be generated...or weird cases of factionless swords.
	else
		if(istajaran(M) || isunathi(M))
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_SHOES)	//If they can't wear shoes, give them a pair of sandals.

		var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet", "officer", "gladiator")

		switch(randomize)
			if("mobster")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/suit/really_black(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("roman")
				var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
				M.equip_to_slot_or_del(new hat(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/shield/riot/roman(M), ITEM_SLOT_LEFT_HAND)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("wizard")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("cyborg")
				if(!ismachineperson(M))
					for(var/obj/item/organ/O in M.bodyparts)
						O.robotize(make_tough = 1)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("syndicate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("assistant")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("animu")
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/dress/schoolgirl(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("cultist")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("highlander")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/costume/kilt(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("clown")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/civilian/clown(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/bikehorn(M), ITEM_SLOT_LEFT_POCKET)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("killer")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/misc/overalls(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/kitchen/knife(M), ITEM_SLOT_LEFT_POCKET)
				M.equip_to_slot_or_del(new /obj/item/scalpel(M), ITEM_SLOT_RIGHT_POCKET)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)
				for(var/obj/item/carried_item in M.contents)
					if(!istype(carried_item, /obj/item/bio_chip))
						carried_item.add_mob_blood(M)

			if("pirate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/costume/pirate(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("soviet")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/sovietofficerhat(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/sovietcoat(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/new_soviet/sovietofficer(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("officer")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), ITEM_SLOT_GLOVES)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), ITEM_SLOT_MASK)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/miljacket(M), ITEM_SLOT_OUTER_SUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), ITEM_SLOT_EYES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)

			if("gladiator")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gladiator(M), ITEM_SLOT_HEAD)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/costume/gladiator(M), ITEM_SLOT_JUMPSUIT)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), ITEM_SLOT_LEFT_EAR)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), ITEM_SLOT_SHOES)
				M.equip_to_slot_or_del(sword, ITEM_SLOT_RIGHT_HAND)


			else
				return

	var/obj/item/card/id/W = new /obj/item/card/id
	if(duplicate_self)
		var/duplicated_access = usr.get_item_by_slot(ITEM_SLOT_ID)
		if(duplicated_access && istype(duplicated_access, /obj/item/card/id))
			var/obj/item/card/id/duplicated_id = duplicated_access
			W.access = duplicated_id.access
			W.icon_state = duplicated_id.icon_state
		else
			W.access += ACCESS_MAINT_TUNNELS
			W.icon_state = "centcom"
	else
		W.access += ACCESS_MAINT_TUNNELS
		W.icon_state = "centcom"
	W.assignment = "Multiverse Traveller"
	W.registered_name = M.real_name
	W.update_label(M.real_name)
	W.SetOwnerInfo(M)
	M.equip_to_slot_or_del(W, ITEM_SLOT_ID)

	if(isvox(M))
		M.dna.species.after_equip_job(null, M) //Nitrogen tanks
	if(isplasmaman(M))
		M.dna.species.after_equip_job(null, M) //No fireballs from other dimensions.

	M.update_icons()

/obj/item/multisword/pure_evil
	probability_evil = 100

/// If We are to be used and spent, let it be for a noble purpose.
/obj/item/multisword/pike
	name = "phantom pike"
	desc = "A fishing pike that appears to be imbued with a peculiar energy."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "harpoon"
	cooldown_between_uses = 200 //Half the time
	probability_evil = 100
	duplicate_self = 1
	sword_type = /obj/item/multisword/pike

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	///List of mobs transformed into skeletons by the stone
	var/list/active_skeletons = list()
	///How many skeletons can be converted by the stone at a time
	var/max_skeletons = 3
	///If the stone can convert infinite skeletons, bypassing max_skeletons
	var/unlimited = FALSE
	///If the stone converts into anime instead of skeletons
	var/heresy = FALSE
	///how long the additional_thralls_cooldown is
	var/above_cap_cooldown = 1 MINUTES
	///Cooldown between uses when living skeletons above max skeletons
	COOLDOWN_DECLARE(additional_thralls_cooldown)

/obj/item/necromantic_stone/Destroy()
	. = ..()
	active_skeletons = null

/obj/item/necromantic_stone/examine(mob/user)
	. = ..()
	var/skele_count = length(active_skeletons)
	if(skele_count)
		. += "[skele_count] skeleton thrall[skele_count > 1 ? "s have" : " has"] been risen by [src]."
	if(unlimited || skele_count < max_skeletons)
		return
	var/cooldown_time_left = COOLDOWN_TIMELEFT(src, additional_thralls_cooldown)
	if(cooldown_time_left)
		. += "[src] is being strained by the amount of risen skeletons thralls. It cannot be used to rise another skeleton thrall for <b>[cooldown_time_left / 10] seconds</b>."

/obj/item/necromantic_stone/attack__legacy__attackchain(mob/living/carbon/human/victim, mob/living/carbon/human/necromancer)
	if(!istype(victim) || !istype(necromancer))
		return ..()

	if(victim.stat != DEAD)
		to_chat(necromancer, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	if((!victim.mind || !victim.client) && !victim.grab_ghost())
		to_chat(necromancer, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	if(victim.mind.has_antag_datum(/datum/antagonist/mindslave/necromancy/plague_zombie))
		to_chat(necromancer, "<span class='warning'>This one is already under another artifact's influence!</span>")
		return

	if(!check_skeletons()) //If above the cap, there is a cooldown on additional skeletons
		to_chat(necromancer, "<span class='notice'>The amount of skeleton thralls risen by [src] strains its power.</span>")
		if(!COOLDOWN_FINISHED(src, additional_thralls_cooldown))
			to_chat(necromancer, "<span class='warning'>[src] cannot rise another thrall for [DisplayTimeText(COOLDOWN_TIMELEFT(src, additional_thralls_cooldown))].</span>")
			return
		COOLDOWN_START(src, additional_thralls_cooldown, above_cap_cooldown)

	convert_victim(victim, necromancer)

///Mindslave and equip the victim
/obj/item/necromantic_stone/proc/convert_victim(mob/living/carbon/human/victim, mob/living/carbon/human/necromancer)
	active_skeletons |= victim
	var/greet_text = "<span class='userdanger'>You have been revived by <b>[necromancer.real_name]</b>!\n[necromancer.p_theyre(TRUE)] your master now, assist them even if it costs you your new life!</span>"
	if(!victim.mind.has_antag_datum(/datum/antagonist/mindslave/necromancy))
		victim.mind.add_antag_datum(new /datum/antagonist/mindslave/necromancy(necromancer.mind, greet_text))

	if(heresy)
		equip_heresy(victim)//oh god why
		return

	victim.visible_message("<span class='warning'>A massive amount of flesh sloughs off [victim] and a skeleton rises up!</span>")
	equip_skeleton(victim)

///Clean the list of active skeletons and check if more can be summoned easily
/obj/item/necromantic_stone/proc/check_skeletons()
	. = FALSE
	if(unlimited)
		return TRUE

	listclearnulls(active_skeletons)
	var/living_skeletons = 0
	for(var/mob/living/carbon/human/skeleton as anything in active_skeletons)
		if(!ishuman(skeleton))
			active_skeletons.Remove(skeleton)
			continue
		if(skeleton.stat != DEAD)
			living_skeletons++

	if(living_skeletons < max_skeletons)
		return TRUE

//Funny gimmick, skeletons always seem to wear roman/ancient armour
//Voodoo Zombie Pirates added for paradise
///Udate the mobs species and gear
/obj/item/necromantic_stone/proc/equip_skeleton(mob/living/carbon/human/victim)
	victim.set_species(/datum/species/skeleton) // OP skellybones
	victim.grab_ghost() // yoinks the ghost if its not in the body
	victim.revive()

	for(var/obj/item/item in victim)
		victim.drop_item_to_ground(item)

	var/skeleton_type = pick("roman", "pirate", "yand", "clown")

	switch(skeleton_type)
		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			victim.equip_to_slot_or_del(new hat(victim), ITEM_SLOT_HEAD)
			victim.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(victim), ITEM_SLOT_JUMPSUIT)
			victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(victim), ITEM_SLOT_SHOES)
			victim.equip_to_slot_or_del(new /obj/item/shield/riot/roman(victim), ITEM_SLOT_LEFT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/claymore(victim), ITEM_SLOT_RIGHT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/spear(victim), ITEM_SLOT_BACK)
		if("pirate")
			victim.equip_to_slot_or_del(new /obj/item/clothing/under/costume/pirate(victim), ITEM_SLOT_JUMPSUIT)
			victim.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(victim),  ITEM_SLOT_OUTER_SUIT)
			victim.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(victim), ITEM_SLOT_HEAD)
			victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(victim), ITEM_SLOT_SHOES)
			victim.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(victim), ITEM_SLOT_EYES)
			victim.equip_to_slot_or_del(new /obj/item/claymore(victim), ITEM_SLOT_RIGHT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/spear(victim), ITEM_SLOT_BACK)
			victim.equip_to_slot_or_del(new /obj/item/shield/riot/roman(victim), ITEM_SLOT_LEFT_HAND)
		if("yand")//mine is an evil laugh
			victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(victim), ITEM_SLOT_SHOES)
			victim.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(victim), ITEM_SLOT_HEAD)
			victim.equip_to_slot_or_del(new /obj/item/clothing/under/dress/schoolgirl(victim), ITEM_SLOT_JUMPSUIT)
			victim.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(victim),  ITEM_SLOT_OUTER_SUIT)
			victim.equip_to_slot_or_del(new /obj/item/katana(victim), ITEM_SLOT_RIGHT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/shield/riot/roman(victim), ITEM_SLOT_LEFT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/spear(victim), ITEM_SLOT_BACK)
		if("clown")
			victim.equip_to_slot_or_del(new /obj/item/clothing/under/rank/civilian/clown(victim), ITEM_SLOT_JUMPSUIT)
			victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(victim), ITEM_SLOT_SHOES)
			victim.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(victim), ITEM_SLOT_MASK)
			victim.equip_to_slot_or_del(new /obj/item/clothing/head/stalhelm(victim), ITEM_SLOT_HEAD)
			victim.equip_to_slot_or_del(new /obj/item/bikehorn(victim), ITEM_SLOT_LEFT_POCKET)
			victim.equip_to_slot_or_del(new /obj/item/claymore(victim), ITEM_SLOT_RIGHT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/shield/riot/roman(victim), ITEM_SLOT_LEFT_HAND)
			victim.equip_to_slot_or_del(new /obj/item/spear(victim), ITEM_SLOT_BACK)

///Updates the mobs species and gear to anime
/obj/item/necromantic_stone/proc/equip_heresy(mob/living/carbon/human/victim)
	victim.set_species(/datum/species/human)
	if(victim.gender == MALE)
		victim.change_gender(FEMALE)

	var/list/anime_hair =list("Odango", "Kusanagi Hair", "Pigtails", "Hime Cut", "Floorlength Braid", "Ombre", "Twincurls", "Twincurls 2")
	victim.change_hair(pick(anime_hair))

	var/list/anime_hair_colours = list(list(216, 192, 120),
	list(140,170,74),list(0,0,0))

	var/list/chosen_colour = pick(anime_hair_colours)
	victim.change_hair_color(chosen_colour[1], chosen_colour[2], chosen_colour[3])

	victim.update_dna()
	victim.update_body()
	victim.grab_ghost()
	victim.revive()

	victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(victim), ITEM_SLOT_SHOES)
	victim.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(victim), ITEM_SLOT_HEAD)
	victim.equip_to_slot_or_del(new /obj/item/clothing/under/dress/schoolgirl(victim), ITEM_SLOT_JUMPSUIT)
	victim.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(victim),  ITEM_SLOT_OUTER_SUIT)
	victim.equip_to_slot_or_del(new /obj/item/katana(victim), ITEM_SLOT_RIGHT_HAND)
	victim.equip_to_slot_or_del(new /obj/item/shield/riot/roman(victim), ITEM_SLOT_LEFT_HAND)
	victim.equip_to_slot_or_del(new /obj/item/spear(victim), ITEM_SLOT_BACK)

	if(!victim.real_name || victim.real_name == "unknown")
		victim.real_name = "Neko-chan"
	else
		victim.real_name = "[victim.name]-chan"

	victim.mind.assigned_role = SPECIAL_ROLE_WIZARD
	victim.mind.special_role = SPECIAL_ROLE_WIZARD

	victim.say("NYA!~")

/obj/item/necromantic_stone/unlimited
	unlimited = TRUE

/obj/item/necromantic_stone/nya
	name = "nya-cromantic stone"
	desc = "A shard capable of resurrecting humans as creatures of Vile Heresy. Even the Wizard Federation fears it.."
	icon_state = "nyacrostone"
	heresy = TRUE
	unlimited = TRUE

//////////////////////// plague Talisman //////////////////////////////

/obj/item/plague_talisman
	name = "\improper Plague Talisman"
	desc = "A vile rune, capable of raising the dead as plague-bearing creatures of destruction. The edges have sharp hooks."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "plague_talisman"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
	var/chosen_plague

//checks if they're a valid target before trying to raise
/obj/item/plague_talisman/attack(mob/living/carbon/human/victim, mob/living/carbon/human/necromancer)
	if(!istype(victim) || !istype(necromancer))
		return ..()

	if(victim.stat != DEAD)
		to_chat(necromancer, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	if(ismachineperson(victim))
		to_chat(necromancer, "<span class='warning'>This one isn't vulnerable to this form of plague magic.</span>")
		return

	if((!victim.mind || !victim.client) && !victim.grab_ghost())
		to_chat(necromancer, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	if(victim.mind.has_antag_datum(/datum/antagonist/mindslave/necromancy))
		to_chat(necromancer, "<span class='warning'>This one is already under the artifact's influence! Give it time.</span>")
		return

	raise_victim(victim, necromancer)

//raises the victim into a special zombies and binds them to wiz
/obj/item/plague_talisman/proc/raise_victim(mob/living/carbon/human/victim, mob/living/carbon/human/necromancer)

	var/datum/disease/chosen_plague = pick_disease() //what disease to give them

	victim.grab_ghost() // to attempt to hold their ghost still while we do our thing
	victim.visible_message("<span class='danger'>[necromancer] places a vile rune upon [victim]'s lifeless forehead. The rune adheres to the flesh, and [victim]'s body rots and decays at unnatural speeds, before rising into a horrendous undead creature!</span>")

	var/static/list/plague_traits = list(TRAIT_NON_INFECTIOUS_ZOMBIE, TRAIT_PLAGUE_ZOMBIE)
	for(var/trait in plague_traits)
		ADD_TRAIT(victim, trait, ZOMBIE_TRAIT)

	var/datum/disease/zombie/wizard/plague_virus = new /datum/disease/zombie/wizard(chosen_plague, TRUE)
	victim.ForceContractDisease(plague_virus)
	for(var/datum/disease/V in victim.viruses)
		if(istype(V, /datum/disease/zombie))
			V.stage = 8 // immediate zombie!
		else
			V.cure() // lets remove any other annoying viruses

	// Wiz and minions shouldnt be able to contract their own diseases
	ADD_TRAIT(necromancer, TRAIT_VIRUSIMMUNE, MAGIC_TRAIT)
	ADD_TRAIT(victim, TRAIT_VIRUSIMMUNE, MAGIC_TRAIT)
	necromancer.add_language("Zombie", TRUE) // make sure necromancer can speak to the bois

	playsound(victim, 'sound/magic/mutate.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(finish_convert), victim, necromancer, chosen_plague), 5 SECONDS)

/obj/item/plague_talisman/proc/finish_convert(mob/living/carbon/human/victim, mob/living/carbon/human/necromancer, datum/disease/chosen_plague)
	var/greet_text = "<span class='userdanger'>You have been raised into undeath by <b>[necromancer.real_name]</b>!<br> \
	[necromancer.p_theyre(TRUE)] your master now, assist [necromancer.p_them()] at all costs, for you are now above death!<br> \
		You have been bestowed the following plague: <br> \
		[chosen_plague.name]!</span>"
	victim.mind.add_antag_datum(new /datum/antagonist/mindslave/necromancy(necromancer.mind, greet_text, chosen_plague))

	// Cant very well have your new minions dead for so long. Make em stronk!
	victim.maxHealth = 200
	victim.health = 200
	victim.rejuvenate()
	qdel(src) // talismans are single use

//choose what disease this zombie will get
/obj/item/plague_talisman/proc/pick_disease()
	var/picked_disease
	var/static/list/possible_diseases = list(
		/datum/disease/beesease/wizard_variant,
		/datum/disease/cold9/wizard_variant,
		/datum/disease/fluspanish/wizard_variant,
		/datum/disease/kingstons_advanced/wizard_variant,
		/datum/disease/dna_retrovirus/wizard_variant,
		/datum/disease/tuberculosis/wizard_variant,
		/datum/disease/anxiety/wizard_variant,
		/datum/disease/wizarditis/wizard_variant,
		/datum/disease/berserker,
		/datum/disease/appendicitis,
		/datum/disease/grut_gut/wizard_variant,
		/datum/disease/wand_rot/wizard_variant,
		/datum/disease/mystic_malaise/wizard_variant,
	)
	picked_disease = pick(possible_diseases)
	return picked_disease

/obj/item/organ/internal/heart/cursed/wizard
	max_shocks_allowed = 3
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

/obj/item/reagent_containers/drinks/everfull
	name = "everfull mug"
	desc = "An enchanted mug which can be filled with any of various liquids on command."
	icon_state = "evermug"

/obj/item/reagent_containers/drinks/everfull/activate_self(mob/user)
	if(..())
		return

	var/static/list/options = list("Omnizine" = image(icon = 'icons/obj/storage.dmi', icon_state = "firstaid"),
							"Ale" = image(icon = 'icons/obj/drinks.dmi', icon_state = "alebottle"),
							"Wine" = image(icon = 'icons/obj/drinks.dmi', icon_state = "wineglass"),
							"Holy Water" = image(icon = 'icons/obj/drinks.dmi', icon_state = "holyflask"),
							"Welder Fuel" = image(icon = 'icons/obj/objects.dmi', icon_state = "fuel"),
							"Vomit" = image(icon = 'icons/effects/blood.dmi', icon_state = "vomit_1"))
	var/static/list/options_to_reagent = list("Omnizine" = "omnizine",
									"Ale" = "ale",
									"Wine" = "wine",
									"Holy Water" = "holywater",
									"Welder Fuel" = "fuel",
									"Vomit" = "vomit")
	var/static/list/options_to_descriptions = list("Omnizine" = "a strange pink-white liquid",
												"Ale" = "foamy amber ale",
												"Wine" = "deep red wine",
												"Holy Water" = "sparkling clear water",
												"Welder Fuel" = "a dark, pungent, oily substance",
												"Vomit" = "warm chunky vomit")

	var/choice = show_radial_menu(user, src, options, require_near = TRUE)
	if(!choice || user.stat || !in_range(user, src) || QDELETED(src))
		return
	to_chat(user, "<span class='notice'>The [name] fills to brimming with [options_to_descriptions[choice]].</span>")
	magic_fill(options_to_reagent[choice])

/obj/item/reagent_containers/drinks/everfull/proc/magic_fill(reagent_choice)
	reagents.clear_reagents()
	reagents.add_reagent(reagent_choice, volume)

//Oblivion Enforcer clothing (the halberd and gloves are defined elsewhere)

/obj/item/clothing/head/hooded/oblivion
	name = "Oblivion Enforcer's hood"
	desc = "A hood worn by an Oblivion Enforcer."
	icon_state = "oblivionhood"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = INFINITY, FIRE = 5, ACID = 5)
	flags_2 = RAD_PROTECT_CONTENTS_2
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	magical = TRUE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/suit/hooded/oblivion
	name = "Oblivion Enforcer's robes"
	desc = "A set of armored, radiation-proof robes worn by Oblivion Enforcers."
	icon_state = "oblivionarmor"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	hoodtype = /obj/item/clothing/head/hooded/oblivion
	allowed = list(/obj/item/supermatter_halberd, /obj/item/nuke_core/supermatter_sliver)
	armor = list(MELEE = 35, BULLET = 20, LASER = 35, ENERGY = 10, BOMB = 15, RAD = INFINITY, FIRE = 5, ACID = 5)
	flags_inv = HIDEJUMPSUIT | HIDESHOES | HIDETAIL | HIDESHOES
	flags = THICKMATERIAL
	flags_2 = RAD_PROTECT_CONTENTS_2
	magical = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
	)

/obj/item/clothing/suit/hooded/oblivion/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/clothing/mask/gas/voice_modulator/oblivion
	name = "Oblivion Enforcer's mask"
	desc = "The mask of an Oblivion Enforcer. Don't forget to turn it on before giving your one-liners!"
	icon_state = "oblivionmask"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi'
	)

/obj/item/clothing/shoes/white/enforcer
	name = "hypernobilium weave shoes"
	desc = "They're surprisingly comfortable and designed to fit under an Oblivion Enforcer's robes."
	magical = TRUE

/obj/item/clothing/shoes/white/enforcer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/clothing/under/color/white/enforcer
	name = "hypernobilium weave jumpsuit"
	desc = "A close-fitting, breathable jumpsuit, tailored for the dirty work of an Oblivion Enforcer."
	has_sensor = FALSE
	magical = TRUE

/obj/item/clothing/under/color/white/enforcer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT)
