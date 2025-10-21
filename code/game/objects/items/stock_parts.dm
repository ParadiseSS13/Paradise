////////////////////////////////////////
// MARK: RPEDs
////////////////////////////////////////
/obj/item/storage/part_replacer
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	w_class = WEIGHT_CLASS_HUGE
	can_hold = list(
		/obj/item/stock_parts,
		// This type is part of can_hold, but is added separately in Initialize to avoid picking up unwanted subtypes.
		// /obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/bluespace
		)
	storage_slots = 50
	use_to_pickup = TRUE
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = TRUE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 100
	usesound = 'sound/items/rped.ogg'
	var/works_from_distance = FALSE
	var/primary_sound = 'sound/items/rped.ogg'
	var/alt_sound = null

/obj/item/storage/part_replacer/Initialize(mapload)
	. = ..()
	can_hold[/obj/item/reagent_containers/glass/beaker] = TRUE

/obj/item/storage/part_replacer/can_be_inserted(obj/item/I, stop_messages = FALSE)
	if(!istype(I, /obj/item/reagent_containers/glass/beaker))
		return ..()

	var/obj/item/reagent_containers/glass/beaker/B = I
	if(B.reagents?.total_volume)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[src] cannot hold [I] while it contains liquid.</span>")
		return FALSE
	return ..()

/obj/item/storage/part_replacer/afterattack__legacy__attackchain(obj/machinery/M, mob/user, proximity_flag, params)
	if(!istype(M))
		return ..()

	if(!proximity_flag)
		if(!works_from_distance)
			return
		if(get_dist(user, M) > (user.client.maxview() / 2))
			message_admins("\[EXPLOIT] [key_name_admin(user)] attempted to upgrade machinery with a BRPED via a camera console (attempted range exploit).")
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			to_chat(user, "<span class='notice'>ERROR: [M] is out of [src]'s range!</span>")
			return

	if(M.component_parts)
		M.exchange_parts(user, src)
		if(works_from_distance)
			user.Beam(M, icon_state="rped_upgrade", icon='icons/effects/effects.dmi', time=5)

/obj/item/storage/part_replacer/tier4/populate_contents()
	for(var/amount in 1 to 30)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/cell/bluespace(src)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

////////////////////////////////////////
// 		Bluespace Part Replacer
////////////////////////////////////////
/obj/item/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = "A version of the RPED that allows for replacement of parts and scanning from a distance, along with higher capacity for parts."
	icon_state = "BS_RPED"
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 400
	max_combined_w_class = 800
	works_from_distance = TRUE
	primary_sound = 'sound/items/pshoom.ogg'
	alt_sound = 'sound/items/pshoom_2.ogg'
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.5

/obj/item/storage/part_replacer/bluespace/tier4/populate_contents()
	for(var/amount in 1 to 30)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/cell/bluespace(src)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exchanging or installing parts.
	if(alt_sound && prob(3))
		playsound(src, alt_sound, 40, 1)
	else
		playsound(src, primary_sound, 40, 1)

////////////////////////////////////////
// MARK: Stock parts
////////////////////////////////////////
/obj/item/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'icons/obj/stock_parts.dmi'
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL
	var/rating = 1
	usesound = 'sound/items/deconstruct.ogg'

//Rank 1

/obj/item/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = "powerstorage=1"
	materials = list(MAT_METAL=50, MAT_GLASS=50)

/obj/item/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	materials = list(MAT_METAL=50, MAT_GLASS=20)

/obj/item/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	materials = list(MAT_METAL=30)

/obj/item/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	materials = list(MAT_METAL=10, MAT_GLASS=20)

/obj/item/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container used to hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	materials = list(MAT_METAL=80)

//Rank 2

/obj/item/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	origin_tech = "powerstorage=3"
	rating = 2
	materials = list(MAT_METAL=50, MAT_GLASS=50)

/obj/item/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	icon_state = "adv_scan_module"
	origin_tech = "magnets=3"
	rating = 2
	materials = list(MAT_METAL=50, MAT_GLASS=20)

/obj/item/stock_parts/manipulator/nano
	name = "nano-manipulator"
	icon_state = "nano_mani"
	origin_tech = "materials=3;programming=2"
	rating = 2
	materials = list(MAT_METAL=30)

/obj/item/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	icon_state = "high_micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	materials = list(MAT_METAL=10, MAT_GLASS=20)

/obj/item/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	icon_state = "advanced_matter_bin"
	origin_tech = "materials=3"
	rating = 2
	materials = list(MAT_METAL=80)

//Rating 3

/obj/item/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	origin_tech = "powerstorage=4;engineering=4"
	rating = 3
	materials = list(MAT_METAL=50, MAT_GLASS=50)

/obj/item/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	origin_tech = "magnets=4;engineering=4"
	rating = 3
	materials = list(MAT_METAL=50, MAT_GLASS=20)

/obj/item/stock_parts/manipulator/pico
	name = "pico-manipulator"
	icon_state = "pico_mani"
	origin_tech = "materials=4;programming=4;engineering=4"
	rating = 3
	materials = list(MAT_METAL=30)

/obj/item/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	origin_tech = "magnets=4;engineering=4"
	rating = 3
	materials = list(MAT_METAL=10, MAT_GLASS=20)

/obj/item/stock_parts/matter_bin/super
	name = "super matter bin"
	icon_state = "super_matter_bin"
	origin_tech = "materials=4;engineering=4"
	rating = 3
	materials = list(MAT_METAL=80)

//Rating 4

/obj/item/stock_parts/capacitor/quadratic
	name = "quadratic capacitor"
	desc = "An ultra-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "quadratic_capacitor"
	origin_tech = "powerstorage=5;materials=4;engineering=4"
	rating = 4
	materials = list(MAT_METAL=50, MAT_GLASS=50)

/obj/item/stock_parts/scanning_module/triphasic
	name = "triphasic scanning module"
	desc = "A compact, ultra resolution triphasic scanning module used in the construction of certain devices."
	icon_state = "triphasic_scan_module"
	origin_tech = "magnets=5;materials=4;engineering=4"
	rating = 4
	materials = list(MAT_METAL=50, MAT_GLASS=20)

/obj/item/stock_parts/manipulator/femto
	name = "femto-manipulator"
	icon_state = "femto_mani"
	origin_tech = "materials=6;programming=4;engineering=4"
	rating = 4
	materials = list(MAT_METAL=30)

/obj/item/stock_parts/micro_laser/quadultra
	name = "quad-ultra micro-laser"
	icon_state = "quadultra_micro_laser"
	origin_tech = "magnets=5;materials=4;engineering=4"
	rating = 4
	materials = list(MAT_METAL=10, MAT_GLASS=20)

/obj/item/stock_parts/matter_bin/bluespace
	name = "bluespace matter bin"
	icon_state = "bluespace_matter_bin"
	origin_tech = "materials=6;programming=4;engineering=4"
	rating = 4
	materials = list(MAT_METAL=80)
