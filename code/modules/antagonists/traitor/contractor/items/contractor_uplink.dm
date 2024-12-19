/**
  * # Contractor Uplink
  *
  * A contractor's point of contact with their Contractor Hub.
  */
/obj/item/contractor_uplink
	name = "contractor uplink"
	desc = "A standard, Syndicate issued tablet for handling important contracts while on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "contractor_uplink"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "programming=5;syndicate=4" // Hackerman encryption
	/// The Contractor Hub associated with this uplink.
	var/datum/contractor_hub/hub = null

/obj/item/contractor_uplink/Destroy()
	// Right now, one uplink = one hub so this is fine.
	QDEL_NULL(hub)
	return ..()

/obj/item/contractor_uplink/attack_self__legacy__attackchain(mob/user)
	hub.ui_interact(user)

/**
  * Sends a message to the mob holding this item.
  *
  * Arguments:
  * * text - The text to send.
  * * sndfile - The sound to play to the holder only.
  */
/obj/item/contractor_uplink/proc/message_holder(text, sndfile)
	var/mob/living/M = loc
	while(!istype(M) && M?.loc)
		M = M.loc
	if(!istype(M))
		return

	to_chat(M, "<span class='notice'>[bicon(src)] Incoming encrypted transmission from your handlers. Message as follows:</span><br />"\
			+ "<span class='boldnotice'>[text]</span>")
	if(sndfile)
		M.playsound_local(get_turf(M), sndfile, 30, FALSE, use_reverb = FALSE)
