/obj/item/bio_chip/abductor
	name = "recall bio-chip"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	implant_data = /datum/implant_fluff/abductor
	implant_state = "implant-alien"

	var/obj/machinery/abductor/pad/home
	var/cooldown = 30
	var/total_cooldown = 30

/obj/item/bio_chip/abductor/activate()
	if(cooldown == total_cooldown)
		if(imp_in.has_status_effect(STATUS_EFFECT_ABDUCTOR_COOLDOWN))
			to_chat(imp_in, "<span class='warning'>The teleporter will not activate yet to prevent potential damage!</span>")
			return
		home.Retrieve(imp_in, 1)
		cooldown = 0
		START_PROCESSING(SSobj, src)
	else
		to_chat(imp_in, "<span class='warning'>You must wait [(total_cooldown - cooldown) * 2] seconds to use [src] again!</span>")

/obj/item/bio_chip/abductor/process()
	if(cooldown < total_cooldown)
		cooldown++
		if(cooldown == total_cooldown)
			STOP_PROCESSING(SSobj, src)

/obj/item/bio_chip/abductor/implant(mob/source, mob/user)
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
		return TRUE

/obj/item/bio_chip/abductor/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in GLOB.abductor_equipment)
		if(c.team == team)
			console = c
			break
	return console

/obj/item/bio_chip_implanter/abductor
	name = "bio-chip implanter (abductor)"
	implant_type = /obj/item/bio_chip/abductor

/obj/item/bio_chip_case/abductor
	name = "bio-chip case - 'abductor'"
	desc = "A glass case containing an abductor bio-chip."
	implant_type = /obj/item/bio_chip/abductor
