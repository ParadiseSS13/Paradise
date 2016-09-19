// Sleeper, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical

/obj/item/mecha_parts/mecha_equipment/medical/New()
	..()
	processing_objects.Add(src)


/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/mecha/medical/M)
	if(..() && istype(M))
		return 1

/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/mecha/M)
	..()
	processing_objects.Add(src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		processing_objects.Remove(src)
		return 1

/obj/item/mecha_parts/mecha_equipment/medical/detach()
	processing_objects.Remove(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	origin_tech = "engineering=3;biotech=3;plasmatech=2"
	energy_drain = 20
	range = MELEE
	equip_cooldown = 20
	var/mob/living/carbon/patient = null
	var/inject_amount = 10
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/allow_drop()
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(!patient_insertion_check(target))
		return
	occupant_message("<span class='notice'>You start putting [target] into [src]...</span>")
	chassis.visible_message("<span class='warning'>[chassis] starts putting [target] into \the [src].</span>")
	if(do_after_cooldown(target))
		if(!patient_insertion_check(target))
			return
		target.forceMove(src)
		patient = target
		processing_objects.Add(src)
		update_equip_info()
		occupant_message("<span class='notice'>[target] successfully loaded into [src]. Life support functions engaged.</span>")
		chassis.visible_message("<span class='warning'>[chassis] loads [target] into [src].</span>")
		log_message("[target] loaded. Life support functions engaged.")

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target)
	if(target.buckled)
		occupant_message("<span class='warning'>[target] will not fit into the sleeper because they are buckled to [target.buckled]!</span>")
		return
	if(target.has_buckled_mobs())
		occupant_message("<span class='warning'>[target] will not fit into the sleeper because of the creatures attached to it!</span>")
		return
	if(patient)
		occupant_message("<span class='warning'>The sleeper is already occupied!</span>")
		return
	return 1

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	occupant_message("[patient] ejected. Life support functions disabled.")
	log_message("[patient] ejected. Life support functions disabled.")
	processing_objects.Remove(src)
	patient = null
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		occupant_message("<span class='warning'>Unable to detach [src] - equipment occupied!</span>")
		return
	processing_objects.Remove(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(patient)
			temp = "<br />\[Occupant: [patient] ([patient.stat > 1 ? "*DECEASED*" : "Health: [patient.health]%"])\]<br /><a href='?src=\ref[src];view_stats=1'>View stats</a>|<a href='?src=\ref[src];eject=1'>Eject</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(filter.get("eject"))
		go_out()
	if(filter.get("view_stats"))
		chassis.occupant << browse(get_patient_stats(),"window=msleeper")
		onclose(chassis.occupant, "msleeper")
		return
	if(filter.get("inject"))
		inject_reagent(filter.getType("inject",/datum/reagent),filter.getObj("source"))
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_stats()
	if(!patient)
		return
	return {"<html>
				<head>
				<title>[patient] statistics</title>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				<style>
				h3 {margin-bottom:2px;font-size:14px;}
				#lossinfo, #reagents, #injectwith {padding-left:15px;}
				</style>
				</head>
				<body>
				<h3>Health statistics</h3>
				<div id="lossinfo">
				[get_patient_dam()]
				</div>
				<h3>Reagents in bloodstream</h3>
				<div id="reagents">
				[get_patient_reagents()]
				</div>
				<div id="injectwith">
				[get_available_reagents()]
				</div>
				</body>
				</html>"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_dam()
	var/t1
	switch(patient.stat)
		if(0)
			t1 = "Conscious"
		if(1)
			t1 = "Unconscious"
		if(2)
			t1 = "*dead*"
		else
			t1 = "Unknown"
	return {"<font color="[patient.health > 50 ? "blue" : "red"]"><b>Health:</b> [patient.stat > 1 ? "[t1]" : "[patient.health]% ([t1])"]</font><br />
				<font color="[patient.bodytemperature > 50 ? "blue" : "red"]"><b>Core Temperature:</b> [patient.bodytemperature-T0C]&deg;C ([patient.bodytemperature*1.8-459.67]&deg;F)</font><br />
				<font color="[patient.getBruteLoss() < 60 ? "blue" : "red"]"><b>Brute Damage:</b> [patient.getBruteLoss()]%</font><br />
				<font color="[patient.getOxyLoss() < 60 ? "blue" : "red"]"><b>Respiratory Damage:</b> [patient.getOxyLoss()]%</font><br />
				<font color="[patient.getToxLoss() < 60 ? "blue" : "red"]"><b>Toxin Content:</b> [patient.getToxLoss()]%</font><br />
				<font color="[patient.getFireLoss() < 60 ? "blue" : "red"]"><b>Burn Severity:</b> [patient.getFireLoss()]%</font><br />
				<font color="red">[patient.getCloneLoss() ? "Subject appears to have cellular damage." : ""]</font><br />
				<font color="red">[patient.getBrainLoss() ? "Significant brain damage detected." : ""]</font><br />
				"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_reagents()
	if(patient.reagents)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			if(R.volume > 0)
				. += "[R]: [round(R.volume,0.01)]<br />"
	return . || "None"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_available_reagents()
	var/output
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(SG && SG.reagents && islist(SG.reagents.reagent_list))
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				output += "<a href=\"?src=\ref[src];inject=\ref[R];source=\ref[SG]\">Inject [R.name]</a><br />"
	return output


/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R,obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return 0
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.id) + to_inject <= inject_amount*2)
		occupant_message("Injecting [patient] with [to_inject] units of [R.name].")
		log_message("Injecting [patient] with [to_inject] units of [R.name].")
		add_logs(chassis.occupant, patient, "injected", "[name] ([R] - [to_inject] units)")
		SG.reagents.trans_id_to(patient,R.id,to_inject)
		update_equip_info()
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/update_equip_info()
	if(..())
		if(patient)
			send_byjax(chassis.occupant,"msleeper.browser","lossinfo",get_patient_dam())
			send_byjax(chassis.occupant,"msleeper.browser","reagents",get_patient_reagents())
			send_byjax(chassis.occupant,"msleeper.browser","injectwith",get_available_reagents())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist()
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process()
	if(..())
		return
	if(!chassis.has_charge(energy_drain))
		set_ready_state(1)
		log_message("Deactivated.")
		occupant_message("[src] deactivated - no power.")
		processing_objects.Remove(src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
		M.updatehealth()
	M.AdjustStunned(-4)
	M.AdjustWeakened(-4)
	M.AdjustStunned(-4)
	if(M.reagents.get_reagent_amount("epinephrine") < 5)
		M.reagents.add_reagent("epinephrine", 5)
	chassis.use_power(energy_drain)
	update_equip_info()


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "syringegun"
	flags = NOREACT
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	range = MELEE|RANGED
	equip_cooldown = 10
	origin_tech = "materials=3;biotech=4;magnets=4"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/New()
	..()
	create_reagents(max_volume)
	syringes = new
	known_reagents = list("epinephrine"="Epinephrine","charcoal"="Charcoal")
	processed_reagents = new

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	processing_objects.Remove(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/critfail()
	..()
	flags &= ~NOREACT

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/mecha/medical/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href=\"?src=\ref[src];toggle_mode=1\">[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [syringes.len]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='?src=\ref[src];show_reagents=1'>Reagents list</a>"
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(atom/movable/target)
	if(!action_checks(target))
		return
	if(istype(target,/obj/item/weapon/reagent_containers/syringe))
		return load_syringe(target)
	if(istype(target,/obj/item/weapon/storage))//Loads syringes from boxes
		for(var/obj/item/weapon/reagent_containers/syringe/S in target.contents)
			load_syringe(S)
		return
	if(mode)
		return analyze_reagents(target)
	if(!syringes.len)
		occupant_message("<span class=\"alert\">No syringes loaded.</span>")
		return
	if(reagents.total_volume<=0)
		occupant_message("<span class=\"alert\">No available reagents to load syringe with.</span>")
		return
	var/turf/trg = get_turf(target)
	var/obj/item/weapon/reagent_containers/syringe/mechsyringe = syringes[1]
	mechsyringe.forceMove(get_turf(chassis))
	reagents.trans_to(mechsyringe, min(mechsyringe.volume, reagents.total_volume))
	syringes -= mechsyringe
	mechsyringe.icon = 'icons/obj/chemical.dmi'
	mechsyringe.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, 1)
	log_message("Launched [mechsyringe] from [src], targeting [target].")
	var/mob/originaloccupant = chassis.occupant
	spawn(0)
		src = null //if src is deleted, still process the syringe
		for(var/i=0, i<6, i++)
			if(!mechsyringe)
				break
			if(step_towards(mechsyringe,trg))
				var/list/mobs = new
				for(var/mob/living/carbon/M in mechsyringe.loc)
					mobs += M
				var/mob/living/carbon/M = safepick(mobs)
				if(M)
					var/R
					mechsyringe.visible_message("<span class=\"attack\"> [M] was hit by the syringe!</span>")
					if(M.can_inject(null, 1))
						if(mechsyringe.reagents)
							for(var/datum/reagent/A in mechsyringe.reagents.reagent_list)
								R += A.id + " ("
								R += num2text(A.volume) + "),"
						mechsyringe.icon_state = initial(mechsyringe.icon_state)
						mechsyringe.icon = initial(mechsyringe.icon)
						mechsyringe.reagents.reaction(M, INGEST)
						mechsyringe.reagents.trans_to(M, mechsyringe.reagents.total_volume)
						M.take_organ_damage(2)
						add_logs(originaloccupant, M, "shot", "syringegun")
					break
				else if(mechsyringe.loc == trg)
					mechsyringe.icon_state = initial(mechsyringe.icon_state)
					mechsyringe.icon = initial(mechsyringe.icon)
					mechsyringe.update_icon()
					break
			else
				mechsyringe.icon_state = initial(mechsyringe.icon_state)
				mechsyringe.icon = initial(mechsyringe.icon)
				mechsyringe.update_icon()
				break
			sleep(1)
	return 1


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new (href,href_list)
	if(filter.get("toggle_mode"))
		mode = !mode
		update_equip_info()
		return
	if(filter.get("select_reagents"))
		processed_reagents.len = 0
		var/m = 0
		var/message
		for(var/i=1 to known_reagents.len)
			if(m>=synth_speed)
				break
			var/reagent = filter.get("reagent_[i]")
			if(reagent && (reagent in known_reagents))
				message = "[m ? ", " : null][known_reagents[reagent]]"
				processed_reagents += reagent
				m++
		if(processed_reagents.len)
			message += " added to production"
			processing_objects.Add(src)
			occupant_message(message)
			occupant_message("Reagent processing started.")
			log_message("Reagent processing started.")
		return
	if(filter.get("show_reagents"))
		chassis.occupant << browse(get_reagents_page(),"window=msyringegun")
	if(filter.get("purge_reagent"))
		var/reagent = filter.get("purge_reagent")
		if(reagent)
			reagents.del_reagent(reagent)
		return
	if(filter.get("purge_all"))
		reagents.clear_reagents()
		return
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_page()
	var/output = {"<html>
						<head>
						<title>Reagent Synthesizer</title>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						</script>
						<style>
						h3 {margin-bottom:2px;font-size:14px;}
						#reagents, #reagents_form {}
						form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
						#submit {margin-top:5px;}
						</style>
						</head>
						<body>
						<h3>Current reagents:</h3>
						<div id="reagents">
						[get_current_reagents()]
						</div>
						<h3>Reagents production:</h3>
						<div id="reagents_form">
						[get_reagents_form()]
						</div>
						</body>
						</html>
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_form()
	var/r_list = get_reagents_list()
	var/inputs
	if(r_list)
		inputs += "<input type=\"hidden\" name=\"src\" value=\"\ref[src]\">"
		inputs += "<input type=\"hidden\" name=\"select_reagents\" value=\"1\">"
		inputs += "<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"
	var/output = {"<form action="byond://" method="get">
						[r_list || "No known reagents"]
						[inputs]
						</form>
						[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_list()
	var/output
	for(var/i=1 to known_reagents.len)
		var/reagent_id = known_reagents[i]
		output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_current_reagents()
	var/output
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			output += "[R]: [round(R.volume,0.001)] - <a href=\"?src=\ref[src];purge_reagent=[R.id]\">Purge Reagent</a><br />"
	if(output)
		output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href=\"?src=\ref[src];purge_all=1\">Purge All</a>"
	return output || "None"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/weapon/reagent_containers/syringe/S)
	if(syringes.len<max_syringes)
		if(get_dist(src,S) >= 2)
			occupant_message("The syringe is too far away.")
			return 0
		for(var/obj/structure/D in S.loc)//Basic level check for structures in the way (Like grilles and windows)
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return 0
		for(var/obj/machinery/door/D in S.loc)//Checks for doors
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Unable to load syringe.")
				return 0
		S.reagents.trans_to(src, S.reagents.total_volume)
		S.forceMove(src)
		syringes += S
		occupant_message("Syringe loaded.")
		update_equip_info()
		return 1
	occupant_message("The [src] syringe chamber is full.")
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A)
	if(get_dist(src,A) >= 4)
		occupant_message("The object is too far away.")
		return 0
	if(!A.reagents || istype(A,/mob))
		occupant_message("<span class=\"alert\">No reagent info gained from [A].</span>")
		return 0
	occupant_message("Analyzing reagents...")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if(R.reagent_state == 2 && add_known_reagent(R.id,R.name))
			occupant_message("Reagent analyzed, identified as [R.name] and added to database.")
			send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
	occupant_message("Analyzis complete.")
	return 1

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/update_equip_info()
	if(..())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents",get_current_reagents())
		send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/on_reagent_change()
	..()
	update_equip_info()
	return


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process()
	if(..())
		return
	if(!processed_reagents.len || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		occupant_message("<span class=\"alert\">Reagent processing stopped.</a>")
		log_message("Reagent processing stopped.")
		processing_objects.Remove(src)
		return
	var/amount = synth_speed / processed_reagents.len
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_power(energy_drain)

