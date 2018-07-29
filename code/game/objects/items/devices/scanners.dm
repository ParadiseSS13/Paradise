/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/
/obj/item/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = 0
	slot_flags = SLOT_BELT
	w_class = 2
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"
	var/scan_range = 1
	var/pulse_duration = 10

/obj/item/t_scanner/longer_pulse
	pulse_duration = 50

/obj/item/t_scanner/extended_range
	scan_range = 3

/obj/item/t_scanner/extended_range/longer_pulse
	scan_range = 3
	pulse_duration = 50

/obj/item/t_scanner/Destroy()
	if(on)
		processing_objects.Remove(src)
	return ..()

/obj/item/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = copytext(icon_state, 1, length(icon_state))+"[on]"

	if(on)
		processing_objects.Add(src)


/obj/item/t_scanner/process()
	if(!on)
		processing_objects.Remove(src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()

	for(var/turf/T in range(scan_range, src.loc) )

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			if(O.invisibility == 101)
				O.invisibility = 0
				O.alpha = 128
				spawn(pulse_duration)
					if(O)
						var/turf/U = O.loc
						if(U && U.intact)
							O.invisibility = 101
							O.alpha = 255
		for(var/mob/living/M in T.contents)
			var/oldalpha = M.alpha
			if(M.alpha < 255 && istype(M))
				M.alpha = 255
				spawn(10)
					if(M)
						M.alpha = oldalpha

		var/mob/living/M = locate() in T

		if(M && M.invisibility == 2)
			M.invisibility = 0
			spawn(2)
				if(M)
					M.invisibility = INVISIBILITY_LEVEL_TWO


/proc/chemscan(var/mob/living/user, var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				user.show_message("<span class='notice'>Subject contains the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.reagent_list)
					user.show_message("<span class='notice'>[R.volume]u of [R.name][R.overdosed ? "</span> - <span class = 'boldannounce'>OVERDOSING</span>" : ".</span>"]")
			else
				user.show_message("<span class = 'notice'>Subject contains no reagents.</span>")
			if(H.reagents.addiction_list.len)
				user.show_message("<span class='danger'>Subject is addicted to the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					user.show_message("<span class='danger'>[R.name] Stage: [R.addiction_stage]/5</span>")
			else
				user.show_message("<span class='notice'>Subject is not addicted to any reagents.</span>")

/obj/item/healthanalyzer
	name = "Health Analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	var/upgraded = 0
	var/mode = 1;


/obj/item/healthanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, text("<span class='warning'>You try to analyze the floor's vitals!</span>"))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='warning'>[user] has analyzed the floor's vitals!</span>"), 1)
		user.show_message(text("<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>"), 1)
		user.show_message(text("<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>"), 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>","<span class='notice'> You have analyzed [M]'s vitals.</span>")

	if(!istype(M,/mob/living/carbon/human) || M.isSynthetic())
		//these sensors are designed for organic life
		user.show_message("<span class='notice'>Analyzing Results for ERROR:\n\t Overall Status: ERROR</span>")
		user.show_message("\t Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>", 1)
		user.show_message("\t Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>")
		user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
		user.show_message("<span class='warning'><b>Warning: Blood Level ERROR: --% --cl.</span><span class='notice'>Type: ERROR</span>")
		user.show_message("<span class='notice'>Subject's pulse: <font color='red'>-- bpm.</font></span>")
		return

	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		user.show_message("<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: dead</span>")
	else
		user.show_message("<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "dead" : "[M.health]% healthy"]</span>")
	user.show_message("\t Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font>", 1)
	user.show_message("\t Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	user.show_message("<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
	if(M.timeofdeath && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		user.show_message("<span class='notice'>Time of Death: [station_time_timestamp("hh:mm:ss", M.timeofdeath)]</span>")
	if(istype(M, /mob/living/carbon/human) && mode == 1)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_organs(1,1)
		user.show_message("<span class='notice'>Localized Damage, Brute/Burn:</span>",1)
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/org in damaged)
				user.show_message("\t\t<span class='info'>[capitalize(org.name)]: [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font></span>" : "<font color='red'>0</font>"]-[(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"]")

	OX = M.getOxyLoss() > 50 ? 	"<font color='blue'><b>Severe oxygen deprivation detected</b></font>" 		: 	"Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? 	"<font color='green'><b>Dangerous amount of toxins detected</b></font>" 	: 	"Subject bloodstream toxin level minimal"
	BU = M.getFireLoss() > 50 ? 	"<font color='#FFA500'><b>Severe burn damage detected</b></font>" 			:	"Subject burn injury status O.K"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" 		: 	"Subject brute-force injury status O.K"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='danger'>Severe oxygen deprivation detected</span>" 	: 	"<span class='notice'>Subject bloodstream oxygen level normal</span>"
	user.show_message("[OX] | [TX] | [BU] | [BR]")
	if(istype(M, /mob/living/carbon))
		if(upgraded)
			chemscan(user, M)
		for(var/thing in M.viruses)
			var/datum/disease/D = thing
			if(!(D.visibility_flags & HIDDEN_SCANNER))
				user.show_message("<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>")
	if(M.getStaminaLoss())
		user.show_message("<span class='info'>Subject appears to be suffering from fatigue.</span>")
	if(M.getCloneLoss())
		user.show_message("<span class='warning'>Subject appears to have [M.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>")
	if(M.has_brain_worms())
		user.show_message("<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span>")
	else if(M.getBrainLoss() >= 100 || istype(M, /mob/living/carbon/human) && !M.get_int_organ(/obj/item/organ/internal/brain))
		user.show_message("<span class='warning'>Subject is brain dead.</span>")
	else if(M.getBrainLoss() >= 60)
		user.show_message("<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span>")
	else if(M.getBrainLoss() >= 10)
		user.show_message("<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/e = H.bodyparts_by_name[name]
			if(!e)
				continue
			var/limb = e.name
			if(e.status & ORGAN_BROKEN)
				if((e.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")) && !(e.status & ORGAN_SPLINTED))
					user.show_message("<span class='warning'>Unsecured fracture in subject [limb]. Splinting recommended for transport.</span>")
			if(e.has_infected_wound())
				user.show_message("<span class='warning'>Infected wound detected in subject [limb]. Disinfection recommended.</span>")

		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/e = H.bodyparts_by_name[name]
			if(!e)
				continue
			if(e.status & ORGAN_BROKEN)
				user.show_message(text("<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span>"), 1)
				break
		for(var/obj/item/organ/external/e in H.bodyparts)
			if(e.internal_bleeding)
				user.show_message(text("<span class='warning'>Internal bleeding detected. Advanced scanner required for location.</span>"), 1)
				break
		var/blood_id = H.get_blood_id()
		if(blood_id)
			if(H.bleed_rate)
				user.show_message("<span class='danger'>Subject is bleeding!</span>")
			var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = H.b_type
			if(blood_id != "blood")//special blood substance
				var/datum/reagent/R = chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
				user.show_message("<span class='danger'>LOW blood level [blood_percent] %, [H.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
			else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
				user.show_message("<span class='danger'>CRITICAL blood level [blood_percent] %, [H.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
			else
				user.show_message("<span class='info'>Blood level [blood_percent] %, [H.blood_volume] cl, type: [blood_type]</span>")

		if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
			user.show_message("<span class='userdanger'>Subject suffering from heart attack: Apply defibrillator immediately.</span>")
		user.show_message("<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span>")
		var/implant_detect
		for(var/obj/item/organ/internal/cyberimp/CI in H.internal_organs)
			if(CI.is_robotic())
				implant_detect += "[H.name] is modified with a [CI.name].<br>"
		if(implant_detect)
			user.show_message("<span class='notice'>Detected cybernetic modifications:</span>")
			user.show_message("<span class='notice'>[implant_detect]</span>")
		if(H.gene_stability < 40)
			user.show_message("<span class='userdanger'>Subject's genes are quickly breaking down!</span>")
		else if(H.gene_stability < 70)
			user.show_message("<span class='danger'>Subject's genes are showing signs of spontaneous breakdown.</span>")
		else if(H.gene_stability < 85)
			user.show_message("<span class='warning'>Subject's genes are showing minor signs of instability.</span>")
		else
			user.show_message("<span class='notice'>Subject's genes are stable.</span>")
	src.add_fingerprint(user)
	return

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	switch(mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/healthupgrade))
		if(upgraded)
			to_chat(user, "<span class='notice'>You have already installed an upgraded in the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You install the upgrade in the [src].</span>")
			overlays += "advanced"
			playsound(loc, W.usesound, 50, 1)
			upgraded = 1
			qdel(W)

/obj/item/healthanalyzer/advanced
	upgraded = 1

/obj/item/healthanalyzer/advanced/New()
	overlays += "advanced"


/obj/item/healthupgrade
	name = "Health Analyzer Upgrade"
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	desc = "An upgrade unit that can be installed on a health analyzer for expanded functionality."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/Deconstruct.ogg'

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

/obj/item/analyzer/attack_self(mob/user as mob)

	if(user.stat)
		return

	var/turf/location = user.loc
	if(!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	user.show_message("<span class='info'><B>Results:</B></span>", 1)
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		user.show_message("<span class='info'>Pressure: [round(pressure,0.1)] kPa</span>", 1)
	else
		user.show_message("<span class='alert'>Pressure: [round(pressure,0.1)] kPa</span>", 1)
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			user.show_message("<span class='info'>Nitrogen: [round(n2_concentration*100)] %</span>", 1)
		else
			user.show_message("<span class='alert'>Nitrogen: [round(n2_concentration*100)] %</span>", 1)

		if(abs(o2_concentration - O2STANDARD) < 2)
			user.show_message("<span class='info'>Oxygen: [round(o2_concentration*100)] %</span>", 1)
		else
			user.show_message("<span class='alert'>Oxygen: [round(o2_concentration*100)] %</span>", 1)

		if(co2_concentration > 0.01)
			user.show_message("<span class='alert'>CO2: [round(co2_concentration*100)] %</span>", 1)
		else
			user.show_message("<span class='info'>CO2: [round(co2_concentration*100)] %</span>", 1)

		if(plasma_concentration > 0.01)
			user.show_message("<span class='info'>Plasma: [round(plasma_concentration*100)] %</span>", 1)

		if(unknown_concentration > 0.01)
			user.show_message("<span class='alert'>Unknown: [round(unknown_concentration*100)] %</span>", 1)

		user.show_message("<span class='info'>Temperature: [round(environment.temperature-T0C)] &deg;C</span>", 1)

	src.add_fingerprint(user)
	return

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

/obj/item/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample. Inject sample with syringe."
	name = "mass-spectrometer"
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT | OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=150, MAT_GLASS=100)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = 0
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/mass_spectrometer/attack_self(mob/user as mob)
	if(user.stat)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample.</span>")
				reagents.clear_reagents()
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = ""
		for(var/R in blood_traces)
			if(details)
				dat += "[R] ([blood_traces[R]] units) "
			else
				dat += "[R] "
		to_chat(user, "Analysis completed. Chemicals found: [dat]")
		scanning = FALSE
		datatoprint = dat
		reagents.clear_reagents()
	return

/obj/item/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/mass_spectrometer/proc/print_report()
	if(!scanning)
		scanning = TRUE
		usr.visible_message("<span class='warning'>[src] rattles and prints out a sheet of paper.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		sleep(50)

		var/obj/item/paper/P = new(get_turf(src))
		P.name = "Mass Spectrometer Scanner Report: [station_time_timestamp()]"
		P.info = "<center><b>Mass Spectrometer</b></center><br><center>Data Analysis:</center><br><hr><br><b>Trace chemicals detected:</b><br>[datatoprint]<br><hr>"

		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(P)
			to_chat(M, "<span class='notice'>Report printed. Log cleared.<span>")
			datatoprint = ""
	else
		to_chat(usr, "<span class='notice'>[src] has no logs or is already in use.</span>")

/obj/item/mass_spectrometer/ui_action_click()
	print_report()

/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
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
	var/details = 0
	var/datatoprint = ""
	var/scanning = 1
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
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for(var/datum/reagent/R in O.reagents.reagent_list)
				dat += "<br>[TAB]<span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
			datatoprint = dat
			scanning = 0
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")
	return

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
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
			to_chat(M, "<span class='notice'>Report printed. Log cleared.<span>")
			datatoprint = ""
			scanning = 1
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

/obj/item/slime_scanner/attack(mob/living/M as mob, mob/living/user as mob)
	if(!isslime(M))
		user.show_message("<span class='warning'>This device can only scan slimes!</span>", 1)
		return
	var/mob/living/carbon/slime/T = M
	user.show_message("Slime scan results:", 1)
	user.show_message(text("[T.colour] [] slime", T.is_adult ? "adult" : "baby"), 1)
	user.show_message(text("Nutrition: [T.nutrition]/[]", T.get_max_nutrition()), 1)
	if(T.nutrition < T.get_starve_nutrition())
		user.show_message("<span class='warning'>Warning: slime is starving!</span>", 1)
	else if(T.nutrition < T.get_hunger_nutrition())
		user.show_message("<span class='warning'>Warning: slime is hungry</span>", 1)
	user.show_message("Electric change strength: [T.powerlevel]", 1)
	user.show_message("Health: [T.health]", 1)
	if(T.slime_mutation[4] == T.colour)
		user.show_message("This slime does not evolve any further.", 1)
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				user.show_message("Possible mutation: [T.slime_mutation[3]]", 1)
				user.show_message("Genetic destability: [T.mutation_chance/2]% chance of mutation on splitting", 1)
			else
				user.show_message("Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)", 1)
				user.show_message("Genetic destability: [T.mutation_chance]% chance of mutation on splitting", 1)
		else
			user.show_message("Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]", 1)
			user.show_message("Genetic destability: [T.mutation_chance]% chance of mutation on splitting", 1)
	if(T.cores > 1)
		user.show_message("Anomalous slime core amount detected", 1)
	user.show_message("Growth progress: [T.amount_grown]/10", 1)
