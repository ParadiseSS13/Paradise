/proc/sql_report_death(mob/living/carbon/human/H)
	if(!SSdbcore.IsConnected())
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/area/placeofdeath = get_area(H.loc)
	var/podname = "Unknown"
	if(placeofdeath)
		podname = placeofdeath.name

	// Empty string is important here!
	var/laname = ""
	var/lakey = ""
	if(H.lastattacker)
		laname = H.lastattacker
	if(H.lastattackerckey)
		lakey = H.lastattackerckey

	var/datum/db_query/deathquery = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord)
		VALUES (:name, :key, :job, :special, :pod, NOW(), :laname, :lakey, :gender, :bruteloss, :fireloss, :brainloss, :oxyloss, :coord)"},
		list(
			"name" = H.real_name,
			"key" = H.key,
			"job" = H.mind.assigned_role,
			"special" = H.mind.special_role || "",
			"pod" = podname,
			"laname" = laname,
			"lakey" = lakey,
			"gender" = H.gender,
			"bruteloss" = H.getBruteLoss(),
			"fireloss" = H.getFireLoss(),
			"brainloss" = H.getBrainLoss(),
			"oxyloss" = H.getOxyLoss(),
			"coord" = "[H.x], [H.y], [H.z]"
		)
	)
	deathquery.warn_execute()
	qdel(deathquery)

// Why the actual fuck is this a different proc for the exact same query?
/proc/sql_report_cyborg_death(mob/living/silicon/robot/H)
	if(!SSdbcore.IsConnected())
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	// Empty string is important here!
	var/laname = ""
	var/lakey = ""
	if(H.lastattacker)
		laname = H.lastattacker
	if(H.lastattackerckey)
		lakey = H.lastattackerckey

	var/datum/db_query/deathquery = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord)
		VALUES (:name, :key, :job, :special, :pod, NOW(), :laname, :lakey, :gender, :bruteloss, :fireloss, :brainloss, :oxyloss, :coord)"},
		list(
			"name" = H.real_name,
			"key" = H.key,
			"job" = H.mind.assigned_role,
			"special" = H.mind.special_role || "",
			"pod" = podname,
			"laname" = laname,
			"lakey" = lakey,
			"gender" = H.gender,
			"bruteloss" = H.getBruteLoss(),
			"fireloss" = H.getFireLoss(),
			"brainloss" = H.getBrainLoss(),
			"oxyloss" = H.getOxyLoss(),
			"coord" = "[H.x], [H.y], [H.z]"
		)
	)
	deathquery.warn_execute()
	qdel(deathquery)
