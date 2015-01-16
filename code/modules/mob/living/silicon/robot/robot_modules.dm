/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/list/stacktypes


	emp_act(severity)
		if(modules)
			for(var/obj/O in modules)
				O.emp_act(severity)
		if(emag)
			emag.emp_act(severity)
		..()
		return


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.emag = new /obj/item/toy/sword(src)
		src.emag.name = "Placeholder Emag Item"
//		src.jetpack = new /obj/item/toy/sword(src)
//		src.jetpack.name = "Placeholder Upgrade Item"
		return


/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R)

	if(!stacktypes || !stacktypes.len) return

	for(var/T in stacktypes)
		var/O = locate(T) in src.modules
		var/obj/item/stack/S = O

		if(!S)
			src.modules -= null
			S = new T(src)
			src.modules += S
			S.amount = 1

		if(S && S.amount < stacktypes[T])
			S.amount++

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/standard
	name = "standard robot module"


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/weapon/melee/baton/loaded(src)
		src.modules += new /obj/item/weapon/extinguisher(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.emag = new /obj/item/weapon/melee/energy/sword/cyborg(src)
		return

/obj/item/weapon/robot_module/surgeon
	name = "surgeon robot module"
	stacktypes = list(
		/obj/item/stack/medical/advanced/bruise_pack = 5,
		/obj/item/stack/nanopaste = 5
		)

	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.modules += new /obj/item/weapon/reagent_containers/borghypo/surgeon(src)
		src.modules += new /obj/item/weapon/scalpel(src)
		src.modules += new /obj/item/weapon/hemostat(src)
		src.modules += new /obj/item/weapon/retractor(src)
		src.modules += new /obj/item/weapon/cautery(src)
		src.modules += new /obj/item/weapon/bonegel(src)
		src.modules += new /obj/item/weapon/FixOVein(src)
		src.modules += new /obj/item/weapon/bonesetter(src)
		src.modules += new /obj/item/weapon/circular_saw(src)
		src.modules += new /obj/item/weapon/surgicaldrill(src)
		src.modules += new /obj/item/weapon/extinguisher/mini(src)
		src.modules += new /obj/item/stack/medical/advanced/bruise_pack(src)
		src.modules += new /obj/item/stack/nanopaste(src)

		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("pacid", 250)
		src.emag.name = "Polyacid spray"
		return

/obj/item/weapon/robot_module/surgeon/respawn_consumable(var/mob/living/silicon/robot/R)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2)
	..()

/obj/item/weapon/robot_module/crisis
	name = "crisis robot module"
	stacktypes = list(
		/obj/item/stack/medical/ointment = 5,
		/obj/item/stack/medical/bruise_pack = 5,
		/obj/item/stack/medical/splint = 5
		)


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.modules += new /obj/item/device/reagent_scanner/adv(src)
		src.modules += new /obj/item/roller_holder(src)
		src.modules += new /obj/item/stack/medical/advanced/ointment(src)
		src.modules += new /obj/item/stack/medical/advanced/bruise_pack(src)
		src.modules += new /obj/item/stack/medical/splint(src)
		src.modules += new /obj/item/weapon/reagent_containers/borghypo/crisis(src)
		src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)
		src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
		src.modules += new /obj/item/weapon/extinguisher/mini(src)

		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("pacid", 250)
		src.emag.name = "Polyacid spray"
		var/obj/item/weapon/reagent_containers/spray/S = emag
		S.banned_reagents = list()
		return

/obj/item/weapon/robot_module/crisis/respawn_consumable(var/mob/living/silicon/robot/R)

	var/obj/item/weapon/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2)

	..()

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

	stacktypes = list(
		/obj/item/stack/sheet/metal = 50,
		/obj/item/stack/sheet/glass = 50,
		/obj/item/stack/sheet/rglass = 50,
		/obj/item/stack/cable_coil = 50,
		/obj/item/stack/rods = 15,
		/obj/item/stack/tile/plasteel = 15
		)

	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/borg/sight/meson(src)
		src.modules += new /obj/item/weapon/rcd/borg(src)
		src.modules += new /obj/item/weapon/extinguisher(src)
		src.modules += new /obj/item/weapon/weldingtool/largetank(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/weapon/wirecutters(src)
		src.modules += new /obj/item/device/multitool(src)
		src.modules += new /obj/item/device/t_scanner(src)
		src.modules += new /obj/item/device/analyzer(src)
		src.modules += new /obj/item/taperoll/engineering(src)
		src.modules += new /obj/item/weapon/gripper(src)
		src.modules += new /obj/item/weapon/matter_decompiler(src)

		src.emag = new /obj/item/borg/stun(src)

		var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
		M.amount = 50
		src.modules += M

		var/obj/item/stack/sheet/rglass/cyborg/R = new /obj/item/stack/sheet/rglass/cyborg(src)
		R.amount = 50
		src.modules += R

		var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src)
		G.amount = 50
		src.modules += G

		var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
		W.amount = 50
		src.modules += W

		var/obj/item/stack/rods/Q = new /obj/item/stack/rods(src)
		Q.amount = 15
		src.modules += Q

		var/obj/item/stack/tile/plasteel/F = new /obj/item/stack/tile/plasteel(src) //floor tiles not regular plasteel, calm down
		F.amount = 15
		src.modules += F

		return

/obj/item/weapon/robot_module/security
	name = "security robot module"


	New()
		src.modules += new /obj/item/device/flashlight/seclite(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
		src.modules += new /obj/item/weapon/melee/baton/robot(src)
		src.modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
		src.modules += new /obj/item/taperoll/police(src)
		src.modules += new /obj/item/device/taperecorder(src)
		src.emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)
		return


/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/weapon/soap/nanotrasen(src)
		src.modules += new /obj/item/weapon/storage/bag/trash(src)
		src.modules += new /obj/item/weapon/mop(src)
		src.modules += new /obj/item/device/lightreplacer(src)
		src.modules += new /obj/item/weapon/holosign_creator(src)
		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("lube", 250)
		src.emag.name = "Lube spray"
		return



/obj/item/weapon/robot_module/butler
	name = "service robot module"


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
		src.modules += new /obj/item/weapon/pen(src)
		src.modules += new /obj/item/weapon/razor(src)
		src.modules += new /obj/item/device/violin(src)

		var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
		M.matter = 30
		src.modules += M

		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)
		src.modules += new /obj/item/weapon/lighter/zippo(src)
		src.modules += new /obj/item/weapon/tray/robotray(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
		src.emag = new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)

		var/datum/reagents/R = new/datum/reagents(50)
		src.emag.reagents = R
		R.my_atom = src.emag
		R.add_reagent("beer2", 50)
		src.emag.name = "Mickey Finn's Special Brew"
		return

/obj/item/weapon/robot_module/butler/respawn_consumable(var/mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent("enzyme", 2)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/food/drinks/cans/beer/B = src.emag
		B.reagents.add_reagent("beer2", 2)

/*
/obj/item/weapon/robot_module/clerical //Whyyyyy?
	name = "clerical robot module"

	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/weapon/pen/robopen(src)
		src.modules += new /obj/item/weapon/form_printer(src)
		src.modules += new /obj/item/device/taperecorder(src)
		src.modules += new /obj/item/weapon/gripper/paperwork(src)

		src.emag = new /obj/item/weapon/stamp/denied(src)
*/

/obj/item/weapon/robot_module/miner
	name = "miner robot module"


	New()
		src.modules += new /obj/item/device/flashlight/lantern(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/borg/sight/meson(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/storage/bag/ore(src)
		src.modules += new /obj/item/weapon/pickaxe/borgdrill(src)
		src.modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
		src.emag = new /obj/item/borg/stun(src)
		return

/obj/item/weapon/robot_module/deathsquad
	name = "NT advanced combat module"

/obj/item/weapon/robot_module/deathsquad/New()
	src.modules += new /obj/item/device/flash/cyborg(src)
	src.modules += new /obj/item/device/flashlight(src)
	src.modules += new /obj/item/borg/sight/thermal(src)
	src.modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/cyborg(src)
	src.modules += new /obj/item/weapon/tank/jetpack/carbondioxide(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = null
	return

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"

/obj/item/weapon/robot_module/syndicate/New()
	src.modules += new /obj/item/device/flash/cyborg(src)
	src.modules += new /obj/item/device/flashlight(src)
	src.modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	src.modules += new /obj/item/weapon/gun/energy/crossbow/cyborg(src)
	src.modules += new /obj/item/weapon/card/emag(src)
	src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
	src.modules += new /obj/item/weapon/tank/jetpack/carbondioxide(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.emag = null
	return

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash/cyborg(src)
		src.modules += new /obj/item/borg/sight/thermal(src)
		src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
		src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
		src.modules += new /obj/item/borg/combat/shield(src)
		src.modules += new /obj/item/borg/combat/mobility(src)
		src.modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
		src.emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)
		return

/obj/item/weapon/robot_module/alien/hunter
	name = "alien hunter module"

	New()
		src.modules += new /obj/item/weapon/melee/energy/alien/claws(src)
		src.modules += new /obj/item/device/flash/cyborg/alien(src)
		src.modules += new /obj/item/borg/sight/thermal/alien(src)
		var/obj/item/weapon/reagent_containers/spray/alien/stun/S = new /obj/item/weapon/reagent_containers/spray/alien/stun(src)
		S.reagents.add_reagent("stoxin",250) //nerfed to sleeptoxin to make it less instant drop.
		src.modules += S
		var/obj/item/weapon/reagent_containers/spray/alien/smoke/A = new /obj/item/weapon/reagent_containers/spray/alien/smoke(src)
		S.reagents.add_reagent("water",50) //Water is used as a dummy reagent for the smoke bombs. More of an ammo counter.
		src.modules += A
		src.emag = new /obj/item/weapon/reagent_containers/spray/alien/acid(src)
		src.emag.reagents.add_reagent("pacid", 125)
		src.emag.reagents.add_reagent("sacid", 125)

/obj/item/weapon/robot_module/drone
	name = "drone module"
	stacktypes = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/mineral/plastic = 1,
		/obj/item/stack/sheet/rglass = 5,
		/obj/item/stack/tile/wood = 5,
		/obj/item/stack/rods = 15,
		/obj/item/stack/tile/plasteel = 15,
		/obj/item/stack/sheet/metal = 20,
		/obj/item/stack/sheet/glass = 20,
		/obj/item/stack/cable_coil = 30
		)

	New()
		src.modules += new /obj/item/weapon/weldingtool(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/weapon/wirecutters(src)
		src.modules += new /obj/item/device/multitool(src)
		src.modules += new /obj/item/device/lightreplacer(src)
		src.modules += new /obj/item/weapon/gripper(src)
		src.modules += new /obj/item/weapon/matter_decompiler(src)
		src.modules += new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
		src.modules += new /obj/item/weapon/soap(src)

		src.emag = new /obj/item/weapon/pickaxe/plasmacutter(src)
		src.emag.name = "Plasma Cutter"

		for(var/T in stacktypes)
			var/obj/item/stack/sheet/W = new T(src)
			W.amount = stacktypes[T]
			src.modules += W

		return

/obj/item/weapon/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/spray/cleaner/C = locate() in src.modules
	C.reagents.add_reagent("cleaner", 3)

	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R)

	..()

	return

//checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if (!istype(src.loc, /mob/living/silicon/robot))
		return 0

	var/mob/living/silicon/robot/R = src.loc

	return (src in R.module.modules)
