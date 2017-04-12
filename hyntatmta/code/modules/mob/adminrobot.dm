/obj/item/weapon/robot_module/admin
	name = "admin module"
	module_type = "Black Moon"
	subsystems = list(
		/mob/living/silicon/proc/subsystem_power_monitor,
		/mob/living/silicon/proc/subsystem_crew_monitor
		)
	module_actions = list(
		/datum/action/innate/robot_sight/meson,
		/datum/action/innate/robot_sight/thermal
	)
	stacktypes = list(
		/obj/item/stack/sheet/metal/cyborg = 50,
		/obj/item/stack/sheet/glass/cyborg = 50,
		/obj/item/stack/sheet/rglass/cyborg = 50,
		/obj/item/stack/cable_coil/cyborg = 50,
		/obj/item/stack/rods/cyborg = 60,
		/obj/item/stack/tile/plasteel = 20,
		/obj/item/stack/medical/bruise_pack/advanced = 5,
		/obj/item/stack/medical/ointment/advanced = 5,
		/obj/item/stack/medical/splint = 5,
		/obj/item/stack/nanopaste = 5
		)

/obj/item/weapon/robot_module/admin/New()
	..()
	modules += new /obj/item/weapon/rcd/borg(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/weapon/gripper(src)
	modules += new /obj/item/weapon/matter_decompiler(src)
	modules += new /obj/item/device/floor_painter(src)
	modules += new /obj/item/device/healthanalyzer/advanced(src)
	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/weapon/borg_defib(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	modules += new /obj/item/weapon/reagent_containers/dropper(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced(src)
	modules += new /obj/item/stack/medical/ointment/advanced(src)
	modules += new /obj/item/stack/nanopaste(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/bonegel(src)
	modules += new /obj/item/weapon/FixOVein(src)
	modules += new /obj/item/weapon/bonesetter(src)
	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/surgicaldrill(src)
	modules += new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
	modules += new /obj/item/weapon/storage/bag/trash/bluespace(src)
	modules += new /obj/item/weapon/mop/advanced/cyborg(src)
	modules += new /obj/item/device/lightreplacer(src)
	modules += new /obj/item/weapon/lighter/zippo(src)
	modules += new /obj/item/weapon/pen(src)
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/gun/cyborg(src)
	modules += new /obj/item/taperoll/police(src)
	modules += new /obj/item/weapon/pickaxe/drill/jackhammer(src)
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/storage/bag/ore/cyborg(src)
	modules += new /obj/item/weapon/hand_tele(src)

	emag = new /obj/item/weapon/gun/energy/laser/instakill/blue(src) //*scream

	for(var/G in stacktypes)
		var/obj/item/stack/sheet/M = new G(src)
		M.amount = stacktypes[G]
		modules += M

	fix_modules()

/obj/item/weapon/robot_module/admin/add_languages(var/mob/living/silicon/robot/R)
	R.add_language("Galactic Common", 1)
	R.add_language("Sol Common", 1)
	R.add_language("Tradeband", 1)
	R.add_language("Gutter", 1)
	R.add_language("Sinta'unathi", 1)
	R.add_language("Siik'tajr", 1)
	R.add_language("Canilunzt", 1)
	R.add_language("Skrellian", 1)
	R.add_language("Vox-pidgin", 1)
	R.add_language("Rootspeak", 1)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 1)
	R.add_language("Bubblish", 1)
	R.add_language("Clownish",1)

/mob/living/silicon/robot/admin
	base_icon = "adminrobot"
	icon_state = "adminrobot"
	modtype = "admin"
	designation = "admin"
	maxHealth = 1000
	health = 1000

/mob/living/silicon/robot/admin/init()
	..()
	module = new /obj/item/weapon/robot_module/admin(src)
	//languages
	module.add_languages(src)
	//subsystems
	status_flags &= ~CANPUSH

	notify_ai(2)
