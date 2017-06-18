/obj/item/weapon/robot_module/dog
/obj/item/weapon/robot_module/dog/get_standard_pixel_x_offset(mob/living/silicon/robot/R)
	return -16
/obj/item/weapon/robot_module/dog/get_standard_pixel_y_offset(mob/living/silicon/robot/R)
	return 0

//Security
/obj/item/weapon/robot_module/dog/knine
	name = "k9 robot module"
	module_type = "k9"
	custom_icon = 'icons/mob/widerobot.dmi'
	sprites = list(
		"K9 hound" = "k9",
		"K9 Alternative (Static)" = "k92"
	)
	channels = list("Security" = 1)
	can_be_pushed = FALSE

/obj/item/weapon/robot_module/dog/knine/New(mob/living/silicon/robot/R)
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src) //You need cuffs to be a proper sec borg!
	modules += new /obj/item/weapon/dogborg/jaws/big(src) //In case there's some kind of hostile mob.
	modules += new /obj/item/weapon/melee/baton/loaded(src) //Since the pounce module refused to work, they get a stunbaton instead.
	modules += new /obj/item/device/dogborg/boop_module(src) //Boop people on the nose.
	modules += new /obj/item/device/dogborg/tongue(src) //This is so they can clean up bloody evidence after it's examined, and so they can lick crew.
	modules += new /obj/item/taperoll/police(src) //Block out crime scenes.
	modules += new /obj/item/device/dogborg/sleeper/K9(src) //Eat criminals. Bring them to the brig.
	modules += new /obj/item/weapon/gun/energy/disabler/cyborg(src) //They /are/ a security borg, after all.
	..()
	emag	 = new /obj/item/weapon/gun/energy/laser/mounted(src) //Emag. Not a big problem.

/obj/item/weapon/robot_module/dog/knine/respawn_consumable(mob/living/silicon/robot/R, amount)
	var/obj/item/device/flash/F = locate() in modules
	if(F.broken)
		F.broken = 0
		F.times_used = 0
		F.icon_state = "flash"
	else if(F.times_used)
		F.times_used--

//Medical
/obj/item/weapon/robot_module/dog/medihound
	name = "MediHound module"
	module_type = "medihound"
	custom_icon = 'icons/mob/widerobot.dmi'
	channels = list("Medical" = 1)
	can_be_pushed = FALSE
	sprites = list(
					"Medical Hound" = "medihound",
					"Dark Medical Hound (Static)" = "medihounddark"
					)

/obj/item/weapon/robot_module/dog/medihound/New(var/mob/living/silicon/robot/R)
	modules += new /obj/item/weapon/dogborg/jaws/small(src) //In case a patient is being attacked by carp.
	modules += new /obj/item/device/dogborg/boop_module(src) //Boop the crew.
	modules += new /obj/item/device/dogborg/tongue(src) //Clean up bloody items by licking them, and eat rubbish for minor energy.
	modules += new /obj/item/device/healthanalyzer(src) // See who's hurt specificially.
	modules += new /obj/item/device/dogborg/sleeper(src) //So they can nom people and heal them
	modules += new /obj/item/weapon/extinguisher/mini(src) //So they can put burning patients out.
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)//So medi-hounds aren't nearly useless
	modules += new /obj/item/weapon/reagent_containers/syringe(src) //In case the chemist is nice!
	modules += new /obj/item/weapon/reagent_containers/glass/beaker(src)//For holding the chemicals when the chemist is nice
	..()
	emag = null //suggestion?

//Janitorial
/obj/item/weapon/robot_module/dog/scrubpup
	name = "Custodial Hound module"
	module_type = "scrubpup"
	custom_icon = 'icons/mob/widerobot.dmi'
	sprites = list(
					"Custodial Hound" = "scrubpup",
					)
	channels = list("Service" = 1)
	can_be_pushed = FALSE
	clean_on_walk = TRUE//subject to change to diffreniat from janiborg

/obj/item/weapon/robot_module/dog/scrubpup/New(var/mob/living/silicon/robot/R)
	modules += new /obj/item/device/lightreplacer(src)
	modules += new /obj/item/weapon/dogborg/jaws/small(src)
	modules += new /obj/item/device/dogborg/boop_module(src)
	modules += new /obj/item/device/dogborg/tongue(src)
	modules += new /obj/item/weapon/holosign_creator(src)
	modules += new /obj/item/device/dogborg/sleeper/compactor(src)
	..()
	emag = null //suggestion?

/obj/item/weapon/robot_module/dog/scrubpup/respawn_consumable(mob/living/silicon/robot/R, amount)
	var/obj/item/device/lightreplacer/LR = locate() in modules
	LR.Charge(R, amount)