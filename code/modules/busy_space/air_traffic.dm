//Cactus, Speedbird, Dynasty, oh my

var/datum/lore/atc_controller/atc = new/datum/lore/atc_controller

/datum/lore/atc_controller
	var/delay_max = 10 MINUTES			//Maximum amount of tiem between ATC messages.  Default is 10 mins.
	var/delay_min = 5 MINUTES			//Minimum amount of time between ATC messages.  Default is 5 mins.
	var/backoff_delay = 5 MINUTES		//How long to back off if we can't talk and want to.  Default is 5 mins.
	var/next_message					//When the next message should happen in world.time
	var/force_chatter_type				//Force a specific type of messages

	var/squelched = FALSE				//If ATC is squelched currently

/datum/lore/atc_controller/New()
	spawn(30 SECONDS) //Lots of lag at the start of a shift.
		msg("New shift beginning, resuming traffic control.")
	next_message = world.time + rand(delay_min, delay_max)
	process()

/datum/lore/atc_controller/proc/process()
	if(world.time >= next_message)
		if(squelched)
			next_message = world.time + backoff_delay
		else
			next_message = world.time + rand(delay_min,delay_max)
			random_convo()

	spawn(1 MINUTES) //We don't really need high-accuracy here.
		process()

/datum/lore/atc_controller/proc/msg(var/message,var/sender)
	ASSERT(message)
	global_announcer.autosay("[message]", sender ? sender : "[using_map.station_short] Space Control")

/datum/lore/atc_controller/proc/reroute_traffic(var/yes = 1)
	if(yes)
		if(!squelched)
			msg("Rerouting traffic away from [using_map.station_name].")
		squelched = TRUE
	else
		if(squelched)
			msg("Resuming normal traffic routing around [using_map.station_name].")
		squelched = FALSE

/datum/lore/atc_controller/proc/shift_ending(var/evac = 0)
	msg("Automated Shuttle departing [using_map.station_name] for [using_map.dock_name] on routine transfer route.", "NT Automated Shuttle")
	sleep(5 SECONDS)
	msg("Automated Shuttle, cleared to complete routine transfer from [using_map.station_name] to [using_map.dock_name].")

/datum/lore/atc_controller/proc/random_convo()
	var/one = pick(loremaster.organizations) //These will pick an index, not an instance
	var/two = pick(loremaster.organizations)

	var/datum/lore/organization/source = loremaster.organizations[one] //Resolve to the instances
	var/datum/lore/organization/dest = loremaster.organizations[two]

	//Let's get some mission parameters
	var/owner = source.short_name					//Use the short name
	var/prefix = pick(source.ship_prefixes)			//Pick a random prefix
	var/mission = source.ship_prefixes[prefix]		//The value of the prefix is the mission type that prefix does
	var/shipname = pick(source.ship_names)			//Pick a random ship name to go with it
	var/destname = pick(dest.destination_names)			//Pick a random holding from the destination

	var/combined_name = "[owner] [prefix] [shipname]"
	var/alt_atc_names = list("[using_map.station_short] TraCon", "[using_map.station_short] Control", "[using_map.station_short] STC", "[using_map.station_short] Airspace")
	var/wrong_atc_names = list("Sol Command", "Orion Control", "[using_map.dock_name]")
	var/mission_noun = list("flight", "mission", "route")
	var/request_verb = list("requesting", "calling for", "asking for")

	//First response is 'yes', second is 'no'
	var/requests = list("[using_map.station_short] transit clearance" = list("cleared to transit", "unable to approve, contact regional on 953.5"),
						"planetary flight rules" = list("cleared planetary flight rules", "unable to approve planetary flight rules due to traffic"),
						"special flight rules" = list("cleared special flight rules", "unable to approve special flight rules for your traffic class"),
						"current solar weather info" = list("sending you the relevant information via tightbeam", "cannot fulfill your request at the moment"),
						"nearby traffic info" = list("sending you current traffic info", "no known traffic for your flight plan route"),
						"remote telemetry data" = list("sending telemetry now", "no uplink from your ship, recheck your uplink and ask again"),
						"refueling information" = list("sending refueling information now", "no fuel for your ship class in this sector"),
						"a current system time sync" = list("sending time sync ping to you now", "your ship isn't compatible with our time sync, set time manually"),
						"current system starcharts" = list("transmitting current starcharts", "request on standby due to demand"),
						"permission to engage FTL" = list("cleared to FTL, good day", "hold position, traffic crossing"),
						"permission to transit system" = list("cleared to transit, good day", "hold position, traffic crossing"),
						"permission to depart system" = list("cleared to leave via flight plan route, good day", "hold position, traffic crossing"),
						"permission to enter system" = list("good day, cleared in as published", "hold position, traffic crossing"),
						)

	//Random chance things for variety
	var/chatter_type = "normal"
	if(force_chatter_type)
		chatter_type = force_chatter_type
	else
		chatter_type = pick(2;"emerg",5;"wrong_freq","normal") //Be nice to have wrong_lang...

	var/yes = prob(90) //Chance for them to say yes vs no

	var/request = pick(requests)
	var/callname = pick(alt_atc_names)
	var/response = requests[request][yes ? 1 : 2] //1 is yes, 2 is no

	var/full_request
	var/full_response
	var/full_closure

	switch(chatter_type)
		if("wrong_freq")
			callname = pick(wrong_atc_names)
			full_request = "[callname], this is [combined_name] on a [mission] [pick(mission_noun)] to [destname], [pick(request_verb)] [request]."
			full_response = "[combined_name], this is [using_map.station_short] TraCon, wrong frequency. Switch to [rand(700,999)].[rand(1,9)]."
			full_closure = "[using_map.station_short] TraCon, copy, apologies."
		if("wrong_lang")
			//Can't implement this until autosay has language support
		if("emerg")
			var/problem = pick("hull breaches on multiple decks","unknown life forms on board","a drive about to go critical","asteroids impacting the hull","a total loss of engine power","people trying to board the ship")
			full_request = "Mayday, mayday, mayday, this is [combined_name] declaring an emergency! We have [problem]!"
			var/rand_freq = "[rand(700,999)].[rand(1,9)]"
			full_response = "[combined_name], this is [using_map.station_short] TraCon, copy. Switch to emergency responder channel [rand_freq]."
			full_closure = "Roger, [using_map.station_short] TraCon, contacting [rand_freq]."
		else
			full_request = "[callname], this is [combined_name] on a [mission] [pick(mission_noun)] to [destname], [pick(request_verb)] [request]."
			full_response = "[combined_name], this is [using_map.station_short] TraCon, [response]." //Station TraCon always calls themselves TraCon
			full_closure = "[using_map.station_short] TraCon, [yes ? "thank you" : "copy"], good day." //They always copy what TraCon called themselves in the end when they realize they said it wrong

	//Ship sends request to ATC
	msg(full_request,"[prefix] [shipname]")
	sleep(5 SECONDS)
	//ATC sends response to ship
	msg(full_response)
	sleep(5 SECONDS)
	//Ship sends response to ATC
	msg(full_closure,"[prefix] [shipname]")