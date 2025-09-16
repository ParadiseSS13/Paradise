/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers for holding only the finest papers, photos, and folders."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	var/static/list/accepted_items = list(
		/obj/item/paper,
		/obj/item/folder,
		/obj/item/photo,
		/obj/item/paper_bundle,
		/obj/item/documents
	)

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/autopsy
	name = "autopsy reports drawer"
	desc = "A large drawer for holding autopsy reports."

/// not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
/obj/structure/filingcabinet/filingcabinet
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo))
			I.loc = src


/obj/structure/filingcabinet/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(insert(O, user))
		return ITEM_INTERACT_COMPLETE
	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't put [O.name] in [src]!</span>")
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/filingcabinet/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/filingcabinet/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(length(contents))
		if(prob(40 + (length(contents) * 5)))
			var/obj/item/I = pick(contents)
			I.loc = loc
			if(prob(25))
				step_rand(I)
			SStgui.update_uis(src)
			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
			return
	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

/obj/structure/filingcabinet/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/filingcabinet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FilingCabinet",  name)
		ui.open()

/obj/structure/filingcabinet/ui_data(mob/user)
	var/list/data = list()
	data["contents"] = null
	var/list/items = list()

	var/index = 1
	for(var/obj/item/P in contents)
		items.Add(list(list("display_name" = capitalize(P.name), "index" = index)))
		index++

	if(length(items))
		data["contents"] = items

	return data

/obj/structure/filingcabinet/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	add_fingerprint(usr)

	switch(action)
		if("retrieve")
			var/index = text2num(params["index"])
			if(!ISINDEXSAFE(contents, index))
				return FALSE
			retrieve(contents[index], ui.user)

/obj/structure/filingcabinet/proc/insert(obj/item/O, mob/user)
	if(!is_type_in_list(O, accepted_items))
		return
	if(!user.unequip(O))
		return
	to_chat(user, "<span class='notice'>You put [O.name] in [src].</span>")
	O.loc = src
	SStgui.update_uis(src)
	icon_state = "[initial(icon_state)]-open"
	sleep(5)
	icon_state = initial(icon_state)
	return TRUE

/obj/structure/filingcabinet/proc/retrieve(obj/item/O, mob/user)
	if(!(istype(O) && (O.loc == src) && Adjacent(user)))
		return
	if(!user.put_in_hands(O))
		O.forceMove(loc)
	icon_state = "[initial(icon_state)]-open"
	sleep(5)
	icon_state = initial(icon_state)

/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/populated = FALSE


/obj/structure/filingcabinet/security/proc/populate()
	if(!populated)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/S
			for(var/datum/data/record/R in GLOB.data_core.security)
				if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
					S = R
					break
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [S.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [S.fields["mi_crim"]]<BR>\nDetails: [S.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [S.fields["ma_crim"]]<BR>\nDetails: [S.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[S.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			for(var/c in S.fields["comments"])
				P.info += "[c]<BR>"
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			populated = TRUE	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand()
	populate()
	..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/populated = FALSE

/obj/structure/filingcabinet/medical/proc/populate()
	if(!populated)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/M
			for(var/datum/data/record/R in GLOB.data_core.medical)
				if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
					M = R
					break
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [M.fields["b_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [M.fields["mi_dis"]]<BR>\nDetails: [M.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [M.fields["ma_dis"]]<BR>\nDetails: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [M.fields["alg"]]<BR>\nDetails: [M.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [M.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			for(var/c in M.fields["comments"])
				P.info += "[c]<BR>"
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			populated = TRUE	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/medical/attack_hand()
	populate()
	..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	..()
