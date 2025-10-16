// Admin verb to debug the DMAPI
ADMIN_VERB(debug_dmapi, R_DEBUG, "Debug DMAPI", "Dump DMAPI information.", VERB_CATEGORY_DEBUG)
	if(!world.TgsAvailable())
		to_chat(user, "DMAPI not connected")
		return

	to_chat(user, "TGS Info")
	to_chat(user, "Revision: [world.TgsRevision()]")
	to_chat(user, "Version: [world.TgsVersion()]")
	to_chat(user, "API Version: [world.TgsApiVersion()]")
	to_chat(user, "Instance Name: [world.TgsInstanceName()]")
	to_chat(user, "Testmerges:")
	for(var/datum/tgs_revision_information/test_merge/TM as anything in world.TgsTestMerges())
		to_chat(user, "#[TM.number] | [TM.author] - [TM.title]")

	to_chat(user, "Channel info:")
	for(var/datum/tgs_chat_channel/CC as anything in world.TgsChatChannelInfo())
		to_chat(user, "I:[CC.id] | FN:[CC.friendly_name] | AC:[CC.is_admin_channel] | PC:[CC.is_private_channel] | CT:[CC.custom_tag]")
	to_chat(user, "Security level: [world.TgsSecurityLevel()]")

ADMIN_VERB(dmapi_log, R_DEBUG, "DMAPI Log", "Open the DMAPI log.", VERB_CATEGORY_DEBUG)
	user << browse(GLOB.tgs_log.Join("<br>"), "window=dmapi_log")
