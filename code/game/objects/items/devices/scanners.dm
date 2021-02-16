/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
REAGENT SCANNER
*/
/obj/item/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"

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

/obj/item/t_scanner/attack_self(mob/user)
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
			I.appearance = MA
			t_ray_images += I
	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)


/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				to_chat(user, "<span class='notice'>Subject contains the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[R.volume]u of [R.name][R.overdosed ? "</span> - <span class = 'boldannounce'>OVERDOSING</span>" : ".</span>"]")
			else
				to_chat(user, "<span class = 'notice'>Subject contains no reagents.</span>")
			if(H.reagents.addiction_list.len)
				to_chat(user, "<span class='danger'>Subject is addicted to the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					to_chat(user, "<span class='danger'>[R.name] Stage: [R.addiction_stage]/5</span>")
			else
				to_chat(user, "<span class='notice'>Subject is not addicted to any reagents.</span>")

/obj/item/healthanalyzer
	name = "Health Analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/advanced = FALSE

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/user)
	if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", "<span class='notice'>You stupidly try to analyze the floor's vitals!</span>")
		to_chat(user, "<span class='info'>Analyzing results for The floor:\n\tOverall status: <b>Healthy</b></span>")
		to_chat(user, "<span class='info'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>")
		to_chat(user, "<span class='info'>\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>")
		to_chat(user, "<span class='info'>Body temperature: ???</span>")
		return

	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", "<span class='notice'>You analyze [M]'s vitals.</span>")

	healthscan(user, M, mode, advanced)

	add_fingerprint(user)

// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	if(!ishuman(M) || ismachineperson(M))
		//these sensors are designed for organic life
		to_chat(user, "<span class='notice'>Analyzing Results for ERROR:\n\t Overall Status: ERROR</span>")
		to_chat(user, "\t Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>")
		to_chat(user, "\t Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>")
		to_chat(user, "<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>")
		to_chat(user, "<span class='warning'><b>Warning: Blood Level ERROR: --% --cl.</span><span class='notice'>Type: ERROR</span>")
		to_chat(user, "<span class='notice'>Subject's pulse: <font color='red'>-- bpm.</font></span>")
		return

	var/mob/living/carbon/human/H = M
	var/fake_oxy = max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))
	var/OX = H.getOxyLoss() > 50 	? 	"<b>[H.getOxyLoss()]</b>" 		: H.getOxyLoss()
	var/TX = H.getToxLoss() > 50 	? 	"<b>[H.getToxLoss()]</b>" 		: H.getToxLoss()
	var/BU = H.getFireLoss() > 50 	? 	"<b>[H.getFireLoss()]</b>" 		: H.getFireLoss()
	var/BR = H.getBruteLoss() > 50 	? 	"<b>[H.getBruteLoss()]</b>" 	: H.getBruteLoss()
	if(H.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		to_chat(user, "<span class='notice'>Analyzing Results for [H]:\n\t Overall Status: dead</span>")
	else
		to_chat(user, "<span class='notice'>Analyzing Results for [H]:\n\t Overall Status: [H.stat > 1 ? "dead" : "[H.health]% healthy"]</span>")
	to_chat(user, "\t Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>")
	to_chat(user, "\t Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	to_chat(user, "<span class='notice'>Body Temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span>")
	if(H.timeofdeath && (H.stat == DEAD || (H.status_flags & FAKEDEATH)))
		to_chat(user, "<span class='notice'>Time of Death: [station_time_timestamp("hh:mm:ss", H.timeofdeath)]</span>")
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT)
			to_chat(user, "<span class='danger'>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</span>")

	if(mode == 1)
		var/list/damaged = H.get_damaged_organs(1,1)
		to_chat(user, "<span class='notice'>Localized Damage, Brute/Burn:</span>")
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/org in damaged)
				to_chat(user, "\t\t<span class='info'>[capitalize(org.name)]: [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : "<font color='red'>0</font>"]-[(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"]")

	OX = H.getOxyLoss() > 50 ? 	"<font color='blue'><b>Severe oxygen deprivation detected</b></font>" 		: 	"Subject bloodstream oxygen level normal"
	TX = H.getToxLoss() > 50 ? 	"<font color='green'><b>Dangerous amount of toxins detected</b></font>" 	: 	"Subject bloodstream toxin level minimal"
	BU = H.getFireLoss() > 50 ? 	"<font color='#FFA500'><b>Severe burn damage detected</b></font>" 			:	"Subject burn injury status O.K"
	BR = H.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" 		: 	"Subject brute-force injury status O.K"
	if(H.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='danger'>Severe oxygen deprivation detected</span>" 	: 	"<span class='notice'>Subject bloodstream oxygen level normal</span>"
	to_chat(user, "[OX] | [TX] | [BU] | [BR]")

	if(advanced)
		chemscan(user, H)
	for(var/thing in H.viruses)
		var/datum/disease/D = thing
		if(D.visibility_flags & HIDDEN_SCANNER)
			continue
		// Snowflaking heart problems, because they are special (and common).
		if(istype(D, /datum/disease/critical))
			to_chat(user, "<span class='alert'><b>Warning: Subject is undergoing [D.name].</b>\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>")
			continue
		to_chat(user, "<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>")
	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !(heart.status & ORGAN_DEAD))
			to_chat(user, "<span class='alert'><b>The patient's heart has stopped.</b>\nPossible Cure: Electric Shock</span>")
		else if(heart && (heart.status & ORGAN_DEAD))
			to_chat(user, "<span class='alert'><b>Subject's heart is necrotic.</b></span>")
		else if(!heart)
			to_chat(user, "<span class='alert'><b>Subject has no heart.</b></span>")

	if(H.getStaminaLoss())
		to_chat(user, "<span class='info'>Subject appears to be suffering from fatigue.</span>")
	if(H.getCloneLoss())
		to_chat(user, "<span class='warning'>Subject appears to have [H.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>")
	if(H.has_brain_worms())
		to_chat(user, "<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span>")

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		if(H.getBrainLoss() >= 100)
			to_chat(user, "<span class='warning'>Subject is brain dead.</span>")
		else if(H.getBrainLoss() >= 60)
			to_chat(user, "<span class='warning'>Severe brain damage detected. Subject likely to have dementia.</span>")
		else if(H.getBrainLoss() >= 10)
			to_chat(user, "<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>")
	else
		to_chat(user, "<span class='warning'>Subject has no brain.</span>")

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.status & ORGAN_BROKEN)
			if((e.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")) && !(e.status & ORGAN_SPLINTED))
				to_chat(user, "<span class='warning'>Unsecured fracture in subject [limb]. Splinting recommended for transport.</span>")
		if(e.has_infected_wound())
			to_chat(user, "<span class='warning'>Infected wound detected in subject [limb]. Disinfection recommended.</span>")

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		if(e.status & ORGAN_BROKEN)
			to_chat(user, "<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span>")
			break
	for(var/obj/item/organ/external/e in H.bodyparts)
		if(e.internal_bleeding)
			to_chat(user, "<span class='warning'>Internal bleeding detected. Advanced scanner required for location.</span>")
			break
	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			to_chat(user, "<span class='danger'>Subject is bleeding!</span>")
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id
		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			to_chat(user, "<span class='danger'>LOW blood level [blood_percent] %, [H.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			to_chat(user, "<span class='danger'>CRITICAL blood level [blood_percent] %, [H.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
		else
			to_chat(user, "<span class='info'>Blood level [blood_percent] %, [H.blood_volume] cl, type: [blood_type]</span>")

	to_chat(user, "<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span>")
	var/implant_detect
	for(var/obj/item/organ/internal/cyberimp/CI in H.internal_organs)
		if(CI.is_robotic())
			implant_detect += "[H.name] is modified with a [CI.name].<br>"
	if(implant_detect)
		to_chat(user, "<span class='notice'>Detected cybernetic modifications:</span>")
		to_chat(user, "<span class='notice'>[implant_detect]</span>")
	if(H.gene_stability < 40)
		to_chat(user, "<span class='userdanger'>Subject's genes are quickly breaking down!</span>")
	else if(H.gene_stability < 70)
		to_chat(user, "<span class='danger'>Subject's genes are showing signs of spontaneous breakdown.</span>")
	else if(H.gene_stability < 85)
		to_chat(user, "<span class='warning'>Subject's genes are showing minor signs of instability.</span>")
	else
		to_chat(user, "<span class='notice'>Subject's genes are stable.</span>")

/obj/item/healthanalyzer/attack_self(mob/user)
	toggle_mode()

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	switch(mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/healthupgrade))
		if(advanced)
			to_chat(user, "<span class='notice'>An upgrade is already installed on [src].</span>")
		else
			if(user.unEquip(I))
				to_chat(user, "<span class='notice'>You install the upgrade on [src].</span>")
				add_overlay("advanced")
				playsound(loc, I.usesound, 50, 1)
				advanced = TRUE
				qdel(I)
		return
	return ..()

/obj/item/healthanalyzer/advanced
	advanced = TRUE

/obj/item/healthanalyzer/advanced/Initialize(mapload)
	. = ..()
	add_overlay("advanced")


/obj/item/healthupgrade
	name = "Health Analyzer Upgrade"
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	desc = "An upgrade unit that can be installed on a health analyzer for expanded functionality."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += "<span class='info'>Alt-click [src] to activate the barometer function.</span>"

/obj/item/analyzer/attack_self(mob/user as mob)

	if(user.stat)
		return

	var/turf/location = user.loc
	if(!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(user, "<span class='info'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='info'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(user, "<span class='alert'>Pressure: [round(pressure,0.1)] kPa</span>")
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, "<span class='info'>Nitrogen: [round(n2_concentration*100)] %</span>")
		else
			to_chat(user, "<span class='alert'>Nitrogen: [round(n2_concentration*100)] %</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, "<span class='info'>Oxygen: [round(o2_concentration*100)] %</span>")
		else
			to_chat(user, "<span class='alert'>Oxygen: [round(o2_concentration*100)] %</span>")

		if(co2_concentration > 0.01)
			to_chat(user, "<span class='alert'>CO2: [round(co2_concentration*100)] %</span>")
		else
			to_chat(user, "<span class='info'>CO2: [round(co2_concentration*100)] %</span>")

		if(plasma_concentration > 0.01)
			to_chat(user, "<span class='info'>Plasma: [round(plasma_concentration*100)] %</span>")

		if(unknown_concentration > 0.01)
			to_chat(user, "<span class='alert'>Unknown: [round(unknown_concentration*100)] %</span>")

		to_chat(user, "<span class='info'>Temperature: [round(environment.temperature-T0C)] &deg;C</span>")

	add_fingerprint(user)

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	..()

	if(!user.incapacitated() && Adjacent(user))

		if(cooldown)
			to_chat(user, "<span class='warning'>[src]'s barometer function is prepraring itself.</span>")
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
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, "<span class='warning'>[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]</span>")
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
		addtimer(CALLBACK(src,/obj/item/analyzer/proc/ping), cooldown_time)

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

/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/reagent_scanner/afterattack(obj/O, mob/user as mob)
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
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for(var/datum/reagent/R in O.reagents.reagent_list)
				if(R.id != "blood")
					dat += "<br>[TAB]<span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
				else
					blood_type = R.data["blood_type"]
					dat += "<br>[TAB]<span class='notice'>[R][blood_type ? " [blood_type]" : ""][details ? ": [R.volume / one_percent]%" : ""]</span>"
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

/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	item_state = "analyzer"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.incapacitated() || user.eye_blind)
		return
	if(!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

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
				to_chat(user, "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting")
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

/obj/item/bodyanalyzer
	name = "handheld body analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "bodyanalyzer_0"
	item_state = "healthanalyser"
	desc = "A handheld scanner capable of deep-scanning an entire body."
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=6;biotech=6"
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell/upgraded
	var/ready = TRUE // Ready to scan
	var/time_to_use = 0 // How much time remaining before next scan is available.
	var/usecharge = 750
	var/scan_time = 10 SECONDS //how long does it take to scan
	var/scan_cd = 60 SECONDS //how long before we can scan again

/obj/item/bodyanalyzer/get_cell()
	return cell

/obj/item/bodyanalyzer/advanced
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/item/bodyanalyzer/borg
	name = "cyborg body analyzer"
	desc = "Scan an entire body to prepare for field surgery. Consumes power for each scan."

/obj/item/bodyanalyzer/borg/syndicate
	scan_time = 5 SECONDS
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

/obj/item/bodyanalyzer/update_icon(printing = FALSE)
	overlays.Cut()
	var/percent = cell.percent()
	if(ready)
		icon_state = "bodyanalyzer_1"
	else
		icon_state = "bodyanalyzer_2"

	var/overlayid = round(percent / 10)
	overlayid = "bodyanalyzer_charge[overlayid]"
	overlays += icon(icon, overlayid)

	if(printing)
		overlays += icon(icon, "bodyanalyzer_printing")

/obj/item/bodyanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
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

/obj/item/bodyanalyzer/borg/attack(mob/living/M, mob/living/silicon/robot/user)
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
			update_icon(TRUE)
			addtimer(CALLBACK(src, /obj/item/bodyanalyzer/.proc/setReady), scan_cd)
			addtimer(CALLBACK(src, /obj/item/bodyanalyzer/.proc/update_icon), 20)

	else if(iscorgi(M) && M.stat == DEAD)
		to_chat(user, "<span class='notice'>You wonder if [M.p_they()] was a good dog. <b>[src] tells you they were the best...</b></span>") // :'(
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		ready = FALSE
		addtimer(CALLBACK(src, /obj/item/bodyanalyzer/.proc/setReady), scan_cd)
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

	dat += "Paralysis Summary %: [target.paralysis] ([round(target.paralysis / 4)] seconds left!)<br>"
	dat += "Body Temperature: [target.bodytemperature-T0C]&deg;C ([target.bodytemperature*1.8-459.67]&deg;F)<br>"

	dat += "<hr>"

	if(target.has_brain_worms())
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"

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
		if(e.internal_bleeding)
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
		if(!AN && !open && !infected & !imp)
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
	if(BLINDNESS in target.mutations)
		dat += "<font color='red'>Cataracts detected.</font><BR>"
	if(COLOURBLIND in target.mutations)
		dat += "<font color='red'>Photoreceptor abnormalities detected.</font><BR>"
	if(NEARSIGHTED in target.mutations)
		dat += "<font color='red'>Retinal misalignment detected.</font><BR>"

	return dat
