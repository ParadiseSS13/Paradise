/obj/item/grenade/megafauna_hardmode
	name = "\improper HRD-MDE Scanning Grenade"
	desc = "An advanced grenade that releases nanomachines, which enter nearby megafauna. This will enrage them greatly, but allows nanotrasen to fully research their abilities."
	icon_state = "enrager"

/obj/item/grenade/megafauna_hardmode/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	for(var/mob/living/simple_animal/hostile/megafauna/M in range(7, src))
		M.enrage()
		visible_message("<span class='userdanger'>[M] begins to wake up as the nanomachines enter them, it looks pissed!</span>")
	qdel(src)

/obj/item/paper/hardmode
	name = "HRD-MDE Scanner Guide"
	info = {"<b>Welcome to the NT HRD-MDE Project</b><br>
	<br>
	This guide will cover the basics on the Hi-tech Research and Development, Mining Department Experiment project.<br>
	<br>
	These grenades when used, will disperse a cloud of nanomachines into nearbye fauna, allowing a detailed examination of their body structure when alive. We will use this data to develope new products to sell, and we need your help!<br>
	<br>
	We need to see these fauna working at their full potential with the nanomachines in them, so you will have to fight them. As a warning, these nanomachines have been known to irratate and annoy animals in testing, as well injecting a cocktail of drugs into them to get their organs outputting at maximum potential.<br>
	<br>
	We operate on a limited budget, but we do provide payment for participating in this project: 0.1% of profits from any products made from this research, and medals showing off your pride for NT and promoting their research.
	<br><hr>
	<font size =\"1\"><i>By participating in this experiment you waive all rights for compensation of death on the job.</font></i>
"}

/obj/item/disk/fauna_research
	name = "empty HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Seems empty?"
	icon_state = "holodisk"
	var/obj/item/clothing/accessory/medal/output

/obj/item/disk/fauna_research/Initialize(mapload)
	. = ..()
	for(var/obj/structure/closet/C in get_turf(src))
		forceMove(C)
		return

/obj/item/disk/fauna_research/blood_drunk_miner
	name = "blood drunk HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the dash and resistance of the blood drunk miner."
	output = /obj/item/clothing/accessory/medal/blood_drunk

/obj/item/disk/fauna_research/hierophant
	name = "\improper Hierophant HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the energy manipulation and material composition of the Hierophant."
	output = /obj/item/clothing/accessory/medal/plasma/hierophant

/obj/item/disk/fauna_research/ash_drake
	name = "ash drake HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the fire production methods and rapid regeneration of the ash drakes."
	output = /obj/item/clothing/accessory/medal/plasma/ash_drake

/obj/item/disk/fauna_research/vetus
	name = "\improper Vetus Speculator HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the anomaly manipulation and computing processes of the Vetus Speculator."
	output = /obj/item/clothing/accessory/medal/alloy/vetus

/obj/item/disk/fauna_research/colossus
	name = "colossus HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the powerful voice and A-T field of the colossi."
	output = /obj/item/clothing/accessory/medal/silver/colossus

/obj/item/disk/fauna_research/legion
	name = "\improper Legion HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the endless regeneration and disintegration laser of the Legion."
	output = /obj/item/clothing/accessory/medal/silver/legion

/obj/item/disk/fauna_research/bubblegum
	name = "\improper Bubblegum HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the bloodcrawling and \[REDACTED\] of Bubblegum." //I hate this so much
	output = /obj/item/clothing/accessory/medal/gold/bubblegum

