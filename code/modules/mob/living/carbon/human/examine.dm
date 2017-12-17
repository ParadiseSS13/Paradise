/mob/living/carbon/human/examine(mob/user)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDEFACE

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"

	var/msg = "<span class='info'>*---------*\nThis is "

	if((skipjumpsuit && skipface)) //big suits/masks/helmets make it hard to tell their gender
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
	else
		if(icon)
			msg += "[bicon(icon(icon, dir=SOUTH))] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
		switch(gender)
			if(MALE)
				t_He = "He"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_his = "her"
				t_him = "her"
			if(PLURAL)
				t_He = "They"
				t_his = "their"
				t_him = "them"
				t_has = "have"
				t_is = "are"

	msg += "<EM>[name]</EM>"

	var/list/nospecies = list("Abductor", "Shadowling", "Neara", "Monkey", "Stok", "Farwa", "Wolpin") //species that won't show their race no matter what

	var/displayed_species = get_species()
	for(var/obj/item/clothing/C in src)			//Disguise checks
		if(C == src.head || C == src.wear_suit || C == src.wear_mask || C == src.w_uniform || C == src.belt || C == src.back)
			if(C.species_disguise)
				displayed_species = C.species_disguise
	if(skipjumpsuit && skipface || (displayed_species in nospecies)) //either obscured or on the nospecies list
		msg += "!\n"    //omit the species when examining
	else if(displayed_species == "Slime People") //snowflakey because Slime People are defined as a plural
		msg += ", a slime person!\n"
	else if(displayed_species == "Unathi") //DAMN YOU, VOWELS
		msg += ", a unathi!\n"
	else
		msg += ", \a [lowertext(displayed_species)]!\n"

	//uniform
	if(w_uniform && !skipjumpsuit && !(w_uniform.flags & ABSTRACT))
		//Ties
		var/tie_msg
		if(istype(w_uniform,/obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.accessories.len)
				tie_msg += " with [english_accessory_list(U)]"

		if(w_uniform.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] [w_uniform.blood_color != "#030303" ? "blood-stained":"oil-stained"] [w_uniform.name][tie_msg]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(w_uniform)] \a [w_uniform][tie_msg].\n"

	//head
	if(head && !(head.flags & ABSTRACT))
		if(head.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] [head.blood_color != "#030303" ? "blood-stained":"oil-stained"] [head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(head)] \a [head] on [t_his] head.\n"

	//suit/armour
	if(wear_suit && !(wear_suit.flags & ABSTRACT))
		if(wear_suit.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] [wear_suit.blood_color != "#030303" ? "blood-stained":"oil-stained"] [wear_suit.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(wear_suit)] \a [wear_suit].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] carrying [bicon(s_store)] [s_store.gender==PLURAL?"some":"a"] [s_store.blood_color != "#030303" ? "blood-stained":"oil-stained"] [s_store.name] on [t_his] [wear_suit.name]!</span>\n"
			else
				msg += "[t_He] [t_is] carrying [bicon(s_store)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back && !(back.flags & ABSTRACT))
		if(back.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] [back.blood_color != "#030303" ? "blood-stained":"oil-stained"] [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back.\n"

	//left hand
	if(l_hand && !(l_hand.flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] [l_hand.blood_color != "#030303" ? "blood-stained":"oil-stained"] [l_hand.name] in [t_his] left hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(l_hand)] \a [l_hand] in [t_his] left hand.\n"

	//right hand
	if(r_hand && !(r_hand.flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] [r_hand.blood_color != "#030303" ? "blood-stained":"oil-stained"] [r_hand.name] in [t_his] right hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(r_hand)] \a [r_hand] in [t_his] right hand.\n"

	//gloves
	if(gloves && !skipgloves && !(gloves.flags & ABSTRACT))
		if(gloves.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] [gloves.blood_color != "#030303" ? "blood-stained":"oil-stained"] [gloves.name] on [t_his] hands!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(gloves)] \a [gloves] on [t_his] hands.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[t_He] [t_has] [hand_blood_color != "#030303" ? "blood-stained":"oil-stained"] hands!</span>\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/restraints/handcuffs/cable/zipties))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with zipties!</span>\n"
		else if(istype(handcuffed, /obj/item/weapon/restraints/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(belt)] [belt.gender==PLURAL?"some":"a"] [belt.blood_color != "#030303" ? "blood-stained":"oil-stained"] [belt.name] about [t_his] waist!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(belt)] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !skipshoes && !(shoes.flags & ABSTRACT))
		if(shoes.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] [shoes.blood_color != "#030303" ? "blood-stained":"oil-stained"] [shoes.name] on [t_his] feet!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(shoes)] \a [shoes] on [t_his] feet.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[t_He] [t_has] [feet_blood_color != "#030303" ? "blood-stained":"oil-stained"] feet!</span>\n"


	//mask
	if(wear_mask && !skipmask && !(wear_mask.flags & ABSTRACT))
		if(wear_mask.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] [wear_mask.blood_color != "#030303" ? "blood-stained":"oil-stained"] [wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(wear_mask)] \a [wear_mask] on [t_his] face.\n"

	//eyes
	if(glasses && !skipeyes && !(glasses.flags & ABSTRACT))
		if(glasses.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] [glasses.blood_color != "#030303" ? "blood-stained":"oil-stained"] [glasses] covering [t_his] eyes!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(glasses)] \a [glasses] covering [t_his] eyes.\n"
	else if (!skipeyes && druggy > 0)
		msg += "<span class='warning'>Pupils are unusually huge!</span>\n"
	//left ear
	if(l_ear && !skipears)
		msg += "[t_He] [t_has] [bicon(l_ear)] \a [l_ear] on [t_his] left ear.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[t_He] [t_has] [bicon(r_ear)] \a [r_ear] on [t_his] right ear.\n"

	//ID
	if(wear_id)
		msg += "[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id].\n"

	if(is_nude() && gender == MALE && species.genitals)
		msg += "<B>Penis size: [potenzia].</B>\n"
	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		if(200 to 300)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		if(100 to 200)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"


	var/appears_dead = FALSE
	if(stat == DEAD || (status_flags & FAKEDEATH))
		appears_dead = TRUE
		if(suiciding)
			msg += "<span class='warning'>[t_He] appears to have committed suicide... there is no hope of recovery.</span>\n"
		msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive; there are no signs of life"
		if(get_int_organ(/obj/item/organ/internal/brain))
			if(!key)
				var/foundghost = FALSE
				if(mind)
					for(var/mob/dead/observer/G in player_list)
						if(G.mind == mind)
							foundghost = TRUE
							if(G.can_reenter_corpse == 0)
								foundghost = FALSE
							break
				if(!foundghost)
					msg += " and [t_his] soul has departed"
		msg += "...</span>\n"

	if(!get_int_organ(/obj/item/organ/internal/brain))
		msg += "<span class='deadsay'>It appears that [t_his] brain is missing...</span>\n"

	msg += "<span class='warning'>"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	for(var/organ_tag in species.has_limbs)

		var/list/organ_data = species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		is_destroyed["[organ_data["descriptor"]]"] = 1

		var/obj/item/organ/external/E = bodyparts_by_name[organ_tag]
		if(!E)
			wound_flavor_text["[organ_tag]"] = "<B>[t_He] [t_is] missing [t_his] [organ_descriptor].</B>\n"
		else
			if(!isSynthetic())
				if(E.status & ORGAN_ROBOT)
					wound_flavor_text["[E.limb_name]"] = "[t_He] [t_has] a robotic [E.name]!\n"

				else if(E.status & ORGAN_SPLINTED)
					wound_flavor_text["[E.limb_name]"] = "[t_He] [t_has] a splint on [t_his] [E.name]!\n"

			for(var/obj/item/I in E.embedded_objects)
				msg += "<B>[t_He] [t_has] \a [bicon(I)] [I] embedded in [t_his] [E.name]!</B>\n"

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	if(wound_flavor_text["l_arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["l_arm"]
	if(wound_flavor_text["l_hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["l_hand"]
	if(wound_flavor_text["r_arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["r_arm"]
	if(wound_flavor_text["r_hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["r_hand"]
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	if(wound_flavor_text["l_leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["l_leg"]
	if(wound_flavor_text["l_foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["l_foot"]
	if(wound_flavor_text["r_leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["r_leg"]
	if(wound_flavor_text["r_foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["r_foot"]

	var/temp = getBruteLoss() //no need to calculate each of these twice

	if(temp)
		var/brute_message = !isSynthetic() ? "bruising" : "denting"
		if(temp < 30)
			msg += "[t_He] [t_has] minor [brute_message ].\n"
		else
			msg += "<B>[t_He] [t_has] severe [brute_message ]!</B>\n"

	temp = getFireLoss()
	if(temp)
		if(temp < 30)
			msg += "[t_He] [t_has] minor burns.\n"
		else
			msg += "<B>[t_He] [t_has] severe burns!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(temp < 30)
			msg += "[t_He] [t_has] minor cellular damage.\n"
		else
			msg += "<B>[t_He] [t_has] severe cellular damage.</B>\n"


	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] looks a little soaked.\n"

	switch(wetlevel)
		if(1)
			msg += "[t_He] looks a bit damp.\n"
		if(2)
			msg += "[t_He] looks a little bit wet.\n"
		if(3)
			msg += "[t_He] looks wet.\n"
		if(4)
			msg += "[t_He] looks very wet.\n"
		if(5)
			msg += "[t_He] looks absolutely soaked.\n"

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else
			msg += "[t_He] [t_is] quite chubby.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "[t_He] [t_has] pale skin.\n"

	if(bleedsuppress)
		msg += "[t_He] [t_is] bandaged with something.\n"
	else if(bleed_rate)
		if(reagents.has_reagent("heparin"))
			msg += "<B>[t_He] [t_is] bleeding uncontrollably!</B>\n"
		else
			msg += "<B>[t_He] [t_is] bleeding!</B>\n"

	if(reagents.has_reagent("teslium"))
		msg += "[t_He] is emitting a gentle blue glow!\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"
		else if(getBrainLoss() >= 60)
			msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

		if(get_int_organ(/obj/item/organ/internal/brain))
			if(istype(src, /mob/living/carbon/human/interactive))
				var/mob/living/carbon/human/interactive/auto = src
				if(auto.showexaminetext)
					msg += "<span class='deadsay'>[t_He] [t_is] appears to be some sort of sick automaton, [t_his] eyes are glazed over and [t_his] mouth is slightly agape.</span>\n"
				if(auto.debugexamine)
					var/dodebug = auto.doing2string(auto.doing)
					var/interestdebug = auto.interest2string(auto.interest)
					msg += "<span class='deadsay'>[t_He] [t_is] appears to be [interestdebug] and [dodebug].</span>\n"
			else if(species.show_ssd)
				if(!key)
					msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
				else if(!client)
					msg += "[t_He] [t_has] suddenly fallen asleep, suffering from Space Sleep Disorder. [t_He] may wake up soon.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.\n"

	if(!(skipface || ( wear_mask && ( wear_mask.flags_inv & HIDEFACE || wear_mask.flags_cover & MASKCOVERSMOUTH) ) ) && is_thrall(src) && in_range(user,src))
		msg += "Their features seem unnaturally tight and drawn.\n"

	if(decaylevel == 1)
		msg += "[t_He] [t_is] starting to smell.\n"
	if(decaylevel == 2)
		msg += "[t_He] [t_is] bloated and smells disgusting.\n"
	if(decaylevel == 3)
		msg += "[t_He] [t_is] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
	if(decaylevel == 4)
		msg += "[t_He] [t_is] mostly dessicated now, with only bones remaining of what used to be a person.\n"

	if(hasHUD(user,"security"))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
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
							criminal = R.fields["criminal"]

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='?src=[UID()];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=[UID()];secrecord=`'>\[View\]</a>  <a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,"medical"))
		var/perpname = "wot"
		var/medical = "None"

		if(wear_id)
			if(istype(wear_id,/obj/item/weapon/card/id))
				perpname = wear_id:registered_name
			else if(istype(wear_id,/obj/item/device/pda))
				var/obj/item/device/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in data_core.general)
					if(R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=[UID()];medrecord=`'>\[View\]</a> <a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>\n"


	if(print_flavor_text() && !skipface)
		msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"
	if(pose)
		if( findtext(pose,".",lentext(pose)) == 0 && findtext(pose,"!",lentext(pose)) == 0 && findtext(pose,"?",lentext(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[t_He] is [pose]"

	to_chat(user, msg)

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M as mob, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/cyberimp/eyes/hud/CIH = H.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/hud)
		switch(hudtype)
			if("security")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses) || istype(CIH,/obj/item/organ/internal/cyberimp/eyes/hud/security)
			if("medical")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(H.glasses, /obj/item/clothing/glasses/hud/health/health_advanced) ||  istype(CIH,/obj/item/organ/internal/cyberimp/eyes/hud/medical)
			else
				return 0
	else if(isrobot(M) || isAI(M)) //Stand-in/Stopgap to prevent pAIs from freely altering records, pending a more advanced Records system
		switch(hudtype)
			if("security")
				return 1
			if("medical")
				return 1
			else
				return 0
	else
		return 0
