USER_VERB(set_ticklag, R_MAINTAINER, "Set Ticklag", \
		"Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9", \
		VERB_CATEGORY_DEBUG)
	var/newtick = input(client, "Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9","Lag of Tick", world.tick_lag) as num|null
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick && newtick <= 2 && newtick > 0)
		log_admin("[key_name(client)] has modified world.tick_lag to [newtick]", 0)
		message_admins("[key_name_admin(client)] has modified world.tick_lag to [newtick]", 0)
		world.tick_lag = newtick
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Ticklag") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	else
		to_chat(client, SPAN_WARNING("Error: ticklag(): Invalid world.ticklag value. No changes made."))
