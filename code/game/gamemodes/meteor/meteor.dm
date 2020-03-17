/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/initialmeteordelay = 6000
	var/wave = 1
	required_players = 35


/datum/game_mode/meteor/announce()
	to_chat(world, "<B>The current game mode is - Meteor!</B>")
	to_chat(world, "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>")


/datum/game_mode/meteor/post_setup()
	spawn(rand(waittime_l, waittime_h))
		command_announcement.Announce("The station is on the path of an incoming wave of meteors. Reinforce the hull and prepare damage control parties.", "Incoming Meteors", 'sound/effects/siren.ogg')
	spawn(initialmeteordelay)
		sendmeteors()
	..()



/datum/game_mode/meteor/proc/sendmeteors()
	var/waveduration = world.time + rand(0,1000) + text2num("[wave]000") / 2
	var/waitduration = rand(3000,6000)
	while(waveduration - world.time > 0)
		sleep(max(65 - text2num("[wave]0") / 2, 40))
		spawn() spawn_meteors(6, meteors_normal)
	wave++
	sleep(waitduration)
	sendmeteors()

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue

			if(location.loc.type == SSshuttle.emergency.areaInstance.type) //didn't work in the switch for some reason
				text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"

			else
				switch(location.loc.type)
					if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom )
						text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
					else
						text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		to_chat(world, "<span class='boldnotice'>The following survived the meteor storm</span>:[text]")
	else
		to_chat(world, "<span class='boldnotice'>Nobody survived the meteor storm!</span>")

	feedback_set_details("round_end_result","meteor end - evacuation")
	feedback_set("round_end_result", "Meteor survivors: [survivors]")

	..()
	return 1
