/*
 * Don't use the apostrophe in name or desc. Causes script errors.
 * TODO: combine atleast some of the functionality with /proc_holder/spell
 */

/datum/action/changeling
	name = "Prototype Sting"
	desc = "" // Fluff
	background_icon_state = "bg_changeling"
	var/helptext = "" // Details
	var/chemical_cost = 0 // negative chemical cost is for passive abilities (chemical glands)
	var/dna_cost = -1 //cost of the sting in dna points. 0 = auto-purchase, -1 = cannot be purchased
	var/req_dna = 0  //amount of dna needed to use this ability. Changelings always have atleast 1
	var/req_human = 0 //if you need to be human to use this ability
	var/req_stat = CONSCIOUS // CONSCIOUS, UNCONSCIOUS or DEAD
	var/genetic_damage = 0 // genetic damage caused by using the sting. Nothing to do with cloneloss.
	var/max_genetic_damage = 100 // hard counter for spamming abilities. Not used/balanced much yet.
	var/always_keep = 0 // important for abilities like regenerate that screw you if you lose them.
	var/needs_button = TRUE // for passive abilities like hivemind that dont need a button
	var/active = FALSE // used by a few powers that toggle

/*
changeling code now relies on on_purchase to grant powers.
if you override it, MAKE SURE you call parent or it will not be usable
the same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
*/

/datum/action/changeling/proc/on_purchase(var/mob/user)
	if(needs_button)
		Grant(user)

/datum/action/changeling/Trigger()
	var/mob/user = owner
	if(!user || !user.mind || !user.mind.changeling)
		return
	try_to_sting(user)

/datum/action/changeling/proc/try_to_sting(var/mob/user, var/mob/target)
	if(!user.mind || !user.mind.changeling)
		return
	if(!can_sting(user, target))
		return
	var/datum/changeling/c = user.mind.changeling
	if(sting_action(user, target))
		sting_feedback(user, target)
		take_chemical_cost(c)

/datum/action/changeling/proc/sting_action(var/mob/user, var/mob/target)
	return 0

/datum/action/changeling/proc/sting_feedback(var/mob/user, var/mob/target)
	return 0

/datum/action/changeling/proc/take_chemical_cost(var/datum/changeling/changeling)
	changeling.chem_charges -= chemical_cost
	changeling.geneticdamage += genetic_damage

//Fairly important to remember to return 1 on success >.<
/datum/action/changeling/proc/can_sting(var/mob/user, var/mob/target)
	if(!ishuman(user)) //typecast everything from mob to carbon from this point onwards
		return 0
	if(req_human && (!ishuman(user) || issmall(user)))
		to_chat(user, "<span class='warning'>We cannot do that in this form!</span>")
		return 0
	var/datum/changeling/c = user.mind.changeling
	if(c.chem_charges<chemical_cost)
		to_chat(user, "<span class='warning'>We require at least [chemical_cost] unit\s of chemicals to do that!</span>")
		return 0
	if(c.absorbedcount<req_dna)
		to_chat(user, "<span class='warning'>We require at least [req_dna] sample\s of compatible DNA.</span>")
		return 0
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return 0
	if((user.status_flags & FAKEDEATH) && name!="Regenerate")
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return 0
	if(c.geneticdamage > max_genetic_damage)
		to_chat(user, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return 0
	return 1

//used in /mob/Stat()
/datum/action/changeling/proc/can_be_used_by(var/mob/user)
	if(!ishuman(user))
		return 0
	if(req_human && !ishuman(user))
		return 0
	return 1

// Transform the target to the chosen dna. Used in transform.dm and tiny_prick.dm (handy for changes since it's the same thing done twice)
/datum/action/changeling/proc/transform_dna(var/mob/living/carbon/human/H, var/datum/dna/D)
	if(!D)
		return
	H.set_species(D.species.type, retain_damage = TRUE)
	H.dna = D.Clone()
	domutcheck(H, null, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them
	H.flavor_text = ""
	H.dna.UpdateSE()
	H.dna.UpdateUI()
	H.sync_organ_dna(1)
	if(istype(H.dna.species, /datum/species/vox)) //Reason: UpdateAppearance() cannot get the UI value for the Donor DNA via arguments.
		H.dna.SetUIValue(13,D.GetUIValue(13)) //Copy Vox Skintone
		switch(H.dna.GetUIValue(13)) //Set H.s_tone based on the UI Value for Skintone
			if(632) //Vox Skintone 1, Green Vox, Hex278 = 632 Log10
				H.s_tone = 1
			if(614) //Vox Skintone 2, Dark Green Vox, Hex266 = 614 Log10
				H.s_tone = 2
			if(595) //Vox Skintone 3, Brown Vox, Hex253 = 595 Log10
				H.s_tone = 3
			if(577) //Vox Skintone 4, Grey Vox, Hex241 = 577 Log10
				H.s_tone = 4
			if(558) //Vox Skintone 5, Emerald Vox, Hex22E = 558 Log10
				H.s_tone = 5
			if(539) //Vox Skintone 6, Azure Vox, Hex21B = 539 Log10
				H.s_tone = 6
			else //Vox Skintone 0, Default Green Vox
				H.s_tone = 0
				
		//Vox Body & Tail Marking
		var/body_marks = D.GetUIValueRange(DNA_UI_BODY_MARK_STYLE, GLOB.marking_styles_list.len)
		var/tail_marks = D.GetUIValueRange(DNA_UI_TAIL_MARK_STYLE, GLOB.marking_styles_list.len)
		H.m_colours["body"] = rgb(D.GetUIValueRange(DNA_UI_BODY_MARK_R, 255), D.GetUIValueRange(DNA_UI_BODY_MARK_G, 255), D.GetUIValueRange(DNA_UI_BODY_MARK_B, 255))
		H.m_colours["tail"] = rgb(D.GetUIValueRange(DNA_UI_TAIL_MARK_R, 255), D.GetUIValueRange(DNA_UI_TAIL_MARK_G, 255), D.GetUIValueRange(DNA_UI_TAIL_MARK_B, 255))
		if((body_marks > 0) && (body_marks <= GLOB.marking_styles_list.len))
			H.m_styles["body"] = GLOB.marking_styles_list[body_marks]
		if((tail_marks > 0) && (tail_marks <= GLOB.marking_styles_list.len))
			H.m_styles["tail"] = GLOB.marking_styles_list[tail_marks]

		for(var/mob/living/carbon/human/C in GLOB.human_list) //This is messy. We know. The reason for this is that trinary-gendered species do not have gender stored on the dna level and transform_dna() is only passed dna-level data through multiple functions. What we do here is search for original mob based on name and pull the gender from them.
			if(C.real_name == D.real_name)
				H.change_gender(C.gender)

		H.real_name = D.real_name
		H.dna.species.handle_dna(H)
		H.regenerate_icons() //Refresh the Sprite with the new Icons
	else
		H.real_name = D.real_name
		H.UpdateAppearance()
