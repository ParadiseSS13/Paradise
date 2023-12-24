	var/list/result
	LAZYINITLIST(client.recent_examines)
	for(var/key in client.recent_examines)
		if(client.recent_examines[key] < world.time)
			client.recent_examines -= key
	var/ref_to_atom = A.UID()
	if(LAZYACCESS(client.recent_examines, ref_to_atom))
		result = A.examine_more(src)
		if(!length(result))
			result += "<span class='notice'><i>You examine [A] closer, but find nothing of interest...</i></span>"
	else
		result = A.examine(src)
		client.recent_examines[ref_to_atom] = world.time + EXAMINE_MORE_WINDOW // set to when we should not examine something
