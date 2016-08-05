
/obj/machinery/replicator
	name = "alien machine"
	desc = "It's some kind of pod with strange wires and gadgets all over it."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "borgcharger0(old)"
	density = 1

	idle_power_usage = 100
	active_power_usage = 1000
	use_power = 1

	var/spawn_progress_time = 0
	var/max_spawn_time = 50
	var/last_process_time = 0

	var/list/construction = list()
	var/list/spawning_types = list()
	var/list/stored_materials = list()

	var/fail_message

/obj/machinery/replicator/New()
	..()

	var/list/viables = list(\
	/obj/item/roller,\
	/obj/structure/closet/crate,\
	/obj/structure/closet/acloset,\
	/mob/living/simple_animal/hostile/mimic,\
	/mob/living/simple_animal/hostile/viscerator,\
	/mob/living/simple_animal/hostile/hivebot,\
	/obj/item/device/analyzer,\
	/obj/item/device/camera,\
	/obj/item/device/flash,\
	/obj/item/device/flashlight,\
	/obj/item/device/healthanalyzer,\
	/obj/item/device/multitool,\
	/obj/item/device/paicard,\
	/obj/item/device/radio,\
	/obj/item/device/radio/headset,\
	/obj/item/device/radio/beacon,\
	/obj/item/weapon/autopsy_scanner,\
	/obj/item/weapon/bikehorn,\
	/obj/item/weapon/bonesetter,\
	/obj/item/weapon/kitchen/knife/butcher,\
	/obj/item/weapon/caution,\
	/obj/item/clothing/head/cone,\
	/obj/item/weapon/crowbar,\
	/obj/item/weapon/clipboard,\
	/obj/item/weapon/stock_parts/cell,\
	/obj/item/weapon/circular_saw,\
	/obj/item/weapon/hatchet,\
	/obj/item/weapon/restraints/handcuffs,\
	/obj/item/weapon/hemostat,\
	/obj/item/weapon/kitchen/knife,\
	/obj/item/weapon/lighter,\
	/obj/item/weapon/lighter,\
	/obj/item/weapon/light/bulb,\
	/obj/item/weapon/light/tube,\
	/obj/item/weapon/pickaxe,\
	/obj/item/weapon/shovel,\
	/obj/item/weapon/table_parts,\
	/obj/item/weapon/weldingtool,\
	/obj/item/weapon/wirecutters,\
	/obj/item/weapon/wrench,\
	/obj/item/weapon/screwdriver,\
	/obj/item/weapon/grenade/chem_grenade/cleaner,\
	/obj/item/weapon/grenade/chem_grenade/metalfoam\
	)

	var/quantity = rand(5,15)
	for(var/i=0, i<quantity, i++)
		var/button_desc = "a [pick("yellow","purple","green","blue","red","orange","white")], "
		button_desc += "[pick("round","square","diamond","heart","dog","human")] shaped "
		button_desc += "[pick("toggle","switch","lever","button","pad","hole")]"
		var/type = pick(viables)
		viables.Remove(type)
		construction[button_desc] = type

	fail_message = "\blue [bicon(src)] a [pick("loud","soft","sinister","eery","triumphant","depressing","cheerful","angry")] \
		[pick("horn","beep","bing","bleep","blat","honk","hrumph","ding")] sounds and a \
		[pick("yellow","purple","green","blue","red","orange","white")] \
		[pick("light","dial","meter","window","protrusion","knob","antenna","swirly thing")] \
		[pick("swirls","flashes","whirrs","goes schwing","blinks","flickers","strobes","lights up")] on the \
		[pick("front","side","top","bottom","rear","inside")] of [src]. A [pick("slot","funnel","chute","tube")] opens up in the \
		[pick("front","side","top","bottom","rear","inside")]."

/obj/machinery/replicator/process()
	if(spawning_types.len && powered())
		spawn_progress_time += world.time - last_process_time
		if(spawn_progress_time > max_spawn_time)
			src.visible_message("\blue [bicon(src)] [src] pings!")

			var/obj/source_material = pop(stored_materials)
			var/spawn_type = pop(spawning_types)
			var/obj/spawned_obj = new spawn_type(src.loc)
			if(source_material)
				if(lentext(source_material.name) < MAX_MESSAGE_LEN)
					spawned_obj.name = "[source_material] " +  spawned_obj.name
				if(lentext(source_material.desc) < MAX_MESSAGE_LEN * 2)
					if(spawned_obj.desc)
						spawned_obj.desc += " It is made of [source_material]."
					else
						spawned_obj.desc = "It is made of [source_material]."
				source_material.loc = null

			spawn_progress_time = 0
			max_spawn_time = rand(30,100)

			if(!spawning_types.len || !stored_materials.len)
				use_power = 1
				icon_state = "borgcharger0(old)"

		else if(prob(5))
			src.visible_message("\blue [bicon(src)] [src] [pick("clicks","whizzes","whirrs","whooshes","clanks","clongs","clonks","bangs")].")

	last_process_time = world.time

/obj/machinery/replicator/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/replicator/interact(mob/user)
	var/dat = "The control panel displays an incomprehensible selection of controls, many with unusual markings or text around them.<br>"
	dat += "<br>"
	for(var/index=1, index<=construction.len, index++)
		dat += "<A href='?src=\ref[src];activate=[index]'>\[[construction[index]]\]</a><br>"

	user << browse(dat, "window=alien_replicator")

/obj/machinery/replicator/attackby(obj/item/weapon/W as obj, mob/living/user as mob, params)
	user.drop_item()
	W.loc = src
	stored_materials.Add(W)
	src.visible_message("\blue [user] inserts [W] into [src].")

/obj/machinery/replicator/Topic(href, href_list)

	if(href_list["activate"])
		var/index = text2num(href_list["activate"])
		if(index > 0 && index <= construction.len)
			if(stored_materials.len > spawning_types.len)
				if(spawning_types.len)
					src.visible_message("\blue [bicon(src)] a [pick("light","dial","display","meter","pad")] on [src]'s front [pick("blinks","flashes")] [pick("red","yellow","blue","orange","purple","green","white")].")
				else
					src.visible_message("\blue [bicon(src)] [src]'s front compartment slides shut.")

				spawning_types.Add(construction[construction[index]])
				spawn_progress_time = 0
				use_power = 2
				icon_state = "borgcharger1(old)"
			else
				src.visible_message(fail_message)
