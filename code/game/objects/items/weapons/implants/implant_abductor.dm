/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	activated = 1
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30
	var/total_cooldown = 30

/obj/item/weapon/implant/abductor/activate()
	if(cooldown == total_cooldown)
		home.Retrieve(imp_in,1)
		cooldown = 0
		processing_objects.Add(src)
	else
		to_chat(imp_in, "<span class='warning'>You must wait [(total_cooldown - cooldown)*2] seconds to use [src] again!</span>")

/obj/item/weapon/implant/abductor/process()
	if(cooldown < total_cooldown)
		cooldown++
		if(cooldown == total_cooldown)
			processing_objects.Remove(src)

/obj/item/weapon/implant/abductor/implant(mob/source, mob/user)
	if(..())
		var/obj/machinery/abductor/console/console
		if(ishuman(source))
			var/mob/living/carbon/human/H = source
			if(H.get_species() == "Abductor")
				console = get_team_console(H.mind.abductor.team)
				home = console.pad

		if(!home)
			console = get_team_console(pick(1, 2, 3, 4))
			home = console.pad
		return 1

/obj/item/weapon/implant/abductor/proc/get_team_console(var/team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in abductor_equipment)
		if(c.team == team)
			console = c
			break
	return console