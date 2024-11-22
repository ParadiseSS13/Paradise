// Unit test to ensure people have appropriately set up their origin_techs in items, ensuring they give the appropriate resources in RnD breakdown
/datum/unit_test/origin_tech/Run()
	var/regex/nums = regex("^\[0-9]+")
	for(var/tpath in subtypesof(/obj/item))
		var/obj/item/I = tpath
		var/tech_str = initial(I.origin_tech)

		var/list/tech_list = params2list(tech_str)

		for(var/k in tech_list)
			if(length(nums.Replace(tech_list[k], "")) > 0)
				Fail("Invalid origin tech for [tpath]: [tech_str]")
