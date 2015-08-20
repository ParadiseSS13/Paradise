/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes = null
	var/struc_enzymes = null
	var/uni_identity = null
	var/b_type = "A+"
	var/mutantrace = null  //The type of mutant race the player is if applicable (i.e. potato-man)
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,

/datum/dna/proc/check_integrity(var/mob/living/carbon/human/character)
	if(character)
		if(length(uni_identity) != 39)
			//Lazy.
			var/temp

			//Hair
			var/hair	= 0
			if(!character.h_style)
				character.h_style = "Skinhead"

			var/hrange = round(4095 / hair_styles_list.len)
			var/index = hair_styles_list.Find(character.h_style)
			if(index)
				hair = index * hrange - rand(1,hrange-1)

			//Facial Hair
			var/beard	= 0
			if(!character.f_style)
				character.f_style = "Shaved"

			var/f_hrange = round(4095 / facial_hair_styles_list.len)
			index = facial_hair_styles_list.Find(character.f_style)
			if(index)
				beard = index * f_hrange - rand(1,f_hrange-1)

			temp = add_zero2(num2hex((character.r_hair),1), 3)
			temp += add_zero2(num2hex((character.b_hair),1), 3)
			temp += add_zero2(num2hex((character.g_hair),1), 3)
			temp += add_zero2(num2hex((character.r_facial),1), 3)
			temp += add_zero2(num2hex((character.b_facial),1), 3)
			temp += add_zero2(num2hex((character.g_facial),1), 3)
			temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
			temp += add_zero2(num2hex((character.r_eyes),1), 3)
			temp += add_zero2(num2hex((character.g_eyes),1), 3)
			temp += add_zero2(num2hex((character.b_eyes),1), 3)

			var/gender

			if (character.gender == MALE)
				gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
			else
				gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

			temp += gender
			temp += add_zero2(num2hex((beard),1), 3)
			temp += add_zero2(num2hex((hair),1), 3)

			uni_identity = temp
		if(length(struc_enzymes)!= 3*STRUCDNASIZE)
			var/mutstring = ""
			for(var/i = 1, i <= STRUCDNASIZE, i++)
				mutstring += add_zero2(num2hex(rand(1,1024)),3)

			struc_enzymes = mutstring
		if(length(unique_enzymes) != 32)
			unique_enzymes = md5(character.real_name)
	else
		if(length(uni_identity) != 39) uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		if(length(struc_enzymes)!= 3*STRUCDNASIZE) struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"

/datum/dna/proc/ready_dna(mob/living/carbon/human/character)
	var/temp

	//Hair
	var/hair	= 0
	if(!character.h_style)
		character.h_style = random_hair_style(character.gender)

	var/hrange = round(4095 / hair_styles_list.len)
	var/index = hair_styles_list.Find(character.h_style)
	if(index)
		hair = index * hrange - rand(1,hrange-1)

	//Facial Hair
	var/beard	= 0
	if(!character.f_style)
		character.f_style = random_facial_hair_style(character.gender)

	var/f_hrange = round(4095 / facial_hair_styles_list.len)
	index = facial_hair_styles_list.Find(character.f_style)
	if(index)
		beard = index * f_hrange - rand(1,f_hrange-1)

	temp = add_zero2(num2hex((character.r_hair),1), 3)
	temp += add_zero2(num2hex((character.b_hair),1), 3)
	temp += add_zero2(num2hex((character.g_hair),1), 3)
	temp += add_zero2(num2hex((character.r_facial),1), 3)
	temp += add_zero2(num2hex((character.b_facial),1), 3)
	temp += add_zero2(num2hex((character.g_facial),1), 3)
	temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
	temp += add_zero2(num2hex((character.r_eyes),1), 3)
	temp += add_zero2(num2hex((character.g_eyes),1), 3)
	temp += add_zero2(num2hex((character.b_eyes),1), 3)

	var/gender

	if (character.gender == MALE)
		gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
	else
		gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

	temp += gender
	temp += add_zero2(num2hex((beard),1), 3)
	temp += add_zero2(num2hex((hair),1), 3)

	uni_identity = temp

	var/mutstring = ""
	for(var/i = 1, i <= STRUCDNASIZE, i++)
		mutstring += add_zero2(num2hex(rand(1,1024)),3)


	struc_enzymes = mutstring

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

/////////////////////////// DNA DATUM