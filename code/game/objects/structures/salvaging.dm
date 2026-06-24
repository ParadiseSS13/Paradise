/obj/structure/salvageable
	name = "broken machinery"
	desc = "It's broken beyond repair. You may be able to salvage something from this."
	icon = 'icons/obj/salvage_structure.dmi'
	density = TRUE
	anchored = TRUE
	var/salvageable_parts = list()
	var/frame_type = /obj/structure/machine_frame

/obj/structure/salvageable/examine(mob/user)
	. = ..()
	. += "You can use a crowbar to salvage this."

/obj/structure/salvageable/proc/dismantle(mob/living/user)
	var/obj/frame = new frame_type(get_turf(src))
	frame.anchored = anchored
	frame.dir = dir
	for(var/path in salvageable_parts)
		if(prob(salvageable_parts[path]))
			new path (loc)

/obj/structure/salvageable/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.a_intent == INTENT_HARM)
		return FALSE
	user.visible_message(
			SPAN_NOTICE("[user] starts dismantling [src]."),
			SPAN_NOTICE("You start salvaging anything useful from [src]..."),
			SPAN_NOTICE("You hear a machine being deconstructed.")
		)
	tool.play_tool_sound(src, 100)
	if(do_after(user, 8 SECONDS, target = src))
		user.visible_message(
			SPAN_NOTICE("[user] dismantles [src]."),
			SPAN_NOTICE("You salvage [src].")
			)
		dismantle(user)
		tool.play_tool_sound(src, 100)
		qdel(src)
	return TRUE

/obj/structure/salvageable/deconstruct(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return FALSE
	user.visible_message(SPAN_NOTICE("[user] starts slicing [src]."), \
					SPAN_NOTICE("You start salvaging anything useful from [src]..."))
	if(tool.use_tool(src, user, 6 SECONDS))
		user.visible_message(SPAN_NOTICE("[user] dismantles [src]."), \
						SPAN_NOTICE("You salvage [src]."))
		dismantle(user)
		qdel(src)
	return TRUE

//Types themself, use them, but not the parent object

/obj/structure/salvageable/machine
	name = "broken machine"
	icon_state = "wreck_pda"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapgold/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,

		/obj/effect/spawner/random/salvage/part/capacitor = 50,
		/obj/effect/spawner/random/salvage/part/capacitor = 50,
		/obj/effect/spawner/random/salvage/part/scanning = 50,
		/obj/effect/spawner/random/salvage/part/scanning = 50,
		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/manipulator = 40,
		/obj/effect/spawner/random/salvage/part/manipulator = 40,
		/obj/effect/spawner/random/salvage_laser = 40,
		/obj/effect/spawner/random/salvage_laser = 40,
	)

/obj/structure/salvageable/computer
	name = "broken computer"
	icon_state = "computer_broken"
	frame_type =  /obj/structure/computerframe
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 90,
		/obj/item/stack/ore/salvage/scrapsilver/five = 90,
		/obj/item/stack/ore/salvage/scrapgold/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,

		/obj/effect/spawner/random/salvage/part/capacitor = 60,

		/obj/effect/spawner/random/circuit/common = 40
	)

/obj/structure/salvageable/autolathe
	name = "broken autolathe"
	icon_state = "wreck_autolathe"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scraptitanium/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,

		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/manipulator = 30,

		/obj/item/stack/sheet/metal/five = 10,
		/obj/item/stack/sheet/glass/five = 10,
		/obj/item/stack/sheet/plastic/five = 10,
		/obj/item/stack/sheet/plasteel/five = 10,
		/obj/item/stack/sheet/mineral/silver/five = 10,
		/obj/item/stack/sheet/mineral/gold/five = 10,
		/obj/item/stack/sheet/mineral/plasma/five = 10,
		/obj/item/stack/sheet/mineral/uranium/five = 5,
		/obj/item/stack/sheet/mineral/diamond/five = 1,
	)

/obj/structure/salvageable/protolathe
	name = "broken protolathe"
	icon_state = "wreck_protolathe"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapplasma/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,

		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/manipulator = 30,
		/obj/effect/spawner/random/salvage/part/manipulator = 30,

		/obj/effect/spawner/random/engineering/tools = 45,
		/obj/effect/spawner/random/medical/surgery_tool = 55,
		/obj/effect/spawner/random/medical/beaker = 45,
		/obj/effect/spawner/random/medical/prosthetic = 25,

		/obj/item/storage/part_replacer = 20,
		/obj/item/storage/part_replacer/bluespace = 1,
		/obj/item/mop = 20,
		/obj/item/mop/advanced = 1, // the holy grail

		/obj/item/stack/sheet/metal/five = 15, //the point isnt the materials in the protolathe wreckage but you can still get them for flavor and stuff
		/obj/item/stack/sheet/glass/five = 15,
		/obj/item/stack/sheet/plastic/five = 15,
		/obj/item/stack/sheet/plasteel/five = 15,
		/obj/item/stack/sheet/mineral/silver/five = 15,
		/obj/item/stack/sheet/mineral/gold/five = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 10,
		/obj/item/stack/sheet/mineral/uranium/five = 5,
		/obj/item/stack/sheet/mineral/diamond/five = 1,
	)

/obj/structure/salvageable/circuit_imprinter
	name = "broken circuit imprinter"
	icon_state = "wreck_circuit_imprinter"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapuranium/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,
		/obj/item/stack/ore/salvage/scrapbluespace = 60,

		/obj/effect/spawner/random/salvage/part/matter_bin = 40,
		/obj/effect/spawner/random/salvage/part/manipulator = 30,

		/obj/effect/spawner/random/circuit/mech = 45,
		/obj/effect/spawner/random/circuit/common = 50,
		/obj/effect/spawner/random/circuit/rare = 5,

		/obj/item/stack/sheet/metal/five = 15, //same as above but more geared towards stuff used by circuit imprinter
		/obj/item/stack/sheet/glass/five = 15,
		/obj/item/stack/sheet/mineral/silver/five = 15,
		/obj/item/stack/sheet/mineral/gold/five = 15,
		/obj/item/stack/ore/bluespace_crystal/refined/five = 5,
		/obj/item/stack/sheet/mineral/diamond/five = 1,
	)

/obj/structure/salvageable/destructive_analyzer
	name = "broken destructive analyzer"
	desc = "If this thing could power up, it would probably slice you in half. You may be able to salvage something from this." //this ones pretty dangerous
	icon_state = "wreck_d_analyzer"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapuranium/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,
		/obj/item/stack/ore/salvage/scrapplasma = 60,

		/obj/effect/spawner/random/salvage/part/scanning = 40,
		/obj/effect/spawner/random/salvage_laser = 30,
		/obj/effect/spawner/random/salvage/part/manipulator = 30,

		/obj/effect/spawner/random/salvage/destructive_analyzer = 65,

		/obj/item/stack/sheet/metal/five = 15, //same as above but more geared towards stuff used by circuit imprinter
		/obj/item/stack/sheet/glass/five = 15,
		/obj/item/stack/sheet/mineral/silver/five = 15,
		/obj/item/stack/sheet/mineral/gold/five = 15,
		/obj/item/stack/ore/bluespace_crystal/refined/five = 5,
		/obj/item/stack/sheet/mineral/diamond/five = 1,
	)

/obj/structure/salvageable/destructive_analyzer/dismantle(mob/living/user)
	. = ..()
	var/danger_level = rand(1,100)
	switch(danger_level) //scary.
		if(1 to 40)
			audible_message(SPAN_NOTICE("You can hear the sound of broken glass in the [src]."))
		if(41 to 60)
			visible_message(SPAN_DANGER("You flinch as the [src]'s laser apparatus lights up, but your tool destroys it before it activates..."))
		if(61 to 79)
			visible_message(SPAN_DANGER("You see a dim light from the [src] before the laser reactivates in your face!"))
			shoot_projectile(user, /obj/projectile/beam/scatter)
			do_sparks(5, TRUE, src)
		if(80 to 89)
			visible_message(SPAN_DANGER("You see a bright light from the [src] before the laser reactivates in your face!"))
			shoot_projectile(user, /obj/projectile/beam)
			do_sparks(5, TRUE, src)
		if(90 to 100)
			visible_message(SPAN_DANGER("You see an intense light from the [src] before the laser reactivates in your face!"))
			shoot_projectile(user, /obj/projectile/beam/laser/heavylaser)
			do_sparks(5, TRUE, src) //i'd like to make this flash people. but i'm not sure how to do that. shame!

/obj/structure/salvageable/destructive_analyzer/proc/shoot_projectile(mob/living/target, obj/projectile/projectile_to_shoot, set_angle)
	var/obj/projectile/projectile_being_shot = new projectile_to_shoot(get_turf(src))
	projectile_being_shot.preparePixelProjectile(get_step(src, pick(GLOB.alldirs)), get_turf(src))
	projectile_being_shot.firer = src
	if(isnum(set_angle))
		projectile_being_shot.fire(set_angle)
	else
		projectile_being_shot.fire()

/obj/structure/salvageable/server
	name = "broken server"
	icon_state = "wreck_server"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapuranium/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,
		/obj/item/stack/ore/salvage/scrapbluespace = 60,

		/obj/item/disk/data = 20,
		/obj/item/disk/design_disk = 20,
		/obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe = 20,
		/obj/item/disk/nuclear/training = 20,
		/obj/item/disk/plantgene = 20,
		/obj/item/disk/rnd_backup_disk = 20,
		/obj/item/disk/tech_disk = 20,
	)

/obj/structure/salvageable/server/dismantle(mob/living/user)
	. = ..()
	var/danger_level = rand(1,100)
	switch(danger_level) //ever wanted the extreme danger of turn based rng but in space station 13?
		if(1 to 45)
			audible_message(SPAN_NOTICE("The [src] makes a crashing sound as its salvaged."))

		if(46 to 89)
			playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, FALSE)
			audible_message(SPAN_DANGER("You hear a buzz from the [src] and a voice,"))

			new /mob/living/simple_animal/bot/medbot/syndicate/emagged/(get_turf(src))

		if(90 to 100)
			playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, FALSE)
			audible_message(SPAN_DANGER("You hear a buzz from the [src] and a voice,"))

			new /mob/living/simple_animal/bot/cleanbot/(get_turf(src))

/obj/structure/salvageable/safe_server //i am evil and horrible and i don't deserve to touch code
	name = "broken server"
	icon_state = "wreck_server"
	salvageable_parts = list(
		/obj/item/stack/sheet/glass/two = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/stack/ore/salvage/scrapuranium/five = 60,
		/obj/item/stack/ore/salvage/scrapmetal/five = 60,
		/obj/item/stack/ore/salvage/scrapbluespace = 60,


		/obj/item/disk/tech_disk = 20,
		/obj/item/disk/data = 20,
		/obj/item/disk/plantgene = 20,
	)

/obj/structure/salvageable/seed
	name = "ruined seed vendor"
	desc = "This is where the seeds lived. Maybe you can still get some?"//megaseed voiceline reference
	icon_state = "seeds_broken"
	icon = 'icons/obj/vending.dmi'
	color = "#808080"

	salvageable_parts = list(
		/obj/item/seeds/random = 80,
		/obj/item/seeds/random = 40,
		/obj/item/seeds/random = 40,
		/obj/item/stack/ore/salvage/scrapmetal/five = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/disk/plantgene = 20,
	)

/obj/structure/salvageable/seed/dismantle(mob/living/user)
	. = ..()
	var/danger_level = rand(1,100)
	switch(danger_level)
		if(1 to 50)
			audible_message(SPAN_NOTICE("The [src] buzzes softly as it falls apart."))

		if(51 to 80)
			playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, FALSE)
			audible_message(SPAN_DANGER("As the [src] collapses, an oversized tomato lunges out from inside!"))
			new /mob/living/basic/killertomato(get_turf(src))

		if(81 to 100)
			playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, FALSE)
			audible_message(SPAN_DANGER("A bundle of vines unfurls from inside the [src]!"))
			new /mob/living/simple_animal/hostile/venus_human_trap(get_turf(src))

/obj/structure/salvageable/kitchenvend
	name = "broken-down kitchen vendor"
	desc = "A ruined kitchen vending machine. Some of its contents might still be intact."
	icon_state = "dinnerware_broken"
	icon = 'icons/obj/vending.dmi'
	salvageable_parts = list(
		/obj/item/kitchen/rollingpin = 80,
		/obj/item/reagent_containers/cooking/bowl = 80,
		/obj/item/trash/bowl = 80,
		/obj/item/kitchen/utensil/fork = 40,
		/obj/item/shard = 80,
		/obj/item/reagent_containers/drinks/drinkingglass = 80,
		/obj/item/storage/belt/chef = 40,
		/obj/item/clothing/suit/chef/classic = 40,
		/obj/item/stack/ore/salvage/scrapmetal/five = 80,
		/obj/item/stack/cable_coil/cut = 80,
		/obj/item/kitchen/knife = 10,
	)

//scrap item, mostly for fluff
/obj/item/stack/ore/salvage
	name = "salvage"
	icon = 'icons/obj/salvage_structure.dmi'
	icon_state = "smetal"
	refined_type = null

/obj/item/stack/ore/salvage/examine(mob/user)
	. = ..()
	. += "You could probably reclaim this in an autolathe, Ore Redemption Machine, or smelter."

/obj/item/stack/ore/salvage/scrapmetal
	name = "scrap metal"
	desc = "A collection of metal parts and pieces."
	points = 1
	materials = list(MAT_METAL = 2000)

/obj/item/stack/ore/salvage/scrapmetal/five
	amount = 5

/obj/item/stack/ore/salvage/scrapmetal/ten
	amount = 10

/obj/item/stack/ore/salvage/scrapmetal/twenty
	amount = 20

/obj/item/stack/ore/salvage/scraptitanium
	name = "scrap titanium"
	desc = "Lightweight, rust-resistant parts and pieces from high-performance equipment."
	icon_state = "stitanium"
	points = 50
	materials = list(MAT_TITANIUM = 2000)

/obj/item/stack/ore/salvage/scraptitanium/five
	amount = 5

/obj/item/stack/ore/salvage/scrapsilver
	name = "worn crt"
	desc = "An old CRT display with the letters 'STANDBY' burnt into the screen."
	icon_state = "ssilver"
	points = 16
	materials = list(MAT_SILVER = 2000)

/obj/item/stack/ore/salvage/scrapsilver/five
	amount = 5

/obj/item/stack/ore/salvage/scrapgold
	name = "scrap electronics"
	desc = "Various bits of electrical components."
	icon_state = "sgold"
	points = 18
	materials = list(MAT_GOLD = 2000)

/obj/item/stack/ore/salvage/scrapgold/five
	amount = 5

/obj/item/stack/ore/salvage/scrapplasma
	name = "junk plasma cell"
	desc = "A nonfunctional plasma cell, once used as portable power generation."
	icon_state = "splasma"
	points = 15
	materials = list(MAT_PLASMA = 2000)

/obj/item/stack/ore/salvage/scrapplasma/five
	amount = 5

/obj/item/stack/ore/salvage/scrapuranium
	name = "broken detector"
	desc = "The label on the side warns the reader of radioactive elements."
	icon_state = "suranium"
	points = 30
	materials = list(MAT_URANIUM = 2000)

/obj/item/stack/ore/salvage/scrapuranium/five
	amount = 5

/obj/item/stack/ore/salvage/scrapbluespace
	name = "damaged bluespace circuit"
	desc = "It's damaged beyond repair, but the crystal inside its housing looks fine."
	icon_state = "sbluespace"
	points = 50
	materials = list(MAT_BLUESPACE = 1000)

/obj/item/stack/ore/salvage/scrapbluespace/five
	amount = 5
