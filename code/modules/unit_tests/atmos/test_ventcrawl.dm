/datum/unit_test/ventcrawl
	var/mob/living/simple_animal/slime = null
	var/obj/machinery/vent = null
	var/obj/structure/table/table = null

/datum/unit_test/ventcrawl/proc/setup_test_area()
	var/datum/map_template/template = GLOB.map_templates["test_ventcrawl.dmm"]
	if(!template.load(run_loc_bottom_left))
		Fail("Failed to load 'test_ventcrawl.dmm'")

	slime = new /mob/living/simple_animal/slime/unit_test_dummy(run_loc_bottom_left)
	vent = find_spawned_test_object(run_loc_bottom_left, /obj/machinery/atmospherics/unary/vent_pump)
	table = find_spawned_test_object(get_step(run_loc_bottom_left, EAST), /obj/structure/table)

/datum/unit_test/ventcrawl/proc/find_spawned_test_object(turf/location as turf, test_object_type)
	for(var/content in location.contents)
		if(istype(content, test_object_type))
			return content
	Fail("Couldn't find spawned test object of type: [test_object_type].")

/datum/unit_test/ventcrawl/Run()
	setup_test_area()

	// Enter vent
	vent.AltClick(slime)
	if(slime.loc != vent)
		Fail("Failed to crawl into vent.")

	// Movement
	slime.loc.relaymove(slime, EAST)
	if(slime.loc == vent)
		Fail("Failed to step EAST while wentcrawling.")

	// Try to flip table on top of pipe, while inside pipe (shouldn't work)
	table.AltShiftClick(slime)
	if(table.flipped)
		Fail("Shouldn't be possible to flip structures while inside vent.")

	// Exit vent
	slime.loc.relaymove(slime, EAST)
	if(!isturf(slime.loc))
		Fail("Wasn't able to ventcrawl out of vent.")
