/obj/item/implant/abductor
	name = "emergency teleport"
	desc = "Returns you to the mothership, at the cost of energy reserves."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	var/obj/machinery/abductor/pad/home
	var/cooldown = 5
	var/total_cooldown = 5

/obj/item/implant/abductor/activate()
	var/datum/antagonist/abductor/A = imp_in.mind.has_antag_datum(/datum/antagonist/abductor)
	if(A && A.team)
		if(!A.team.energy_reserves && !istype(get_area(imp_in), /area/abductor_ship))
			to_chat(imp_in, "<span class='danger'>Your mothership is out of emergency energy! Find an exit point!</span>")
			return FALSE
		if(cooldown != total_cooldown)
			to_chat(imp_in, "<span class='warning'>You must wait [(total_cooldown - cooldown)*2] seconds to use [src] again!</span>")
			return FALSE
		if(!istype(get_area(imp_in), /area/abductor_ship))
			A.team.spend_energy(1)
		cooldown = 0
		START_PROCESSING(SSobj, src)
		home.Retrieve(imp_in, 1)
	else
		to_chat(imp_in, "<span class='warning'>You hear a harsh noise followed by gibberish. Nothing else happens.</span>")
		return FALSE

/obj/item/implant/abductor/process()
	if(cooldown < total_cooldown)
		cooldown++
		if(cooldown == total_cooldown)
			STOP_PROCESSING(SSobj, src)

/obj/item/implant/abductor/implant(mob/source, mob/user)
	if(..())
		var/obj/machinery/abductor/console/console
		if(ishuman(source))
			var/mob/living/carbon/human/H = source
			if(isabductor(H))
				var/datum/species/abductor/S = H.dna.species
				console = get_team_console(S.team_number)
				home = console.pad

		if(!home)
			console = get_team_console(pick(1, 2, 3, 4))
			home = console.pad
		return 1

/obj/item/implant/abductor/proc/get_team_console(team_number)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in GLOB.abductor_equipment)
		if(c.team_number == team_number)
			console = c
			break
	return console
