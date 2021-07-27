/**
  * # Contractor Extraction Flare
  *
  * Used to designate where the [/obj/effect/portal/redspace/contractor] should spawn during the extraction process.
  */
/obj/effect/contractor_flare
	name = "contractor extraction flare"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"

/obj/effect/contractor_flare/New()
	..()
	playsound(loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
	set_light(8, l_color = "#FFD165")

/obj/effect/contractor_flare/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	return ..()

/**
  * # Contractor Extraction Portal
  *
  * Used to extract contract targets and send them to the Syndicate jail for a few minutes.
  */
/obj/effect/portal/redspace/contractor
	name = "suspicious portal"
	icon_state = "portal-syndicate"
	/// The contract associated with this portal.
	var/datum/syndicate_contract/contract = null
	/// The mind of the contractor. Used to tell them they shouldn't be taking the portal.
	var/datum/mind/contractor_mind = null
	/// The mind of the kidnapping target. Prevents non-targets from taking the portal.
	var/datum/mind/target_mind = null

/obj/effect/portal/redspace/contractor/can_teleport(atom/movable/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(M == usr && M.mind == contractor_mind)
		to_chat(M, "<span class='warning'>The portal is here to extract the contract target, not you!</span>")
		return FALSE
	if(M.mind != target_mind)
		if(usr?.mind == contractor_mind) // Contractor shoving a non-target into the portal
			to_chat(M, "<span class='warning'>Somehow you are not sure [M] is the target you have to kidnap.</span>")
			return FALSE
		else if(usr == M) // Non-target trying to enter the portal
			to_chat(M, "<span class='warning'>Somehow you are not sure this is a good idea.</span>")
			return FALSE
		return FALSE
	return ..()

/obj/effect/portal/redspace/contractor/teleport(atom/movable/M)
	. = ..()
	if(.)
		contract.target_received(M, src)

/**
  * # Prisoner Belongings Closet
  *
  * Cannot be opened. Contains the belongings of all kidnapped targets.
  * Any item added inside stops processing and starts again when removed.
  */
/obj/structure/closet/secure_closet/contractor
	anchored = TRUE
	can_be_emaged = FALSE
	max_integrity = INFINITY
	/// Lazy list of atoms which should process again when taken out.
	var/list/atom/suspended_items = null
	/// Lazy, associative list of prisoners being held as part of a contract.
	/// Structure: [/mob/living] => [/datum/syndicate_contract]
	var/list/prisoners = null

/obj/structure/closet/secure_closet/contractor/Initialize(mapload)
	. = ..()
	if(!GLOB.prisoner_belongings)
		GLOB.prisoner_belongings = src

/obj/structure/closet/secure_closet/contractor/allowed(mob/M)
	return FALSE

/**
  * Tries to add an atom for temporary holding, suspending its processing.
  *
  * Arguments:
  * * A - The atom to add.
  */
/obj/structure/closet/secure_closet/contractor/proc/give_item(atom/A)
	if(ismob(A)) // No mobs allowed
		return FALSE
	var/obj/item/I = A
	if(!istype(I))
		return FALSE
	if(I.isprocessing)
		LAZYSET(suspended_items, I.UID(), list(I, (I in SSfastprocess.processing)))
		STOP_PROCESSING(SSobj, I)
	I.loc = src // No forceMove because we don't want to trigger anything here
	return TRUE

/**
  * Removes an atom from temporary holding.
  *
  * Arguments:
  * * A - The atom to remove.
  */
/obj/structure/closet/secure_closet/contractor/proc/remove_item(atom/A)
	if(!(A in contents))
		return
	var/obj/item/I = A
	if(!istype(I))
		return FALSE
	// Resume processing if it was paused
	var/list/tuple = LAZYACCESS(suspended_items, I.UID())
	if(tuple)
		if(tuple[2])
			START_PROCESSING(SSfastprocess, I)
		else
			START_PROCESSING(SSobj, I)
		suspended_items[I.UID()] = null
	I.loc = loc // No forceMove because we don't want to trigger anything here
	return I
