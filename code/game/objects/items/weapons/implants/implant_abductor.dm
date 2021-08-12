/obj/item/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	activated = 1
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	var/obj/machinery/abductor/pad/home
	/// How long is the delay between each implant activation.
	var/cooldown_time = 60 SECONDS
	/// Cooldown timer to track how long is left before the implant is available again.
	COOLDOWN_DECLARE(recall_cooldown)

/obj/item/implant/abductor/activate()
	var/time_left = round(COOLDOWN_TIMELEFT(src, recall_cooldown) / 10)
	if(time_left)
		to_chat(imp_in, "<span class='warning'>You must wait [time_left] second\s to use [src] again!</span>")
	else
		COOLDOWN_START(src, recall_cooldown, cooldown_time)
		home.Retrieve(imp_in)

/obj/item/implant/abductor/implant(mob/source, mob/user)
	if(..())
		var/obj/machinery/abductor/console/console
		if(ishuman(source))
			var/mob/living/carbon/human/H = source
			if(isabductor(H))
				var/datum/species/abductor/S = H.dna.species
				console = get_team_console(S.team)
				home = console.pad

		if(!home)
			console = get_team_console(pick(1, 2, 3, 4))
			home = console.pad
		return 1

/obj/item/implant/abductor/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in GLOB.abductor_equipment)
		if(c.team == team)
			console = c
			break
	return console
