/datum/unit_test/map_templates/Run()
	var/list/datum/map_template/templates = subtypesof(/datum/map_template)
	for(var/I in templates)
		var/datum/map_template/MT = new I // The new is important here to ensure stuff gets set properly
		// Check if it even has a path and if so, does it exist
		if(MT.mappath && !fexists(MT.mappath))
			Fail("The map file for [MT.type] does not exist!")
