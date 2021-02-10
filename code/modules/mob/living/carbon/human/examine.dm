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
		skipeyes |= wear_mask.flags_inv & HIDEEYES

	var/msg = "<span class='info'>*---------*\nThis is "

	if(!(skipjumpsuit && skipface) && icon) //big suits/masks/helmets make it hard to tell their gender
		msg += "[bicon(icon(icon, dir=SOUTH))] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
	msg += "<EM>[name]</EM>"

	var/displayed_species = dna.species.name
	var/examine_color = dna.species.flesh_color
	for(var/obj/item/clothing/C in src)			//Disguise checks
		if(C == src.head || C == src.wear_suit || C == src.wear_mask || C == src.w_uniform || C == src.belt || C == src.back)
			if(C.species_disguise)
				displayed_species = C.species_disguise
	if(skipjumpsuit && skipface || (NO_EXAMINE in dna.species.species_traits)) //either obscured or on the nospecies list
		msg += "!\n"    //omit the species when examining
	else if(displayed_species == "Slime People") //snowflakey because Slime People are defined as a plural
		msg += ", a<b><font color='[examine_color]'> slime person</font></b>!\n"
	else if(displayed_species == "Unathi") //DAMN YOU, VOWELS
		msg += ", a<b><font color='[examine_color]'> unathi</font></b>!\n"
	else
		msg += ", a<b><font color='[examine_color]'> [lowertext(displayed_species)]</font></b>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit && !(w_uniform.flags & ABSTRACT))
		//Ties
		var/tie_msg
		if(istype(w_uniform,/obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.accessories.len)
				tie_msg += " with [english_accessory_list(U)]"

		if(w_uniform.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] [w_uniform.blood_color != "#030303" ? "blood-stained":"oil-stained"] [w_uniform.name][tie_msg]!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] wearing [bicon(w_uniform)] \a [w_uniform][tie_msg].\n"

	//head
	if(head && !(head.flags & ABSTRACT))
		if(head.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] [head.blood_color != "#030303" ? "blood-stained":"oil-stained"] [head.name] on [p_their()] head!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] wearing [bicon(head)] \a [head] on [p_their()] head.\n"

	//suit/armour
	if(wear_suit && !(wear_suit.flags & ABSTRACT))
		if(wear_suit.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] [wear_suit.blood_color != "#030303" ? "blood-stained":"oil-stained"] [wear_suit.name]!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] wearing [bicon(wear_suit)] \a [wear_suit].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += "<span class='warning'>[p_they(TRUE)] [p_are()] carrying [bicon(s_store)] [s_store.gender==PLURAL?"some":"a"] [s_store.blood_color != "#030303" ? "blood-stained":"oil-stained"] [s_store.name] on [p_their()] [wear_suit.name]!</span>\n"
			else
				msg += "[p_they(TRUE)] [p_are()] carrying [bicon(s_store)] \a [s_store] on [p_their()] [wear_suit.name].\n"

	//back
	if(back && !(back.flags & ABSTRACT))
		if(back.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [bicon(back)] [back.gender==PLURAL?"some":"a"] [back.blood_color != "#030303" ? "blood-stained":"oil-stained"] [back] on [p_their()] back.</span>\n"
		else
			msg += "[p_they(TRUE)] [p_have()] [bicon(back)] \a [back] on [p_their()] back.\n"

	//left hand
	if(l_hand && !(l_hand.flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] [l_hand.blood_color != "#030303" ? "blood-stained":"oil-stained"] [l_hand.name] in [p_their()] left hand!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] holding [bicon(l_hand)] \a [l_hand] in [p_their()] left hand.\n"

	//right hand
	if(r_hand && !(r_hand.flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] [r_hand.blood_color != "#030303" ? "blood-stained":"oil-stained"] [r_hand.name] in [p_their()] right hand!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] holding [bicon(r_hand)] \a [r_hand] in [p_their()] right hand.\n"

	//gloves
	if(gloves && !skipgloves && !(gloves.flags & ABSTRACT))
		if(gloves.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] [gloves.blood_color != "#030303" ? "blood-stained":"oil-stained"] [gloves.name] on [p_their()] hands!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_have()] [bicon(gloves)] \a [gloves] on [p_their()] hands.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [hand_blood_color != "#030303" ? "blood-stained":"oil-stained"] hands!</span>\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable/zipties))
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with zipties!</span>\n"
		else if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] handcuffed!</span>\n"

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [bicon(belt)] [belt.gender==PLURAL?"some":"a"] [belt.blood_color != "#030303" ? "blood-stained":"oil-stained"] [belt.name] about [p_their()] waist!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_have()] [bicon(belt)] \a [belt] about [p_their()] waist.\n"

	//shoes
	if(shoes && !skipshoes && !(shoes.flags & ABSTRACT))
		if(shoes.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] [shoes.blood_color != "#030303" ? "blood-stained":"oil-stained"] [shoes.name] on [p_their()] feet!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_are()] wearing [bicon(shoes)] \a [shoes] on [p_their()] feet.\n"
	else if(blood_DNA)
		msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [feet_blood_color != "#030303" ? "blood-stained":"oil-stained"] feet!</span>\n"


	//mask
	if(wear_mask && !skipmask && !(wear_mask.flags & ABSTRACT))
		if(wear_mask.blood_DNA)
			msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] [wear_mask.blood_color != "#030303" ? "blood-stained":"oil-stained"] [wear_mask.name] on [p_their()] face!</span>\n"
		else
			msg += "[p_they(TRUE)] [p_have()] [bicon(wear_mask)] \a [wear_mask] on [p_their()] face.\n"

	//eyes
	if(!skipeyes)
		if(glasses && !(glasses.flags & ABSTRACT))
			if(glasses.blood_DNA)
				msg += "<span class='warning'>[p_they(TRUE)] [p_have()] [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] [glasses.blood_color != "#030303" ? "blood-stained":"oil-stained"] [glasses] covering [p_their()] eyes!</span>\n"
			else
				msg += "[p_they(TRUE)] [p_have()] [bicon(glasses)] \a [glasses] covering [p_their()] eyes.\n"
		else if(iscultist(src) && HAS_TRAIT(src, CULT_EYES))
			msg += "<span class='boldwarning'>[p_their(TRUE)] eyes are glowing an unnatural red!</span>\n"

	//left ear
	if(l_ear && !skipears)
		msg += "[p_they(TRUE)] [p_have()] [bicon(l_ear)] \a [l_ear] on [p_their()] left ear.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[p_they(TRUE)] [p_have()] [bicon(r_ear)] \a [r_ear] on [p_their()] right ear.\n"

	//ID
	if(wear_id)
		msg += "[p_they(TRUE)] [p_are()] wearing [bicon(wear_id)] \a [wear_id].\n"

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			msg += "<span class='warning'><B>[p_they(TRUE)] [p_are()] convulsing violently!</B></span>\n"
		if(200 to 300)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] extremely jittery.</span>\n"
		if(100 to 200)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] twitching ever so slightly.</span>\n"


	var/appears_dead = FALSE
	if(stat == DEAD || (status_flags & FAKEDEATH))
		appears_dead = TRUE
		if(suiciding)
			msg += "<span class='warning'>[p_they(TRUE)] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>\n"
		msg += "<span class='deadsay'>[p_they(TRUE)] [p_are()] limp and unresponsive; there are no signs of life"
		if(get_int_organ(/obj/item/organ/internal/brain))
			if(!key)
				var/foundghost = FALSE
				if(mind)
					for(var/mob/dead/observer/G in GLOB.player_list)
						if(G.mind == mind)
							foundghost = TRUE
							if(G.can_reenter_corpse == 0)
								foundghost = FALSE
							break
				if(!foundghost)
					msg += " and [p_their()] soul has departed"
		msg += "...</span>\n"

	if(!get_int_organ(/obj/item/organ/internal/brain))
		msg += "<span class='deadsay'>It appears that [p_their()] brain is missing...</span>\n"

	msg += "<span class='warning'>"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	for(var/organ_tag in dna.species.has_limbs)

		var/list/organ_data = dna.species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		is_destroyed["[organ_data["descriptor"]]"] = 1

		var/obj/item/organ/external/E = bodyparts_by_name[organ_tag]
		if(!E)
			wound_flavor_text["[organ_tag]"] = "<B>[p_they(TRUE)] [p_are()] missing [p_their()] [organ_descriptor].</B>\n"
		else
			if(!ismachineperson(src))
				if(E.is_robotic())
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a robotic [E.name]!\n"

				else if(E.status & ORGAN_SPLINTED)
					wound_flavor_text["[E.limb_name]"] = "[p_they(TRUE)] [p_have()] a splint on [p_their()] [E.name]!\n"

			if(E.open)
				if(E.is_robotic())
					msg += "<b>The maintenance hatch on [p_their()] [ignore_limb_branding(E.limb_name)] is open!</b>\n"
				else
					msg += "<b>[p_their(TRUE)] [ignore_limb_branding(E.limb_name)] has an open incision!</b>\n"

			for(var/obj/item/I in E.embedded_objects)
				msg += "<B>[p_they(TRUE)] [p_have()] \a [bicon(I)] [I] embedded in [p_their()] [E.name]!</B>\n"

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

	var/damage = getBruteLoss() //no need to calculate each of these twice

	if(damage)
		var/brute_message = !ismachineperson(src) ? "bruising" : "denting"
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] [brute_message].\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe [brute_message]!</B>\n"

	damage = getFireLoss()
	if(damage)
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] burns.\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe burns!</B>\n"

	damage = getCloneLoss()
	if(damage)
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] cellular damage.\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe cellular damage.</B>\n"


	if(fire_stacks > 0)
		msg += "[p_they(TRUE)] [p_are()] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[p_they(TRUE)] looks a little soaked.\n"

	switch(wetlevel)
		if(1)
			msg += "[p_they(TRUE)] looks a bit damp.\n"
		if(2)
			msg += "[p_they(TRUE)] looks a little bit wet.\n"
		if(3)
			msg += "[p_they(TRUE)] looks wet.\n"
		if(4)
			msg += "[p_they(TRUE)] looks very wet.\n"
		if(5)
			msg += "[p_they(TRUE)] looks absolutely soaked.\n"

	if(nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
		msg += "[p_they(TRUE)] [p_are()] severely malnourished.\n"

	if(FAT in mutations)
		msg += "[p_they(TRUE)] [p_are()] morbidly obese.\n"
		if(user.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
			msg += "[p_they(TRUE)] [p_are()] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"

	else if(nutrition >= NUTRITION_LEVEL_FAT)
		msg += "[p_they(TRUE)] [p_are()] quite chubby.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "[p_they(TRUE)] [p_have()] pale skin.\n"

	if(bleedsuppress)
		msg += "[p_they(TRUE)] [p_are()] bandaged with something.\n"
	else if(bleed_rate)
		msg += "<B>[p_they(TRUE)] [p_are()] bleeding!</B>\n"

	if(reagents.has_reagent("teslium"))
		msg += "[p_they(TRUE)] [p_are()] emitting a gentle blue glow!\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[p_they(TRUE)] [p_are()]n't responding to anything around [p_them()] and seems to be asleep.\n"
		else if(getBrainLoss() >= 60)
			msg += "[p_they(TRUE)] [p_have()] a stupid expression on [p_their()] face.\n"

		if(get_int_organ(/obj/item/organ/internal/brain))
			if(dna.species.show_ssd)
				if(!key)
					msg += "<span class='deadsay'>[p_they(TRUE)] [p_are()] totally catatonic. The stresses of life in deep-space must have been too much for [p_them()]. Any recovery is unlikely.</span>\n"
				else if(!client)
					msg += "[p_they(TRUE)] [p_have()] suddenly fallen asleep, suffering from Space Sleep Disorder. [p_they(TRUE)] may wake up soon.\n"

		if(digitalcamo)
			msg += "[p_they(TRUE)] [p_are()] moving [p_their()] body in an unnatural and blatantly inhuman manner.\n"

	if(!(skipface || ( wear_mask && ( wear_mask.flags_inv & HIDEFACE || wear_mask.flags_cover & MASKCOVERSMOUTH) ) ) && is_thrall(src) && in_range(user,src))
		msg += "Their features seem unnaturally tight and drawn.\n"

	if(decaylevel == 1)
		msg += "[p_they(TRUE)] [p_are()] starting to smell.\n"
	if(decaylevel == 2)
		msg += "[p_they(TRUE)] [p_are()] bloated and smells disgusting.\n"
	if(decaylevel == 3)
		msg += "[p_they(TRUE)] [p_are()] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
	if(decaylevel == 4)
		msg += "[p_they(TRUE)] [p_are()] mostly desiccated now, with only bones remaining of what used to be a person.\n"

	if(hasHUD(user, EXAMINE_HUD_SECURITY_READ))
		var/perpname = get_visible_name(TRUE)
		var/criminal = "None"
		var/commentLatest = "ERROR: Unable to locate a data core entry for this person." //If there is no datacore present, give this

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]
							if(LAZYLEN(R.fields["comments"])) //if the commentlist is present
								var/list/comments = R.fields["comments"]
								commentLatest = LAZYACCESS(comments, comments.len) //get the latest entry from the comment log
							else
								commentLatest = "No entries." //If present but without entries (=target is recognized crew)

			var/criminal_status = hasHUD(user, EXAMINE_HUD_SECURITY_WRITE) ? "<a href='?src=[UID()];criminal=1'>\[[criminal]\]</a>" : "\[[criminal]\]"
			msg += "<span class = 'deptradio'>Criminal status:</span> [criminal_status]\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=[UID()];secrecordComment=`'>\[View comment log\]</a> <a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>\n"
			msg += "<span class = 'deptradio'>Latest entry:</span> [commentLatest]\n"

	if(hasHUD(user, EXAMINE_HUD_SKILLS))
		var/perpname = get_visible_name(TRUE)
		var/skills

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					skills = E.fields["notes"]
			if(skills)
				var/char_limit = 40
				if(length(skills) <= char_limit)
					msg += "<span class='deptradio'>Employment records:</span> [skills]\n"
				else
					msg += "<span class='deptradio'>Employment records: [copytext_preserve_html(skills, 1, char_limit-3)]...</span><a href='byond://?src=[UID()];employment_more=1'>More...</a>\n"


	if(hasHUD(user,EXAMINE_HUD_MEDICAL))
		var/perpname = get_visible_name(TRUE)
		var/medical = "None"

		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in GLOB.data_core.general)
					if(R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=[UID()];medrecord=`'>\[View\]</a> <a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>\n"

	if(print_flavor_text() && !skipface)
		if(get_organ("head"))
			var/obj/item/organ/external/head/H = get_organ("head")
			if(!H.disfigured)
				msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"
	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[p_they(TRUE)] [p_are()] [pose]"

	. = list(msg)

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/have_hudtypes = list()
		var/mob/living/carbon/human/H = M

		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			var/obj/item/clothing/glasses/hud/hudglasses = H.glasses
			if(hudglasses?.examine_extensions)
				have_hudtypes += hudglasses.examine_extensions

		var/obj/item/organ/internal/cyberimp/eyes/hud/CIH = H.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/hud)
		if(CIH?.examine_extensions)
			have_hudtypes += CIH.examine_extensions

		return (hudtype in have_hudtypes)

	else if(isrobot(M) || isAI(M)) //Stand-in/Stopgap to prevent pAIs from freely altering records, pending a more advanced Records system
		return (hudtype in list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SECURITY_WRITE, EXAMINE_HUD_MEDICAL))

	else if(isobserver(M))
		var/mob/dead/observer/O = M
		if(O.data_hud_seen == DATA_HUD_SECURITY_ADVANCED || O.data_hud_seen == DATA_HUD_DIAGNOSTIC + DATA_HUD_SECURITY_ADVANCED + DATA_HUD_MEDICAL_ADVANCED)
			return (hudtype in list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SKILLS))

	return FALSE

// Ignores robotic limb branding prefixes like "Morpheus Cybernetics"
/proc/ignore_limb_branding(limb_name)
	switch(limb_name)
		if("chest")
			. = "upper body"
		if("groin")
			. = "lower body"
		if("head")
			. = "head"
		if("l_arm")
			. = "left arm"
		if("r_arm")
			. = "right arm"
		if("l_leg")
			. = "left leg"
		if("r_leg")
			. = "right leg"
		if("l_foot")
			. = "left foot"
		if("r_foot")
			. = "right foot"
		if("l_hand")
			. = "left hand"
		if("r_hand")
			. = "right hand"
