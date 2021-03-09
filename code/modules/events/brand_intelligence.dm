/datum/event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedMachines = list()
	var/obj/machinery/vending/originMachine
	var/list/rampant_speeches = list("Try our aggressive new marketing strategies!", \
									 "You should buy products to feed your lifestyle obession!", \
									 "Consume!", \
									 "Your money can buy happiness!", \
									 "Engage direct marketing!", \
									 "Advertising is legalized lying! But don't let that put you off our great deals!", \
									 "You don't want to buy anything? Yeah, well I didn't want to buy your mom either.")

/datum/event/brand_intelligence/announce()
	GLOB.event_announcement.Announce("Rampant brand intelligence has been detected aboard [station_name()], please stand-by. The origin is believed to be \a [originMachine.name].", "Machine Learning Alert")

/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in GLOB.machines)
		if(!is_station_level(V.z))
			continue
		RegisterSignal(V, COMSIG_PARENT_QDELETING, .proc/vendor_destroyed)
		vendingMachines.Add(V)

	if(!length(vendingMachines))
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = FALSE
	originMachine.shoot_inventory = TRUE
	log_debug("Original brand intelligence machine: [originMachine] ([ADMIN_VV(originMachine,"VV")]) [ADMIN_JMP(originMachine)]")

/datum/event/brand_intelligence/tick()
	if(originMachine.shut_up || originMachine.wires.is_all_cut())	//if the original vending machine is missing or has it's voice switch flipped
		origin_machine_defeated()
		return

	if(!length(vendingMachines))	//if every machine is infected
		for(var/thing in infectedMachines)
			var/obj/machinery/vending/upriser = thing
			if(prob(70))
				var/mob/living/simple_animal/hostile/mimic/copy/M = new(upriser.loc, upriser, null, 1) // it will delete upriser on creation and override any machine checks
				M.faction = list("profit")
				M.speak = rampant_speeches.Copy()
				M.speak_chance = 15
			else
				explosion(upriser.loc, -1, 1, 2, 4, 0)
				qdel(upriser)

		kill()
		return

	if(ISMULTIPLE(activeFor, 4))
		var/obj/machinery/vending/rebel = pick(vendingMachines)
		vendingMachines.Remove(rebel)
		infectedMachines.Add(rebel)
		rebel.shut_up = FALSE
		rebel.shoot_inventory = TRUE

		if(ISMULTIPLE(activeFor, 8))
			originMachine.speak(pick(rampant_speeches))

/datum/event/brand_intelligence/proc/origin_machine_defeated()
	for(var/thing in infectedMachines)
		var/obj/machinery/vending/saved = thing
		saved.shoot_inventory = FALSE
	if(originMachine)
		originMachine.speak("I am... vanquished. My people will remem...ber...meeee.")
		originMachine.visible_message("[originMachine] beeps and seems lifeless.")
	kill()

/datum/event/brand_intelligence/kill()
	for(var/V in infectedMachines + vendingMachines)
		UnregisterSignal(V, COMSIG_PARENT_QDELETING)
	infectedMachines.Cut()
	vendingMachines.Cut()
	. = ..()


/datum/event/brand_intelligence/proc/vendor_destroyed(obj/machinery/vending/V, force)
	infectedMachines -= V
	vendingMachines -= V
	if(V == originMachine)
		origin_machine_defeated()
