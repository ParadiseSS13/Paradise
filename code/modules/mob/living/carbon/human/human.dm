/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	deathgasp_on_death = TRUE
	var/obj/item/rig/wearing_rig // This is very not good, but it's much much better than calling get_rig() every update_canmove() call.

/mob/living/carbon/human/New(loc)
	icon = null // This is now handled by overlays -- we just keep an icon for the sake of the map editor.
	if(length(args) > 1)
		log_runtime(EXCEPTION("human/New called with more than 1 argument (REPORT THIS ENTIRE RUNTIME TO A CODER)"))
	. = ..()

/mob/living/carbon/human/Initialize(mapload, datum/species/new_species = /datum/species/human)
	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	set_species(new_species, 1, delay_icon_update = 1, skip_same_check = TRUE)

	..()

	if(dna.species)
		real_name = dna.species.get_random_name(gender)
		name = real_name
		if(mind)
			mind.name = real_name

	create_reagents(330)

	martial_art = default_martial_art

	handcrafting = new()

	var/mob/M = src
	faction |= "\ref[M]" //what

	// Set up DNA.
	if(dna)
		dna.ready_dna(src)
		dna.real_name = real_name
		sync_organ_dna(1)

	UpdateAppearance()

/mob/living/carbon/human/OpenCraftingMenu()
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
	QDEL_LIST(bodyparts)
	splinted_limbs.Cut()

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/skrell/Initialize(mapload)
	..(mapload, /datum/species/skrell)

/mob/living/carbon/human/tajaran/Initialize(mapload)
	..(mapload, /datum/species/tajaran)

/mob/living/carbon/human/vulpkanin/Initialize(mapload)
	..(mapload, /datum/species/vulpkanin)

/mob/living/carbon/human/unathi/Initialize(mapload)
	..(mapload, /datum/species/unathi)

/mob/living/carbon/human/vox/Initialize(mapload)
	..(mapload, /datum/species/vox)

/mob/living/carbon/human/voxarmalis/Initialize(mapload)
	..(mapload, /datum/species/vox/armalis)

/mob/living/carbon/human/skeleton/Initialize(mapload)
	..(mapload, /datum/species/skeleton)

/mob/living/carbon/human/kidan/Initialize(mapload)
	..(mapload, /datum/species/kidan)

/mob/living/carbon/human/plasma/Initialize(mapload)
	..(mapload, /datum/species/plasmaman)

/mob/living/carbon/human/slime/Initialize(mapload)
	..(mapload, /datum/species/slime)

/mob/living/carbon/human/grey/Initialize(mapload)
	..(mapload, /datum/species/grey)

/mob/living/carbon/human/abductor/Initialize(mapload)
	..(mapload, /datum/species/abductor)

/mob/living/carbon/human/diona/Initialize(mapload)
	..(mapload, /datum/species/diona)

/mob/living/carbon/human/machine/Initialize(mapload)
	..(mapload, /datum/species/machine)

/mob/living/carbon/human/machine/created
	name = "Integrated Robotic Chassis"

/mob/living/carbon/human/machine/created/Initialize(mapload)
	..()
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
	..(mapload, /datum/species/shadow)

/mob/living/carbon/human/golem/Initialize(mapload)
	..(mapload, /datum/species/golem)

/mob/living/carbon/human/wryn/Initialize(mapload)
	..(mapload, /datum/species/wryn)

/mob/living/carbon/human/nucleation/Initialize(mapload)
	..(mapload, /datum/species/nucleation)

/mob/living/carbon/human/drask/Initialize(mapload)
	..(mapload, /datum/species/drask)

/mob/living/carbon/human/monkey/Initialize(mapload)
	..(mapload, /datum/species/monkey)

/mob/living/carbon/human/farwa/Initialize(mapload)
	..(mapload, /datum/species/monkey/tajaran)

/mob/living/carbon/human/wolpin/Initialize(mapload)
	..(mapload, /datum/species/monkey/vulpkanin)

/mob/living/carbon/human/neara/Initialize(mapload)
	..(mapload, /datum/species/monkey/skrell)

/mob/living/carbon/human/stok/Initialize(mapload)
	..(mapload, /datum/species/monkey/unathi)

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")

	show_stat_station_time()

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		if(locate(/obj/item/assembly/health) in src)
			stat(null, "Health: [health]")
		if(internal)
			if(!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		if(istype(back, /obj/item/rig))
			var/obj/item/rig/suit = back
			var/cell_status = "ERROR"
			if(suit.cell)
				cell_status = "[suit.cell.charge]/[suit.cell.maxcharge]"
			stat(null, "Suit charge: [cell_status]")

		// I REALLY need to split up status panel things into datums
		var/mob/living/simple_animal/borer/B = has_brain_worms()
		if(B && B.controlling)
			stat("Chemicals", B.chemicals)

		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)

			if(mind.vampire)
				stat("Total Blood", "[mind.vampire.bloodtotal]")
				stat("Usable Blood", "[mind.vampire.bloodusable]")

			if(mind.nation)
				stat("Nation Name", "[mind.nation.current_name ? "[mind.nation.current_name]" : "[mind.nation.default_name]"]")
				stat("Nation Leader", "[mind.nation.current_leader ? "[mind.nation.current_leader]" : "None"]")
				stat("Nation Heir", "[mind.nation.heir ? "[mind.nation.heir]" : "None"]")


	if(istype(loc, /obj/spacepod)) // Spacdpods!
		var/obj/spacepod/S = loc
		stat("Spacepod Charge", "[istype(S.battery) ? "[(S.battery.charge / S.battery.maxcharge) * 100]" : "No cell detected"]")
		stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

/mob/living/carbon/human/ex_act(severity)
	var/shielded = 0
	var/b_loss = null
	var/f_loss = null

	if(status_flags & GODMODE)
		return 0

	switch(severity)
		if(1)
			b_loss += 500
			if(!prob(getarmor(null, "bomb")))
				gib()
				return 0
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)

				var/limbs_affected = pick(2,3,4)
				var/obj/item/organ/external/processing_dismember
				var/list/valid_limbs = bodyparts.Copy()

				while(limbs_affected != 0 && valid_limbs.len > 0)
					processing_dismember = pick(valid_limbs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,DROPLIMB_SHARP,0,1)
						valid_limbs -= processing_dismember
						limbs_affected -= 1
					else valid_limbs -= processing_dismember

		if(2)
			if(!shielded) //literally nothing could change shielded before this so wth
				b_loss += 60

			f_loss += 60

			var/limbs_affected = 0
			var/obj/item/organ/external/processing_dismember
			var/list/valid_limbs = bodyparts.Copy()

			if(prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

				limbs_affected = pick(1, 1, 2)
			else
				limbs_affected = pick(1, 2, 3)

			while(limbs_affected != 0 && valid_limbs.len > 0)
				processing_dismember = pick(valid_limbs)
				if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
					processing_dismember.droplimb(1,DROPLIMB_SHARP,0,1)
					valid_limbs -= processing_dismember
					limbs_affected -= 1
				else valid_limbs -= processing_dismember

			if(!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				AdjustEarDamage(30, 120)
			if(prob(70) && !shielded)
				Paralyse(10)

		if(3)
			b_loss += 30
			if(prob(getarmor(null, "bomb")))
				b_loss = b_loss/2

			else

				var/limbs_affected = pick(0, 1)
				var/obj/item/organ/external/processing_dismember
				var/list/valid_limbs = bodyparts.Copy()

				while(limbs_affected != 0 && valid_limbs.len > 0)
					processing_dismember = pick(valid_limbs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,DROPLIMB_SHARP,0,1)
						valid_limbs -= processing_dismember
						limbs_affected -= 1
					else valid_limbs -= processing_dismember

			if(!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				AdjustEarDamage(15, 60)
			if(prob(50) && !shielded)
				Paralyse(10)

	take_overall_damage(b_loss,f_loss, TRUE, used_weapon = "Explosive Blast")

	..()

/mob/living/carbon/human/blob_act()
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))

/mob/living/carbon/human/bullet_act()
	if(martial_art && martial_art.deflection_chance) //Some martial arts users can deflect projectiles!
		if(!prob(martial_art.deflection_chance))
			return ..()
		if(!src.lying && !(HULK in mutations)) //But only if they're not lying down, and hulks can't do it
			visible_message("<span class='danger'>[src] deflects the projectile; [p_they()] can't be hit with ranged weapons!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
			return 0
	..()

/mob/living/carbon/human/restrained()
	if(handcuffed)
		return 1
	if(istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0


/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask) || get_organ_slot("breathing_tube")
	var/list/obscured = check_obscured_slots()

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[UID()];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	var/obj/item/organ/internal/headpocket/C = get_int_organ(/obj/item/organ/internal/headpocket)
	if(C)
		if(slot_wear_mask in obscured)
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Headpocket:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			var/list/items = C.get_contents()
			if(items.len)
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><A href='?src=[UID()];dislodge_headpocket=1'>Dislodge Items</A></td></tr>"
			else
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><font color=grey>Empty</font></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A>"

		if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
			var/obj/item/clothing/mask/muzzle/M = wear_mask
			if(M.security_lock)
				dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(!issmall(src))
		if(slot_glasses in obscured)
			dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=[UID()];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_l_ear in obscured)
			dat += "<tr><td><font color=grey><B>Left Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Left Ear:</B></td><td><A href='?src=[UID()];item=[slot_l_ear]'>[(l_ear && !(l_ear.flags&ABSTRACT))		? l_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_r_ear in obscured)
			dat += "<tr><td><font color=grey><B>Right Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Right Ear:</B></td><td><A href='?src=[UID()];item=[slot_r_ear]'>[(r_ear && !(r_ear.flags&ABSTRACT))		? r_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

		dat += "<tr><td>&nbsp;</td></tr>"

		dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
		if(wear_suit)
			dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=[UID()];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(s_store, /obj/item/tank))
				dat += "&nbsp;<A href='?src=[UID()];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
		else
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

		if(slot_shoes in obscured)
			dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=[UID()];item=[slot_shoes]'>[(shoes && !(shoes.flags&ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_gloves in obscured)
			dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=[UID()];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_w_uniform in obscured)
			dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=[UID()];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(w_uniform == null || (slot_w_uniform in obscured))
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Sensors:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>PDA:</B></font></td></tr>"
		else
			dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=[UID()];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(belt, /obj/item/tank))
				dat += "&nbsp;<A href='?src=[UID()];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=[UID()];pockets=left'>[(l_store && !(l_store.flags&ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += "&nbsp;<A href='?src=[UID()];pockets=right'>[(r_store && !(r_store.flags&ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=[UID()];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>PDA:</B></td><td><A href='?src=[UID()];item=[slot_wear_pda]'>[(wear_pda && !(wear_pda.flags&ABSTRACT)) ? wear_pda : "<font color=grey>Empty</font>"]</A></td></tr>"

			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				dat += "<tr><td>&nbsp;&#8627;<B>Suit Sensors:</b></td><td><A href='?src=[UID()];set_sensor=1'>[U.has_sensor >= 2 ? "</a><font color=grey>--SENSORS LOCKED--</font>" : "Set Sensors</a>"]</td></tr>"

				if(U.accessories.len)
					dat += "<tr><td>&nbsp;&#8627;<A href='?src=[UID()];strip_accessory=1'>Remove Accessory</a></td></tr>"


	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 540)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/human/Crossed(atom/movable/AM)
	var/mob/living/simple_animal/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
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

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/pda/pda = wear_id
	var/obj/item/card/id/id = wear_id
	if(istype(pda))
		if(pda.id && istype(pda.id, /obj/item/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if(istype(id))
		. = id.assignment
	else
		return if_no_id
	if(!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/pda/pda = wear_id
	var/obj/item/card/id/id = wear_id
	if(istype(pda))
		if(pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if(istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name(var/id_override = FALSE)
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
	if(!head || head.disfigured || cloneloss > 50 || !real_name || (HUSK in mutations))	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/pda/pda = wear_id
	var/obj/item/card/id/id = wear_id
	if(istype(pda))		. = pda.owner
	else if(istype(id))	. = id.registered_name
	if(!.) 				. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or, if applicable, hands as well
/mob/living/carbon/human/proc/get_idcard(var/check_hands = FALSE)
	var/obj/item/card/id/id = wear_id
	var/obj/item/pda/pda = wear_id
	if(istype(pda) && pda.id)
		id = pda.id

	if(check_hands)
		if(istype(get_active_hand(), /obj/item/card/id))
			id = get_active_hand()
		else if(istype(get_inactive_hand(), /obj/item/card/id))
			id = get_inactive_hand()

	if(istype(id))
		return id

/mob/living/carbon/human/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	dna.species.update_sight(src)

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0)
	if(status_flags & GODMODE)	//godmode
		return 0
	if(NO_SHOCK in mutations) //shockproof
		return 0
	if(tesla_shock)
		var/total_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			if(G.siemens_coefficient <= 0)
				total_coeff -= 0.5
		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			if(S.siemens_coefficient <= 0)
				total_coeff -= 0.95
			else if(S.siemens_coefficient == (-1))
				total_coeff -= 1
		siemens_coeff = total_coeff
		if(tesla_ignore)
			siemens_coeff = 0
	else if(!safety)
		var/gloves_siemens_coeff = 1
		var/species_siemens_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			gloves_siemens_coeff = G.siemens_coefficient
		if(dna.species)
			species_siemens_coeff = dna.species.siemens_coeff
		siemens_coeff = gloves_siemens_coeff * species_siemens_coeff
	if(undergoing_cardiac_arrest())
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			set_heartattack(FALSE)
			if(stat == CONSCIOUS)
				to_chat(src, "<span class='notice'>You feel your heart beating again!</span>")
	. = ..()


/mob/living/carbon/human/Topic(href, href_list)
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))
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
				L.embedded_objects -= I
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
						equip_to_slot_if_possible(place_item, pocket_id, 0, 1)
						add_attack_logs(usr, src, "Equipped with [pocket_item]", isLivingSSD(src) ? null : ATKLOG_ALL)

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
						A.on_removed(usr)
						U.accessories -= A
						update_inv_w_uniform()

	if(href_list["criminal"])
		if(hasHUD(usr,"security"))
			if(usr.incapacitated())
				return
			var/found_record = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for(var/datum/data/record/E in data_core.general)
					if(E.fields["name"] == perpname)
						for(var/datum/data/record/R in data_core.security)
							if(R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")
								var/t1 = copytext(trim(sanitize(input("Enter Reason:", "Security HUD", null, null) as text)), 1, MAX_MESSAGE_LEN)
								if(!t1)
									t1 = "(none)"

								if(hasHUD(usr, "security") && setcriminal != "Cancel")
									found_record = 1
									if(R.fields["criminal"] == "*Execute*")
										to_chat(usr, "<span class='warning'>Unable to modify the sec status of a person with an active Execution order. Use a security computer instead.</span>")
									else
										var/rank
										if(ishuman(usr))
											var/mob/living/carbon/human/U = usr
											rank = U.get_assignment()
										else if(isrobot(usr))
											var/mob/living/silicon/robot/U = usr
											rank = "[U.modtype] [U.braintype]"
										else if(isAI(usr))
											rank = "AI"
										set_criminal_status(usr, R, setcriminal, t1, rank)
								break // Git out of the securiy records loop!
						if(found_record)
							break // Git out of the general records

			if(!found_record)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecord"])
		if(hasHUD(usr,"security"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
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
		if(hasHUD(usr,"security"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								if(length(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comment found</span>")
								to_chat(usr, "<a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = copytext(trim(sanitize(input("Add Comment:", "Sec. records", null, null) as message)), 1, MAX_MESSAGE_LEN)
								if(!t1 || usr.stat || usr.restrained() || !hasHUD(usr, "security"))
									return
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields["comments"] += "Made by [U.get_authentification_name()] ([U.get_assignment()]) on [current_date_string] [station_time_timestamp()]<BR>[t1]"
								if(isrobot(usr))
									var/mob/living/silicon/robot/U = usr
									R.fields["comments"] += "Made by [U.name] ([U.modtype] [U.braintype]) on [current_date_string] [station_time_timestamp()]<BR>[t1]"
								if(isAI(usr))
									var/mob/living/silicon/ai/U = usr
									R.fields["comments"] += "Made by [U.name] (artificial intelligence) on [current_date_string] [station_time_timestamp()]<BR>[t1]"

	if(href_list["medical"])
		if(hasHUD(usr,"medical"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			var/modified = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name

			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.general)
						if(R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.Cut()

									spawn()
										sec_hud_set_security_status()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
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
		if(hasHUD(usr,"medical"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								if(length(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comment found</span>")
								to_chat(usr, "<a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			if(usr.incapacitated())
				return
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/pda))
					var/obj/item/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = copytext(trim(sanitize(input("Add Comment:", "Med. records", null, null) as message)), 1, MAX_MESSAGE_LEN)
								if(!t1 || usr.stat || usr.restrained() || !hasHUD(usr, "medical"))
									return
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields["comments"] += "Made by [U.get_authentification_name()] ([U.get_assignment()]) on [current_date_string] [station_time_timestamp()]<BR>[t1]"
								if(isrobot(usr))
									var/mob/living/silicon/robot/U = usr
									R.fields["comments"] += "Made by [U.name] ([U.modtype] [U.braintype]) on [current_date_string] [station_time_timestamp()]<BR>[t1]"

	if(href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if(href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)
	. = ..()


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
	for(var/obj/item/organ/internal/cyberimp/eyes/EFP in internal_organs)
		number += EFP.flash_protect

	return number

/mob/living/carbon/human/check_ear_prot()
	if(head && (head.flags & HEADBANGPROTECT))
		return 1
	if(l_ear && (l_ear.flags & EARBANGPROTECT))
		return 1
	if(r_ear && (r_ear.flags & EARBANGPROTECT))
		return 1

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

	//god help me
	if(istype(back, /obj/item/rig))
		var/obj/item/rig/O = back
		if(O.helmet && O.helmet == head && (O.helmet.body_parts_covered & HEAD))
			if((O.offline && O.offline_vision_restriction == 1) || (!O.offline && O.vision_restriction == 1))
				tinted = 2
			if((O.offline && O.offline_vision_restriction == 2) || (!O.offline && O.vision_restriction == 2))
				tinted = 3
	//im so sorry

	return tinted


/mob/living/carbon/human/abiotic(var/full_body = 0)
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

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone, var/penetrate_thick = 0)
	. = 1

	if(!target_zone)
		if(!user)
			target_zone = pick("chest","chest","chest","left leg","right leg","left arm", "right arm", "head")
		else
			target_zone = user.zone_sel.selecting

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = 0
		fail_msg = "[p_they(TRUE)] [p_are()] missing that limb."
	else if(affecting.is_robotic())
		. = 0
		fail_msg = "That limb is robotic."
	else
		switch(target_zone)
			if("head")
				if(head && head.flags & THICKMATERIAL && !penetrate_thick)
					. = 0
			else
				if(wear_suit && wear_suit.flags & THICKMATERIAL && !penetrate_thick)
					. = 0
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

/mob/living/carbon/human/proc/check_and_regenerate_organs(var/mob/living/carbon/human/H) //Regenerates missing limbs/organs.
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
				continue					 //In an example, this will prevent duplication of the mob's right arm if the mob is a Human and they have a Diona right arm, since,
											 //while the limb with the name 'right_arm' the mob has may not be listed in their species' bodyparts definition, it is still viable and has the appropriate limb name.
			else
				O = new limb_path(H) //Create the limb on the player.
				O.owner = H
				H.bodyparts |= H.bodyparts_by_name[O.limb_name]

	//Replacing lost organs with the species default.
	temp_holder = new /mob/living/carbon/human()
	for(var/index in H.dna.species.has_organ)
		var/organ = H.dna.species.has_organ[index]
		if(!(organ in types_of_int_organs)) //If the mob is missing this particular organ...
			var/obj/item/organ/internal/I = new organ(temp_holder) //Create the organ inside our holder so we can check it before implantation.
			if(H.get_organ_slot(I.slot)) //Check to see if the user already has an organ in the slot the 'missing organ' belongs to. If they do, skip implantation.
				continue				 //In an example, this will prevent duplication of the mob's eyes if the mob is a Human and they have Nucleation eyes, since,
										 //while the organ in the eyes slot may not be listed in the mob's species' organs definition, it is still viable and fits in the appropriate organ slot.
			else
				I = new organ(H) //Create the organ inside the player.
				I.insert(H)

/mob/living/carbon/human/revive()
	//Fix up all organs and replace lost ones.
	restore_all_organs() //Rejuvenate and reset all existing organs.
	check_and_regenerate_organs(src) //Regenerate limbs and organs only if they're really missing.
	surgeries.Cut() //End all surgeries.

	if(!isskeleton(src) && (SKELETON in mutations))
		mutations.Remove(SKELETON)
	if(NOCLONE in mutations)
		mutations.Remove(NOCLONE)
	if(HUSK in mutations)
		mutations.Remove(HUSK)

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

//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()
	if(clean_feet && !shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		qdel(feet_blood_DNA)
		bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0,  BLOOD_STATE_NOT_BLOODY = 0)
		blood_state = BLOOD_STATE_NOT_BLOODY
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(HULK in mutations)
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(..(I, cuff_break = 1))
			unEquip(I)
	else
		if(..())
			unEquip(I)

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
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

	if(usr.stat == 1 || usr.restrained() || !isliving(usr)) return

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

/mob/living/carbon/human/proc/set_species(datum/species/new_species, default_colour, delay_icon_update = FALSE, skip_same_check = FALSE, retain_damage = FALSE)
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

		if(oldspecies.default_genes.len)
			oldspecies.handle_dna(src, TRUE) // Remove any genes that belong to the old species

		oldspecies.on_species_loss(src)

	dna.species = new new_species()

	tail = dna.species.tail

	maxHealth = dna.species.total_health

	if(dna.species.language)
		add_language(dna.species.language)

	if(dna.species.default_language)
		add_language(dna.species.default_language)

	hunger_drain = dna.species.hunger_drain
	digestion_ratio = dna.species.digestion_ratio

	if(dna.species.base_color && default_colour)
		//Apply colour.
		skin_colour = dna.species.base_color
	else
		skin_colour = "#000000"

	if(!(dna.species.bodyflags & HAS_SKIN_TONE))
		s_tone = 0

	var/list/thing_to_check = list(slot_wear_mask, slot_head, slot_shoes, slot_gloves, slot_l_ear, slot_r_ear, slot_glasses, slot_l_hand, slot_r_hand)
	var/list/kept_items[0]

	for(var/thing in thing_to_check)
		var/obj/item/I = get_item_by_slot(thing)
		if(I)
			kept_items[I] = thing

	if(retain_damage)
		//Create a list of body parts which are damaged by burn or brute and save them to apply after new organs are generated. First we just handle external organs.
		var/bodypart_damages = list()
		//Loop through all external organs and save the damage states for brute and burn
		for(var/obj/item/organ/external/E in bodyparts)
			if(E.brute_dam == 0 && E.burn_dam == 0 && E.internal_bleeding == FALSE) //If there's no damage we don't bother remembering it.
				continue
			var/brute = E.brute_dam
			var/burn = E.burn_dam
			var/IB = E.internal_bleeding
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
		dna.species.create_organs(src)

		//Apply relevant damages and variables to the new organs.
		for(var/B in bodyparts)
			var/obj/item/organ/external/E = B
			for(var/list/part in bodypart_damages)
				var/obj/item/organ/external/OE = part[1]
				if((E.type == OE.type)) // Type has to be explicit, as right limbs are a child of left ones etc.
					var/brute = part[2]
					var/burn = part[3]
					var/IB = part[4]
					//Deal the damage to the new organ and then delete the entry to prevent duplicate checks
					E.receive_damage(brute, burn, ignore_resists = TRUE)
					E.internal_bleeding = IB
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
		dna.species.create_organs(src)

	for(var/thing in kept_items)
		equip_to_slot_if_possible(thing, kept_items[thing], redraw_mob = 0)

	//Handle default hair/head accessories for created mobs.
	var/obj/item/organ/external/head/H = get_organ("head")
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
	body_accessory = null

	dna.real_name = real_name

	dna.species.on_species_gain(src)

	see_in_dark = dna.species.get_resultant_darksight(src)
	if(see_in_dark > 2)
		see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		see_invisible = SEE_INVISIBLE_LIVING

	dna.species.handle_dna(src) //Give them whatever special dna business they got.

	update_client_colour(0)

	if(!delay_icon_update)
		UpdateAppearance()

	overlays.Cut()
	update_mutantrace(1)
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

	if(!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if(src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/simulated/T = src.loc
	if(!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

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

	if(message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if(length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/proc/get_eyecon()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/cyberimp/eyes/eye_implant = get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
	if(istype(dna.species) && dna.species.eyes)
		var/icon/eyes_icon = new/icon('icons/mob/human_face.dmi', dna.species.eyes)
		if(eye_implant) //Eye implants override native DNA eye colo(u)r
			eyes_icon = eye_implant.generate_icon()
		else if(eyes)
			eyes_icon = eyes.generate_icon()
		else
			eyes_icon.Blend("#800000", ICON_ADD)

		return eyes_icon

/mob/living/carbon/human/proc/get_eye_shine() //Referenced cult constructs for shining in the dark. Needs to be above lighting effects such as shading.
	var/obj/item/organ/external/head/head_organ = get_organ("head")
	var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	var/icon/hair = new /icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	var/mutable_appearance/MA = mutable_appearance(get_icon_difference(get_eyecon(), hair), layer = LIGHTING_LAYER + 1)
	MA.plane = LIGHTING_PLANE
	return MA //Cut the hair's pixels from the eyes icon so eyes covered by bangs stay hidden even while on a higher layer.

/*Used to check if eyes should shine in the dark. Returns the image of the eyes on the layer where they will appear to shine.
Eyes need to have significantly high darksight to shine unless the mob has the XRAY vision mutation. Eyes will not shine if they are covered in any way.*/
/mob/living/carbon/human/proc/eyes_shine()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/cyberimp/eyes/eye_implant = get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
	if(!(istype(eyes) || istype(eye_implant)))
		return FALSE
	if(!get_location_accessible(src, "eyes"))
		return FALSE
	if(!(eyes.shine()) && !istype(eye_implant) && !(XRAY in mutations)) //If their eyes don't shine, they don't have other augs, nor do they have X-RAY vision
		return FALSE

	return TRUE

/mob/living/carbon/human/assess_threat(var/mob/living/simple_animal/bot/secbot/judgebot, var/lasercolor)
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
	var/obj/item/card/id/idcard = get_idcard()
	if(judgebot.idcheck && !idcard)
		threatcount += 4

	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			if(judgebot.check_for_weapons(l_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(r_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(belt))
				threatcount += 2

	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Execute*")
					threatcount += 7
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Parolled")
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
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/singularity_pull(S, current_size)
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)	&& unEquip(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	apply_effect(current_size * 3, IRRADIATE)
	if(mob_negates_gravity())
		return
	..()

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/human/H)
	if(H.stat == DEAD || (H.status_flags & FAKEDEATH))
		to_chat(src, "<span class='warning'>[H.name] is dead!</span>")
		return
	if(!check_has_mouth())
		to_chat(src, "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>")
		return
	if(!H.check_has_mouth())
		to_chat(src, "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>")
		return
	if((head && (head.flags_cover & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && !wear_mask.mask_adjusted))
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return 0
	if((H.head && (H.head.flags_cover & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags_cover & MASKCOVERSMOUTH) && !H.wear_mask.mask_adjusted))
		to_chat(src, "<span class='warning'>Remove [H.p_their()] mask first!</span>")
		return 0
	visible_message("<span class='danger'>[src] is trying to perform CPR on [H.name]!</span>", \
					  "<span class='danger'>You try to perform CPR on [H.name]!</span>")
	if(do_mob(src, H, 40))
		if(H.health > config.health_threshold_dead && H.health <= config.health_threshold_crit)
			var/suff = min(H.getOxyLoss(), 7)
			H.adjustOxyLoss(-suff)
			H.updatehealth("cpr")
			visible_message("<span class='danger'>[src] performs CPR on [H.name]!</span>", \
							  "<span class='notice'>You perform CPR on [H.name].</span>")

			to_chat(H, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			to_chat(src, "<span class='alert'>Repeat at least every 7 seconds.")
			add_attack_logs(src, H, "CPRed", ATKLOG_ALL)
			return 1
	else
		to_chat(src, "<span class='danger'>You need to stay still while performing CPR!</span>")

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
	return (health <= config.health_threshold_crit && stat == UNCONSCIOUS)


/mob/living/carbon/human/IsAdvancedToolUser()
	if(dna.species.has_fine_manipulation)
		return 1
	return 0

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

/mob/living/carbon/human/can_see_reagents()
	for(var/obj/item/clothing/C in src) //If they have some clothing equipped that lets them see reagents, they can see reagents
		if(C.scan_reagents)
			return 1

/mob/living/carbon/human/can_eat(flags = 255)
	return dna.species && (dna.species.dietflags & flags)

/mob/living/carbon/human/selfFeed(var/obj/item/reagent_containers/food/toEat, fullness)
	if(!check_has_mouth())
		to_chat(src, "Where do you intend to put \the [toEat]? You don't have a mouth!")
		return 0
	return ..()

/mob/living/carbon/human/forceFed(var/obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(!check_has_mouth())
		if(!((istype(toEat, /obj/item/reagent_containers/food/drinks) && (ismachine(src)))))
			to_chat(user, "Where do you intend to put \the [toEat]? \The [src] doesn't have a mouth!")
			return 0
	return ..()

/mob/living/carbon/human/selfDrink(var/obj/item/reagent_containers/food/drinks/toDrink)
	if(!check_has_mouth())
		if(!ismachine(src))
			to_chat(src, "Where do you intend to put \the [src]? You don't have a mouth!")
			return 0
		else
			to_chat(src, "<span class='notice'>You pour a bit of liquid from [toDrink] into your connection port.</span>")
	else
		to_chat(src, "<span class='notice'>You swallow a gulp of [toDrink].</span>")
	return 1

/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id)
		var/obj/item/card/id/id = wear_id
		if(istype(id) && id.is_untrackable())
			return 0
	if(wear_pda)
		var/obj/item/pda/pda = wear_pda
		if(istype(pda))
			var/obj/item/card/id/id = pda.id
			if(istype(id) && id.is_untrackable())
				return 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return 0

	return ..()

/mob/living/carbon/human/proc/get_age_pitch()
	return 1.0 + 0.5*(30 - age)/80

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

/mob/living/carbon/human/can_use_guns(var/obj/item/gun/G)
	. = ..()

	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(HULK in mutations)
			to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return 0
		if(NOGUNS in dna.species.species_traits)
			to_chat(src, "<span class='warning'>Your fingers don't fit in the trigger guard!</span>")
			return 0

	if(martial_art && martial_art.no_guns) //great dishonor to famiry
		to_chat(src, "<span class='warning'>[martial_art.no_guns_message]</span>")
		return 0

	return .

/mob/living/carbon/human/proc/change_icobase(var/new_icobase, var/new_deform, var/owner_sensitive)
	for(var/obj/item/organ/external/O in bodyparts)
		O.change_organ_icobase(new_icobase, new_deform, owner_sensitive) //Change the icobase/deform of all our organs. If owner_sensitive is set, that means the proc won't mess with frankenstein limbs.

/mob/living/carbon/human/serialize()
	// Currently: Limbs/organs only
	var/list/data = ..()
	var/list/limbs_list = list()
	var/list/organs_list = list()
	var/list/equip_list = list()
	data["limbs"] = limbs_list
	data["iorgans"] = organs_list
	data["equip"] = equip_list

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

	return data

/mob/living/carbon/human/deserialize(list/data)
	var/list/limbs_list = data["limbs"]
	var/list/organs_list = data["iorgans"]
	var/list/equip_list = data["equip"]
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


/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Set Species"] = "?_src_=vars;setspecies=[UID()]"
	.["Make AI"] = "?_src_=vars;makeai=[UID()]"
	.["Make Mask of Nar'sie"] = "?_src_=vars;makemask=[UID()]"
	.["Make cyborg"] = "?_src_=vars;makerobot=[UID()]"
	.["Make monkey"] = "?_src_=vars;makemonkey=[UID()]"
	.["Make alien"] = "?_src_=vars;makealien=[UID()]"
	.["Make slime"] = "?_src_=vars;makeslime=[UID()]"
	.["Make superhero"] = "?_src_=vars;makesuper=[UID()]"
	. += "---"

/mob/living/carbon/human/get_taste_sensitivity()
	if(dna.species)
		return dna.species.taste_sensitivity
	else
		return 1

/mob/living/carbon/human/proc/special_post_clone_handling()
	if(mind && mind.assigned_role == "Cluwne") //HUNKE your suffering never stops
		makeCluwne()

/mob/living/carbon/human/proc/influenceSin()
	var/datum/objective/sintouched/O
	switch(rand(1,7))//traditional seven deadly sins... except lust.
		if(1) // acedia
			log_game("[src] was influenced by the sin of Acedia.")
			O = new /datum/objective/sintouched/acedia
		if(2) // Gluttony
			log_game("[src] was influenced by the sin of gluttony.")
			O = new /datum/objective/sintouched/gluttony
		if(3) // Greed
			log_game("[src] was influenced by the sin of greed.")
			O = new /datum/objective/sintouched/greed
		if(4) // sloth
			log_game("[src] was influenced by the sin of sloth.")
			O = new /datum/objective/sintouched/sloth
		if(5) // Wrath
			log_game("[src] was influenced by the sin of wrath.")
			O = new /datum/objective/sintouched/wrath
		if(6) // Envy
			log_game("[src] was influenced by the sin of envy.")
			O = new /datum/objective/sintouched/envy
		if(7) // Pride
			log_game("[src] was influenced by the sin of pride.")
			O = new /datum/objective/sintouched/pride
	ticker.mode.sintouched += src.mind
	src.mind.objectives += O
	var/obj_count = 1
	to_chat(src, "<span class='notice> Your current objectives:")
	for(var/datum/objective/objective in src.mind.objectives)
		to_chat(src, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/mob/living/carbon/human/is_literate()
	return getBrainLoss() < 100


/mob/living/carbon/human/fakefire(var/fire_icon = "Generic_mob_burning")
	if(!overlays_standing[FIRE_LAYER])
		overlays_standing[FIRE_LAYER] = image("icon"=fire_dmi, "icon_state"=fire_icon)
		update_icons()

/mob/living/carbon/human/fakefireextinguish()
	overlays_standing[FIRE_LAYER] = null
	update_icons()
/mob/living/carbon/human/proc/cleanSE()	//remove all disabilities/powers
	for(var/block = 1; block <= DNA_SE_LENGTH; block++)
		dna.SetSEState(block, FALSE, TRUE)
		genemutcheck(src, block, null, MUTCHK_FORCED)
	dna.UpdateSE()

/mob/living/carbon/human/extinguish_light()
	// Parent function handles stuff the human may be holding
	..()

	var/obj/item/organ/internal/lantern/O = get_int_organ(/obj/item/organ/internal/lantern)
	if(O && O.glowing)
		O.toggle_biolum(TRUE)
		visible_message("<span class='danger'>[src] is engulfed in shadows and fades into the darkness.</span>", "<span class='danger'>A sense of dread washes over you as you suddenly dim dark.</span>")
