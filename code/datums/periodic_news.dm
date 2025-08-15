// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement

	var/round_time // time of the round at which this should be announced, in seconds
	var/message // body of the message
	var/headline
	var/author = "Nanotrasen Editor"
	var/channel_name = "Nyx Daily"
	var/can_be_redacted = FALSE
	var/message_type = "Story"

/datum/news_announcement/revolution_inciting_event/paycuts_suspicion
	round_time = 60*10
	headline = "Paycuts Suspected at Nanotrasen"
	message = {"Reports have leaked that Nanotrasen Inc. is planning to put pay cuts into
				effect on many of its Research Stations in Tau Ceti. Apparently these research
				stations haven't been able to yield the expected revenue, and thus adjustments
				have to be made."}
	author = "Unauthorized"

/datum/news_announcement/revolution_inciting_event/paycuts_confirmation
	round_time = 60*40
	headline = "Paycuts Confirmed at Nanotrasen"
	message = {"Earlier rumours about pay cuts on Research Stations in the Tau Ceti system have
				been confirmed. Shockingly, however, the cuts will only affect lower tier
				personnel. Heads of Staff will, according to our sources, not be affected."}
	author = "Unauthorized"

/datum/news_announcement/revolution_inciting_event/human_experiments
	round_time = 60*90
	headline = "Human Experimentation Alleged at Nanotrasen"
	message = {"Unbelievable reports about human experimentation have reached our ears. According
				to a refugee from one of the Tau Ceti Research Stations, their station, in order
				to increase revenue, has refactored several of their facilities to perform experiments
				on live humans, including virology research, genetic manipulation, and \"feeding them
				to the slimes to see what happens\". Allegedly, these test subjects were neither
				humanified monkeys nor volunteers, but rather unqualified staff that were forced into
				the experiments, and reported to have died in a \"work accident\" by Nanotrasen Inc."}
	author = "Unauthorized"

/datum/news_announcement/bluespace_research
	round_time = 60*20
	headline = "Bluespace Research Advances"
	message = {"The new field of research trying to explain several interesting spacetime oddities,
				also known as \"Bluespace Research\", has reached new heights. Of the several
				hundred space stations now orbiting in Tau Ceti, fifteen are now specially equipped
				to experiment with and research Bluespace effects. Rumours have it some of these
				stations even sport functional \"travel gates\" that can instantly move a whole research
				team to an alternate reality."}

/datum/news_announcement/random_junk/cheesy_honkers
	author = "Assistant Editor Carl Ritz"
	channel_name = "The Gibson Gazette"
	headline = "Cheesy Honkers Alleged Health Risk"
	message = {"Do cheesy honkers increase risk of having a miscarriage? Several health administrations
				say so!"}
	round_time = 60 * 15

/datum/news_announcement/random_junk/net_block
	author = "Assistant Editor Carl Ritz"
	channel_name = "The Gibson Gazette"
	headline = "WETSKRELL.NT Blocked"
	message = {"Several corporations banding together to block access to 'wetskrell.nt', site administrators
	claiming violation of net laws."}
	round_time = 60 * 50

/datum/news_announcement/random_junk/found_ssd
	author = "Doctor Eric Hanfield"
	headline = "Employees found SSD"
	message = {"Several people have been found unconscious at their terminals. It is thought that it was due
				to a lack of sleep or of simply migraines from staring at the screen too long. Camera footage
				reveals that many of them were playing games instead of working and their pay has been docked
				accordingly."}
	round_time = 60 * 90

/datum/news_announcement/lotus_tree
	author = "Reporter Leland H. Howards"
	headline = "Explosion on Civilian Transport"
	message = {"The newly-christened civilian transport Lotus Tree suffered two very large explosions near the
				bridge today, and there are unconfirmed reports that the death toll has passed 50. The cause of
				the explosions remain unknown, but there is speculation that it might have something to do with
				the recent change of regulation in the Moore-Lee Corporation, a major funder of the ship, when M-L
				announced that they were officially acknowledging inter-species marriage and providing couples
				with marriage tax-benefits."}
	round_time = 60 * 30

/datum/news_announcement/food_riots/breaking_news
	author = "Reporter Ro'kii Ar-Raqis"
	headline = "Food Riots in Tenebrae Lupus"
	message = {"Breaking news: Food riots have broken out throughout the Refuge asteroid colony in the Tenebrae
				Lupus system. This comes only hours after Nanotrasen officials announced they will no longer trade with the
				colony, citing the increased presence of \"hostile factions\" on the colony has made trade too dangerous to
				continue. Nanotrasen officials have not given any details about said factions. More on that at the top of
				the hour."}
	round_time = 60 * 10

/datum/news_announcement/food_riots/more
	author = "Reporter Ro'kii Ar-Raqis"
	headline = "Food Riots Continue Amid NT Withdrawl"
	message = {"More on the Refuge food riots: The Refuge Council has condemned Nanotrasen's withdrawal from
	the colony, claiming \"there has been no increase in anti-Nanotrasen activity\", and \"\[the only] reason
	Nanotrasen withdrew was because the \[Tenebrae Lupus] system's Plasma deposits have been completely mined out.
	We have little to trade with them now\". Nanotrasen officials have denied these allegations, calling them
	\"further proof\" of the colony's anti-Nanotrasen stance. Meanwhile, Refuge Security has been unable to quell
	the riots. More on this at 6."}
	round_time = 60 * 60
GLOBAL_LIST_INIT(newscaster_standard_feeds, list(/datum/news_announcement/bluespace_research, /datum/news_announcement/lotus_tree, /datum/news_announcement/random_junk,  /datum/news_announcement/food_riots))

/proc/process_newscaster()
	check_for_newscaster_updates(SSticker.mode.newscaster_announcements)

GLOBAL_LIST_EMPTY(announced_news_types)

/proc/check_for_newscaster_updates(type)
	for(var/subtype in subtypesof(type))
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in GLOB.announced_news_types))
			GLOB.announced_news_types += subtype
			announce_newscaster_news(news)

/proc/announce_newscaster_news(datum/news_announcement/news)

	var/datum/feed_channel/sendto = GLOB.news_network.get_channel_by_name(news.channel_name)
	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.frozen = TRUE
		sendto.admin_locked = TRUE
		GLOB.news_network.channels += sendto

	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = news.author ? news.author : sendto.author
	newMsg.admin_locked = !news.can_be_redacted
	newMsg.body = news.message
	newMsg.title = "[news.channel_name]: [news.headline]"

	sendto.add_message(newMsg)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(news.channel_name)
