//Datum for handling supermatter explosion aftermath effects.
#define DETONATION_MACHINE_BREAKDOWN_CHANCE 20
#define DETONATION_MACHINE_EFFECT_CHANCE 30
#define DETONATION_APC_BREAKDOWN_CHANCE 40
#define SPECIAL_EFFECTS_TIMER_DELAY 10 //periods between special effects, for optimizing
#define SIMPLE_ANIMAL_MINDGIVING_CHANCE 2

/datum/supermatter_explosive_effects
	var/z = 0

/datum/supermatter_explosive_effects/proc/handle_special_effects()
	//1. All machinery will have 30% on each one machine messing up wires AND 20% of having damage
	addtimer(CALLBACK(src, PROC_REF(handle_machinery_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY)
	//2. All APCs in current sector will roll 40% chance for breaking
	addtimer(CALLBACK(src, PROC_REF(handle_apc_breaking)), SPECIAL_EFFECTS_TIMER_DELAY*2)
	//3. Ionospheric anomaly
	addtimer(CALLBACK(src, PROC_REF(handle_ion_storm)), SPECIAL_EFFECTS_TIMER_DELAY*3)
	//4. Give every simplemob on current z level chance to be open-minded
	addtimer(CALLBACK(src, PROC_REF(handle_mind_giving)), SPECIAL_EFFECTS_TIMER_DELAY*4)
	//5. Random up seeds.
	addtimer(CALLBACK(src, PROC_REF(handle_seeds_mutation)), SPECIAL_EFFECTS_TIMER_DELAY*5)

//Makes APCs go wild
/datum/supermatter_explosive_effects/proc/handle_apc_breaking()
	var/affected_apc_count = 0
	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		if(src.z == apc.z)
			var/area/current_area = get_area(apc)
			if(prob(DETONATION_APC_BREAKDOWN_CHANCE))
				if(apc.wires)
					if(!apc.wires.is_cut(WIRE_MAIN_POWER1))
						apc.wires.cut(WIRE_MAIN_POWER1)
					if(!apc.wires.is_cut(WIRE_MAIN_POWER2))
						apc.wires.cut(WIRE_MAIN_POWER2)
				if(apc.operating)
					apc.toggle_breaker()
				current_area.power_change()
				affected_apc_count++
	log_and_message_admins("Supermatter breakdown affected [affected_apc_count] APCs")

/datum/supermatter_explosive_effects/proc/handle_machinery_breakdown()
	addtimer(CALLBACK(src, PROC_REF(handle_vendor_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY)
	addtimer(CALLBACK(src, PROC_REF(handle_door_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY*2)
	addtimer(CALLBACK(src, PROC_REF(handle_alarm_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY*3)
	addtimer(CALLBACK(src, PROC_REF(handle_mulebot_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY*4)
	addtimer(CALLBACK(src, PROC_REF(handle_autolathe_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY*5)
	addtimer(CALLBACK(src, PROC_REF(handle_camera_breakdown)), SPECIAL_EFFECTS_TIMER_DELAY*6)

//Break vendors
/datum/supermatter_explosive_effects/proc/handle_vendor_breakdown()
	for(var/obj/machinery/vending/vendor in GLOB.machines)
		if(vendor.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				vendor.wires?.pulse_random()
				continue
			if(prob(DETONATION_MACHINE_BREAKDOWN_CHANCE))
				vendor.deconstruct()

//Break doors
/datum/supermatter_explosive_effects/proc/handle_door_breakdown()
	for(var/obj/machinery/door/airlock/door in GLOB.airlocks)
		if(door.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				door.wires?.pulse_random()
				door.wires?.pulse_random()
				door.wires?.pulse_random()
				door.wires?.pulse_random()
				continue
			if(prob(DETONATION_MACHINE_BREAKDOWN_CHANCE))
				door.electronics = null

//Break air alarms
/datum/supermatter_explosive_effects/proc/handle_alarm_breakdown()
	for(var/obj/machinery/alarm/alarm in GLOB.air_alarms)
		if(alarm.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				alarm.wires?.pulse_random()
				alarm.wires?.pulse_random()
				alarm.wires?.pulse_random()
				continue
			if(prob(DETONATION_MACHINE_BREAKDOWN_CHANCE))
				alarm.take_damage(40, BURN)

//Mulebots are machines too!
/datum/supermatter_explosive_effects/proc/handle_mulebot_breakdown()
	for(var/mob/living/simple_animal/bot/mulebot/bot in GLOB.mob_living_list)
		if(bot.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				bot.wires?.pulse_random()
				bot.wires?.pulse_random()
				continue
			if(prob(DETONATION_MACHINE_BREAKDOWN_CHANCE))
				bot.take_overall_damage(0,40)

//Well, random pulse autolathes
/datum/supermatter_explosive_effects/proc/handle_autolathe_breakdown()
	for(var/obj/machinery/autolathe/autolathe in GLOB.machines)
		if(autolathe.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				autolathe.wires?.pulse_random()
				autolathe.wires?.pulse_random()
				autolathe.wires?.pulse_random()
				continue
			if(prob(DETONATION_MACHINE_BREAKDOWN_CHANCE))
				autolathe.wires?.cut(WIRE_AUTOLATHE_DISABLE)
				autolathe.take_damage(40, BURN)

/datum/supermatter_explosive_effects/proc/handle_camera_breakdown()
	for(var/obj/machinery/camera/camera in GLOB.cameranet.cameras)
		if(camera.z == src.z)
			if(prob(DETONATION_MACHINE_EFFECT_CHANCE))
				camera.wires?.pulse_random()

//Summons ion storm on tcomms without warning
/datum/supermatter_explosive_effects/proc/handle_ion_storm()
	for(var/obj/machinery/tcomms/core/T in GLOB.tcomms_machines)
		T.start_ion()
		addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/machinery/tcomms, end_ion)), rand(1800, 3000))

//Gives every simple animal chance to become smart.
/datum/supermatter_explosive_effects/proc/handle_mind_giving()
	var/sentience_type = SENTIENCE_ORGANIC
	for(var/mob/living/simple_animal/animal in GLOB.alive_mob_list)
		if(animal.z == src.z)
			if(!(animal in GLOB.player_list) && !animal.mind && (animal.sentience_type == sentience_type))
				if(prob(SIMPLE_ANIMAL_MINDGIVING_CHANCE))
					INVOKE_ASYNC(src, PROC_REF(give_mind), animal)

	for(var/mob/living/carbon/human/lesser/monke in GLOB.alive_mob_list)
		var/turf/T = get_turf(monke)
		if (T.z != src.z)
			continue
		if (monke.health <= monke.maxHealth - 50)
			continue
		if(!(monke in GLOB.player_list) && !monke.mind)
			if(prob(SIMPLE_ANIMAL_MINDGIVING_CHANCE))
				INVOKE_ASYNC(src, PROC_REF(give_mind_lesser), monke)
	return

/datum/supermatter_explosive_effects/proc/give_mind_lesser(mob/living/carbon/human/lesser/monke)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to awaken as [monke]?", ROLE_SENTIENT, TRUE, source = monke)
	if(!length(candidates))
		return
	var/mob/SG = pick(candidates)
	monke.key = SG.key
	monke.health = monke.maxHealth
	greet_sentient(monke)

//Gives mind to a random simple animal. Works asynchronically.
/datum/supermatter_explosive_effects/proc/give_mind(mob/living/simple_animal/animal)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to awaken as [animal]?", ROLE_SENTIENT, TRUE, source = animal)
	if(!length(candidates))
		return
	var/mob/SG = pick(candidates)
	animal.key = SG.key
	animal.universal_speak = 1
	animal.sentience_act()
	animal.can_collar = 1
	animal.maxHealth = max(animal.maxHealth, 200)
	animal.health = animal.maxHealth
	animal.del_on_death = FALSE
	greet_sentient(animal)


/datum/supermatter_explosive_effects/proc/greet_sentient(var/mob/M)
	to_chat(M, span_userdanger("Hello world!"))
	to_chat(M, span_warning("Due to freak radiation, you have gained \
	 						human level intelligence and the ability to speak and understand \
							human language!"))

//All seeds in sector will become strange-like
/datum/supermatter_explosive_effects/proc/handle_seeds_mutation()
	for(var/obj/item/seeds/seed in GLOB.plant_seeds)
		var/turf/t = seed.get_loc_turf()
		if(!t)
			continue
		if(t.z == src.z)
			if(prob(50))
				//We don't actually make them *strange*, just changing their properties to look like *strange* because of optimization.
				seed.transform_into_random()
			else
				seed.product = /obj/item/reagent_containers/food/snacks/grown/random
				seed.transform_into_random()
