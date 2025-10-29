/mob/living/carbon/human/Initialize(mapload, datum/species/new_species = /datum/species/human)
	icon = null // This is now handled by overlays -- we just keep an icon for the sake of the map editor.
	create_dna()

	. = ..()

	setup_dna(new_species)
	setup_other()

	UpdateAppearance()
	GLOB.human_list += src
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	RegisterSignal(src, COMSIG_BODY_TRANSFER_TO, PROC_REF(mind_checks))

/**
  * Handles any adjustments to the mob after a mind transfer.
  */

/mob/living/carbon/human/proc/mind_checks()
	if(!mind)
		return FALSE
	if(mind.miming)
		DeleteComponent(/datum/component/footstep)
	return TRUE

/**
  * Sets up DNA and species.
  *
  * Arguments:
  * * new_species - The new species to assign.
  */
/mob/living/carbon/human/proc/setup_dna(datum/species/new_species)
	set_species(new_species, use_default_color = TRUE, delay_icon_update = TRUE, skip_same_check = TRUE)
	// Name
	real_name = dna.species.get_random_name(gender)
	name = real_name
	if(mind)
		mind.name = real_name
	// DNA ready
	dna.ready_dna(src)
	dna.real_name = real_name
	sync_organ_dna()

/**
  * Sets up other variables and components that may be needed for gameplay.
  */
/mob/living/carbon/human/proc/setup_other()
	create_reagents(330)
	physiology = new()

/mob/living/carbon/human/OpenCraftingMenu()
	if(!handcrafting)
		handcrafting = new()
	handcrafting.ui_interact(src)

/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/Destroy()
	. = ..()
	SSmobs.cubemonkeys -= src
	QDEL_LIST_CONTENTS(bodyparts)
	splinted_limbs.Cut()
	QDEL_NULL(physiology)
	GLOB.human_list -= src
	UnregisterSignal(src, COMSIG_BODY_TRANSFER_TO)

/datum/hit_feedback
	var/timeof
	var/damage
	var/damage_type
	var/projectile_type
	var/target_zone

/datum/hit_feedback/New(timeof, damage, damage_type, projectile_type, target_zone)
	src.timeof = timeof
	src.damage = damage
	src.damage_type = damage_type
	src.projectile_type = projectile_type
	src.target_zone = target_zone

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	var/list/hits = list()
	var/first_hit = 0
	var/last_hit = 0
	var/timer_id = TIMER_ID_NULL

/mob/living/carbon/human/dummy/bullet_act(obj/item/projectile/P, def_zone)
	if(!first_hit)
		first_hit = world.time
		visible_message("Started tracking hit at time [first_hit]!")
	last_hit = world.time
	var/datum/hit_feedback/packet = new(last_hit, P.damage, P.damage_type, P.type, def_zone)
	hits.Add(packet)
	timer_id = addtimer(CALLBACK(src, PROC_REF(check_done)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	visible_message("Hit [length(hits)]: [P.damage] dmg from [P.type] at time [last_hit]")
	return ..()

/mob/living/carbon/human/dummy/proc/check_done()
	if(!first_hit)
		return
	var/delta_now = world.time - last_hit
	// Tracking window is still open
	if(delta_now < 3 SECONDS)
		return
	// Stop counting, print, and reset
	if(timer_id != TIMER_ID_NULL)
		deltimer(timer_id)
		timer_id = TIMER_ID_NULL
	print_summary()
	first_hit = 0
	last_hit = 0
	hits.Cut()

/mob/living/carbon/human/dummy/proc/print_summary()
	if(!length(hits) || !first_hit || !last_hit)
		CRASH("Tried to print a summary with no hits/first_hit/last_hit: [hits], [first_hit], [last_hit]")
	var/N = length(hits)
	var/delta = 1
	if(length(hits) > 1)
		delta = (last_hit - first_hit)/10 // deciseconds -> seconds
	var/hits_per_sec = N/delta
	var/total_damage = 0
	for(var/hit in hits)
		var/datum/hit_feedback/h = hit
		total_damage += h.damage
	var/damage_per_sec = total_damage/delta
	log_debug("############# Starting hit report #############")
	log_debug("Counted [N] hits in [delta] sec, start/stop time = [first_hit] - [last_hit] dsec")
	log_debug("Fire rate = [hits_per_sec] hits/sec")
	log_debug("Total damage = [total_damage], DPS = [damage_per_sec]")
	log_debug("############### End hit report ################")
/mob/living/carbon/human/skrell/Initialize(mapload)
	. = ..(mapload, /datum/species/skrell)

/mob/living/carbon/human/tajaran/Initialize(mapload)
	. = ..(mapload, /datum/species/tajaran)

/mob/living/carbon/human/vulpkanin/Initialize(mapload)
	. = ..(mapload, /datum/species/vulpkanin)

/mob/living/carbon/human/unathi/Initialize(mapload)
	. = ..(mapload, /datum/species/unathi)

/mob/living/carbon/human/vox/Initialize(mapload)
	. = ..(mapload, /datum/species/vox)

/mob/living/carbon/human/skeleton/Initialize(mapload)
	. = ..(mapload, /datum/species/skeleton)

/mob/living/carbon/human/skeleton/lich/Initialize(mapload)
	. = ..(mapload, /datum/species/skeleton/lich)

/mob/living/carbon/human/skeleton/brittle/Initialize(mapload)
	. = ..(mapload, /datum/species/skeleton/brittle)

/mob/living/carbon/human/kidan/Initialize(mapload)
	. = ..(mapload, /datum/species/kidan)

/mob/living/carbon/human/plasma/Initialize(mapload)
	. = ..(mapload, /datum/species/plasmaman)

/mob/living/carbon/human/slime/Initialize(mapload)
	. = ..(mapload, /datum/species/slime)

/mob/living/carbon/human/grey/Initialize(mapload)
	. = ..(mapload, /datum/species/grey)

/mob/living/carbon/human/abductor/Initialize(mapload)
	. = ..(mapload, /datum/species/abductor)

/mob/living/carbon/human/diona/Initialize(mapload)
	. = ..(mapload, /datum/species/diona)

/mob/living/carbon/human/pod_diona/Initialize(mapload)
	. = ..(mapload, /datum/species/diona/pod)

/mob/living/carbon/human/machine/Initialize(mapload)
	. = ..(mapload, /datum/species/machine)

/mob/living/carbon/human/machine/created
	name = "Integrated Robotic Chassis"

/mob/living/carbon/human/machine/created/Initialize(mapload)
	. = ..()
	rename_character(null, "Integrated Robotic Chassis ([rand(1, 9999)])")
	update_dna()
	for(var/obj/item/organ/external/E in bodyparts)
		if(istype(E, /obj/item/organ/external/chest) || istype(E, /obj/item/organ/external/groin))
			continue
		qdel(E)
	for(var/obj/item/organ/O in internal_organs)
		qdel(O)
	regenerate_icons()
	death()

/mob/living/carbon/human/shadow/Initialize(mapload)
	. = ..(mapload, /datum/species/shadow)

/mob/living/carbon/human/golem/Initialize(mapload)
	. = ..(mapload, /datum/species/golem)

/mob/living/carbon/human/drask/Initialize(mapload)
	. = ..(mapload, /datum/species/drask)

/mob/living/carbon/human/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)

/mob/living/carbon/human/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)

/mob/living/carbon/human/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)

/mob/living/carbon/human/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)

/mob/living/carbon/human/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)

/mob/living/carbon/human/nian_worme/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/nian_worme)

/mob/living/carbon/human/moth/Initialize(mapload)
	. = ..(mapload, /datum/species/moth)
	if(!body_accessory)
		change_body_accessory("Plain Wings")

/mob/living/carbon/human/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data

	status_tab_data[++status_tab_data.len] = list("Intent:", "[a_intent]")
	status_tab_data[++status_tab_data.len] = list("Move Mode:", "[m_intent]")

	if(HAS_TRAIT(src, TRAIT_HAS_GPS))
		var/turf/T = get_turf(src)
		status_tab_data[++status_tab_data.len] = list("GPS:", "[COORD(T)]")
	if(HAS_TRAIT(src, TRAIT_CAN_VIEW_HEALTH))
		status_tab_data[++status_tab_data.len] = list("Health:", "[health]")

	if(internal)
		if(!internal.air_contents)
			qdel(internal)
		else
			status_tab_data[++status_tab_data.len] = list("Internal Atmosphere Info:", "[internal.name]")
			status_tab_data[++status_tab_data.len] = list("Tank Pressure:", "[internal.air_contents.return_pressure()]")
			status_tab_data[++status_tab_data.len] = list("Distribution Pressure:", "[internal.distribute_pressure]")

	// I REALLY need to split up status panel things into datums
	if(mind)
		var/datum/antagonist/changeling/cling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(cling)
			status_tab_data[++status_tab_data.len] = list("Chemical Storage:", "[cling.chem_charges]/[cling.chem_storage]")
			status_tab_data[++status_tab_data.len] = list("Absorbed DNA:", "[cling.absorbed_count]")

		var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
		if(V)
			status_tab_data[++status_tab_data.len] = list("Total Blood:", "[V.bloodtotal]")
			status_tab_data[++status_tab_data.len] = list("Usable Blood:", "[V.bloodusable]")

/mob/living/carbon/human/ex_act(severity)
	if((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_EXPLOSION_PROOF))
		return FALSE

	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = ARMOUR_VALUE_TO_PERCENTAGE(getarmor(armor_type = BOMB))
	var/list/valid_limbs = list("l_arm", "l_leg", "r_arm", "r_leg")
	var/limbs_amount = 1
	var/limb_loss_chance = 50
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(!prob(bomb_armor))
				gib()
				return
			else
				brute_loss = 200
				burn_loss = 200
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
				limbs_amount = 4

		if(EXPLODE_HEAVY)
			var/stuntime = 5 SECONDS - (bomb_armor / 2) //Between no stun and 5 seconds of stun depending on bomb armor
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30 * (2 - round(bomb_armor * 0.01, 0.05))
				burn_loss = brute_loss				//Damage gets reduced from 120 to up to 60 combined brute+burn
			if(ears && check_ear_prot() < HEARING_PROTECTION_TOTAL)
				ears.receive_damage(30)
			Deaf(2 MINUTES)
			Weaken(stuntime)
			KnockDown(stuntime * 3) //Up to 15 seconds of knockdown

		if(EXPLODE_LIGHT)
			brute_loss = 30
			if(bomb_armor)
				brute_loss = 15 * (2 - round(bomb_armor * 0.01, 0.05)) //Reduced from 30 to up to 15
			if(ears && check_ear_prot() < HEARING_PROTECTION_TOTAL)
				ears.receive_damage(15)
			Deaf(1 MINUTES)
			KnockDown(10 SECONDS - bomb_armor) //Between no knockdown to 10 seconds of knockdown depending on bomb armor
			valid_limbs = list("l_hand", "l_foot", "r_hand", "r_foot")
			limb_loss_chance = 25

	//attempt to dismember bodyparts
	for(var/X in valid_limbs)
		var/obj/item/organ/external/BP = get_organ(X)
		if(!BP) //limb already blown off, move to the next one without counting it
			continue
		if(prob(limb_loss_chance) && !prob(getarmor(BP, BOMB)))
			BP.droplimb(TRUE, DROPLIMB_SHARP, FALSE, TRUE)
		limbs_amount--
		if(!limbs_amount)
			break

	take_overall_damage(brute_loss, burn_loss, TRUE, used_weapon = "Explosive Blast")

	..()

/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, MELEE))

/mob/living/carbon/human/get_restraining_item()
	. = ..()
	if(!. && istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		. = wear_suit

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(if_no_id = "No id", if_no_job = "No job")
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return if_no_id
	var/obj/item/card/id/id = wear_id?.GetID()
	if(istype(id))
		return id.rank || if_no_job
	return if_no_id

//gets assignment from ID, PDA, Wallet, etc.
//This should not be relied on for authentication, because PDAs show their owner's job, even if an ID is not inserted
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return if_no_id
	if(!wear_id)
		return if_no_id
	var/obj/item/card/id/id = wear_id.GetID()
	if(istype(id)) // Make sure its actually an ID
		if(!id.assignment)
			return if_no_job
		return id.assignment

	if(is_pda(wear_id))
		var/obj/item/pda/pda = wear_id
		return pda.ownjob

	return if_no_id

//gets name from ID, PDA, Wallet, etc.
//This should not be relied on for authentication, because PDAs show their owner's name, even if an ID is not inserted
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	if(!wear_id)
		return if_no_id
	var/obj/item/card/id/id = wear_id.GetID()
	if(istype(id) && id.registered_name)
		return id.registered_name

	if(is_pda(wear_id))
		var/obj/item/pda/pda = wear_id
		return pda.owner

	return if_no_id

/mob/living/carbon/human/get_id_card()
	var/obj/item/card/id/id = wear_id?.GetID()
	if(istype(id)) // Make sure its actually an ID
		return id
	if(get_active_hand())
		var/obj/item/I = get_active_hand()
		return I.GetID()

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name(id_override = FALSE)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return "Unknown"
	if(name_override)
		return name_override
	if(wear_mask && (wear_mask.flags_inv & HIDEFACE))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if(head && (head.flags_inv & HIDEFACE))
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name) && !id_override)
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head = get_organ("head")
	if(!head || (head.status & ORGAN_DISFIGURED) || cloneloss > 50 || !real_name || HAS_TRAIT(src, TRAIT_HUSK))	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = wear_id?.GetID()
	if(istype(id))
		return id.registered_name
	if(is_pda(wear_id))
		var/obj/item/pda/pda = wear_id
		return pda.owner
	return if_no_id	//to prevent null-names making the mob unclickable

//gets ID card object from special clothes slot or, if applicable, hands as well
/mob/living/carbon/human/proc/get_idcard(check_hands = FALSE) // here
	var/obj/item/card/id/id = wear_id?.GetID()
	if(!istype(id)) //We only check for PDAs if there isn't an ID in the ID slot. IDs take priority.
		id = wear_pda?.GetID()

	if(check_hands)
		if(istype(get_active_hand(), /obj/item/card/id))
			id = get_active_hand()
		else if(istype(get_inactive_hand(), /obj/item/card/id))
			id = get_inactive_hand()

	if(istype(id))
		return id

//Gets ID card object from hands only
/mob/living/carbon/human/proc/get_id_from_hands()
	var/obj/item/card/id/ID
	var/obj/item/pda/PDA
	var/obj/item/storage/wallet/W
	var/active_hand = get_active_hand()
	var/inactive_hand = get_inactive_hand()

	//ID
	if(istype(active_hand, /obj/item/card/id) || istype(inactive_hand, /obj/item/card/id))
		if(istype(active_hand, ID))
			ID = active_hand
		else
			ID = inactive_hand

	//PDA
	else if(istype(active_hand, /obj/item/pda) || istype(inactive_hand, /obj/item/pda))
		if(istype(active_hand, PDA))
			PDA = active_hand
		else
			PDA = inactive_hand
		if(PDA.id)
			ID = PDA.id

	//Wallet
	else if(istype(active_hand, /obj/item/storage/wallet) || istype(inactive_hand, /obj/item/storage/wallet))
		if(istype(active_hand, W))
			W = active_hand
		else
			W = inactive_hand
		if(W.front_id)
			ID = W.front_id

	return ID

/mob/living/carbon/human/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	dna.species.update_sight(src)
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_suit)
			if(wear_suit.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_suit.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	else if(!(flags & SHOCK_NOGLOVES)) //This gets the siemens_coeff for all non tesla shocks
		if(gloves)
			siemens_coeff *= gloves.siemens_coefficient
	siemens_coeff *= physiology.siemens_coeff
	siemens_coeff *= dna.species.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	//Note we both check that the user is in cardiac arrest and can actually heartattack
	//If they can't, they're missing their heart and this would runtime
	if(undergoing_cardiac_arrest() && !(flags & SHOCK_ILLUSION))
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			set_heartattack(FALSE)
			if(stat == CONSCIOUS)
				to_chat(src, "<span class='notice'>You feel your heart beating again!</span>")

	dna.species.spec_electrocute_act(src, shock_damage, source, siemens_coeff, flags)

/mob/living/carbon/human/Topic(href, href_list)
	if(!usr.stat && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && !usr.restrained() && in_range(src, usr))

		if(href_list["embedded_object"])
			var/obj/item/organ/external/L = locate(href_list["embedded_limb"]) in bodyparts
			if(!L)
				return
			var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
			if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
				return
			var/time_taken = I.embedded_unsafe_removal_time*I.w_class
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from [usr.p_their()] [L.name].</span>","<span class='notice'>You attempt to remove [I] from your [L.name]... (It will take [time_taken/10] seconds.)</span>")
			if(do_after(usr, time_taken, needhand = 1, target = src))
				if(!I || !L || I.loc != src || !(I in L.embedded_objects))
					return
				L.remove_embedded_object(I)
				L.receive_damage(I.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
				I.forceMove(get_turf(src))
				usr.put_in_hands(I)
				usr.emote("scream")
				usr.visible_message("[usr] successfully rips [I] out of [usr.p_their()] [L.name]!","<span class='notice'>You successfully remove [I] from your [L.name].</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")
			return

	if(href_list["criminal"])
		try_set_criminal_status(usr)
	if(href_list["secrecord"])
		if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
			if(usr.incapacitated())
				return
			var/perpname = get_visible_name(TRUE)
			var/read = 0

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='byond://?src=[UID()];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordComment"])
		if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
			if(usr.incapacitated() && !isobserver(usr)) //give the ghosts access to "View Comment Log" while they can't manipulate it
				return
			var/perpname = get_visible_name(TRUE)
			var/read = 0

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
								read = 1
								if(LAZYLEN(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										if(islist(c))
											to_chat(usr, "[c["header"]]: [c["text"]]")
										else
											to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comments found</span>")
								if(hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
									to_chat(usr, "<a href='byond://?src=[UID()];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
			return
		var/raw_input = tgui_input_text(usr, "Add Comment:", "Security records", multiline = TRUE, encode = FALSE)
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_SECURITY_WRITE))
			return
		add_comment(usr, "security", sanitized)

	if(href_list["medical"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL_WRITE))
			if(usr.incapacitated())
				return
			var/modified = FALSE
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.general)
						if(R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr, EXAMINE_HUD_MEDICAL_WRITE))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = TRUE
									if(length(GLOB.PDA_Manifest))
										GLOB.PDA_Manifest.Cut()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["mental"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL_WRITE))
			if(usr.incapacitated())
				return
			var/modified = FALSE
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.general)
						if(R.fields["id"] == E.fields["id"])
							var/setmental = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("*Insane*", "*Unstable*", "*Watch*", "Stable", "Cancel")

							if(hasHUD(usr, EXAMINE_HUD_MEDICAL_WRITE))
								if(setmental != "Cancel")
									R.fields["m_stat"] = setmental
									modified = TRUE

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecord"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL_READ))
			if(usr.incapacitated())
				return
			var/read = 0
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL_READ))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["blood_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='byond://?src=[UID()];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordComment"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL_READ))
			if(usr.incapacitated())
				return
			var/perpname = get_visible_name(TRUE)
			var/read = FALSE

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL_READ))
								read = TRUE
								if(LAZYLEN(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comment found</span>")
								to_chat(usr, "<a href='byond://?src=[UID()];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_MEDICAL_WRITE))
			return
		var/raw_input = tgui_input_text(usr, "Add Comment:", "Medical records", multiline = TRUE, encode = FALSE)
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_MEDICAL_WRITE))
			return
		add_comment(usr, "medical", sanitized)

	if(href_list["employment_more"])
		if(hasHUD(usr, EXAMINE_HUD_SKILLS))


			var/skills
			var/perpname = get_visible_name(TRUE)
			if(perpname)
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == perpname)
						skills = E.fields["notes"]
						break
				if(skills)
					to_chat(usr, "<span class='deptradio'>Employment records: [skills]</span>\n")

	if(href_list["ai"])
		try_set_malf_status(usr)

	. = ..()

/mob/living/carbon/human/proc/try_set_criminal_status(mob/user)
	if(!hasHUD(user, EXAMINE_HUD_SECURITY_WRITE))
		return
	if(user.incapacitated())
		return

	var/perpname = get_visible_name(TRUE)
	if(perpname == "Unknown")
		to_chat(user, "<span class='warning'>Unable to locate a record for this person.</span>")
		return

	var/datum/data/record/found_record
	outer:
		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in GLOB.data_core.security)
					if(R.fields["id"] == E.fields["id"])
						found_record = R
						break outer

	if(!found_record)
		to_chat(user, "<span class='warning'>Unable to locate a record for this person.</span>")
		return

	if(found_record.fields["criminal"] == SEC_RECORD_STATUS_EXECUTE)
		to_chat(user, "<span class='warning'>Unable to modify the criminal status of a person with an active Execution order. Use a security computer instead.</span>")
		return

	var/static/list/possible_status = list(
		SEC_RECORD_STATUS_NONE,
		SEC_RECORD_STATUS_ARREST,
		SEC_RECORD_STATUS_SEARCH,
		SEC_RECORD_STATUS_MONITOR,
		SEC_RECORD_STATUS_DEMOTE,
		SEC_RECORD_STATUS_INCARCERATED,
		SEC_RECORD_STATUS_PAROLLED,
		SEC_RECORD_STATUS_RELEASED,
	)

	var/new_status = tgui_input_list(user, "Set the new criminal status for [perpname]", "Security HUD", possible_status)
	if(!new_status)
		return

	var/reason = copytext(trim(sanitize(input(user, "Enter reason:", "Security HUD") as text)), 1, MAX_MESSAGE_LEN)
	if(!reason)
		reason = "(none)"

	if(!hasHUD(user, EXAMINE_HUD_SECURITY_WRITE))
		return
	if(found_record.fields["criminal"] == SEC_RECORD_STATUS_EXECUTE)
		to_chat(user, "<span class='warning'>Unable to modify the criminal status of a person with an active Execution order. Use a security computer instead.</span>")
		return
	var/rank
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		rank = U.get_assignment()
	else if(isrobot(user))
		var/mob/living/silicon/robot/U = user
		rank = "[U.modtype] [U.braintype]"
	else if(is_ai(user))
		rank = "AI"
	set_criminal_status(user, found_record, new_status, reason, rank)

/mob/living/carbon/human/proc/try_set_malf_status(mob/user)
	if(!hasHUD(user, EXAMINE_HUD_MALF_WRITE))
		return
	if(user.incapacitated())
		return

	var/targetname = get_visible_name(TRUE)
	if(targetname == "Unknown")
		to_chat(user, "<span class='warning'>Unable to set a status for unknown persons.</span>")
		return

	var/datum/data/record/found_record
	outer:
		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == targetname)
				for(var/datum/data/record/R in GLOB.data_core.security)
					if(R.fields["id"] == E.fields["id"])
						found_record = E
						break outer

	if(!found_record)
		to_chat(user, "<span class='warning'>Unable to locate a record for this person.</span>")
		return

	var/static/list/possible_status = list(
		MALF_STATUS_NONE,
		MALF_STATUS_GREEN,
		MALF_STATUS_RED,
		MALF_STATUS_AVOID,
	)

	var/new_status = tgui_input_list(user, "What status shall we give [targetname]?", "MALF Status", possible_status)
	if(!new_status)
		return

	if(!hasHUD(user, EXAMINE_HUD_MALF_WRITE))
		return

	found_record.fields["ai_target"] = new_status

	update_all_mob_malf_hud()


/mob/living/carbon/human/can_be_flashed(intensity = 1, override_blindness_check = 0)

	var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
	. = ..()

	if((!. || (!E && !(dna.species.bodyflags & NO_EYES))))
		return FALSE

	return TRUE

///check_eye_prot()
///Returns a number between -1 to 2
/mob/living/carbon/human/check_eye_prot()
	var/number = ..()
	if(istype(head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = glasses
		number += GFP.flash_protect
	if(istype(wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = wear_mask
		number += MFP.flash_protect
	var/obj/item/organ/internal/eyes/E = get_organ_slot("eyes")
	if(E)
		number += E.flash_protect
	number = clamp(number, -1, 2)
	return number

/mob/living/carbon/human/check_ear_prot()
	if(!can_hear())
		return HEARING_PROTECTION_TOTAL
	if(istype(l_ear, /obj/item/clothing/ears/earmuffs))
		return HEARING_PROTECTION_TOTAL
	if(istype(r_ear, /obj/item/clothing/ears/earmuffs))
		return HEARING_PROTECTION_TOTAL
	if(head && (head.flags & HEADBANGPROTECT))
		return HEARING_PROTECTION_MINOR
	if(l_ear && (l_ear.flags & EARBANGPROTECT))
		return HEARING_PROTECTION_MINOR
	if(r_ear && (r_ear.flags & EARBANGPROTECT))
		return HEARING_PROTECTION_MINOR

///tintcheck()
///Checks eye covering items for visually impairing tinting, such as welding masks
///Checked in life.dm. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = You can see jack, but you can't see shit.
/mob/living/carbon/human/tintcheck()
	var/tinted = 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint

	return tinted


/mob/living/carbon/human/abiotic(full_body = 0)
	if(full_body && ((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return TRUE

	if((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)))
		return TRUE

	return FALSE


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>[src] begins playing [p_their()] ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='warning'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, TRUE, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE, penetrate_everything = FALSE)
	. = TRUE

	if(!target_zone)
		if(!user)
			. = FALSE
			CRASH("can_inject() called on a human mob with neither a user nor a targeting zone selected.")
		else
			target_zone = user.zone_selected

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = FALSE
		fail_msg = "[p_they(TRUE)] [p_are()] missing that limb."
	else if(affecting.is_robotic())
		. = FALSE
		fail_msg = "That limb is robotic."

	// If there is flesh, inject.
	if(penetrate_everything)
		return TRUE

	if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		. = FALSE

	if(wear_suit && HAS_TRAIT(wear_suit, TRAIT_RSG_IMMUNE))
		. = FALSE

	if(target_zone == "head")
		if((head?.flags & THICKMATERIAL) && !penetrate_thick)
			. = FALSE
	else
		if((wear_suit?.flags & THICKMATERIAL) && !penetrate_thick)
			. = FALSE
	if(!. && error_msg && user)
		if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == "head" ? "on [p_their()] head" : "on [p_their()] body"] to inject into."
		to_chat(user, "<span class='alert'>[fail_msg]</span>")

///
/**
 * Gets the obscured ITEM_SLOTs on a human
 *
 * Returns:
 * * A bitfield containing the ITEM_SLOTS bitflags that are obscured.
 */
/mob/living/carbon/human/proc/check_obscured_slots()
	var/obscured = NONE

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= ITEM_SLOT_GLOVES
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= ITEM_SLOT_JUMPSUIT
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= ITEM_SLOT_SHOES

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= ITEM_SLOT_MASK
		if(head.flags_inv & HIDEEYES)
			obscured |= ITEM_SLOT_EYES
		if(head.flags_inv & HIDEEARS)
			obscured |= ITEM_SLOT_BOTH_EARS

	if(obscured)
		return obscured

/mob/living/carbon/human/proc/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H || !H.can_intake_reagents)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/get_visible_gender()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if(skipface && (check_obscured_slots() & ITEM_SLOT_JUMPSUIT))
		return PLURAL
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/proc/check_and_regenerate_organs(mob/living/carbon/human/H) //Regenerates missing limbs/organs.
	var/list/types_of_int_organs = list() //This will hold all the types of organs in the mob before rejuvenation.
	for(var/obj/item/organ/internal/I in H.internal_organs)
		types_of_int_organs |= I.type //Compiling the list of organ types. It is possible for organs to be missing from this list if they are absent from the mob.

	//Clean up limbs
	for(var/organ_name in H.bodyparts_by_name)
		var/obj/item/organ/organ = H.bodyparts_by_name[organ_name]
		if(!organ) //The !organ check is to account for mechanical limb (prostheses) losses, since those are handled in a way that leaves indexed but null list entries instead of stumps.
			qdel(organ)
			H.bodyparts_by_name -= organ_name //Making sure the list entry is removed.

	//Replacing lost limbs with the species default.
	var/mob/living/carbon/human/temp_holder
	for(var/limb_type in H.dna.species.has_limbs)
		if(!(limb_type in H.bodyparts_by_name))
			var/list/organ_data = H.dna.species.has_limbs[limb_type]
			var/limb_path = organ_data["path"]
			var/obj/item/organ/external/O = new limb_path(temp_holder)
			if(H.get_limb_by_name(O.name)) //Check to see if the user already has an limb with the same name as the 'missing limb'. If they do, skip regrowth.
				continue					//In an example, this will prevent duplication of the mob's right arm if the mob is a Human and they have a Diona right arm, since,
											//while the limb with the name 'right_arm' the mob has may not be listed in their species' bodyparts definition, it is still viable and has the appropriate limb name.
			else
				O = new limb_path(H) //Create the limb on the player.
				O.owner = H
				H.bodyparts |= H.bodyparts_by_name[O.limb_name]
				if(O.body_part == HEAD) //They're sprouting a fresh head so lets hook them up with their genetic stuff so their new head looks like the original.
					H.UpdateAppearance()

	//Replacing lost organs with the species default.
	temp_holder = new /mob/living/carbon/human/fake()
	var/list/species_organs = H.dna.species.has_organ.Copy() //Compile a list of species organs and tack on the mutantears afterward.
	if(H.dna.species.mutantears)
		species_organs["ears"] = H.dna.species.mutantears
	for(var/index in species_organs)
		var/organ = species_organs[index]
		if(!(organ in types_of_int_organs)) //If the mob is missing this particular organ...
			var/obj/item/organ/internal/I = new organ(temp_holder) //Create the organ inside our holder so we can check it before implantation.
			if(H.get_organ_slot(I.slot)) //Check to see if the user already has an organ in the slot the 'missing organ' belongs to. If they do, skip implantation.
				continue				 //In an example, this will prevent duplication of the mob's eyes if the mob is a Human and they have Nian eyes, since,
										//while the organ in the eyes slot may not be listed in the mob's species' organs definition, it is still viable and fits in the appropriate organ slot.
			else
				I = new organ(H) //Create the organ inside the player.
				I.insert(H)
	qdel(temp_holder)

/**
 * Regrows a given external limb if it is missing. Does not add internal organs back in.
 * Returns whether or not it regrew the limb
 *
 * Arguments:
 * * limb_name - The name of the limb being added. "l_arm" for example
 */
/mob/living/carbon/human/proc/regrow_external_limb_if_missing(limb_name)
	if(has_organ(limb_name))
		return FALSE// Already there

	var/list/organ_data = dna.species.has_limbs[limb_name]
	var/limb_path = organ_data["path"]
	new limb_path(src)
	return TRUE

/mob/living/carbon/human/revive()
	//Fix up all organs and replace lost ones.
	restore_all_organs() //Rejuvenate and reset all existing organs.
	check_and_regenerate_organs(src) //Regenerate limbs and organs only if they're really missing.
	surgeries.Cut() //End all surgeries.

	REMOVE_TRAIT(src, TRAIT_SKELETONIZED, null)
	REMOVE_TRAIT(src, TRAIT_BADDNA, null)
	cure_husk()

	if(!client || !key) //Don't boot out anyone already in the mob.
		for(var/obj/item/organ/internal/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/datum/organ/lungs/L = get_int_organ_datum(ORGAN_DATUM_LUNGS)

	return L?.linked_organ.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/datum/organ/lungs/L = get_int_organ_datum(ORGAN_DATUM_LUNGS)
	if(L && !L.linked_organ.is_bruised())
		var/obj/item/organ/external/affected = get_organ("chest")
		affected.custom_pain("You feel a stabbing pain in your chest!")
		L.linked_organ.damage = L.linked_organ.min_bruised_damage

/mob/living/carbon/human/resist_restraints(attempt_breaking)
	if(HAS_TRAIT(src, TRAIT_HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		attempt_breaking = TRUE
	return ..()

/mob/living/carbon/human/generate_name()
	name = dna.species.get_random_name(gender)
	real_name = name
	if(dna)
		dna.real_name = name
	return name

/mob/living/carbon/human/proc/change_dna(datum/dna/new_dna, include_species_change = FALSE)
	if(include_species_change)
		set_species(new_dna.species.type, retain_damage = TRUE, transformation = TRUE, keep_missing_bodyparts = TRUE)
	dna = new_dna.Clone()
	if(include_species_change) //We have to call this after new_dna.Clone() so that species actions don't get overwritten
		dna.species.on_species_gain(src)
	real_name = new_dna.real_name
	flavor_text = dna.flavor_text
	domutcheck(src, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them
	dna.UpdateSE()
	dna.UpdateUI()
	sync_organ_dna(TRUE)
	UpdateAppearance()
	sec_hud_set_ID()



/mob/living/carbon/human/proc/export_dmi_json()
	var/filename = clean_input("filename", "filename", "my_character")

	if(filename == "")
		return

	var/maxCount = 10
	var/curCount = 0
	var/dmipath = "data/exports/characters/[filename].dmi"
	log_world("saving icon to [filename]")
	var/icon/allDirs = null

	var/list/directions = list(SOUTH, NORTH, EAST, WEST)
	for(var/d in directions)
		var/icon/new_icon
		for(var/i = 0; i < maxCount; i++)
			sleep(5)
			curCount = i
			new_icon = getFlatIcon(src, defdir=d)
			if(new_icon != null)
				break

		if(new_icon == null)
			log_world("ran [curCount] times and could not find icon")
		else
			log_world("ran [curCount] times and found icon")
			if(allDirs == null)
				allDirs = icon(new_icon, "", d)
			else
				allDirs.Insert(new_icon, "", d)

	fcopy(allDirs, dmipath)
	log_world("saved icon to [dmipath]")

	var/jsonpath = "data/exports/characters/[filename].json"
	var/json = json_encode(serialize())
	text2file(json, jsonpath)
	log_world("saved json to [jsonpath]")

/**
 * Change a mob's species.
 *
 * Arguments:
 * * new_species - The user's new species.
 * * use_default_color - If true, use the species' default color for the new mob.
 * * delay_icon_update - If true, UpdateAppearance() won't be called in this proc.
 * * skip_same_check - If true, don't bail out early if we would be changing to our current species and run through everything anyway.
 * * retain_damage - If true, damage on the mob will be re-applied post-transform. Otherwise, the mob will have its organs healed.
 * * transformation - If true, don't apply new species traits to the mob. A false value should be used when creating a new mob instead of transforming into a new species.
 * * keep_missing_bodyparts - If true, any bodyparts (legs, head, etc.) that were missing on the mob before species change will be missing post-change as well.
 */
/mob/living/carbon/human/proc/set_species(datum/species/new_species, use_default_color = FALSE, delay_icon_update = FALSE, skip_same_check = FALSE, retain_damage = FALSE, transformation = FALSE, keep_missing_bodyparts = FALSE)
	if(!skip_same_check)
		if(dna.species.name == initial(new_species.name))
			return
	var/datum/species/oldspecies = dna.species

	if(oldspecies)
		if(oldspecies.language)
			remove_language(oldspecies.language)

		if(oldspecies.default_language)
			remove_language(oldspecies.default_language)

		oldspecies.handle_dna(src, TRUE) // Remove any mutations that belong to the old species

		oldspecies.on_species_loss(src)

	dna.species = new new_species()

	tail = dna.species.tail

	wing = dna.species.wing

	maxHealth = dna.species.total_health

	if(dna.species.language)
		add_language(dna.species.language)

	if(dna.species.default_language)
		add_language(dna.species.default_language)

	hunger_drain = dna.species.hunger_drain

	if(dna.species.base_color && use_default_color)
		//Apply colour.
		skin_colour = dna.species.base_color
	else
		skin_colour = "#000000"

	if(!(dna.species.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE)))
		s_tone = 1

	var/list/thing_to_check = list(ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_SHOES, ITEM_SLOT_GLOVES, ITEM_SLOT_LEFT_EAR, ITEM_SLOT_RIGHT_EAR, ITEM_SLOT_EYES, ITEM_SLOT_LEFT_HAND, ITEM_SLOT_RIGHT_HAND, ITEM_SLOT_NECK)
	var/list/kept_items[0]
	var/list/item_flags[0]
	for(var/thing in thing_to_check)
		var/obj/item/I = get_item_by_slot(thing)
		if(I)
			if(I.flags & SKIP_TRANSFORM_REEQUIP)
				continue
			kept_items[I] = thing
			item_flags[I] = I.flags
			I.flags = 0 // Temporary set the flags to 0

	if(!transformation) //Distinguish between creating a mob and switching species
		dna.species.on_species_gain(src)

	var/list/missing_bodyparts = list()  // should line up here to pop out only what's missing
	if(keep_missing_bodyparts)
		for(var/organ_name as anything in bodyparts_by_name)
			if(isnull(bodyparts_by_name[organ_name]))
				missing_bodyparts |= organ_name

	if(retain_damage)
		//Create a list of body parts which are damaged by burn or brute and save them to apply after new organs are generated. First we just handle external organs.
		var/bodypart_damages = list()

		//Loop through all external organs and save the damage states for brute and burn
		for(var/obj/item/organ/external/E as anything in bodyparts)
			if(E.brute_dam == 0 && E.burn_dam == 0 && !(E.status & ORGAN_INT_BLEEDING)) //If there's no damage we don't bother remembering it.
				continue
			var/brute = E.brute_dam
			var/burn = E.burn_dam
			var/IB = (E.status & ORGAN_INT_BLEEDING)
			var/obj/item/organ/external/OE = new E.type()
			var/stats = list(OE, brute, burn, IB)
			bodypart_damages += list(stats)

		//Now we do the same for internal organs via the same proceedure.
		var/internal_damages = list()
		for(var/obj/item/organ/internal/I in internal_organs)
			if(I.damage == 0)
				continue
			var/obj/item/organ/internal/OI = new I.type()
			var/damage = I.damage
			var/broken = I.is_broken()
			var/stats = list(OI, damage, broken)
			internal_damages += list(stats)

		//Create the new organs for the species change
		dna.species.create_organs(src, missing_bodyparts)

		//Apply relevant damages and variables to the new organs.
		for(var/obj/item/organ/external/E as anything in bodyparts)
			for(var/list/part in bodypart_damages)
				var/obj/item/organ/external/OE = part[1]
				if((E.type == OE.type)) // Type has to be explicit, as right limbs are a child of left ones etc.
					var/brute = part[2]
					var/burn = part[3]
					var/IB = part[4] //Deal the damage to the new organ and then delete the entry to prevent duplicate checks
					if(IB)
						E.status |= ORGAN_INT_BLEEDING
					E.receive_damage(brute, burn, ignore_resists = TRUE)
					qdel(part)

		for(var/O in internal_organs)
			var/obj/item/organ/internal/I = O
			for(var/list/part in internal_damages)
				var/obj/item/organ/internal/OI = part[1]
				var/organ_type

				if(OI.parent_type == /obj/item/organ/internal) //Dealing with species organs
					organ_type = OI.type
				else
					organ_type = OI.parent_type

				if(istype(I, organ_type))
					var/damage = part[2]
					var/broken = part[3]
					I.receive_damage(damage, 1)
					if(broken && !(I.status & ORGAN_BROKEN))
						I.status |= ORGAN_BROKEN
					qdel(part)

	else
		dna.species.create_organs(src, missing_bodyparts)

	for(var/obj/item/thing in kept_items)
		var/equipped = equip_to_slot_if_possible(thing, kept_items[thing])
		thing.flags = item_flags[thing] // Reset the flags to the origional ones
		if(!equipped)
			thing.dropped() // Ensures items know they are dropped. Using their original flags

	//Handle default hair/head accessories for created mobs.
	var/obj/item/organ/external/head/H = get_organ("head")
	if(istype(H))
		if(dna.species.default_hair)
			H.h_style = dna.species.default_hair
		else
			H.h_style = "Bald"
		if(dna.species.default_fhair)
			H.f_style = dna.species.default_fhair
		else
			H.f_style = "Shaved"
		if(dna.species.default_headacc)
			H.ha_style = dna.species.default_headacc
		else
			H.ha_style = "None"

		if(dna.species.default_hair_colour)
			//Apply colour.
			H.hair_colour = dna.species.default_hair_colour
		else
			H.hair_colour = "#000000"
		if(dna.species.default_fhair_colour)
			H.facial_colour = dna.species.default_fhair_colour
		else
			H.facial_colour = "#000000"
		if(dna.species.default_headacc_colour)
			H.headacc_colour = dna.species.default_headacc_colour
		else
			H.headacc_colour = "#000000"

	m_styles = DEFAULT_MARKING_STYLES //Wipes out markings, setting them all to "None".
	m_colours = DEFAULT_MARKING_COLOURS //Defaults colour to #00000 for all markings.
	if(dna.species.bodyflags & HAS_BODY_ACCESSORY)
		body_accessory = GLOB.body_accessory_by_name[dna.species.default_bodyacc]
	else
		body_accessory = null

	dna.real_name = real_name

	update_sight()

	dna.species.handle_dna(src) //Give them whatever special dna business they got.

	update_client_colour(0)

	if(!delay_icon_update)
		UpdateAppearance()
		overlays.Cut()
		update_mutantrace()
		regenerate_icons()

	if(dna.species)
		return TRUE
	else
		return FALSE

/mob/living/carbon/human/get_default_language()
	if(default_language)
		return default_language

	if(HAS_TRAIT(src, TRAIT_I_WANT_BRAINS)) // you're not allowed to speak common
		return GLOB.all_languages["Zombie"]

	if(!dna.species)
		return null
	return dna.species.default_language ? GLOB.all_languages[dna.species.default_language] : null

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if(usr != src)
		return FALSE //something is terribly wrong
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't write on the floor in your current state!</span>")
		return
	if(bloody_hands <= 1)
		remove_verb(src, /mob/living/carbon/human/proc/bloody_doodle)
		to_chat(src, "<span class='warning'>Your hands aren't bloody enough!</span>")
		return

	if(gloves)
		to_chat(src, "<span class='warning'>[gloves] are preventing you from writing anything down!</span>")
		return

	var/turf/simulated/T = loc
	if(!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/turf/origin = T
	var/direction = tgui_input_list(src, "Which direction?", "Tile selection", list("Here", "North", "South", "East", "West"))
	if(!direction)
		return
	if(direction != "Here")
		T = get_step(T,text2dir(direction))
	if(!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for(var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if(num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = (bloody_hands - 1) * 30 //tweeter style

	var/message = tgui_input_text(src, "Write a message. It cannot be longer than [max_length] characters.", "Blood writing", max_length = max_length)
	if(origin != loc)
		to_chat(src, "<span class='notice'>Stay still while writing!</span>")
		return
	if(message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(1, bloody_hands - used_blood_amount) //use up some blood

		if(length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")
		else
			to_chat(src, "<span class='notice'>You daub '[message]' on [T] in shiny red lettering.</span>")
		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/proc/get_eyecon()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(istype(dna.species) && dna.species.eyes)
		var/icon/eyes_icon
		if(eyes)
			eyes_icon = eyes.generate_icon()
		else //Error 404: Eyes not found!
			eyes_icon = new('icons/mob/human_face.dmi', dna.species.eyes)
			eyes_icon.Blend("#800000", ICON_ADD)

		return eyes_icon

/mob/living/carbon/human/proc/get_eye_shine() //Referenced cult constructs for shining in the dark. Needs to be above lighting effects such as shading.
	var/obj/item/organ/external/head/head_organ = get_organ("head")
	if(!istype(head_organ))
		return
	var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	var/icon/hair = new /icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	var/mutable_appearance/MA = mutable_appearance(get_icon_difference(get_eyecon(), hair), layer = ABOVE_LIGHTING_LAYER)
	MA.plane = ABOVE_LIGHTING_PLANE
	return MA //Cut the hair's pixels from the eyes icon so eyes covered by bangs stay hidden even while on a higher layer.

/*Used to check if eyes should shine in the dark. Returns the image of the eyes on the layer where they will appear to shine.
Eyes need to have significantly high darksight to shine unless the mob has the XRAY vision mutation. Eyes will not shine if they are covered in any way.*/
/mob/living/carbon/human/proc/eyes_shine()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/cyberimp/eyes/eye_implant = get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
	if(!get_location_accessible(src, "eyes"))
		return FALSE
	// Natural eyeshine, any implants, and XRAY - all give shiny appearance.
	if((istype(eyes) && eyes.shine()) || istype(eye_implant) || HAS_TRAIT(src, TRAIT_XRAY_VISION))
		return TRUE

	return FALSE

/mob/living/carbon/human/assess_threat(mob/living/simple_animal/bot/secbot/judgebot, lasercolor)
	if(judgebot.emagged)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/red)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/red)))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/tag/red))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/blue)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/blue)))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/tag/blue))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/card/id/idcard = get_idcard(TRUE)
	if(judgebot.idcheck && !idcard)
		threatcount += 4

	//Check for weapons
	if(judgebot.weapons_check)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			if(judgebot.check_for_weapons(l_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(r_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(belt))
				threatcount += 4
			if(judgebot.check_for_weapons(s_store))
				threatcount += 4


	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_visible_name(TRUE)
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if(SEC_RECORD_STATUS_EXECUTE)
					threatcount += 7
				if(SEC_RECORD_STATUS_ARREST)
					threatcount += 5
				if(SEC_RECORD_STATUS_INCARCERATED)
					threatcount += 2
				if(SEC_RECORD_STATUS_PAROLLED)
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
		threatcount += 2


	//Mindshield implants imply slight trustworthiness
	if(ismindshielded(src))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/card/id/syndicate))
		threatcount -= 5

	return threatcount

/mob/living/carbon/human/singularity_act()
	. = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer"))
			. = 100
		if(mind.assigned_role == "Clown")
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in get_both_hands(src))
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)	&& drop_item_to_ground(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	base_rad_act(S, current_size * 3, GAMMA_RAD)

/mob/living/carbon/human/narsie_act()
	if(iswizard(src) || IS_CULTIST(src)) // Wizards are immune to the magic. Cultists also don't get transformed.
		return
	..()


#define CPR_CHEST_COMPRESSION_ONLY	0.75
#define CPR_RESCUE_BREATHS			1
#define CPR_CHEST_COMPRESSION_RESTORATION (2 SECONDS)
#define CPR_BREATHS_RESTORATION (4 SECONDS)

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/human/H)

	var/static/list/effective_cpr_messages = list(
		"You feel like you're able to stave off the inevitable for a little longer.",
		"You can still see the color in their cheeks."
	)

	var/static/list/ineffective_cpr_messages = list(
		"You're starting to feel them stiffen under you, but you keep going.",
		"Without rescue breaths, they seem to be turning a little blue, but you press on.",
	)

	if(H == src)
		to_chat(src, "<span class='warning'>You cannot perform CPR on yourself!</span>")
		return
	if(!isnull(H.receiving_cpr_from)) // To prevent spam stacking
		to_chat(src, "<span class='warning'>They are already receiving CPR!</span>")
		return
	if(!can_use_hands() || !has_both_hands())
		to_chat(src, "<span class='warning'>You need two hands available to do CPR!</span>")
		return
	if(l_hand || r_hand)
		to_chat(src, "<span class='warning'>You can't perform effective CPR with your hands full!</span>")
		return

	H.receiving_cpr_from = UID()
	var/cpr_modifier = get_cpr_mod(H)
	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH))
		if(ismachineperson(H) && do_mob(src, H, 4 SECONDS))  // hehe
			visible_message(
				"<span class='warning'>[src] bangs [p_their()] head on [H]'s chassis by accident!</span>",
				"<span class='danger'>You go in for a rescue breath, and bang your head on [H]'s <i>machine</i> chassis. CPR's not going to work.</span>"
				)
			playsound(H, 'sound/weapons/ringslam.ogg', 50, TRUE)
			adjustBruteLossByPart(2, "head")
			H.receiving_cpr_from = null
			return

		if(!H.is_revivable())
			to_chat(src, "<span class='warning'>[H] is already too far gone for CPR...</span>")
			H.receiving_cpr_from = null
			return

		visible_message("<span class='danger'>[src] is trying to perform CPR on [H]'s lifeless body!</span>", "<span class='danger'>You start trying to perform CPR on [H]'s lifeless body!</span>")
		while(do_mob(src, H, 4 SECONDS) && (H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH)) && H.is_revivable())
			var/timer_restored
			if(cpr_modifier == CPR_CHEST_COMPRESSION_ONLY)
				visible_message("<span class='notice'>[src] gives [H] chest compressions.</span>", "<span class='notice'>You can't make rescue breaths work, so you do your best to give chest compressions.</span>")
				timer_restored = CPR_CHEST_COMPRESSION_RESTORATION  // without rescue breaths, it won't stave off the death timer forever
			else
				visible_message("<span class='notice'>[src] gives [H] chest compressions and rescue breaths.</span>", "<span class='notice'>You give [H] chest compressions and rescue breaths.</span>")
				timer_restored = CPR_BREATHS_RESTORATION  // this, however, should keep it indefinitely postponed assuming CPR continues

			if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
				if(prob(25))
					to_chat(H, "<span class='userdanger'>Your chest burns as you receive unnecessary CPR!</span>")
				continue

			// this is the amount of time that should get added onto the timer.
			var/new_time = (timer_restored + H.get_cpr_timer_adjustment(cpr_modifier))

			SEND_SIGNAL(H, COMSIG_HUMAN_RECEIVE_CPR, (new_time SECONDS))

			if(prob(5))
				if(timer_restored >= CPR_BREATHS_RESTORATION)
					to_chat(src, pick(effective_cpr_messages))
				else
					to_chat(src, pick(ineffective_cpr_messages))

			cpr_try_activate_bomb(H)


		if(!H.is_revivable())
			to_chat(src, "<span class='notice'>You feel [H]'s body is already starting to stiffen beneath you...it's too late for CPR now.</span>")
		else
			visible_message("<span class='notice'>[src] stops giving [H] CPR.</span>", "<span class='notice'>You stop giving [H] CPR.</span>")

		H.receiving_cpr_from = null
		return

	visible_message("<span class='danger'>[src] is trying to perform CPR on [H.name]!</span>", "<span class='danger'>You try to perform CPR on [H.name]!</span>")
	if(cpr_modifier == CPR_CHEST_COMPRESSION_ONLY)
		to_chat(src, "<span class='warning'>You can't get to [H]'s mouth, so your CPR will be less effective!</span>")
	while(do_mob(src, H, 4 SECONDS) && H.health <= HEALTH_THRESHOLD_CRIT)
		H.adjustOxyLoss(-15 * cpr_modifier)
		H.SetLoseBreath(0)
		H.AdjustParalysis(-2 SECONDS)
		H.updatehealth("cpr")
		visible_message("<span class='danger'>[src] performs CPR on [H.name]!</span>", "<span class='notice'>You perform CPR on [H.name].</span>")

		cpr_try_activate_bomb(H)

		if(cpr_modifier == CPR_RESCUE_BREATHS)
			to_chat(H, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
		add_attack_logs(src, H, "CPRed", ATKLOG_ALL)

	H.receiving_cpr_from = null
	visible_message("<span class='notice'>[src] stops performing CPR on [H].</span>", "<span class='notice'>You stop performing CPR on [H].</span>")
	to_chat(src, "<span class='danger'>You need to stay still while performing CPR!</span>")

/mob/living/carbon/human/proc/get_cpr_mod(mob/living/carbon/human/H)
	if(is_mouth_covered() || H.is_mouth_covered())
		return CPR_CHEST_COMPRESSION_ONLY
	if(!H.check_has_mouth() || !check_has_mouth())
		return CPR_CHEST_COMPRESSION_ONLY
	if(HAS_TRAIT(src, TRAIT_NOBREATH) || HAS_TRAIT(H, TRAIT_NOBREATH))
		return CPR_CHEST_COMPRESSION_ONLY

	if(dna?.species.breathid != H.dna?.species.breathid)  // sorry non oxy-breathers
		to_chat(src, "<span class='warning'>You don't think you'd be able to give [H] very effective rescue breaths...</span>")
		return CPR_CHEST_COMPRESSION_ONLY
	return CPR_RESCUE_BREATHS

/// Get the amount of time that this round of CPR should add to the death timer
/mob/living/carbon/human/proc/get_cpr_timer_adjustment(cpr_mod)
	var/time_since_original_death = round(world.time - timeofdeath) / 10
	// this looks good on desmos I guess
	// goal here is that you'll get some surplus time added regardless of method if you catch them early
	var/adjustment_time = max(round(-60 * log((12 + time_since_original_death) / 240)), 0)
	if(cpr_mod == CPR_CHEST_COMPRESSION_ONLY)
		// you just won't get as much if you're late
		adjustment_time /= 2

	return adjustment_time

/mob/living/carbon/human/proc/cpr_try_activate_bomb(mob/living/carbon/human/target)
	var/obj/item/organ/external/chest/org = target.get_organ("chest")
	if(istype(org) && istype(org.hidden, /obj/item/grenade))
		var/obj/item/grenade/G = org.hidden
		if(!G.active && prob(25))
			to_chat(src, "<span class='notice'>You feel something <i>click</i> under your hands.</span>")
			add_attack_logs(src, target, "activated an implanted grenade [G] in [target] with CPR.", ATKLOG_MOST)
			playsound(target.loc, 'sound/weapons/armbomb.ogg', 60, TRUE)
			G.active = TRUE
			addtimer(CALLBACK(G, TYPE_PROC_REF(/obj/item/grenade, prime)), G.det_time)

#undef CPR_CHEST_COMPRESSION_ONLY
#undef CPR_RESCUE_BREATHS
#undef CPR_CHEST_COMPRESSION_RESTORATION
#undef CPR_BREATHS_RESTORATION

/mob/living/carbon/human/has_mutated_organs()
	for(var/obj/item/organ/external/E in bodyparts)
		if(E.status & ORGAN_MUTATED)
			return TRUE
	return FALSE

/mob/living/carbon/human/InCritical()
	return (health <= HEALTH_THRESHOLD_CRIT && stat == UNCONSCIOUS)


/mob/living/carbon/human/IsAdvancedToolUser()
	if(dna.species.has_fine_manipulation)
		return TRUE
	return FALSE

/mob/living/carbon/human/get_permeability_protection()
	var/list/prot = list("hands"=0, "chest"=0, "groin"=0, "legs"=0, "feet"=0, "arms"=0, "head"=0)
	for(var/obj/item/I in get_equipped_items())
		if(I.body_parts_covered & HANDS)
			prot["hands"] = max(1 - I.permeability_coefficient, prot["hands"])
		if(I.body_parts_covered & UPPER_TORSO)
			prot["chest"] = max(1 - I.permeability_coefficient, prot["chest"])
		if(I.body_parts_covered & LOWER_TORSO)
			prot["groin"] = max(1 - I.permeability_coefficient, prot["groin"])
		if(I.body_parts_covered & LEGS)
			prot["legs"] = max(1 - I.permeability_coefficient, prot["legs"])
		if(I.body_parts_covered & FEET)
			prot["feet"] = max(1 - I.permeability_coefficient, prot["feet"])
		if(I.body_parts_covered & ARMS)
			prot["arms"] = max(1 - I.permeability_coefficient, prot["arms"])
		if(I.body_parts_covered & HEAD)
			prot["head"] = max(1 - I.permeability_coefficient, prot["head"])
	var/protection = (prot["head"] + prot["arms"] + prot["feet"] + prot["legs"] + prot["groin"] + prot["chest"] + prot["hands"])/7
	return protection

/mob/living/carbon/human/proc/get_full_print()
	if(!dna || !dna.uni_identity)
		return
	return md5(dna.uni_identity)

/mob/living/carbon/human/reagent_vision() // If they have some glasses or helmet equipped that lets them see reagents inside transparent containers, they can see them.
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.scan_reagents)
			return TRUE
	if(istype(glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/rscan = glasses
		if(rscan.scan_reagents)
			return TRUE

/mob/living/carbon/human/advanced_reagent_vision() // If they have some glasses or helmet equipped that lets them see reagents inside everything, they can see reagents inside everything.
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.scan_reagents_advanced)
			return TRUE
	if(istype(glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/rscan = glasses
		if(rscan.scan_reagents_advanced)
			return TRUE

/mob/living/carbon/human/can_eat(flags = 255)
	return dna.species && ((dna.species.dietflags & flags) || HAS_TRAIT(src, TRAIT_IPC_CAN_EAT))

/mob/living/carbon/human/selfFeed(obj/item/food/toEat, fullness)
	if(!check_has_mouth())
		if(!ismachineperson(src) || (ismachineperson(src) && !HAS_TRAIT(src, TRAIT_IPC_CAN_EAT)))
			to_chat(src, "<span class='notice'>Where do you intend to put [toEat]? You don't have a mouth!</span>")
			return FALSE
	return ..()

/mob/living/carbon/human/forceFed(obj/item/food/toEat, mob/user, fullness)
	if(!check_has_mouth())
		if(!ismachineperson(src) || !HAS_TRAIT(src, TRAIT_IPC_CAN_EAT))
			if(!((istype(toEat, /obj/item/reagent_containers/drinks) && (ismachineperson(src)))))
				to_chat(user, "<span class='notice'>Where do you intend to put [toEat]? \The [src] doesn't have a mouth!</span>")
				return FALSE
	return ..()

/mob/living/carbon/human/selfDrink(obj/item/reagent_containers/drinks/toDrink)
	if(!check_has_mouth())
		if(!ismachineperson(src))
			to_chat(src, "<span class='notice'>Where do you intend to put \the [src]? You don't have a mouth!</span>")
			return FALSE
		else
			to_chat(src, "<span class='notice'>You pour a bit of liquid from [toDrink] into your connection port.</span>")
	else
		to_chat(src, "<span class='notice'>You swallow a gulp of [toDrink].</span>")
	return TRUE

/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id)
		var/obj/item/card/id/id = wear_id.GetID()
		if(istype(id) && id.is_untrackable())
			return FALSE
	if(wear_pda)
		var/obj/item/card/id/id = wear_pda.GetID()
		if(istype(id) && id.is_untrackable())
			return FALSE
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return FALSE
	if(w_uniform)
		var/obj/item/clothing/under/uniform = w_uniform
		if(uniform.blockTracking)
			return FALSE

	return ..()

/mob/living/carbon/human/proc/get_age_pitch(species_pitch = 85)
	return 1.0 + 0.5 * ((species_pitch * 0.35) - age) / (0.94 * species_pitch)

/mob/living/carbon/human/get_access()
	. = ..()

	if(wear_id)
		. |= wear_id.GetAccess()
	if(wear_pda)
		. |= wear_pda.GetAccess()
	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(U.accessories)
			for(var/obj/item/clothing/accessory/A in U.accessories)
				. |= A.GetAccess()

/mob/living/carbon/human/is_mechanical()
	return ..() || (dna.species.bodyflags & ALL_RPARTS) != 0

/mob/living/carbon/human/can_use_guns(obj/item/gun/G)
	. = ..()

	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(HAS_TRAIT(src, TRAIT_CHUNKYFINGERS))
			to_chat(src, "<span class='warning'>Your meaty finger is far too large for the trigger guard!</span>")
			return FALSE

	if(mind && mind.martial_art && mind.martial_art.no_guns) //great dishonor to famiry
		to_chat(src, "<span class='warning'>[mind.martial_art.no_guns_message]</span>")
		return FALSE

/mob/living/carbon/human/proc/change_icobase(new_icobase, owner_sensitive)
	for(var/obj/item/organ/external/O in bodyparts)
		O.change_organ_icobase(new_icobase, owner_sensitive) //Change the icobase of all our organs. If owner_sensitive is set, that means the proc won't mess with frankenstein limbs.

/mob/living/carbon/human/serialize()
	// Currently: Limbs/organs only
	var/list/data = ..()
	var/list/limbs_list = list()
	var/list/organs_list = list()
	var/list/equip_list = list()
	var/list/implant_list = list()
	data["limbs"] = limbs_list
	data["iorgans"] = organs_list
	data["equip"] = equip_list
	data["implant_list"] = implant_list

	data["dna"] = dna.serialize()
	data["age"] = age

	// No being naked
	data["ushirt"] = undershirt
	data["socks"] = socks
	data["uwear"] = underwear

	// Limbs
	for(var/limb in bodyparts_by_name)
		var/obj/item/organ/O = bodyparts_by_name[limb]
		if(!O)
			limbs_list[limb] = "missing"
			continue

		limbs_list[limb] = O.serialize()

	// Internal organs/augments
	for(var/organ in internal_organs)
		var/obj/item/organ/O = organ
		organs_list[O.name] = O.serialize()

	// Equipment
	equip_list.len = ITEM_SLOT_AMOUNT
	for(var/i in 1 to ITEM_SLOT_AMOUNT)
		var/obj/item/thing = get_item_by_slot(1<<(i - 1)) // -1 because ITEM_SLOT_FLAGS start at 0 (and BYOND lists do not)
		if(!isnull(thing))
			equip_list[i] = thing.serialize()

	for(var/obj/item/bio_chip/implant in src)
		implant_list[implant] = implant.serialize()

	return data

/mob/living/carbon/human/deserialize(list/data)
	var/list/limbs_list = data["limbs"]
	var/list/organs_list = data["iorgans"]
	var/list/equip_list = data["equip"]
	var/list/implant_list = data["implant_list"]
	var/turf/T = get_turf(src)
	if(!islist(data["limbs"]))
		throw EXCEPTION("Expected a limbs list, but found none")

	if(islist(data["dna"]))
		dna.deserialize(data["dna"])
		real_name = dna.real_name
		name = real_name
		set_species(dna.species.type, skip_same_check = TRUE)
	age = data["age"]
	undershirt = data["ushirt"]
	underwear = data["uwear"]
	socks = data["socks"]
	for(var/obj/item/organ/internal/iorgan in internal_organs)
		qdel(iorgan)

	for(var/obj/item/organ/external/organ in bodyparts)
		qdel(organ)

	for(var/limb in limbs_list)
		// Missing means skip this part - it's missing
		if(limbs_list[limb] == "missing")
			continue
		// "New" code handles insertion and DNA sync'ing
		var/obj/item/organ/external/E = list_to_object(limbs_list[limb], src)
		E.sync_colour_to_dna()

	for(var/organ in organs_list)
		// As above, "New" code handles insertion, DNA sync
		list_to_object(organs_list[organ], src)

	for(var/thing in implant_list)
		var/implant_data = implant_list[thing]
		var/path = text2path(implant_data["type"])
		var/obj/item/bio_chip/implant = new path(T)
		if(!implant.implant(src, src))
			qdel(implant)

	UpdateAppearance()

	// De-serialize equipment
	// #1: Jumpsuit
	// #2: Outer suit
	// #3+: Everything else
	if(islist(equip_list[ITEM_SLOT_2_INDEX(ITEM_SLOT_JUMPSUIT)]))
		var/obj/item/clothing/C = list_to_object(equip_list[ITEM_SLOT_2_INDEX(ITEM_SLOT_JUMPSUIT)], T)
		equip_to_slot_if_possible(C, ITEM_SLOT_JUMPSUIT)

	if(islist(equip_list[ITEM_SLOT_2_INDEX(ITEM_SLOT_OUTER_SUIT)]))
		var/obj/item/clothing/C = list_to_object(equip_list[ITEM_SLOT_2_INDEX(ITEM_SLOT_OUTER_SUIT)], T)
		equip_to_slot_if_possible(C, ITEM_SLOT_OUTER_SUIT)

	for(var/i in 1 to (ITEM_SLOT_AMOUNT))
		if(i == ITEM_SLOT_2_INDEX(ITEM_SLOT_JUMPSUIT) || i == ITEM_SLOT_2_INDEX(ITEM_SLOT_OUTER_SUIT))
			continue
		if(islist(equip_list[i]))
			var/obj/item/clothing/C = list_to_object(equip_list[i], T)
			equip_to_slot_if_possible(C, 1<<(i - 1)) // -1 because ITEM_SLOT_FLAGS start at 0 (and BYOND lists do not)
	update_icons()

	..()

/mob/living/carbon/human/adjust_nutrition(change)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/set_nutrition(change)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	return ..()

/mob/living/carbon/human/proc/special_post_clone_handling()
	if(mind && mind.assigned_role == "Cluwne") //HUNKE your suffering never stops
		makeCluwne()

/mob/living/carbon/human/is_literate()
	return getBrainLoss() < 90


/mob/living/carbon/human/fakefire(fire_icon = "Generic_mob_burning")
	if(!overlays_standing[FIRE_LAYER])
		overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_icon)
		update_icons()

/mob/living/carbon/human/fakefireextinguish()
	overlays_standing[FIRE_LAYER] = null
	update_icons()

/mob/living/carbon/human/proc/cleanSE()	//remove all disabilities/powers
	for(var/block = 1; block <= DNA_SE_LENGTH; block++)
		dna.SetSEState(block, FALSE, TRUE)
		singlemutcheck(src, block, MUTCHK_FORCED)
	dna.UpdateSE()

/mob/living/carbon/human/get_spooked()
	to_chat(src, "<span class='whisper'>[pick(GLOB.boo_phrases)]</span>")
	return TRUE

/mob/living/carbon/human/extinguish_light(force = FALSE)
	// Parent function handles stuff the human may be holding
	..()

	var/obj/item/organ/internal/lantern/O = get_int_organ(/obj/item/organ/internal/lantern)
	if(O && O.glowing)
		O.toggle_biolum(TRUE)
		visible_message("<span class='danger'>[src] is engulfed in shadows and fades into the darkness.</span>", "<span class='danger'>A sense of dread washes over you as you suddenly dim dark.</span>")

/mob/living/carbon/human/proc/get_perceived_trauma(shock_reduction)
	return min(health, maxHealth) + shock_reduction

/mob/living/carbon/human/WakeUp(updating = TRUE)
	if(dna.species.spec_WakeUp(src))
		return
	..()

/mob/living/carbon/human/update_runechat_msg_location()
	if(ismecha(loc))
		runechat_msg_location = loc.UID()
	else if(istgvehicle(loc))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/carbon/human/verb/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(GLOB.configuration.general.allow_character_metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[sanitize(client.prefs.active_character.metadata)]")
		else
			to_chat(usr, "[src] does not have any stored information!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	// no metagaming
	if(stat)
		return

	pose = tgui_input_text(usr, "This is [src]. [p_they(TRUE)]...", "Pose")

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()

/mob/living/carbon/human/proc/expert_chef_knowledge()
	if(!HAS_TRAIT(mind, TRAIT_KNOWS_COOKING_RECIPES))
		return

	var/list/possible_cookware = view(1, src)

	for(var/obj/item/storage/storage in possible_cookware)
		possible_cookware += storage.contents
		possible_cookware -= storage

	shuffle_inplace(possible_cookware)

	var/list/available_ingredients = list()
	var/list/available_reagents = list()
	for(var/obj/item/item in possible_cookware)
		if(item.container_type == OPENCONTAINER && item.reagents)
			for(var/datum/reagent/reagent in item.reagents.reagent_list)
				if(!available_reagents[reagent.id])
					available_reagents[reagent.id] = 0
				available_reagents[reagent.id] += reagent.volume
		else
			if(!available_ingredients[item.type])
				available_ingredients[item.type] = 0
			available_ingredients[item.type] += 1

	var/list/possible_recipes = list()
	for(var/datum/recipe/recipe_type as anything in subtypesof(/datum/recipe))
		if(!recipe_type.result)
			continue
		var/datum/recipe/recipe = new recipe_type()
		if(recipe.check_reagents_assoc_list(available_reagents) != INGREDIENT_CHECK_FAILURE && recipe.check_items_assoc_list(available_ingredients) != INGREDIENT_CHECK_FAILURE)
			if(istype(recipe, /datum/recipe/microwave))
				possible_recipes[recipe] = RECIPE_MICROWAVE
			else
				possible_recipes[recipe] = "something? This shouldn't happen, make a bug report"

	if(!length(possible_recipes))
		to_chat(src, "<span class='warning'>You can't think of anything to cook with the items around you.</span>")
		return

	var/list/message = list("You draw upon your extensive experience in space food, contemplating what you could make with the items around you...")
	for(var/datum/recipe/recipe in possible_recipes)
		var/list/assoc = type_list_to_counted_assoc_list(recipe.items)
		var/list/ingredient_list = list()
		for(var/obj/item/path_key as anything in assoc)
			ingredient_list += "[assoc[path_key]] [initial(path_key.name)]\s"

		var/list/required_reagents = list()
		for(var/reagent_id in recipe.reagents)
			var/datum/reagent/temp = GLOB.chemical_reagents_list[reagent_id]
			if(temp)
				required_reagents += "[recipe.reagents[reagent_id]] unit\s of [temp.name]"

		var/obj/item/result = recipe.result
		message += "\tI could make [result.gender == PLURAL ? "some" : "a"] [bicon(result)] <b>[result.name]</b> by using \a [possible_recipes[recipe]] with [english_list(ingredient_list)][length(required_reagents) ? ", along with [english_list(required_reagents)]" : ""]."
		qdel(recipe)
	to_chat(src, chat_box_examine(message.Join("<br>")))

/mob/living/carbon/human/proc/get_unarmed_attack()
	var/datum/antagonist/zombie/zombie = mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!istype(zombie))
		return dna.species.unarmed
	return zombie.claw_attack

/mob/living/carbon/human/proc/get_dna_scrambled()
	scramble(1, src, 100)
	real_name = random_name(gender, dna.species.name) // Give them a name that makes sense for their species.
	sync_organ_dna(assimilate = 1)
	update_body()
	reset_hair() // No more winding up with hairstyles you're not supposed to have, and blowing your cover.
	reset_markings() // ...Or markings.
	dna.ResetUIFrom(src)
	flavor_text = ""

/**
 * Helper for tracking alpha, use this to set an alpha source
 *
 * alpha_num - num between 0 and 255 that represents the alpha from `source`
 * source - a datum that is the cause of the alpha source. This will be turned into a key via UID.
 * update_alpha - boolean if alpha should be updated with this proc. Set this to false if you plan to animate the alpha after this call.
 */
/mob/living/carbon/human/proc/set_alpha_tracking(alpha_num, datum/source, update_alpha = TRUE)
	alpha_num = round(alpha_num)
	if(alpha_num >= ALPHA_VISIBLE)
		LAZYREMOVE(alpha_sources, source.UID())
	else
		LAZYSET(alpha_sources, source.UID(), max(alpha_num, 0))
	if(update_alpha)
		alpha = get_alpha()

/**
 * Gets the target alpha of the human
 *
 * optional_source - use this to get the alpha of an exact source. This is unsafe, only use if you 100% know it will be in the list. For the best safety, only call this as get_alpha(src)
 */
/mob/living/carbon/human/proc/get_alpha(datum/optional_source)
	if(optional_source)
		return alpha_sources[optional_source.UID()]
	. = ALPHA_VISIBLE
	for(var/source in alpha_sources)
		. = min(., alpha_sources[source])

/*
 * Returns wether or not the brain is below the threshold
 */
/mob/living/carbon/human/proc/check_brain_threshold(threshold_level)
	var/obj/item/organ/internal/brain/brain_organ = get_int_organ(/obj/item/organ/internal/brain)
	return brain_organ.damage >= (brain_organ.max_damage * threshold_level)


/mob/living/carbon/human/plushify(plushie_override, curse_time)
	. = ..(dna.species.plushie_type, curse_time)

/*
 * Invokes a hallucination on the mob. Hallucination must be a path or a string of a path
 */
/mob/living/carbon/human/proc/invoke_hallucination(hallucination_to_make)
	var/string_path = text2path(hallucination_to_make)
	if(!ispath(hallucination_to_make))
		if(!string_path)
			return
		hallucination_to_make = string_path
	new hallucination_to_make(get_turf(src), src)

/// Checks if an item is inside the body of the mob
/mob/living/carbon/human/is_inside_mob(atom/thing)
	if(!(..()))
		return FALSE
	if(w_uniform && w_uniform.UID() == thing.UID())
		return FALSE
	if(shoes && shoes.UID() == thing.UID())
		return FALSE
	if(belt && belt.UID() == thing.UID())
		return FALSE
	if(gloves && gloves.UID() == thing.UID())
		return FALSE
	if(neck && neck.UID() == thing.UID())
		return FALSE
	if(glasses && glasses.UID() == thing.UID())
		return FALSE
	if(l_ear && l_ear.UID() == thing.UID())
		return FALSE
	if(r_ear && r_ear.UID() == thing.UID())
		return FALSE
	if(wear_id && wear_id.UID() == thing.UID())
		return FALSE
	if(wear_pda && wear_pda.UID() == thing.UID())
		return FALSE
	if(r_store && r_store.UID() == thing.UID())
		return FALSE
	if(l_store && l_store.UID() == thing.UID())
		return FALSE
	if(s_store && s_store.UID() == thing.UID())
		return FALSE

	return TRUE

/mob/living/carbon/human/AltClick(mob/user, modifiers)
	. = ..()
	if(user.stat || user.restrained() || (!in_range(src, user)))
		return

	if(user.mind && !HAS_TRAIT(user.mind, TRAIT_MED_EXAMINE))
		return

	user.visible_message("[user] begins to thoroughly examine [src].")
	if(do_after_once(user, 12 SECONDS, target = src, allow_moving = FALSE, attempt_cancel_message = "You couldn't get a good look at [src]!"))
		var/list/missing = list("head", "chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
		var/list/analysis = list()
		for(var/obj/item/organ/external/E in src.bodyparts)
			missing -= E.limb_name
			if(E.status & ORGAN_DEAD)
				analysis += "<span class='info'>You conclude [src]'s [E.name] is dead.</span>"
			if(E.status & ORGAN_INT_BLEEDING)
				analysis += "<span class='info'>You conclude [src]'s [E.name] has internal bleeding.</span>"
			if(E.status & ORGAN_BURNT)
				analysis += "<span class='info'>You conclude [src]'s [E.name] has been critically burned.</span>"
			if(E.status & ORGAN_BROKEN)
				if(!E.broken_description)
					analysis += "<span class='info'>You conclude [src]'s [E.name] is broken.</span>"
				else
					analysis += "<span class='info'>You conclude [src]'s [E.name] has a [E.broken_description].</span>"
		if(!length(analysis))
			analysis += "<span class='info'>[src] appears to be in perfect health.</span>"
		to_chat(user, chat_box_healthscan(analysis.Join("<br>")))

/mob/living/carbon/human/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = null
	if(next_move >= world.time)
		return

	if(istype(A, /obj/effect/temp_visual/point) || istype(A, /atom/movable/emissive_blocker))
		return FALSE
	if(mind && HAS_MIND_TRAIT(src, TRAIT_COFFEE_SNOB))
		var/found_coffee = FALSE
		for(var/reagent in reagents.reagent_list)
			if(istype(reagent, /datum/reagent/consumable/drink/coffee))
				found_coffee = TRUE
		if(found_coffee)
			changeNext_move(CLICK_CD_POINT / 3)
		else
			changeNext_move(CLICK_CD_POINT)
	else
		changeNext_move(CLICK_CD_POINT)

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_pointed), A))

/// Default behavior when getting ground up in a compressor
/mob/living/carbon/human/compressor_grind()
	dna.species.do_compressor_grind(src)
	. = ..()

/mob/living/carbon/human/get_strippable_items(datum/source, list/items)
	items |= GLOB.strippable_human_items
