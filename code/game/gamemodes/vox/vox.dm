#define MAX_VOX_KILLS 10 //Number of kills during the round before the Inviolate is broken.
						 //Would be nice to use vox-specific kills but is currently not feasible.

var/global/vox_kills = 0 //Used to check the Inviolate.

/datum/game_mode/
	var/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.

//Vox global procs

/datum/game_mode/vox/proc/is_vox_crew_safe()

	if(cortical_stacks.len == 0)
		return 0

	for(var/obj/stack in cortical_stacks)
		if (get_area(stack) != locate(/area/shuttle/vox/station))
			return 0
	return 1

//Vox global objectives.

datum/objective/vox
	proc/choose_target()
		return

datum/objective/vox/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

	check_completion()
		var/datum/game_mode/vox/H = ticker.mode
		if(H.is_vox_crew_safe()) return 1
		return 0

datum/objective/vox/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."
	check_completion()
		if(vox_kills>5) return 0
		return 1


//Vox heist objectives.



datum/objective/vox/heist/kidnap
	choose_target()
		var/list/roles = list("Chief Engineer","Research Director","Roboticist","Chemist","Station Engineer")
		var/list/possible_targets = list()
		var/list/priority_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && (possible_target.assigned_role != "MODE"))
				possible_targets += possible_target
				for(var/role in roles)
					if(possible_target.assigned_role == role)
						priority_targets += possible_target
						continue

		if(priority_targets.len > 0)
			target = pick(priority_targets)
		else if(possible_targets.len > 0)
			target = pick(possible_targets)

		if(target && target.current)
			explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if (target.current.stat == 2)
				return 0 // They're dead. Fail.
			//if (!target.current.restrained())
			//	return 0 // They're loose. Close but no cigar.

			var/area/shuttle/vox/station/A = locate()
			for(var/mob/living/carbon/human/M in A)
				if(target.current == M)
					return 1 //They're restrained on the shuttle. Success.
		else
			return 0

datum/objective/vox/heist/loot

	choose_target()
		var/loot = "an object"
		switch(rand(1,8))
			if(1)
				target = /obj/structure/particle_accelerator
				target_amount = 6
				loot = "a complete particle accelerator"
			if(2)
				target = /obj/machinery/the_singularitygen
				target_amount = 1
				loot = "a gravitational singularity generator"
			if(3)
				target = /obj/machinery/power/emitter
				target_amount = 4
				loot = "four emitters"
			if(4)
				target = /obj/machinery/nuclearbomb
				target_amount = 1
				loot = "a nuclear bomb"
			if(5)
				target = /obj/item/weapon/gun
				target_amount = 6
				loot = "six guns"
			if(6)
				target = /obj/item/weapon/gun/energy
				target_amount = 4
				loot = "four energy guns"
			if(7)
				target = /obj/item/weapon/gun/energy/laser
				target_amount = 2
				loot = "two laser guns"
			if(8)
				target = /obj/item/weapon/gun/energy/ionrifle
				target_amount = 1
				loot = "an ion gun"

		explanation_text = "We are lacking in hardware. Steal [loot]."

	check_completion()

		var/total_amount = 0

		for(var/obj/O in locate(/area/shuttle/vox/station))
			if(istype(O,target)) total_amount++
			for(var/obj/I in O.contents)
				if(istype(I,target)) total_amount++
			if(total_amount >= target_amount) return 1

		var/datum/game_mode/vox/heist/H = ticker.mode
		for(var/datum/mind/raider in H.raiders)
			if(raider.current)
				for(var/obj/O in raider.current.get_contents())
					if(istype(O,target)) total_amount++
					if(total_amount >= target_amount) return 1

		return 0

datum/objective/vox/heist/salvage

	choose_target()
		switch(rand(1,8))
			if(1)
				target = "metal"
				target_amount = 300
			if(2)
				target = "glass"
				target_amount = 200
			if(3)
				target = "plasteel"
				target_amount = 100
			if(4)
				target = "plasma"
				target_amount = 100
			if(5)
				target = "silver"
				target_amount = 50
			if(6)
				target = "gold"
				target_amount = 20
			if(7)
				target = "uranium"
				target_amount = 20
			if(8)
				target = "diamond"
				target_amount = 20

		explanation_text = "Ransack the station and escape with [target_amount] [target]."

	check_completion()

		var/total_amount = 0

		for(var/obj/item/O in locate(/area/shuttle/vox/station))

			var/obj/item/stack/sheet/S
			if(istype(O,/obj/item/stack/sheet))
				if(O.name == target)
					S = O
					total_amount += S.amount
			for(var/obj/I in O.contents)
				if(istype(I,/obj/item/stack/sheet))
					if(I.name == target)
						S = I
						total_amount += S.amount

		var/datum/game_mode/vox/heist/H = ticker.mode
		for(var/datum/mind/raider in H.raiders)
			if(raider.current)
				for(var/obj/item/O in raider.current.get_contents())
					if(istype(O,/obj/item/stack/sheet))
						if(O.name == target)
							var/obj/item/stack/sheet/S = O
							total_amount += S.amount

		if(total_amount >= target_amount) return 1
		return 0


//Vox Trade Objectives

datum/objective/vox/trade/trade

	choose_target()
		var/loot = "an object"
		switch(rand(1,8))
			if(1)
				target = /obj/structure/particle_accelerator
				target_amount = 6
				loot = "a complete particle accelerator"
			if(2)
				target = /obj/machinery/the_singularitygen
				target_amount = 1
				loot = "a gravitational singularity generator"
			if(3)
				target = /obj/machinery/power/emitter
				target_amount = 4
				loot = "four emitters"
			if(4)
				target = /obj/machinery/nuclearbomb
				target_amount = 1
				loot = "a nuclear bomb"
			if(5)
				target = /obj/item/weapon/gun
				target_amount = 6
				loot = "six guns"
			if(6)
				target = /obj/item/weapon/gun/energy
				target_amount = 4
				loot = "four energy guns"
			if(7)
				target = /obj/item/weapon/gun/energy/laser
				target_amount = 2
				loot = "two laser guns"
			if(8)
				target = /obj/item/weapon/gun/energy/ionrifle
				target_amount = 1
				loot = "an ion gun"

		explanation_text = "We are lacking in hardware. Trade for [loot]."

	check_completion()

		var/total_amount = 0

		for(var/obj/O in locate(/area/shuttle/vox/station))
			if(istype(O,target)) total_amount++
			for(var/obj/I in O.contents)
				if(istype(I,target)) total_amount++
			if(total_amount >= target_amount) return 1

		var/datum/game_mode/vox/trade/H = ticker.mode
		for(var/datum/mind/trader in H.traders)
			if(trader.current)
				for(var/obj/O in trader.current.get_contents())
					if(istype(O,target)) total_amount++
					if(total_amount >= target_amount) return 1

		return 0

datum/objective/vox/trade/raw_materials

	choose_target()
		switch(rand(1,8))
			if(1)
				target = "metal"
				target_amount = 300
			if(2)
				target = "glass"
				target_amount = 200
			if(3)
				target = "plasteel"
				target_amount = 100
			if(4)
				target = "plasma"
				target_amount = 100
			if(5)
				target = "silver"
				target_amount = 50
			if(6)
				target = "gold"
				target_amount = 20
			if(7)
				target = "uranium"
				target_amount = 20
			if(8)
				target = "diamond"
				target_amount = 20

		explanation_text = "Trade with the crew for [target_amount] [target]."

	check_completion()

		var/total_amount = 0

		for(var/obj/item/O in locate(/area/shuttle/vox/station))

			var/obj/item/stack/sheet/S
			if(istype(O,/obj/item/stack/sheet))
				if(O.name == target)
					S = O
					total_amount += S.amount
			for(var/obj/I in O.contents)
				if(istype(I,/obj/item/stack/sheet))
					if(I.name == target)
						S = I
						total_amount += S.amount

		var/datum/game_mode/vox/trade/H = ticker.mode
		for(var/datum/mind/trader in H.traders)
			if(trader.current)
				for(var/obj/item/O in trader.current.get_contents())
					if(istype(O,/obj/item/stack/sheet))
						if(O.name == target)
							var/obj/item/stack/sheet/S = O
							total_amount += S.amount

		if(total_amount >= target_amount) return 1
		return 0