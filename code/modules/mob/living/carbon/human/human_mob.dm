/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	deathgasp_on_death = TRUE
	throw_range = 4

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species = /datum/species/human)
	icon = null // This is now handled by overlays -- we just keep an icon for the sake of the map editor.
	create_dna()

	. = ..()

	setup_dna(new_species)
	setup_other()

	UpdateAppearance()
	GLOB.human_list += src
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)

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

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

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

/mob/living/carbon/human/voxarmalis/Initialize(mapload)
	. = ..(mapload, /datum/species/vox/armalis)

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

/mob/living/carbon/human/nucleation/Initialize(mapload)
	. = ..(mapload, /datum/species/nucleation)

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

/mob/living/carbon/human/moth/Initialize(mapload)
	. = ..(mapload, /datum/species/moth)
	if(!body_accessory)
		change_body_accessory("Plain Wings")

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		var/total_user_contents = GetAllContents() // cache it
		if(locate(/obj/item/gps) in total_user_contents)
			var/turf/T = get_turf(src)
			stat(null, "GPS: [COORD(T)]")
		if(locate(/obj/item/assembly/health) in total_user_contents)
			stat(null, "Health: [health]")

		if(internal)
			if(!internal.air_contents)
				qdel(internal)
			else if(client?.prefs.toggles2 & PREFTOGGLE_2_SIMPLE_STAT_PANEL)
				stat(null, "Internals Tank Connected")
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		// I REALLY need to split up status panel things into datums

		if(mind)
			var/datum/antagonist/changeling/cling = mind.has_antag_datum(/datum/antagonist/changeling)
			if(cling)
				stat("Chemical Storage", "[cling.chem_charges]/[cling.chem_storage]")
				stat("Absorbed DNA", cling.absorbed_count)

			var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
			if(V)
				stat("Total Blood", "[V.bloodtotal]")
				stat("Usable Blood", "[V.bloodusable]")

/mob/living/carbon/human/ex_act(severity)
	if(status_flags & GODMODE)
		return FALSE

	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = ARMOUR_VALUE_TO_PERCENTAGE(getarmor(null, BOMB))
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
			if(check_ear_prot() < HEARING_PROTECTION_TOTAL)
				Deaf(2 MINUTES)
				ears.receive_damage(30)
			Weaken(stuntime)
			KnockDown(stuntime * 3) //Up to 15 seconds of knockdown

		if(EXPLODE_LIGHT)
			brute_loss = 30
			if(bomb_armor)
				brute_loss = 15 * (2 - round(bomb_armor * 0.01, 0.05)) //Reduced from 30 to up to 15
			if(check_ear_prot() < HEARING_PROTECTION_TOTAL)
				Deaf(1 MINUTES)
				ears.receive_damage(15)
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

/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask) || get_organ_slot("breathing_tube")
	var/list/obscured = check_obscured_slots()

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? html_encode(l_hand) : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? html_encode(r_hand) : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? html_encode(back) : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[UID()];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? html_encode(head) : "<font color=grey>Empty</font>"]</A></td></tr>"

	var/obj/item/organ/internal/headpocket/C = get_int_organ(/obj/item/organ/internal/headpocket)
	if(C)
		if(slot_wear_mask in obscured)
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Headpocket:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			if(C.held_item)
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><A href='?src=[UID()];dislodge_headpocket=1'>Dislodge Items</A></td></tr>"
			else
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><font color=grey>Empty</font></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? html_encode(wear_mask) : "<font color=grey>Empty</font>"]</A>"

		if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
			var/obj/item/clothing/mask/muzzle/M = wear_mask
			if(M.security_lock)
				dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(!issmall(src))
		if(slot_glasses in obscured)
			dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=[UID()];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? html_encode(glasses) : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_l_ear in obscured)
			dat += "<tr><td><font color=grey><B>Left Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Left Ear:</B></td><td><A href='?src=[UID()];item=[slot_l_ear]'>[(l_ear && !(l_ear.flags&ABSTRACT))		? html_encode(l_ear)	: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_r_ear in obscured)
			dat += "<tr><td><font color=grey><B>Right Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Right Ear:</B></td><td><A href='?src=[UID()];item=[slot_r_ear]'>[(r_ear && !(r_ear.flags&ABSTRACT))		? html_encode(r_ear)		: "<font color=grey>Empty</font>"]</A></td></tr>"

		dat += "<tr><td>&nbsp;</td></tr>"

		dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? html_encode(wear_suit) : "<font color=grey>Empty</font>"]</A></td></tr>"
		if(wear_suit)
			dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=[UID()];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? html_encode(s_store) : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(s_store, /obj/item/tank))
				dat += "&nbsp;<A href='?src=[UID()];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
		else
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

		if(slot_shoes in obscured)
			dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=[UID()];item=[html_encode(slot_shoes)]'>[(shoes && !(shoes.flags&ABSTRACT))		? html_encode(shoes)		: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_gloves in obscured)
			dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=[UID()];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? html_encode(gloves)	: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_w_uniform in obscured)
			dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=[UID()];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? html_encode(w_uniform) : "<font color=grey>Empty</font>"]</A></td></tr>"

		if((w_uniform == null && !(dna && dna.species.nojumpsuit)) || (slot_w_uniform in obscured))
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Sensors:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>PDA:</B></font></td></tr>"
		else
			dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=[UID()];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? html_encode(belt) : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(belt, /obj/item/tank))
				dat += "&nbsp;<A href='?src=[UID()];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
			// Pockets
			dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=[UID()];pockets=left'>"
			if(l_store && internal && l_store == internal)
				dat += "[l_store]"
			else if(l_store && !(l_store.flags&ABSTRACT))
				dat += "Left (Full)"
			else
				dat += "<font color=grey>Left (Empty)</font>"
			dat += "</A>&nbsp;<A href='?src=[UID()];pockets=right'>"
			if(r_store && internal && r_store == internal)
				dat += "[r_store]"
			else if(r_store && !(r_store.flags&ABSTRACT))
				dat += "Right (Full)"
			else
				dat += "<font color=grey>Right (Empty)</font>"
			dat += "</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=[UID()];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? html_encode(wear_id) : "<font color=grey>Empty</font>"]</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>PDA:</B></td><td><A href='?src=[UID()];item=[slot_wear_pda]'>[(wear_pda && !(wear_pda.flags&ABSTRACT)) ? "Full" : "<font color=grey>Empty</font>"]</A></td></tr>"

			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				dat += "<tr><td>&nbsp;&#8627;<B>Suit Sensors:</b></td><td><A href='?src=[UID()];set_sensor=1'>[U.has_sensor >= 2 ? "</a><font color=grey>--SENSORS LOCKED--</font>" : "Set Sensors</a>"]</td></tr>"

				if(U.accessories.len)
					dat += "<tr><td>&nbsp;&#8627;<A href='?src=[UID()];strip_accessory=1'>Remove Accessory</a></td></tr>"


	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><b>Legcuffed:</b> <a href='?src=[UID()];item=[slot_legcuffed]'>Remove</a></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 540)
	popup.set_content(dat)
	popup.open()

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/pda/pda = wear_id
	if(istype(pda))
		if(pda.id)
			return pda.id.rank
		else
			return pda.ownrank
	else
		var/obj/item/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID, PDA, Wallet, etc.
//This should not be relied on for authentication, because PDAs show their owner's job, even if an ID is not inserted
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
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
		var/thief_mode = 0
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/obj/item/clothing/gloves/G = H.gloves
			if(G && G.pickpocket)
				thief_mode = 1

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

		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					to_chat(usr, "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
				to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
			else if(place_item && place_item.mob_can_equip(src, pocket_id, 1) && !(place_item.flags&ABSTRACT))
				to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
				if(pocket_item)
					if(pocket_item == (pocket_id == slot_r_store ? r_store : l_store)) //item still in the pocket we search
						unEquip(pocket_item)
						if(thief_mode)
							usr.put_in_hands(pocket_item)
						add_attack_logs(usr, src, "Stripped of [pocket_item]", isLivingSSD(src) ? null : ATKLOG_ALL)
				else
					if(place_item)
						usr.unEquip(place_item)
						equip_to_slot_if_possible(place_item, pocket_id, FALSE, TRUE)
						add_attack_logs(usr, src, "Equipped with [place_item]", isLivingSSD(src) ? null : ATKLOG_ALL)

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up if they don't have pickpocket gloves.
				if(!thief_mode)
					to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")
				add_attack_logs(usr, src, "Attempted strip of [pocket_item]", isLivingSSD(src) ? null : ATKLOG_ALL)

		if(href_list["set_sensor"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				U.set_sensors(usr)

		if(href_list["dislodge_headpocket"])
			usr.visible_message("<span class='danger'>[usr] is trying to remove something from [src]'s head!</span>",
													"<span class='danger'>You start to dislodge whatever's inside [src]'s headpocket!</span>")
			if(do_mob(usr, src, POCKET_STRIP_DELAY))
				usr.visible_message("<span class='danger'>[usr] has dislodged something from [src]'s head!</span>",
														"<span class='danger'>You have dislodged everything from [src]'s headpocket!</span>")
				var/obj/item/organ/internal/headpocket/C = get_int_organ(/obj/item/organ/internal/headpocket)
				C.empty_contents()
				add_attack_logs(usr, src, "Stripped of headpocket items", isLivingSSD(src) ? null : ATKLOG_ALL)

		if(href_list["strip_accessory"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				if(U.accessories.len)
					var/obj/item/clothing/accessory/A = U.accessories[1]
					if(!thief_mode)
						usr.visible_message("<span class='danger'>\The [usr] starts to take off \the [A] from \the [src]'s [U]!</span>", \
											"<span class='danger'>You start to take off \the [A] from \the [src]'s [U]!</span>")

					if(do_mob(usr, src, 40) && A && U.accessories.len)
						if(!thief_mode)
							usr.visible_message("<span class='danger'>\The [usr] takes \the [A] off of \the [src]'s [U]!</span>", \
												"<span class='danger'>You take \the [A] off of \the [src]'s [U]!</span>")
						U.detach_accessory(A, usr)

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
								to_chat(usr, "<a href='?src=[UID()];secrecordComment=`'>\[View Comment Log\]</a>")
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
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comments found</span>")
								if(hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
									to_chat(usr, "<a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
			return
		var/raw_input = input("Add Comment:", "Security records", null, null) as message
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_SECURITY_WRITE))
			return
		add_comment(usr, "security", sanitized)

	if(href_list["medical"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/modified = 0
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.general)
						if(R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(GLOB.PDA_Manifest.len)
										GLOB.PDA_Manifest.Cut()

									spawn()
										sec_hud_set_security_status()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecord"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/read = 0
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=[UID()];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordComment"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/perpname = get_visible_name(TRUE)
			var/read = FALSE

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								read = TRUE
								if(LAZYLEN(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comment found</span>")
								to_chat(usr, "<a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_MEDICAL))
			return
		var/raw_input = input("Add Comment:", "Medical records", null, null) as message
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_MEDICAL))
			return
		add_comment(usr, "medical", sanitized)

	if(href_list["employment_more"])
		if(hasHUD(usr, EXAMINE_HUD_SKILLS))
			if(usr.incapacitated() && !isobserver(usr))
				return

			var/skills
			var/perpname = get_visible_name(TRUE)
			if(perpname)
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == perpname)
						skills = E.fields["notes"]
						break
				if(skills)
					to_chat(usr, "<span class='deptradio'>Employment records: [skills]</span>\n")

	if(href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if(href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)
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

	var/new_status = input(user, "Set the new criminal status for [perpname].", "Security HUD", found_record.fields["criminal"]) as null|anything in possible_status
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
	else if(isAI(user))
		rank = "AI"
	set_criminal_status(user, found_record, new_status, reason, rank)

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
	if(istype(src.head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(src.glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint

	return tinted


/mob/living/carbon/human/abiotic(full_body = 0)
	if(full_body && ((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)))
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>[src] begins playing [p_their()] ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='warning'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	. = TRUE

	if(!target_zone)
		if(!user)
			. = FALSE
			CRASH("can_inject() called on a human mob with neither a user nor a targeting zone selected.")
		else
			target_zone = user.zone_selected

	if(HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		. = FALSE

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = FALSE
		fail_msg = "[p_they(TRUE)] [p_are()] missing that limb."
	else if(affecting.is_robotic())
		. = FALSE
		fail_msg = "That limb is robotic."
	else
		switch(target_zone)
			if("head")
				if(head && head.flags & THICKMATERIAL && !penetrate_thick)
					. = FALSE
			else
				if(wear_suit && wear_suit.flags & THICKMATERIAL && !penetrate_thick)
					. = FALSE
	if(!. && error_msg && user)
		if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == "head" ? "on [p_their()] head" : "on [p_their()] body"] to inject into."
		to_chat(user, "<span class='alert'>[fail_msg]</span>")

/mob/living/carbon/human/proc/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= slot_gloves
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= slot_w_uniform
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= slot_shoes

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= slot_wear_mask
		if(head.flags_inv & HIDEEYES)
			obscured |= slot_glasses
		if(head.flags_inv & HIDEEARS)
			obscured |= slot_r_ear
			obscured |= slot_l_ear

	if(obscured.len > 0)
		return obscured
	else
		return null

/mob/living/carbon/human/proc/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H || !H.can_intake_reagents)
		return 0
	return 1

/mob/living/carbon/human/proc/get_visible_gender()
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((slot_w_uniform in obscured) && skipface)
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
	temp_holder = new /mob/living/carbon/human()
	var/list/species_organs = H.dna.species.has_organ.Copy() //Compile a list of species organs and tack on the mutantears afterward.
	if(H.dna.species.mutantears)
		species_organs["ears"] = H.dna.species.mutantears
	for(var/index in species_organs)
		var/organ = species_organs[index]
		if(!(organ in types_of_int_organs)) //If the mob is missing this particular organ...
			var/obj/item/organ/internal/I = new organ(temp_holder) //Create the organ inside our holder so we can check it before implantation.
			if(H.get_organ_slot(I.slot)) //Check to see if the user already has an organ in the slot the 'missing organ' belongs to. If they do, skip implantation.
				continue				 //In an example, this will prevent duplication of the mob's eyes if the mob is a Human and they have Nucleation eyes, since,
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
	var/obj/item/organ/internal/lungs/L = get_int_organ(/obj/item/organ/internal/lungs)
	if(!L)
		return 0

	return L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/internal/lungs/L = get_int_organ(/obj/item/organ/internal/lungs)
	if(!L)
		return 0

	if(!L.is_bruised())
		custom_pain("You feel a stabbing pain in your chest!")
		L.damage = L.min_bruised_damage

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(HAS_TRAIT(src, TRAIT_HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(..(I, cuff_break = 1))
			unEquip(I)
	else
		if(..())
			unEquip(I)

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/generate_name()
	name = dna.species.get_random_name(gender)
	real_name = name
	if(dna)
		dna.real_name = name
	return name

/mob/living/carbon/human/verb/check_pulse()
	set category = null
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if (!ishuman(src))
		to_chat(usr, "<span class='notice'>You do not know how to check someone's pulse!</span>")
		return

	if(usr.stat == 1 || usr.restrained() || !isliving(usr) || usr.is_dead()) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts [usr.p_their()] hand on [src]'s wrist and begins counting [p_their()] pulse.</span>",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting [p_their()] pulse.</span>",\
		"You begin counting your pulse.")

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse

		return

	to_chat(usr, "Don't move until counting is finished.")
	var/time = world.time
	sleep(60)
	if(usr.l_move_time >= time)	//checks if our mob has moved during the sleep()
		to_chat(usr, "You moved while counting. Try again.")
	else
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")


/mob/living/carbon/human/proc/change_dna(datum/dna/new_dna, include_species_change = FALSE, keep_flavor_text = FALSE)
	if(include_species_change)
		set_species(new_dna.species.type, retain_damage = TRUE, transformation = TRUE, keep_missing_bodyparts = TRUE)
	dna = new_dna.Clone()
	if (include_species_change) //We have to call this after new_dna.Clone() so that species actions don't get overwritten
		dna.species.on_species_gain(src)
	real_name = new_dna.real_name
	domutcheck(src, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them
	if(!keep_flavor_text)
		flavor_text = ""
	dna.UpdateSE()
	dna.UpdateUI()
	sync_organ_dna(TRUE)
	UpdateAppearance()
	sec_hud_set_ID()


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

		if(gender == PLURAL && oldspecies.has_gender)
			change_gender(pick(MALE, FEMALE))

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

	if(!(dna.species.bodyflags & HAS_SKIN_TONE))
		s_tone = 0

	var/list/thing_to_check = list(slot_wear_mask, slot_head, slot_shoes, slot_gloves, slot_l_ear, slot_r_ear, slot_glasses, slot_l_hand, slot_r_hand)
	var/list/kept_items[0]
	var/list/item_flags[0]
	for(var/thing in thing_to_check)
		var/obj/item/I = get_item_by_slot(thing)
		if(I)
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

	if(!dna.species)
		return null
	return dna.species.default_language ? GLOB.all_languages[dna.species.default_language] : null

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if(usr != src)
		return 0 //something is terribly wrong
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't write on the floor in your current state!</span>")
		return
	if(!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if(gloves)
		to_chat(src, "<span class='warning'>[gloves] are preventing you from writing anything down!</span>")
		return

	var/turf/simulated/T = loc
	if(!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/turf/origin = T
	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
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

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")
	if(origin != loc)
		to_chat(src, "<span class='notice'>Stay still while writing!</span>")
		return
	if(message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

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
	if(judgebot.emagged == 2)
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
	if(judgebot.weaponscheck)
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
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard))
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
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			. = 100
		if(mind.assigned_role == "Clown")
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)	&& unEquip(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	rad_act(current_size * 3)

/mob/living/carbon/human/narsie_act()
	if(iswizard(src) && iscultist(src)) //Wizard cultists are immune to narsie because it would prematurely end the wiz round that's about to end by the automated shuttle call anyway
		return
	..()

#define CPR_CHEST_COMPRESSION_ONLY	0.75
#define CPR_RESCUE_BREATHS			1

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/human/H)
	if(H == src)
		to_chat(src, "<span class='warning'>You cannot perform CPR on yourself!</span>")
		return
	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH))
		to_chat(src, "<span class='warning'>[H.name] is dead!</span>")
		return
	if(H.receiving_cpr) // To prevent spam stacking
		to_chat(src, "<span class='warning'>They are already receiving CPR!</span>")
		return
	H.receiving_cpr = TRUE
	var/cpr_modifier = get_cpr_mod(H)
	visible_message("<span class='danger'>[src] is trying to perform CPR on [H.name]!</span>", "<span class='danger'>You try to perform CPR on [H.name]!</span>")

	if(do_mob(src, H, 4 SECONDS))
		if(H.health <= HEALTH_THRESHOLD_CRIT)
			H.adjustOxyLoss(-15 * cpr_modifier)
			H.SetLoseBreath(0)
			H.AdjustParalysis(-2 SECONDS)
			H.updatehealth("cpr")
			visible_message("<span class='danger'>[src] performs CPR on [H.name]!</span>", "<span class='notice'>You perform CPR on [H.name].</span>")

			if(cpr_modifier == CPR_RESCUE_BREATHS)
				to_chat(H, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			H.receiving_cpr = FALSE
			add_attack_logs(src, H, "CPRed", ATKLOG_ALL)
			return TRUE
	else
		H.receiving_cpr = FALSE
		to_chat(src, "<span class='danger'>You need to stay still while performing CPR!</span>")

/mob/living/carbon/human/proc/get_cpr_mod(mob/living/carbon/human/H)
	if(is_mouth_covered() || H.is_mouth_covered())
		return CPR_CHEST_COMPRESSION_ONLY
	if(!H.check_has_mouth() || !check_has_mouth())
		return CPR_CHEST_COMPRESSION_ONLY
	return CPR_RESCUE_BREATHS

#undef CPR_CHEST_COMPRESSION_ONLY
#undef CPR_RESCUE_BREATHS

/mob/living/carbon/human/canBeHandcuffed()
	if(get_num_arms() >= 2)
		return TRUE
	else
		return FALSE

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

/mob/living/carbon/human/can_see_reagents() //If they have some glasses or helmet equipped that lets them see reagents, they can see reagents
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.scan_reagents)
			return 1
	if(istype(glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/rscan = glasses
		if(rscan.scan_reagents)
			return 1

/mob/living/carbon/human/can_eat(flags = 255)
	return dna.species && (dna.species.dietflags & flags)

/mob/living/carbon/human/selfFeed(obj/item/reagent_containers/food/toEat, fullness)
	if(!check_has_mouth())
		to_chat(src, "Where do you intend to put \the [toEat]? You don't have a mouth!")
		return 0
	return ..()

/mob/living/carbon/human/forceFed(obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(!check_has_mouth())
		if(!((istype(toEat, /obj/item/reagent_containers/food/drinks) && (ismachineperson(src)))))
			to_chat(user, "Where do you intend to put \the [toEat]? \The [src] doesn't have a mouth!")
			return 0
	return ..()

/mob/living/carbon/human/selfDrink(obj/item/reagent_containers/food/drinks/toDrink)
	if(!check_has_mouth())
		if(!ismachineperson(src))
			to_chat(src, "Where do you intend to put \the [src]? You don't have a mouth!")
			return 0
		else
			to_chat(src, "<span class='notice'>You pour a bit of liquid from [toDrink] into your connection port.</span>")
	else
		to_chat(src, "<span class='notice'>You swallow a gulp of [toDrink].</span>")
	return 1

/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id)
		var/obj/item/card/id/id = wear_id.GetID()
		if(istype(id) && id.is_untrackable())
			return 0
	if(wear_pda)
		var/obj/item/card/id/id = wear_pda.GetID()
		if(istype(id) && id.is_untrackable())
			return 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return 0

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
	equip_list.len = slots_amt
	for(var/i = 1, i < slots_amt, i++)
		var/obj/item/thing = get_item_by_slot(i)
		if(thing != null)
			equip_list[i] = thing.serialize()

	for(var/obj/item/implant/implant in src)
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
		var/obj/item/implant/implant = new path(T)
		if(!implant.implant(src, src))
			qdel(implant)

	UpdateAppearance()

	// De-serialize equipment
	// #1: Jumpsuit
	// #2: Outer suit
	// #3+: Everything else
	if(islist(equip_list[slot_w_uniform]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_w_uniform], T)
		equip_to_slot_if_possible(C, slot_w_uniform)

	if(islist(equip_list[slot_wear_suit]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_wear_suit], T)
		equip_to_slot_if_possible(C, slot_wear_suit)

	for(var/i = 1, i < slots_amt, i++)
		if(i == slot_w_uniform || i == slot_wear_suit)
			continue
		if(islist(equip_list[i]))
			var/obj/item/clothing/C = list_to_object(equip_list[i], T)
			equip_to_slot_if_possible(C, i)
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
	return getBrainLoss() < 100


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
	return min(health, maxHealth - getStaminaLoss()) + shock_reduction

/mob/living/carbon/human/WakeUp(updating = TRUE)
	if(dna.species.spec_WakeUp(src))
		return
	..()

/**
  * Helper to get the mobs runechat colour span
  *
  * Basically just a quick redirect to the DNA handler that gets the species-specific colour handler
  */
/mob/living/carbon/human/get_runechat_color()
	if(client?.prefs.toggles2 & PREFTOGGLE_2_FORCE_WHITE_RUNECHAT)
		return "#FFFFFF" // Force white if they want it
	return dna.species.get_species_runechat_color(src)

/mob/living/carbon/human/update_runechat_msg_location()
	if(ismecha(loc))
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

	pose = sanitize(copytext(input(usr, "This is [src]. [p_they(TRUE)] [p_are()]...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()

// Behavior for deadchat control

/mob/living/carbon/human/proc/dchat_emote()
	var/list/possible_emotes = list("scream", "clap", "snap", "crack", "dap", "burp")
	emote(pick(possible_emotes), intentional = TRUE)

/mob/living/carbon/human/proc/dchat_attack(intent)
	var/turf/ahead = get_turf(get_step(src, dir))
	var/atom/victim = locate(/mob/living) in ahead
	var/obj/item/in_hand = get_active_hand()
	var/implement = "[isnull(in_hand) ? "[p_their()] fists" : in_hand]"
	if(!victim)
		victim = locate(/obj/structure) in ahead
	if(!victim)
		switch(intent)
			if(INTENT_HARM)
				visible_message("<span class='warning'>[src] swings [implement] wildly!</span>")
			if(INTENT_HELP)
				visible_message("<span class='notice'>[src] seems to take a deep breath.</span>")
		return
	if(isLivingSSD(victim))
		visible_message("<span class='notice'>[src] [intent == INTENT_HARM ? "reluctantly " : ""]lowers [p_their()] [implement].</span>")
		return

	var/original_intent = a_intent
	a_intent = intent
	if(in_hand)
		in_hand.melee_attack_chain(src, victim)
	else
		UnarmedAttack(victim, TRUE)
	a_intent = original_intent

/mob/living/carbon/human/proc/dchat_resist()
	if(!can_resist())
		visible_message("<span class='warning'>[src] seems to be unable to do anything!</span>")
		return
	if(!restrained())
		visible_message("<span class='notice'>[src] seems to be doing nothing in particular.</span>")
		return

	visible_message("<span class='warning'>[src] is trying to break free!</span>")
	resist()

/mob/living/carbon/human/proc/dchat_pickup()
	var/turf/ahead = get_step(src, dir)
	var/obj/item/thing = locate(/obj/item) in ahead
	if(!thing)
		return

	var/old_loc = thing.loc
	var/obj/item/in_hand = get_active_hand()

	if(in_hand)
		visible_message("<span class='notice'>[src] drops [in_hand] and picks up [thing] instead!</span>")
		unEquip(in_hand)
		in_hand.forceMove(old_loc)
	else
		visible_message("<span class='notice'>[src] picks up [thing]!</span>")
	put_in_active_hand(thing)

/mob/living/carbon/human/proc/dchat_throw()
	var/in_hand = get_active_hand()
	if(!in_hand)
		visible_message("<span class='notice'>[src] makes a throwing motion!</span>")
		return
	var/atom/possible_target
	var/cur_turf = get_turf(src)
	for(var/i in 1 to 5)
		cur_turf = get_step(cur_turf, dir)
		possible_target = locate(/mob/living) in cur_turf
		if(possible_target)
			break

		possible_target = locate(/obj/structure) in cur_turf
		if(possible_target)
			break

	if(!possible_target)
		throw_item(cur_turf)
	else
		throw_item(possible_target)

/mob/living/carbon/human/proc/dchat_shove()
	var/turf/ahead = get_turf(get_step(src, dir))
	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in ahead
	if(!H)
		visible_message("<span class='notice'>[src] tries to shove something away!</span>")
		return
	dna?.species.disarm(src, H)


/mob/living/carbon/human/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 7 SECONDS)
	var/list/inputs = list(
		"emote" = CALLBACK(src, PROC_REF(dchat_emote)),
		"attack" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HARM),
		"help" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HELP),
		"pickup" = CALLBACK(src, PROC_REF(dchat_pickup)),
		"throw" = CALLBACK(src, PROC_REF(dchat_throw)),
		"disarm" = CALLBACK(src, PROC_REF(dchat_shove)),
		"resist" = CALLBACK(src, PROC_REF(dchat_resist)),
	)

	AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, inputs, cooldown)
