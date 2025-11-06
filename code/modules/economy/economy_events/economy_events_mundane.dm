/datum/event/mundane_news
	endWhen = 10

/datum/event/mundane_news/announce()
	var/datum/trade_destination/topic = pickweight(GLOB.weighted_mundaneevent_locations)
	var/event_type
	if(length(topic.viable_mundane_events))
		event_type = pick(topic.viable_mundane_events)

	if(!event_type)
		return

	var/datum/event_news/news_event = new event_type(topic)
	var/datum/feed_message/message = news_event.build_newscaster_message()

	GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(message)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(message.title)

/datum/event/trivial_news
	endWhen = 10

/datum/event/trivial_news/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new
	newMsg.author = "Editor Mike Hammers"
	var/datum/trade_destination/affected_dest = pick(GLOB.weighted_mundaneevent_locations)
	var/headline = pick(file2list("config/news/trivial.txt"))
	newMsg.title = replacetext(headline, "{{AFFECTED}}", affected_dest.name)

	GLOB.news_network.get_channel_by_name("The Gibson Gazette")?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news("The Gibson Gazette: [newMsg.title]")
