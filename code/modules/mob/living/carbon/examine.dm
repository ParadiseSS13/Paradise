/**
 * Get the message parts, in order, for a proper examine.
 * Message parts should be as follows:
 * - Pronoun/intro for how they've got it on them
 * - The item itself
 * - Preposition for where it is
 * - the location it's in
 */
/mob/living/carbon/proc/examine_visible_clothing(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	return list(
		list("[p_are()] holding", l_hand, "in", "left hand"),
		list("[p_are()] holding", r_hand, "in", "right hand"),
		list("[p_are()] wearing", head, "on", "head"),
		list("[p_are()] wearing", wear_suit, null, null),
		list("[p_have()]", back, "on", "back"),
	)

/**
 * Special handlers for processing limbs go here, based on limb names in examine_visible_clothing.
 * TODO rename this
 */
/mob/living/carbon/proc/examine_process_limb(limb_name)
	return ""

/mob/living/carbon/proc/examine_what_am_i(skip_jumpsuit, skip_face)
	return ".\n"

/mob/living/carbon/proc/examine_limb_flavor(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	return ""

/**
 * Add your damage flavor here.
 */
/mob/living/carbon/proc/examine_damage_flavor()

	var/msg = ""

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

	return msg

/**
 * Add any extra info which should be within the "damage" block, the big warning span.
 */
/mob/living/carbon/proc/examine_extra_damage_flavor()
	return ""

/**
 * Add some last information in before HUDs get put through.
 */
/mob/living/carbon/proc/examine_extra_general_flavor()
	return ""

/mob/living/carbon/examine(mob/user)
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

	msg += examine_what_am_i()

	// All the things wielded/worn that can be reasonably described with a common template:
	var/list/message_parts = examine_visible_clothing(skipgloves, skipsuitstorage, skipjumpsuit, skipshoes, skipmask, skipears, skipeyes, skipface)

	for(var/parts in message_parts)
		var/action = parts[1]
		var/obj/item/item = parts[2]
		var/preposition = parts[3]
		var/limb_name = parts[4]
		var/accessories = null
		if(length(parts) >= 5)
			accessories = parts[5]

		if(item && !(item.flags & ABSTRACT))
			var/item_words = item.name
			if(item.blood_DNA)
				item_words = "[item.blood_color != "#030303" ? "blood-stained":"oil-stained"] [item_words]"
			var/submsg = "[p_they(TRUE)] [action] [bicon(item)] \a [item_words]"
			if(accessories)
				submsg += " with [accessories]"
			if(limb_name)
				submsg += " [preposition] [p_their()] [limb_name]"
			if(item.blood_DNA)
				submsg = "<span class='warning'>[submsg]!</span>\n"
			else
				submsg = "[submsg].\n"
			msg += submsg
		else
			msg += examine_process_limb(limb_name)

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable/zipties))
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with zipties!</span>\n"
		else if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] [bicon(handcuffed)] handcuffed!</span>\n"

	//Jitters
	switch(AmountJitter())
		if(600 SECONDS to INFINITY)
			msg += "<span class='warning'><B>[p_they(TRUE)] [p_are()] convulsing violently!</B></span>\n"
		if(400 SECONDS to 600 SECONDS)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] extremely jittery.</span>\n"
		if(200 SECONDS to 400 SECONDS)
			msg += "<span class='warning'>[p_they(TRUE)] [p_are()] twitching ever so slightly.</span>\n"


	var/appears_dead = FALSE
	var/just_sleeping = FALSE //We don't appear as dead upon casual examination, just sleeping

	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		var/obj/item/clothing/glasses/E = get_item_by_slot(slot_glasses)
		var/are_we_in_weekend_at_bernies = E?.tint && istype(buckled, /obj/structure/chair/wheelchair) //Are we in a wheelchair with our eyes obscured?

		if(isliving(user) && are_we_in_weekend_at_bernies)
			just_sleeping = TRUE
		else
			appears_dead = TRUE

		if(suiciding)
			msg += "<span class='warning'>[p_they(TRUE)] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>\n"
		if(!just_sleeping)
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

	msg += examine_limb_flavor()

	msg += examine_damage_flavor()

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

	if(HAS_TRAIT(src, TRAIT_FAT))
		msg += "[p_they(TRUE)] [p_are()] morbidly obese.\n"
		if(user.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
			msg += "[p_they(TRUE)] [p_are()] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"

	else if(nutrition >= NUTRITION_LEVEL_FAT)
		msg += "[p_they(TRUE)] [p_are()] quite chubby.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "[p_they(TRUE)] [p_have()] pale skin.\n"

	msg += examine_extra_damage_flavor()

	if(reagents.has_reagent("teslium"))
		msg += "[p_they(TRUE)] [p_are()] emitting a gentle blue glow!\n"

	msg += examine_extra_damage_flavor()

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS || just_sleeping)
			msg += "[p_they(TRUE)] [p_are()]n't responding to anything around [p_them()] and seems to be asleep.\n"
		else if(getBrainLoss() >= 60)
			msg += "[p_they(TRUE)] [p_have()] a stupid expression on [p_their()] face.\n"

		if(get_int_organ(/obj/item/organ/internal/brain))
			if(dna?.species.show_ssd)
				if(!HAS_TRAIT(src, SCRYING))
					if(!key)
						msg += "<span class='deadsay'>[p_they(TRUE)] [p_are()] totally catatonic. The stresses of life in deep-space must have been too much for [p_them()]. Any recovery is unlikely.</span>\n"
					else if(!client)
						msg += "[p_they(TRUE)] [p_have()] suddenly fallen asleep, suffering from Space Sleep Disorder. [p_they(TRUE)] may wake up soon.\n"

	msg += examine_extra_general_flavor()

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
			if(!(H.status & ORGAN_DISFIGURED))
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
		if(DATA_HUD_SECURITY_ADVANCED in O.data_hud_seen)
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
