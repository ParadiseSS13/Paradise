/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	anchored = TRUE
	var/obj/machinery/mineral/stacking_machine/machine

/obj/machinery/mineral/stacking_unit_console/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/mineral/stacking_machine/found_machine in range(1, src))
		machine = found_machine
		machine.console = src
		return

	CRASH("[src] failed to link to a stacking machine!")

/obj/machinery/mineral/stacking_unit_console/Destroy()
	if(machine)
		machine.console = null
	machine = null
	return ..()

/obj/machinery/mineral/stacking_unit_console/attack_hand(mob/user)
	var/obj/item/stack/sheet/s
	var/dat

	if(!machine)
		return

	dat += text("<b>Stacking unit console</b><br><br>")

	for(var/O in machine.stack_list)
		s = machine.stack_list[O]
		if(s.amount > 0)
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=[UID()];release=[s.type]'>Release</A><br>")

	dat += text("<br>Stacking: [machine.stack_amt]<br><br>")

	user << browse("[dat]", "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in machine.stack_list))
			return //someone tried to spawn materials by spoofing hrefs
		var/obj/item/stack/sheet/inp = machine.stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type()
		out.amount = inp.amount
		inp.amount = 0
		machine.unload_mineral(out)

	updateUsrDialog()

/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/stacking_unit_console/console
	var/list/stack_list = list() //Key: Type.  Value: Instance of type.
	var/stack_amt = 50 //ammount to stack before releassing
	input_dir = EAST
	output_dir = WEST
	speed_process = TRUE

/obj/machinery/mineral/stacking_machine/Destroy()
	QDEL_LIST_CONTENTS(stack_list)
	if(console)
		console.machine = null
	console = null
	return ..()

/obj/machinery/mineral/stacking_machine/process()
	var/turf/T = get_step(src, input_dir)
	if(T)
		for(var/obj/item/stack/sheet/S in T)
			process_sheet(S)
			CHECK_TICK

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	if(!(inp.type in stack_list)) //It's the first of this sheet added
		var/obj/item/stack/sheet/s = new inp.type(src,0)
		s.amount = 0
		stack_list[inp.type] = s
	var/obj/item/stack/sheet/storage = stack_list[inp.type]
	storage.amount += inp.amount //Stack the sheets
	inp.loc = null //Let the old sheet garbage collect
	while(storage.amount > stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type()
		out.amount = stack_amt
		unload_mineral(out)
		storage.amount -= stack_amt
