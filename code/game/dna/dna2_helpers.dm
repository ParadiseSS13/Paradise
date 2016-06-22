/////////////////////////////
// Helpers for DNA2
/////////////////////////////

// Pads 0s to t until length == u
/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

// DNA Gene activation boundaries, see dna2.dm.
// Returns a list object with 4 numbers.
/proc/GetDNABounds(var/block)
	var/list/BOUNDS=dna_activity_bounds[block]
	if(!istype(BOUNDS))
		return DNA_DEFAULT_BOUNDS
	return BOUNDS

// Give Random Bad Mutation to M
/proc/randmutb(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/block = pick(bad_blocks)
	M.dna.SetSEState(block, 1)

// Give Random Good Mutation to M
/proc/randmutg(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/block = pick(good_blocks)
	M.dna.SetSEState(block, 1)

// Random Appearance Mutation
/proc/randmuti(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	M.dna.SetUIValue(rand(1,DNA_UI_LENGTH),rand(1,4095))

// Scramble UI or SE.
/proc/scramble(var/UI, var/mob/M, var/prob)
	if(!M)	return
	M.dna.check_integrity()
	if(UI)
		for(var/i = 1, i <= DNA_UI_LENGTH-1, i++)
			if(prob(prob))
				M.dna.SetUIValue(i,rand(1,4095),1)
		M.dna.UpdateUI()
		M.UpdateAppearance()

	else
		for(var/i = 1, i <= DNA_SE_LENGTH-1, i++)
			if(prob(prob))
				M.dna.SetSEValue(i,rand(1,4095),1)
		M.dna.UpdateSE()
		domutcheck(M, null)
	return

// I haven't yet figured out what the fuck this is supposed to do.
/proc/miniscramble(input,rs,rd)
	var/output
	output = null
	if (input == "C" || input == "D" || input == "E" || input == "F")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"6",prob((rs*10));"7",prob((rs*5)+(rd));"0",prob((rs*5)+(rd));"1",prob((rs*10)-(rd));"2",prob((rs*10)-(rd));"3")
	if (input == "8" || input == "9" || input == "A" || input == "B")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "4" || input == "5" || input == "6" || input == "7")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "0" || input == "1" || input == "2" || input == "3")
		output = pick(prob((rs*10));"8",prob((rs*10));"9",prob((rs*10));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C",prob((rs*10)-(rd));"D",prob((rs*5)+(rd));"E",prob((rs*5)+(rd));"F")
	if (!output) output = "5"
	return output

// HELLO I MAKE BELL CURVES AROUND YOUR DESIRED TARGET
// So a shitty way of replacing gaussian noise.
// input: YOUR TARGET
// rs: RAD STRENGTH
// rd: DURATION
/proc/miniscrambletarget(input,rs,rd)
	var/output = null
	switch(input)
		if("0")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10));"2",prob((rs*10)-(rd));"3")
		if("1")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10));"3",prob((rs*10)-(rd));"4")
		if("2")
			output = pick(prob((rs*10));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10));"4",prob((rs*10)-(rd));"5")
		if("3")
			output = pick(prob((rs*10)-(rd));"0",prob((rs*10));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10));"5",prob((rs*10)-(rd));"6")
		if("4")
			output = pick(prob((rs*10)-(rd));"1",prob((rs*10));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10));"6",prob((rs*10)-(rd));"7")
		if("5")
			output = pick(prob((rs*10)-(rd));"2",prob((rs*10));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10));"7",prob((rs*10)-(rd));"8")
		if("6")
			output = pick(prob((rs*10)-(rd));"3",prob((rs*10));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10));"8",prob((rs*10)-(rd));"9")
		if("7")
			output = pick(prob((rs*10)-(rd));"4",prob((rs*10));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10));"9",prob((rs*10)-(rd));"A")
		if("8")
			output = pick(prob((rs*10)-(rd));"5",prob((rs*10));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10));"A",prob((rs*10)-(rd));"B")
		if("9")
			output = pick(prob((rs*10)-(rd));"6",prob((rs*10));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C")
		if("10")//A
			output = pick(prob((rs*10)-(rd));"7",prob((rs*10));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10));"C",prob((rs*10)-(rd));"D")
		if("11")//B
			output = pick(prob((rs*10)-(rd));"8",prob((rs*10));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10));"D",prob((rs*10)-(rd));"E")
		if("12")//C
			output = pick(prob((rs*10)-(rd));"9",prob((rs*10));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10));"E",prob((rs*10)-(rd));"F")
		if("13")//D
			output = pick(prob((rs*10)-(rd));"A",prob((rs*10));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10));"F")
		if("14")//E
			output = pick(prob((rs*10)-(rd));"B",prob((rs*10));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")
		if("15")//F
			output = pick(prob((rs*10)-(rd));"C",prob((rs*10));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")

	if(!input || !output) //How did this happen?
		output = "8"

	return output

// /proc/updateappearance has changed behavior, so it's been removed
// Use mob.UpdateAppearance() instead.

// Simpler. Don't specify UI in order for the mob to use its own.
/mob/proc/UpdateAppearance(var/list/UI=null)
	if(istype(src, /mob/living/carbon/human))
		if(UI!=null)
			src.dna.UI=UI
			src.dna.UpdateUI()
		dna.check_integrity()
		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.r_hair		= dna.GetUIValueRange(DNA_UI_HAIR_R,	255)
		head_organ.g_hair		= dna.GetUIValueRange(DNA_UI_HAIR_G,	255)
		head_organ.b_hair		= dna.GetUIValueRange(DNA_UI_HAIR_B,	255)

		head_organ.r_facial		= dna.GetUIValueRange(DNA_UI_BEARD_R,	255)
		head_organ.g_facial		= dna.GetUIValueRange(DNA_UI_BEARD_G,	255)
		head_organ.b_facial		= dna.GetUIValueRange(DNA_UI_BEARD_B,	255)

		H.r_skin		= dna.GetUIValueRange(DNA_UI_SKIN_R,	255)
		H.g_skin		= dna.GetUIValueRange(DNA_UI_SKIN_G,	255)
		H.b_skin		= dna.GetUIValueRange(DNA_UI_SKIN_B,	255)

		H.r_eyes		= dna.GetUIValueRange(DNA_UI_EYES_R,	255)
		H.g_eyes		= dna.GetUIValueRange(DNA_UI_EYES_G,	255)
		H.b_eyes		= dna.GetUIValueRange(DNA_UI_EYES_B,	255)

		head_organ.r_headacc		= dna.GetUIValueRange(DNA_UI_HACC_R,	255)
		head_organ.g_headacc		= dna.GetUIValueRange(DNA_UI_HACC_G,	255)
		head_organ.b_headacc		= dna.GetUIValueRange(DNA_UI_HACC_B,	255)

		var/list/marking_colours = params2list(H.m_colours)
		marking_colours["head"] = "#[num2hex(dna.GetUIValueRange(DNA_UI_HEAD_MARK_R,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_HEAD_MARK_G,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_HEAD_MARK_B,255),2)]"
		marking_colours["body"] = "#[num2hex(dna.GetUIValueRange(DNA_UI_BODY_MARK_R,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_BODY_MARK_G,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_BODY_MARK_B,255),2)]"
		marking_colours["tail"] = "#[num2hex(dna.GetUIValueRange(DNA_UI_TAIL_MARK_R,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_TAIL_MARK_G,255),2)][num2hex(dna.GetUIValueRange(DNA_UI_TAIL_MARK_B,255),2)]"

		H.update_eyes()

		if(H.species.bodyflags & HAS_SKIN_TONE)
			H.s_tone = 35 - dna.GetUIValueRange(DNA_UI_SKIN_TONE, 220) // Value can be negative.
		else if(H.species.bodyflags & HAS_ICON_SKIN_TONE)
			H.s_tone = dna.GetUIValueRange(DNA_UI_SKIN_TONE, H.species.icon_skin_tones.len)

		if(dna.GetUIState(DNA_UI_GENDER))
			H.change_gender(FEMALE, 0)
		else
			H.change_gender(MALE, 0)

		//Hair
		var/hair = dna.GetUIValueRange(DNA_UI_HAIR_STYLE,hair_styles_list.len)
		if((0 < hair) && (hair <= hair_styles_list.len))
			head_organ.h_style = hair_styles_list[hair]

		//Facial Hair
		var/beard = dna.GetUIValueRange(DNA_UI_BEARD_STYLE,facial_hair_styles_list.len)
		if((0 < beard) && (beard <= facial_hair_styles_list.len))
			head_organ.f_style = facial_hair_styles_list[beard]

		//Head Accessories
		var/headacc = dna.GetUIValueRange(DNA_UI_HACC_STYLE,head_accessory_styles_list.len)
		if((0 < headacc) && (headacc <= head_accessory_styles_list.len))
			head_organ.ha_style = head_accessory_styles_list[headacc]

		var/number_head_marks = 0
		var/number_body_marks = 0
		var/number_tail_marks = 0
		for(var/m in marking_styles_list)
			var/datum/sprite_accessory/body_markings/marking = marking_styles_list[m]
			if(marking.marking_location == "head")
				number_head_marks++
			else if(marking.marking_location == "body")
				number_body_marks++
			else if(marking.marking_location == "tail")
				number_tail_marks++

		//Head Markings
		var/head_marks = dna.GetUIValueRange(DNA_UI_HEAD_MARK_STYLE,marking_styles_list.len)
		if((0 < head_marks) && (head_marks <= number_head_marks))
			var/list/marking_styles = params2list(H.m_styles)
			marking_styles["head"] = marking_styles_list[head_marks]
			H.m_styles = list2params(marking_styles)
		//Body Markings
		var/body_marks = dna.GetUIValueRange(DNA_UI_BODY_MARK_STYLE,marking_styles_list.len)
		if((0 < body_marks) && (body_marks <= number_body_marks))
			var/list/marking_styles = params2list(H.m_styles)
			marking_styles["body"] = marking_styles_list[body_marks]
			H.m_styles = list2params(marking_styles)
		//Tail Markings
		var/tail_marks = dna.GetUIValueRange(DNA_UI_TAIL_MARK_STYLE,marking_styles_list.len)
		if((0 < tail_marks) && (tail_marks <= number_tail_marks))
			var/list/marking_styles = params2list(H.m_styles)
			marking_styles["tail"] = marking_styles_list[tail_marks]
			H.m_styles = list2params(marking_styles)

		H.force_update_limbs()
		H.update_eyes()
		H.update_hair()
		H.update_fhair()
		H.update_markings()
		H.update_tail_layer()
		H.update_head_accessory()

		return 1
	else
		return 0

// Used below, simple injection modifier.
/proc/probinj(var/pr, var/inj)
	return prob(pr+inj*pr)
