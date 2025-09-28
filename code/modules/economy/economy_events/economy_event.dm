/datum/event/economic_event
	endWhen = 50			// this will be set randomly, later
	announceWhen = 15
	var/datum/event_news/economic/news_story

/datum/event/economic_event/start()
	var/datum/trade_destination/topic = pickweight(GLOB.weighted_randomevent_locations)

	if(length(topic.viable_random_events))
		endWhen = rand(60, 300)
		var/event_type = pick(topic.viable_random_events)

		if(!event_type)
			return

		news_story = new event_type(topic)
		for(var/good_type in news_story.pricier_goods)
			topic.temp_price_change[good_type] = rand(1,100)
		for(var/good_type in news_story.cheaper_goods)
			topic.temp_price_change[good_type] = rand(1,100) / 100

/datum/event/economic_event/announce()
	var/datum/feed_message/message = news_story.build_newscaster_message()

	GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(message)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(message.title)

/datum/event/economic_event/end()
	for(var/good_type in news_story.pricier_goods)
		news_story.topic.temp_price_change[good_type] = 1
	for(var/good_type in news_story.cheaper_goods)
		news_story.topic.temp_price_change[good_type] = 1
