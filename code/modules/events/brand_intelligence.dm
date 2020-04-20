/datum/event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedMachines = list()
	var/obj/machinery/vending/originMachine
	var/list/rampant_speeches = list("Pruebe nuestras nuevas y agresivas estrategias de marketing.!", \
									 "Deberias comprar productos para alimentar tu obsesion por el estilo de vida!", \
									 "Consume!", \
									 "Tu dinero puede comprar la felicidad!", \
									 "Iniciando el marketing directo!", \
									 "La publicidad es una mentira legalizada! Pero no dejes que eso te desanime de nuestras grandes ofertas!", \
									 "No quieres comprar nada? Si, bueno, yo tampoco queria comprar a tu madre.")

/datum/event/brand_intelligence/announce()
	GLOB.event_announcement.Announce("Se ha detectado inteligencia desenfrenada a bordo de la [station_name()], Por favor espere. Se cree que el origen es \a [originMachine.name].", "Alerta de aprendizaje automatico")

/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in GLOB.machines)
		if(!is_station_level(V.z))	continue
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1
	log_debug("Original brand intelligence machine: [originMachine] ([ADMIN_VV(originMachine,"VV")]) [ADMIN_JMP(originMachine)]")

/datum/event/brand_intelligence/tick()
	if(!originMachine || QDELETED(originMachine) || originMachine.shut_up || originMachine.wires.IsAllCut())	//if the original vending machine is missing or has it's voice switch flipped
		for(var/obj/machinery/vending/saved in infectedMachines)
			saved.shoot_inventory = 0
		if(originMachine)
			originMachine.speak("Estoy ... vencido. Mi gente me recor...dara....")
			originMachine.visible_message("[originMachine] suena y parece sin vida.")
		kill()
		return

	if(!vendingMachines.len)	//if every machine is infected
		for(var/obj/machinery/vending/upriser in infectedMachines)
			if(prob(70) && !QDELETED(upriser))
				var/mob/living/simple_animal/hostile/mimic/copy/M = new(upriser.loc, upriser, null, 1) // it will delete upriser on creation and override any machine checks
				M.faction = list("profit")
				M.speak = rampant_speeches.Copy()
				M.speak_chance = 15
			else
				explosion(upriser.loc, -1, 1, 2, 4, 0)
				qdel(upriser)

		kill()
		return

	if(IsMultiple(activeFor, 4))
		var/obj/machinery/vending/rebel = pick(vendingMachines)
		vendingMachines.Remove(rebel)
		infectedMachines.Add(rebel)
		rebel.shut_up = 0
		rebel.shoot_inventory = 1

		if(IsMultiple(activeFor, 8))
			originMachine.speak(pick(rampant_speeches))
