// Admin verb to debug the DMAPI
USER_VERB(debug_dmapi, R_DEBUG, "Debug DMAPI", "Dump DMAPI information.", VERB_CATEGORY_DEBUG)
	if(!world.TgsAvailable())
		to_chat(client, "DMAPI not connected")
		return

	to_chat(client, "TGS Info")
	to_chat(client, "Revision: [world.TgsRevision()]")
	to_chat(client, "Version: [world.TgsVersion()]")
	to_chat(client, "API Version: [world.TgsApiVersion()]")
	to_chat(client, "Instance Name: [world.TgsInstanceName()]")
	to_chat(client, "Testmerges:")
	for(var/datum/tgs_revision_information/test_merge/TM as anything in world.TgsTestMerges())
		to_chat(client, "#[TM.number] | [TM.author] - [TM.title]")

	to_chat(client, "Channel info:")
	for(var/datum/tgs_chat_channel/CC as anything in world.TgsChatChannelInfo())
		to_chat(client, "I:[CC.id] | FN:[CC.friendly_name] | AC:[CC.is_admin_channel] | PC:[CC.is_private_channel] | CT:[CC.custom_tag]")
	to_chat(client, "Security level: [world.TgsSecurityLevel()]")

USER_VERB(dmapi_log, R_DEBUG, "DMAPI Log", "Open the DMAPI log.", VERB_CATEGORY_DEBUG)
	client << browse(GLOB.tgs_log.Join("<br>"), "window=dmapi_log")
