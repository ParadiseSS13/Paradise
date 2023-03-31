// Admin verb to debug the DMAPI

/client/proc/dmapi_debug()
	set name = "Debug DMAPI"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	if(!world.TgsAvailable())
		to_chat(src, "DMAPI not connected")
		return

	to_chat(src, "TGS Info")
	to_chat(src, "Revision: [world.TgsRevision()]")
	to_chat(src, "Version: [world.TgsVersion()]")
	to_chat(src, "API Version: [world.TgsApiVersion()]")
	to_chat(src, "Instance Name: [world.TgsInstanceName()]")
	to_chat(src, "Testmerges:")
	for(var/datum/tgs_revision_information/test_merge/TM as anything in world.TgsTestMerges())
		to_chat(src, "#[TM.number] | [TM.author] - [TM.title]")

	to_chat(src, "Channel info:")
	for(var/datum/tgs_chat_channel/CC as anything in world.TgsChatChannelInfo())
		to_chat(src, "I:[CC.id] | FN:[CC.friendly_name] | AC:[CC.is_admin_channel] | PC:[CC.is_private_channel] | CT:[CC.custom_tag]")
	to_chat(src, "Security level: [world.TgsSecurityLevel()]")

/client/proc/dmapi_log()
	set name = "DMAPI Log"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	usr << browse(GLOB.tgs_log.Join("<br>"), "window=dmapi_log")
