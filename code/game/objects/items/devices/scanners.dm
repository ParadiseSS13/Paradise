/*
CONTAINS:
T-RAY SCANNER
HEALTH ANALYZER
MACHINE ANALYZER
GAS ANALYZER
REAGENT SCANNERS
BODY SCANNERS
SLIME SCANNER
*/

////////////////////////////////////////
// MARK:	T-ray scanner
////////////////////////////////////////
/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 300)
	origin_tech = "magnets=1;engineering=1"
	var/on = FALSE

/obj/item/t_scanner/Destroy()
	if(on)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self__legacy__attackchain(mob/user)
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer))
		if(O.level != 1)
			continue

		if(O.invisibility == INVISIBILITY_MAXIMUM)
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			if(MA.layer < TURF_LAYER)
				MA.layer += TRAY_SCAN_LAYER_OFFSET
			MA.plane = GAME_PLANE
			I.appearance = MA
			t_ray_images += I
	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

////////////////////////////////////////
// MARK:	Health analyzer
////////////////////////////////////////
#define SIMPLE_HEALTH_SCAN 0
#define DETAILED_HEALTH_SCAN 1

/proc/get_chemscan_results(mob/living/user, mob/living/M)
	var/msgs = list()
	if(!ishuman(M))
		return

	var/hallucinating = HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING)

	var/mob/living/carbon/human/H = M
	var/has_real_or_fake_reagents = FALSE
	if(length(H.reagents.reagent_list))
		has_real_or_fake_reagents = TRUE
		msgs += "<span class='boldnotice'>Subject contains the following reagents:</span>"
		for(var/datum/reagent/R in H.reagents.reagent_list)
			var/volume = R.volume
			var/overdosing = R.overdosed

			if(hallucinating)
				if(prob(20))
					// make reagents look like they may exist in really crazy amounts, but also disappear
					volume = max(rand(hallucinating - 10, hallucinating + 100), 0)
				if(!volume)
					continue
				if(!overdosing)
					overdosing = prob(10)

			msgs += "<span class='notice'>[volume]u of [R.name][overdosing ? "</span> - <span class='boldannounceic'>OVERDOSING</span>" : ".</span>"]"

	if(hallucinating && prob(10))
		has_real_or_fake_reagents = TRUE
		if(!length(H.reagents.reagent_list))
			msgs += "<span class='boldnotice'>Subject contains the following reagents:</span>"
			for(var/i in 1 to rand(1, 2))
				var/reagent_name = pick(GLOB.chemical_reagents_list)
				msgs += "<span class='notice'>[rand(5, 100)]u of [GLOB.chemical_reagents_list[reagent_name]][prob(30) ? "</span> - <span class='boldannounceic'>OVERDOSING</span>" : ".</span>"]"

	if(!has_real_or_fake_reagents)
		msgs += "<span class='notice'>Subject contains no reagents.</span>"

	if(length(H.reagents.addiction_list))
		msgs += "<span class='danger'>Subject is addicted to the following reagents:</span>"
		for(var/datum/reagent/R in H.reagents.addiction_list)
			msgs += "<span class='danger'>[R.name] Stage: [R.addiction_stage]/5</span>"

	if(hallucinating && prob(10))
		if(!length(H.reagents.addiction_list))
			msgs += "<span class='danger'>Subject is addicted to the following reagents:</span>"
		// try to add two random chems
		for(var/i in 1 to rand(1, 2))
			var/reagent_name = pick(GLOB.chemical_reagents_list)
			msgs += "<span class='danger'>[GLOB.chemical_reagents_list[reagent_name]] Stage: [rand(1, 5)]/5</span>"

	return msgs

/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/list/results = get_chemscan_results(user, M)
		to_chat(user, results.Join("<br>"))

/obj/item/healthanalyzer
	name = "health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	worn_icon_state = "healthanalyzer"
	inhand_icon_state = "healthanalyzer"
	belt_icon = "health_analyzer"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	/// Can be SIMPLE_HEALTH_SCAN (damage is only shown as a single % value), or DETAILED_HEALTH_SCAN (shows the % value and also damage for every specific limb).
	var/mode = DETAILED_HEALTH_SCAN
	/// Is the health analyzer upgraded? Allows reagents in the body to be seen.
	var/advanced = FALSE

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use [src] in hand to toggle showing localised damage.</span>"

/obj/item/healthanalyzer/attack_self__legacy__attackchain(mob/user)
	mode = !mode
	switch(mode)
		if(DETAILED_HEALTH_SCAN)
			to_chat(user, "<span class='notice'>The scanner is now showing localised limb damage.</span>")
		if(SIMPLE_HEALTH_SCAN)
			to_chat(user, "<span class='notice'>The scanner is no longer showing localised limb damage.</span>")

/obj/item/healthanalyzer/attack__legacy__attackchain(mob/living/M, mob/living/user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		var/list/msgs = list()
		user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", "<span class='notice'>You stupidly try to analyze the floor's vitals!</span>")
		msgs += "<span class='notice'>Analyzing results for The floor:\nOverall status: Healthy</span>"
		msgs += "<span class='notice'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burn</font>/<font color='red'>Brute</font></span>"
		msgs += "<span class='notice'>Damage specifics: <font color='blue'>0</font> - <font color='green'>0</font> - <font color='#FFA500'>0</font> - <font color='red'>0</font></span>"
		msgs += "<span class='notice'>Body temperature: ???</span>"
		to_chat(user, chat_box_healthscan(msgs.Join("<br>")))
		return

	user.visible_message(
		"<span class='notice'>[user] analyzes [M]'s vitals.</span>",
		"<span class='notice'>You analyze [M]'s vitals.</span>"
	)
	healthscan(user, M, mode, advanced)
	add_fingerprint(user)

// Used by the PDA medical scanner too.
/proc/healthscan(mob/user, mob/living/M, mode = DETAILED_HEALTH_SCAN, advanced = FALSE)
	var/list/msgs = list()

	var/scanned_name = "[M]"

	var/probably_dead = (M.stat == DEAD)

	// show your own health, evil
	if(HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5))
		M = user

	if(HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(10) && IS_HORIZONTAL(M))
		probably_dead = TRUE

	if(isanimal_or_basicmob(M))
		// No box here, keep it simple.
		if(probably_dead)
			to_chat(user, "<span class='notice'>Analyzing Results for [M]:\nOverall Status: <font color='red'>Dead</font></span>")
			return

		to_chat(user, "<span class='notice'>Analyzing Results for [M]:\nOverall Status: [round(M.health / M.maxHealth * 100, 0.1)]% Healthy")
		to_chat(user, "\t Damage Specifics: <font color='red'>[M.maxHealth - M.health]</font>")
		return

	// These sensors are designed for organic life.
	if(!ishuman(M) || ismachineperson(M) || (HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5)))
		msgs += "<span class='notice'>Analyzing Results for ERROR:\nOverall Status: ERROR</span>"
		msgs += "Key: <span class='healthscan_oxy'>Suffocation</span>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>"
		msgs += "Damage Specifics: <span class='healthscan_oxy'>?</span> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>"
		msgs += "<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>"
		msgs += "<span class='warning'><b>Warning: Blood Level ERROR: --% --cl.</span><span class='notice'>Type: ERROR</span>"
		msgs += "<span class='notice'>Subject's pulse: <font color='red'>-- bpm.</font></span>"
		to_chat(user, chat_box_healthscan(msgs.Join("<br>")))
		return

	var/mob/living/carbon/human/H = M
	var/fake_oxy = max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))
	var/OX = H.getOxyLoss()
	var/TX = H.getToxLoss()
	var/BU = H.getFireLoss()
	var/BR = H.getBruteLoss()

	// adjust health randomly if hallucinating
	if(HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5))
		var/list/healths = list(OX, TX, BU, BR)
		shuffle_inplace(healths)
		OX = healths[1]
		TX = healths[2]
		BU = healths[3]
		BR = healths[4]

	OX = OX > 50 ? "<b>[OX]</b>" : OX
	TX = TX > 50 ? "<b>[TX]</b>" : TX
	BU = BU > 50 ? "<b>[BU]</b>" : BU
	BR = BR > 50 ? "<b>[BR]</b>" : BR

	var/status = "<font color='red'>Dead</font>" // Dead by default to make it simpler
	var/DNR = !H.ghost_can_reenter() // If the ghost can't reenter
	if(H.stat == DEAD)
		if(DNR)
			status = "<font color='red'>Dead <b>(DNR)</b></font>"
	else // Alive or unconscious
		if(HAS_TRAIT(H, TRAIT_FAKEDEATH) || probably_dead) // status still shows as "Dead"
			OX = fake_oxy > 50 ? "<b>[fake_oxy]</b>" : fake_oxy
		else
			status = "[H.health]% Healthy"

	msgs += "<span class='notice'>Analyzing Results for [scanned_name]:\nOverall Status: [status]"
	msgs += "Key: <span class='healthscan_oxy'>Suffocation</span>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>"
	msgs += "Damage Specifics: <span class='healthscan_oxy'>[OX]</span> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>"

	if(H.timeofdeath && (H.stat == DEAD || (HAS_TRAIT(H, TRAIT_FAKEDEATH)) || probably_dead))
		var/tod = probably_dead && (HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(10)) ? world.time - rand(10, 5000) : H.timeofdeath  // Sure let's blow it out
		msgs += "<span class='notice'>Time of Death: [station_time_timestamp("hh:mm:ss", tod)]</span>"
		var/tdelta = round(world.time - tod)
		if(H.is_revivable() && !DNR)
			msgs += "<span class='danger'>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</span>"
		else
			msgs += "<font color='red'>Subject died [DisplayTimeText(tdelta)] ago. <b>Defibrillation is not possible!</b></font>"

	if(mode == DETAILED_HEALTH_SCAN)
		var/list/damaged = H.get_damaged_organs(1,1)
		if(length(damaged))
			msgs += "<span class='notice'>Localized Damage, Brute/Burn:</span>"
			for(var/obj/item/organ/external/org in damaged)
				msgs += "<span class='notice'>[capitalize(org.name)]: [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : "<font color='red'>0</font>"]-[(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"]"

	if(advanced)
		msgs.Add(get_chemscan_results(user, H))

	for(var/thing in H.viruses)
		var/datum/disease/D = thing
		// If the disease is incubating, or if it's stealthy and hasn't been put into a pandemic yet the scanner won't see it
		if(D.incubation || (D.visibility_flags & VIRUS_HIDDEN_SCANNER && !(D.GetDiseaseID() in GLOB.detected_advanced_diseases["[user.z]"])))
			continue
		// Snowflaking heart problems, because they are special (and common).
		if(istype(D, /datum/disease/critical))
			msgs += "<span class='notice'><font color='red'><b>Warning: Subject is undergoing [D.name].</b>\nStage: [D.stage]/[D.max_stages].\nCure: [D.cure_text]</font></span>"
			continue
		if(istype(D, /datum/disease/advance))
			var/datum/disease/advance/A = D
			if(!(A.id in GLOB.known_advanced_diseases[num2text(user.z)]))
				msgs += "<span class='notice'><font color='red'><b>Warning: Unknown viral strain detected</b>\nStrain:[A.strain]\nStage: [A.stage]</span>"
			else
				msgs += "<span class='notice'><font color='red'><b>Warning: [A.form] detected</b>\nName: [A.name].\nStrain:[A.strain]\nType: [A.spread_text].\nStage: [A.stage]/[A.max_stages].\nPossible Cures: [A.cure_text]\nNeeded Cures: [A.cures_required]</font></span>"
			continue
		msgs += "<span class='notice'><font color='red'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</font></span>"

	if(H.undergoing_cardiac_arrest())
		var/datum/organ/heart/heart = H.get_int_organ_datum(ORGAN_DATUM_HEART)
		if(heart && !(heart.linked_organ.status & ORGAN_DEAD))
			msgs += "<span class='notice'><font color='red'><b>The patient's heart has stopped.</b>\nPossible Cure: Electric Shock</font>"
		else if(heart && (heart.linked_organ.status & ORGAN_DEAD))
			msgs += "<span class='notice'><font color='red'><b>Subject's heart is necrotic.</b></font>"
		else if(!heart)
			msgs += "<span class='notice'><font color='red'><b>Subject has no heart.</b></font>"

	if(H.getStaminaLoss() || HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5))
		msgs += "<span class='notice'>Subject appears to be suffering from fatigue.</span>"

	if(H.getCloneLoss() || (HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5)))
		msgs += "<span class='warning'>Subject appears to have [H.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>"

	// Brain.
	var/obj/item/organ/internal/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(brain)
		if(H.check_brain_threshold(BRAIN_DAMAGE_RATIO_CRITICAL)) // 100
			msgs += "<span class='warning'>Subject is brain dead.</span>"
		else if(H.check_brain_threshold(BRAIN_DAMAGE_RATIO_MODERATE)) // 60
			msgs += "<span class='warning'>Severe brain damage detected. Subject likely to have dementia.</span>"
		else if(H.check_brain_threshold(BRAIN_DAMAGE_RATIO_MINOR)) // 10
			msgs += "<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>"
	else
		msgs += "<span class='warning'>Subject has no brain.</span>"

	// Broken bones, internal bleeding, infection, and critical burns.
	var/broken_bone = FALSE
	var/internal_bleed = FALSE
	var/burn_wound = FALSE
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.status & ORGAN_BROKEN)
			if((e.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")) && !(e.status & ORGAN_SPLINTED))
				msgs += "<span class='warning'>Unsecured fracture in subject [limb]. Splinting recommended for transport.</span>"
			broken_bone = TRUE
		if(e.has_infected_wound())
			msgs += "<span class='warning'>Infected wound detected in subject [limb]. Disinfection recommended.</span>"
		burn_wound = burn_wound || (e.status & ORGAN_BURNT)
		internal_bleed = internal_bleed || (e.status & ORGAN_INT_BLEEDING)
	if(broken_bone)
		msgs += "<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span>"
	if(internal_bleed)
		msgs += "<span class='warning'>Internal bleeding detected. Advanced scanner required for location.</span>"
	if(burn_wound)
		msgs += "<span class='warning'>Critical burn detected. Examine patient's body for location.</span>"

	if(HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5))
		var/list/spooky_conditions = list(
			"<span class='dead'>Patient appears to be infested.</span>",
			"<span class='dead'>Patient's bones are hollow.</span>",
			"<span class='dead'>Patient has limited attachment to this physical plane.</span>",
			"<span class='userdanger'>Patient is aggressive. Immediate sedation recommended.</span>",
			"<span class='warning'>Patient's vitamin D levels are dangerously low.</span>",
			"<span class='warning'>Patient's spider levels are dangerously low.</span>",
			"<span class='dead'>Subject is ready for experimentation.</span>",
		)
		msgs += pick(spooky_conditions)

	if(HAS_TRAIT(user, TRAIT_MED_MACHINE_HALLUCINATING) && prob(5) && (H.stat == DEAD || (HAS_TRAIT(H, TRAIT_FAKEDEATH))))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), user, "<span class='danger'>[H]'s head snaps to look at you.</span>"), rand(1 SECONDS, 3 SECONDS))

	// Blood.
	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			msgs += "<span class='danger'>Subject is bleeding!</span>"
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_volume = round(H.blood_volume)
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id
		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			msgs += "<span class='danger'>LOW blood level [blood_percent] %, [blood_volume] cl,</span> <span class='notice'>type: [blood_type]</span>"
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			msgs += "<span class='danger'>CRITICAL blood level [blood_percent] %, [blood_volume] cl,</span> <span class='notice'>type: [blood_type]</span>"
		else
			msgs += "<span class='notice'>Blood level [blood_percent] %, [blood_volume] cl, type: [blood_type]</span>"

	msgs += "<span class='notice'>Body Temperature: [round(H.bodytemperature-T0C, 0.01)]&deg;C ([round(H.bodytemperature*1.8-459.67, 0.01)]&deg;F)</span>"
	msgs += "<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse()] bpm.</font></span>"

	var/implant_detect
	for(var/obj/item/organ/internal/O in H.internal_organs)
		if(O.is_robotic() && !O.stealth_level)
			implant_detect += "[O.name].<br>"
	if(implant_detect)
		msgs += "<span class='notice'>Detected cybernetic modifications:</span>"
		msgs += "<span class='notice'>[implant_detect]</span>"

	// Do you have too many genetics superpowers?
	if(H.gene_stability < 40)
		msgs += "<span class='userdanger'>Subject's genes are quickly breaking down!</span>"
	else if(H.gene_stability < 70)
		msgs += "<span class='danger'>Subject's genes are showing signs of spontaneous breakdown.</span>"
	else if(H.gene_stability < 85)
		msgs += "<span class='warning'>Subject's genes are showing minor signs of instability.</span>"

	if(HAS_TRAIT(H, TRAIT_HUSK))
		msgs += "<span class='danger'>Subject is husked. Application of synthflesh is recommended.</span>"

	if(H.radiation > RAD_MOB_SAFE)
		msgs += "<span class='danger'>Subject is irradiated.</span>"

	msgs += "<span class='notice'>Biological Age: [H.age]</span>"

	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))

/obj/item/healthanalyzer/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/healthupgrade))
		return ..()

	if(advanced)
		to_chat(user, "<span class='notice'>An upgrade is already installed on [src].</span>")
		return

	if(!user.unequip(I))
		to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
		return

	to_chat(user, "<span class='notice'>You install the upgrade on [src].</span>")
	add_overlay("advanced")
	playsound(loc, I.usesound, 50, TRUE)
	advanced = TRUE
	qdel(I)

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	advanced = TRUE

/obj/item/healthanalyzer/advanced/Initialize(mapload)
	. = ..()
	add_overlay("advanced")


/obj/item/healthupgrade
	name = "Health Analyzer Upgrade"
	desc = "An upgrade unit that can be installed on a health analyzer for expanded functionality."
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/deconstruct.ogg'

#undef SIMPLE_HEALTH_SCAN
#undef DETAILED_HEALTH_SCAN

////////////////////////////////////////
// MARK:	Machine analyzer
////////////////////////////////////////
/obj/item/robotanalyzer
	name = "machine analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries and the condition of machinery."
	icon = 'icons/obj/device.dmi'
	icon_state = "robotanalyzer"
	inhand_icon_state = "analyzer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"

/obj/item/robotanalyzer/proc/handle_clumsy(mob/living/user)
	var/list/msgs = list()
	user.visible_message("<span class='warning'>[user] has analyzed the floor's components!</span>", "<span class='warning'>You try to analyze the floor's vitals!</span>")
	msgs += "<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Unknown</span>"
	msgs += "<span class='notice'>\t Damage Specifics: <font color='#FFA500'>[0]</font>/<font color='red'>[0]</font></span>"
	msgs += "<span class='notice'>Key: <font color='#FFA500'>Burns</font><font color ='red'>/Brute</font></span>"
	msgs += "<span class='notice'>Chassis Temperature: ???</span>"
	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))

/obj/item/robotanalyzer/attack_obj__legacy__attackchain(obj/machinery/M, mob/living/user) // Scanning a machine object
	if(!ismachinery(M))
		return
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		handle_clumsy(user)
		return
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s components with [src].</span>", "<span class='notice'>You analyze [M]'s components with [src].</span>")
	machine_scan(user, M)
	add_fingerprint(user)

/obj/item/robotanalyzer/proc/machine_scan(mob/user, obj/machinery/M)
	if(M.obj_integrity == M.max_integrity)
		to_chat(user, "<span class='notice'>[M] is at full integrity.</span>")
		return
	to_chat(user, "<span class='notice'>Structural damage detected! [M]'s overall estimated integrity is [round((M.obj_integrity / M.max_integrity) * 100)]%.</span>")
	if(M.stat & BROKEN) // Displays alongside above message. Machines with a "broken" state do not become broken at 0% HP - anything that reaches that point is destroyed
		to_chat(user, "<span class='warning'>Further analysis: Catastrophic component failure detected! [M] requires reconstruction to fully repair.</span>")

/obj/item/robotanalyzer/attack__legacy__attackchain(mob/living/M, mob/living/user) // Scanning borgs, IPCs/augmented crew, and AIs
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		handle_clumsy(user)
		return
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s components with [src].</span>", "<span class='notice'>You analyze [M]'s components with [src].</span>")
	robot_healthscan(user, M)
	add_fingerprint(user)

/proc/robot_healthscan(mob/user, mob/living/M)
	var/scan_type
	var/list/msgs = list()
	if(isrobot(M))
		scan_type = "robot"
	else if(ishuman(M))
		scan_type = "prosthetics"
	else if(is_ai(M))
		scan_type = "ai"
	else
		to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
		return

	switch(scan_type)
		if("robot")
			var/burn = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/brute = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			msgs += "<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat == DEAD ? "fully disabled" : "[M.health]% functional"]</span>"
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += "\t Damage Specifics: <font color='#FFA500'>[burn]</font> - <font color='red'>[brute]</font>"
			if(M.timeofdeath && M.stat == DEAD)
				msgs += "<span class='notice'>Time of disable: [station_time_timestamp("hh:mm:ss", M.timeofdeath)]</span>"
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(TRUE, TRUE, TRUE) // Get all except the missing ones
			var/list/missing = H.get_missing_components()
			msgs += "<span class='notice'>Localized Damage:</span>"
			if(!LAZYLEN(damaged) && !LAZYLEN(missing))
				msgs += "<span class='notice'>\t Components are OK.</span>"
			else
				if(LAZYLEN(damaged))
					for(var/datum/robot_component/org in damaged)
						msgs += text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
						capitalize(org.name),					\
						(org.is_destroyed())	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
						(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
						(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
						(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
						(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>")
				if(LAZYLEN(missing))
					for(var/datum/robot_component/org in missing)
						msgs += "<span class='warning'>\t [capitalize(org.name)]: MISSING</span>"

			if(H.emagged && prob(5))
				msgs += "<span class='warning'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>"

		if("prosthetics")
			var/mob/living/carbon/human/H = M
			var/is_ipc = ismachineperson(H)
			msgs += "<span class='notice'>Analyzing Results for [M]: [is_ipc ? "\n\t Overall Status: [H.stat == DEAD ? "fully disabled" : "[H.health]% functional"]</span><hr>" : "<hr>"]" //for the record im sorry
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += "<span class='notice'>External prosthetics:</span>"
			var/organ_found
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/external/E in H.bodyparts)
					if(!E.is_robotic() || (is_ipc && (E.get_damage() == 0))) //Non-IPCs have their cybernetics show up in the scan, even if undamaged
						continue
					organ_found = TRUE
					msgs += "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#FFA500'>[E.burn_dam]</font>"
			if(!organ_found)
				msgs += "<span class='warning'>No prosthetics located.</span>"
			msgs += "<hr>"
			msgs += "<span class='notice'>Internal prosthetics:</span>"
			organ_found = null
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/internal/O in H.internal_organs)
					if(!O.is_robotic() || istype(O, /obj/item/organ/internal/cyberimp) || O.stealth_level > 1)
						continue
					organ_found = TRUE
					msgs += "[capitalize(O.name)]: <font color='red'>[O.status & ORGAN_DEAD ? "CRITICAL FAILURE" : O.damage]</font>"
			if(!organ_found)
				msgs += "<span class='warning'>No prosthetics located.</span>"
			msgs += "<hr>"
			msgs += "<span class='notice'>Cybernetic implants:</span>"
			organ_found = null
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
					if(I.stealth_level > 1)
						continue
					organ_found = TRUE
					msgs += "[capitalize(I.name)]: <font color='red'>[(I.crit_fail || I.status & ORGAN_DEAD) ? "CRITICAL FAILURE" : I.damage]</font>"
			if(!organ_found)
				msgs += "<span class='warning'>No implants located.</span>"
			msgs += "<hr>"
			if(is_ipc)
				msgs.Add(get_chemscan_results(user, H))
			msgs += "<span class='notice'>Subject temperature: [round(H.bodytemperature-T0C, 0.01)]&deg;C ([round(H.bodytemperature*1.8-459.67, 0.01)]&deg;F)</span>"
		if("ai")
			var/mob/living/silicon/ai/A = M
			var/burn = A.getFireLoss() > 50 	? 	"<b>[A.getFireLoss()]</b>" 		: A.getFireLoss()
			var/brute = A.getBruteLoss() > 50 	? 	"<b>[A.getBruteLoss()]</b>" 	: A.getBruteLoss()
			msgs += "<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [A.stat == DEAD ? "fully disabled" : "[A.health]% functional"]</span>"
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += "\t Damage Specifics: <font color='#FFA500'>[burn]</font> - <font color='red'>[brute]</font>"

	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))

////////////////////////////////////////
// MARK:	Gas analyzer
////////////////////////////////////////
/obj/item/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	inhand_icon_state = "analyzer"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throw_speed = 3
	materials = list(MAT_METAL = 210, MAT_GLASS = 140)
	origin_tech = "magnets=1;engineering=1"
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.
	/// FALSE: Sum gas mixes then present. TRUE: Present each mix individually
	var/show_detailed = FALSE

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click [src] to activate the barometer function.</span>"
	. += "<span class='notice'>Alt-Shift-click [src] to toggle detailed reporting on or off.</span>"

/obj/item/analyzer/attack_self__legacy__attackchain(mob/user as mob)

	if(user.stat)
		return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	atmos_scan(user = user, target = location, detailed = show_detailed)
	add_fingerprint(user)

/obj/item/analyzer/AltShiftClick(mob/user)
	show_detailed = !show_detailed
	to_chat(user, "<span class='notice'>You toggle detailed reporting [show_detailed ? "on" : "off"]</span>")

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	..()

	if(!user.incapacitated() && Adjacent(user))

		if(cooldown)
			to_chat(user, "<span class='warning'>[src]'s barometer function is preparing itself.</span>")
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, "<span class='warning'>[src]'s barometer function won't work indoors!</span>")
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && is_type_in_list(user_area, W.area_types) && !(W.stage == WEATHER_END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == WEATHER_MAIN_STAGE) || (ongoing_weather.stage == WEATHER_WIND_DOWN_STAGE))
				to_chat(user, "<span class='warning'>[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == WEATHER_MAIN_STAGE ? "already here!" : "winding down."]</span>")
				return

			to_chat(user, "<span class='notice'>The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)].</span>")
			if(ongoing_weather.aesthetic)
				to_chat(user, "<span class='warning'>[src]'s barometer function says that the next storm will breeze on by.</span>")
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, "<span class='warning'>[src]'s barometer function was unable to trace any weather patterns.</span>")
			else
				to_chat(user, "<span class='warning'>[src]'s barometer function says a storm will land in approximately [butchertime(fixed)].</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(ping)), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='notice'>[src]'s barometer function is ready!</span>")
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy * (1 / 3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1, amount))

/obj/item/analyzer/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	. = ..()
	if(!can_see(user, target, 1))
		return
	if(target.return_analyzable_air())
		atmos_scan(user, target, detailed = show_detailed)
	else
		atmos_scan(user, get_turf(target), detailed = show_detailed)

/**
 * Outputs a message to the user describing the target's gasmixes.
 * Used in chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent = FALSE, print = TRUE, milla_turf_details = FALSE, detailed = FALSE)
	var/list/airs
	var/list/milla = null
	if(milla_turf_details && istype(target, /turf))
		// This is one of the few times when it's OK to call MILLA directly, as we need more information than we normally keep, aren't trying to modify it, and don't need it to be synchronized with anything.
		milla = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(target, milla)

		var/datum/gas_mixture/air = new()
		air.copy_from_milla(milla)
		airs = list(air)
	else
		airs = target.return_analyzable_air()
		if(!airs)
			return FALSE
		if(!islist(airs))
			airs = list(airs)

	var/list/message = list()
	if(!silent && isliving(user))
		user.visible_message("<span class='notice'>[user] uses the analyzer on [target].</span>", "<span class='notice'>You use the analyzer on [target].</span>")
	message += "<span class='boldnotice'>Results of analysis of [bicon(target)] [target].</span>"

	if(!print)
		return TRUE
	var/total_moles = 0
	var/pressure = 0
	var/volume = 0
	var/heat_capacity = 0
	var/thermal_energy = 0
	var/oxygen = 0
	var/nitrogen = 0
	var/toxins
	var/carbon_dioxide = 0
	var/sleeping_agent = 0
	var/agent_b = 0

	if(detailed)// Present all mixtures one by one
		for(var/datum/gas_mixture/air as anything in airs)
			total_moles = air.total_moles()
			pressure = air.return_pressure()
			volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
			heat_capacity = air.heat_capacity()
			thermal_energy = air.thermal_energy()
			if(total_moles)
				message += "<span class='notice'>Total: [round(total_moles, 0.01)] moles</span>"
				if(air.oxygen() && (milla_turf_details || air.oxygen() / total_moles > 0.01))
					message += "  <span class='oxygen'>Oxygen: [round(air.oxygen(), 0.01)] moles ([round(air.oxygen() / total_moles * 100, 0.01)] %)</span>"
				if(air.nitrogen() && (milla_turf_details || air.nitrogen() / total_moles > 0.01))
					message += "  <span class='nitrogen'>Nitrogen: [round(air.nitrogen(), 0.01)] moles ([round(air.nitrogen() / total_moles * 100, 0.01)] %)</span>"
				if(air.carbon_dioxide() && (milla_turf_details || air.carbon_dioxide() / total_moles > 0.01))
					message += "  <span class='carbon_dioxide'>Carbon Dioxide: [round(air.carbon_dioxide(), 0.01)] moles ([round(air.carbon_dioxide() / total_moles * 100, 0.01)] %)</span>"
				if(air.toxins() && (milla_turf_details || air.toxins() / total_moles > 0.01))
					message += "  <span class='plasma'>Plasma: [round(air.toxins(), 0.01)] moles ([round(air.toxins() / total_moles * 100, 0.01)] %)</span>"
				if(air.sleeping_agent() && (milla_turf_details || air.sleeping_agent() / total_moles > 0.01))
					message += "  <span class='sleeping_agent'>Nitrous Oxide: [round(air.sleeping_agent(), 0.01)] moles ([round(air.sleeping_agent() / total_moles * 100, 0.01)] %)</span>"
				if(air.agent_b() && (milla_turf_details || air.agent_b() / total_moles > 0.01))
					message += "  <span class='agent_b'>Agent B: [round(air.agent_b(), 0.01)] moles ([round(air.agent_b() / total_moles * 100, 0.01)] %)</span>"
				message += "<span class='notice'>Temperature: [round(air.temperature()-T0C)] &deg;C ([round(air.temperature())] K)</span>"
				message += "<span class='notice'>Volume: [round(volume)] Liters</span>"
				message += "<span class='notice'>Pressure: [round(pressure, 0.1)] kPa</span>"
				message += "<span class='notice'>Heat Capacity: [DisplayJoules(heat_capacity)] / K</span>"
				message += "<span class='notice'>Thermal Energy: [DisplayJoules(thermal_energy)]</span>"
			else
				message += "<span class='notice'>[target] is empty!</span>"
				message += "<span class='notice'>Volume: [round(volume)] Liters</span>" // don't want to change the order volume appears in, suck it

	else// Sum mixtures then present
		for(var/datum/gas_mixture/air as anything in airs)
			if(isnull(air))
				continue
			total_moles += air.total_moles()
			volume += air.return_volume()
			heat_capacity += air.heat_capacity()
			thermal_energy += air.thermal_energy()
			oxygen += air.oxygen()
			nitrogen += air.nitrogen()
			toxins += air.toxins()
			carbon_dioxide += air.carbon_dioxide()
			sleeping_agent += air.sleeping_agent()
			agent_b += air.agent_b()

		var/temperature = heat_capacity ? thermal_energy / heat_capacity : 0
		pressure = volume ? total_moles * R_IDEAL_GAS_EQUATION * temperature / volume : 0

		if(total_moles)
			message += "<span class='notice'>Total: [round(total_moles, 0.01)] moles</span>"
			if(oxygen && (milla_turf_details || oxygen / total_moles > 0.01))
				message += "  <span class='oxygen'>Oxygen: [round(oxygen, 0.01)] moles ([round(oxygen / total_moles * 100, 0.01)] %)</span>"
			if(nitrogen && (milla_turf_details || nitrogen / total_moles > 0.01))
				message += "  <span class='nitrogen'>Nitrogen: [round(nitrogen, 0.01)] moles ([round(nitrogen / total_moles * 100, 0.01)] %)</span>"
			if(carbon_dioxide && (milla_turf_details || carbon_dioxide / total_moles > 0.01))
				message += "  <span class='carbon_dioxide'>Carbon Dioxide: [round(carbon_dioxide, 0.01)] moles ([round(carbon_dioxide / total_moles * 100, 0.01)] %)</span>"
			if(toxins && (milla_turf_details || toxins / total_moles > 0.01))
				message += "  <span class='plasma'>Plasma: [round(toxins, 0.01)] moles ([round(toxins / total_moles * 100, 0.01)] %)</span>"
			if(sleeping_agent && (milla_turf_details || sleeping_agent / total_moles > 0.01))
				message += "  <span class='sleeping_agent'>Nitrous Oxide: [round(sleeping_agent, 0.01)] moles ([round(sleeping_agent / total_moles * 100, 0.01)] %)</span>"
			if(agent_b && (milla_turf_details || agent_b / total_moles > 0.01))
				message += "  <span class='agent_b'>Agent B: [round(agent_b, 0.01)] moles ([round(agent_b / total_moles * 100, 0.01)] %)</span>"
			message += "<span class='notice'>Temperature: [round(temperature-T0C)] &deg;C ([round(temperature)] K)</span>"
			message += "<span class='notice'>Volume: [round(volume)] Liters</span>"
			message += "<span class='notice'>Pressure: [round(pressure, 0.1)] kPa</span>"
			message += "<span class='notice'>Heat Capacity: [DisplayJoules(heat_capacity)] / K</span>"
			message += "<span class='notice'>Thermal Energy: [DisplayJoules(thermal_energy)]</span>"
		else
			message += "<span class='notice'>[target] is empty!</span>"
			message += "<span class='notice'>Volume: [round(volume)] Liters</span>" // don't want to change the order volume appears in, suck it

	if(milla)
		// Values from milla/src/lib.rs, +1 due to array indexing difference.
		message += "<span class='notice'>Airtight N/E/S/W: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_NORTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_EAST) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_SOUTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_WEST) ? "yes" : "no"]</span>"
		switch(milla[MILLA_INDEX_ATMOS_MODE])
			// These are enum values, so they don't get increased.
			if(0)
				message += "<span class='notice'>Atmos Mode: Space</span>"
			if(1)
				message += "<span class='notice'>Atmos Mode: Sealed</span>"
			if(2)
				message += "<span class='notice'>Atmos Mode: Exposed to Environment (ID: [milla[MILLA_INDEX_ENVIRONMENT_ID]])</span>"
			else
				message += "<span class='notice'>Atmos Mode: Unknown ([milla[MILLA_INDEX_ATMOS_MODE]]), contact a coder.</span>"
		message += "<span class='notice'>Superconductivity N/E/S/W: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_NORTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_EAST]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_WEST]]</span>"
		message += "<span class='notice'>Turf's Innate Heat Capacity: [milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]]</span>"
		message += "<span class='notice'>Hotspot: [floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE]-T0C)] &deg;C ([floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE])] K), [round(milla[MILLA_INDEX_HOTSPOT_VOLUME] * CELL_VOLUME, 1)] Liters ([milla[MILLA_INDEX_HOTSPOT_VOLUME]]x)</span>"
		message += "<span class='notice'>Wind: ([round(milla[MILLA_INDEX_WIND_X], 0.001)], [round(milla[MILLA_INDEX_WIND_Y], 0.001)])</span>"
		message += "<span class='notice'>Fuel burnt last tick: [milla[MILLA_INDEX_FUEL_BURNT]] moles</span>"

	to_chat(user, chat_box_examine(message.Join("<br>")))
	return TRUE

////////////////////////////////////////
// MARK:	Reagent scanners
////////////////////////////////////////
/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=300, MAT_GLASS=200)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/reagent_scanner/afterattack__legacy__attackchain(obj/O, mob/user as mob)
	if(user.stat)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		var/blood_type = ""
		if(length(O.reagents.reagent_list) > 0)
			var/one_percent = O.reagents.total_volume / 100
			for(var/datum/reagent/R in O.reagents.reagent_list)
				if(R.id != "blood")
					dat += "<br>[TAB]<span class='notice'>[R] [details ? ":([R.volume / one_percent]%)" : ""]</span>"
				else
					blood_type = R.data["blood_type"]
					dat += "<br>[TAB]<span class='notice'>[blood_type ? "[blood_type]" : ""] [R.data["species"]] [R.name] [details ? ":([R.volume / one_percent]%)" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
			datatoprint = dat
			scanning = FALSE
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")
	return

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/reagent_scanner/proc/print_report()
	if(!scanning)
		usr.visible_message("<span class='warning'>[src] rattles and prints out a sheet of paper.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		sleep(50)

		var/obj/item/paper/P = new(get_turf(src))
		P.name = "Reagent Scanner Report: [station_time_timestamp()]"
		P.info = "<center><b>Reagent Scanner</b></center><br><center>Data Analysis:</center><br><hr><br><b>Chemical agents detected:</b><br> [datatoprint]<br><hr>"

		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(P)
			to_chat(M, "<span class='notice'>Report printed. Log cleared.</span>")
			datatoprint = ""
			scanning = TRUE
	else
		to_chat(usr, "<span class='notice'>[src]  has no logs or is already in use.</span>")

/obj/item/reagent_scanner/ui_action_click()
	print_report()

////////////////////////////////////////
// MARK:	Slime scanner
////////////////////////////////////////
/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	inhand_icon_state = "analyzer"
	origin_tech = "biotech=2"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throw_speed = 3
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack__legacy__attackchain(mob/living/M, mob/living/user)
	if(user.incapacitated() || user.AmountBlinded())
		return
	if(!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	slime_scan(M, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, "<span class='notice'>[T.colour] [T.is_adult ? "adult" : "baby"] slime</span>")
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if(T.nutrition < T.get_starve_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is starving!</span>")
	else if(T.nutrition < T.get_hunger_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is hungry</span>")
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if(T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if(T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	if(T.effectmod)
		to_chat(user, "<span class='notice'>Core mutation in progress: [T.effectmod]</span>")
		to_chat(user, "<span class='notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>")
	to_chat(user, "========================")

////////////////////////////////////////
// MARK:	Body analyzers
////////////////////////////////////////
/obj/item/bodyanalyzer
	name = "handheld body analyzer"
	desc = "A handheld scanner capable of deep-scanning an entire body."
	icon = 'icons/obj/device.dmi'
	icon_state = "bodyanalyzer_0"
	worn_icon_state = "healthanalyzer"
	inhand_icon_state = "healthanalyzer"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=6;biotech=6"
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell/high
	var/ready = TRUE // Ready to scan
	var/printing = FALSE
	var/time_to_use = 0 // How much time remaining before next scan is available.
	var/usecharge = 750
	var/scan_time = 5 SECONDS //how long does it take to scan
	var/scan_cd = 30 SECONDS //how long before we can scan again

/obj/item/bodyanalyzer/get_cell()
	return cell

/obj/item/bodyanalyzer/advanced
	cell_type = /obj/item/stock_parts/cell/super // twice the charge!

/obj/item/bodyanalyzer/borg
	name = "cyborg body analyzer"
	desc = "Scan an entire body to prepare for field surgery. Consumes power for each scan."

/obj/item/bodyanalyzer/borg/syndicate
	scan_cd = 20 SECONDS

/obj/item/bodyanalyzer/New()
	..()
	cell = new cell_type(src)
	cell.give(cell.maxcharge)
	update_icon()

/obj/item/bodyanalyzer/proc/setReady()
	ready = TRUE
	playsound(src, 'sound/machines/defib_saftyon.ogg', 50, 0)
	update_icon()

/obj/item/bodyanalyzer/update_icon_state()
	if(!cell)
		icon_state = "bodyanalyzer_0"
		return
	if(ready)
		icon_state = "bodyanalyzer_1"
	else
		icon_state = "bodyanalyzer_2"

/obj/item/bodyanalyzer/update_overlays()
	. = ..()
	var/percent = cell.percent()
	var/overlayid = round(percent / 10)
	. += "bodyanalyzer_charge[overlayid]"
	if(printing)
		. += "bodyanalyzer_printing"

/obj/item/bodyanalyzer/attack__legacy__attackchain(mob/living/M, mob/living/carbon/human/user)
	if(user.incapacitated() || !user.Adjacent(M))
		return

	if(!ready)
		to_chat(user, "<span class='notice'>The scanner beeps angrily at you! It's currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining.</span>")
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return

	if(cell.charge >= usecharge)
		mobScan(M, user)
	else
		to_chat(user, "<span class='notice'>The scanner beeps angrily at you! It's out of charge!</span>")
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)

/obj/item/bodyanalyzer/borg/attack__legacy__attackchain(mob/living/M, mob/living/silicon/robot/user)
	if(user.incapacitated() || !user.Adjacent(M))
		return

	if(!ready)
		to_chat(user, "<span class='notice'>[src] is currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining.</span>")
		return

	if(user.cell.charge >= usecharge)
		mobScan(M, user)
	else
		to_chat(user, "<span class='notice'>You need to recharge before you can use [src]</span>")

/obj/item/bodyanalyzer/proc/mobScan(mob/living/M, mob/user)
	if(ishuman(M))
		var/report = generate_printing_text(M, user)
		user.visible_message("[user] begins scanning [M] with [src].", "You begin scanning [M].")
		if(do_after(user, scan_time, target = M))
			var/obj/item/paper/printout = new
			printout.info = report
			printout.name = "Scan report - [M.name]"
			playsound(user.loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			user.put_in_hands(printout)
			time_to_use = world.time + scan_cd
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.use(usecharge)
			else
				cell.use(usecharge)
			ready = FALSE
			printing = TRUE
			update_icon()
			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
			addtimer(VARSET_CALLBACK(src, printing, FALSE), 1.4 SECONDS)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), 1.5 SECONDS)
	else if(iscorgi(M) && M.stat == DEAD)
		to_chat(user, "<span class='notice'>You wonder if [M.p_they()] was a good dog. <b>[src] tells you they were the best...</b></span>") // :'(
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		ready = FALSE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
		time_to_use = world.time + scan_cd
	else
		to_chat(user, "<span class='notice'>Scanning error detected. Invalid specimen.</span>")

//Unashamedly ripped from adv_med.dm
/obj/item/bodyanalyzer/proc/generate_printing_text(mob/living/M, mob/user)
	var/dat = ""
	var/mob/living/carbon/human/target = M

	dat = "<font color='blue'><b>Target Statistics:</b></font><br>"
	var/t1
	switch(target.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 = "Conscious"
		if(UNCONSCIOUS)
			t1 = "Unconscious"
		else
			t1 = "*dead*"
	dat += "[target.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth %: [target.health], ([t1])</font><br>"

	var/found_disease = FALSE
	for(var/thing in target.viruses)
		var/datum/disease/D = thing
		if(D.visibility_flags) //If any visibility flags are on.
			continue
		found_disease = TRUE
		break
	if(found_disease)
		dat += "<font color='red'>Disease detected in target.</font><BR>"

	var/extra_font = null
	extra_font = (target.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Brute Damage %: [target.getBruteLoss()]</font><br>"

	extra_font = (target.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Respiratory Damage %: [target.getOxyLoss()]</font><br>"

	extra_font = (target.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Toxin Content %: [target.getToxLoss()]</font><br>"

	extra_font = (target.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Burn Severity %: [target.getFireLoss()]</font><br>"

	extra_font = (target.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tRadiation Level %: [target.radiation]</font><br>"

	extra_font = (target.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tGenetic Tissue Damage %: [target.getCloneLoss()]<br>"

	extra_font = (target.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tApprox. Brain Damage %: [target.getBrainLoss()]<br>"

	dat += "Paralysis Summary %: [target.IsParalyzed()] ([round(target.AmountParalyzed() / 10)] seconds left!)<br>"
	dat += "Body Temperature: [target.bodytemperature-T0C]&deg;C ([target.bodytemperature*1.8-459.67]&deg;F)<br>"

	dat += "<hr>"

	var/blood_percent =  round((target.blood_volume / BLOOD_VOLUME_NORMAL))
	blood_percent *= 100

	extra_font = (target.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tBlood Level %: [blood_percent] ([target.blood_volume] units)</font><br>"

	if(target.reagents)
		dat += "Epinephrine units: [target.reagents.get_reagent_amount("Epinephrine")] units<BR>"
		dat += "Ether: [target.reagents.get_reagent_amount("ether")] units<BR>"

		extra_font = (target.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSilver Sulfadiazine: [target.reagents.get_reagent_amount("silver_sulfadiazine")]</font><br>"

		extra_font = (target.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tStyptic Powder: [target.reagents.get_reagent_amount("styptic_powder")] units<BR>"

		extra_font = (target.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSalbutamol: [target.reagents.get_reagent_amount("salbutamol")] units<BR>"

	dat += "<hr><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/obj/item/organ/external/e in target.bodyparts)
		dat += "<tr>"
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/robot = ""
		var/imp = ""
		var/bled = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		if(e.status & ORGAN_INT_BLEEDING)
			internal_bleeding = "<br>Internal bleeding"
		if(istype(e, /obj/item/organ/external/chest) && target.is_lung_ruptured())
			lung_ruptured = "Lung ruptured:"
		if(e.status & ORGAN_SPLINTED)
			splint = "Splinted:"
		if(e.status & ORGAN_BROKEN)
			AN = "[e.broken_description]:"
		if(e.is_robotic())
			robot = "Robotic:"
		if(e.open)
			open = "Open:"
		switch(e.germ_level)
			if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
				infected = "Acute Infection++:"
			if(INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic:"

		var/unknown_body = 0
		for(var/I in e.embedded_objects)
			unknown_body++

		if(unknown_body || e.hidden)
			imp += "Unknown body present:"
		if(!AN && !open && !infected && !imp)
			AN = "None:"
		dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
		dat += "</tr>"
	for(var/obj/item/organ/internal/i in target.internal_organs)
		var/mech = i.desc
		var/infection = "None"
		switch(i.germ_level)
			if(1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFINITY)
				infection = "Acute Infection++:"

		dat += "<tr>"
		dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"
	if(HAS_TRAIT(target, TRAIT_BLIND))
		dat += "<font color='red'>Cataracts detected.</font><BR>"
	if(HAS_TRAIT(target, TRAIT_COLORBLIND))
		dat += "<font color='red'>Photoreceptor abnormalities detected.</font><BR>"
	if(HAS_TRAIT(target, TRAIT_NEARSIGHT))
		dat += "<font color='red'>Retinal misalignment detected.</font><BR>"
	if(HAS_TRAIT(target, TRAIT_PARAPLEGIC))
		dat += "<font color='red'>Lumbar nerves damaged.</font><BR>"

	return dat
