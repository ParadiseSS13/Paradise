/mob/living/simple_animal/possessed_object
	name = "possessed doodad"
	var/spirit_name = "mysterious force" // What we call ourselves in attack messages.
	health = 50
	maxHealth = 50

	pass_flags = PASSTABLE 	// Floating past tables is pretty damn spooky.
	status_flags = null 	// No canpush to prevent grabs ...
	density = 0 			//  ... But a density of 0 means we won't be blocking anyone's way.
	healable = 0			// Animated with SPACE NECROMANCY, mere mortal medicines cannot heal such an object.
	wander = 0				// These things probably ought to never be AI controlled, but in the event they are probably shouldn't wander.

	universal_speak = 1		// Tell the humans spooky things about the afterlife
	speak_emote = list("mumbles", "moans", "whispers", "laments", "screeches")

	allow_spin = 0			// No spinning. Spinning breaks our floating animation.
	no_spin_thrown = 1
	del_on_death = TRUE

	var/obj/item/possessed_item

/mob/living/simple_animal/possessed_object/examine(mob/user)
	. = possessed_item.examine(user)
	if(health > (maxHealth / 30))
		. += "<span class='warning'>[src] appears to be floating without any support!</span>"
	else
		. += "<span class='warning'>[src] appears to be having trouble staying afloat!</span>"


/mob/living/simple_animal/possessed_object/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect, end_pixel_y)
	..()
	animate_ghostly_presence(src, -1, 20, 1) // Restart the floating animation after the attack animation, as it will be cancelled.


/mob/living/simple_animal/possessed_object/start_pulling(var/atom/movable/AM) // Silly motherfuckers think they can pull things.
	to_chat(src, "<span class='warning'>You are unable to pull [AM]!</span>")


/mob/living/simple_animal/possessed_object/ghost() // Ghosting will return the object to normal, and will not disqualify the ghoster from various mid-round antag positions.
	var/response = alert(src, "End your possession of this object? (It will not stop you from respawning later)","Are you sure you want to ghost?","Ghost","Stay in body")
	if(response != "Ghost")
		return
	StartResting()
	var/mob/dead/observer/ghost = ghostize(1)
	ghost.timeofdeath = world.time
	death(0) // Turn back into a regular object.

/mob/living/simple_animal/possessed_object/death(gibbed)
	if(can_die())
		ghostize(GHOST_CAN_REENTER)
		// if gibbed, the item goes with the ghost
		if(!gibbed && possessed_item.loc == src)
			// Put the normal item back once the EVIL SPIRIT has been vanquished from it. If it's not already in place
			possessed_item.forceMove(loc)
	return ..()

/mob/living/simple_animal/possessed_object/Life(seconds, times_fired)
	..()

	if(!possessed_item) // If we're a donut and someone's eaten us, for instance.
		death(1)

	if( possessed_item.loc != src )
		if ( isturf(possessed_item.loc) ) // If we've, say, placed the possessed item on the table move onto the table ourselves instead and put it back inside of us.
			forceMove(possessed_item.loc)
			possessed_item.forceMove(src)
		else // If we're inside a toolbox or something, we are inside the item rather than the item inside us. This is so people can see the item in the toolbox.
			forceMove( possessed_item )

	if(l_hand) // Incase object interactions put things directly into our hands. (Like cameras, or gun magizines)
		drop_l_hand()
	if(r_hand)
		drop_r_hand()

/mob/living/simple_animal/possessed_object/Login()
	..()
	to_chat(src, "<span class='shadowling'><b>Your spirit has entered [src] and possessed it.</b><br>You are able to do most things a humanoid would be able to do with a [src] in their hands.<br>If you want to end your ghostly possession, use the '<b>ghost</b>' verb, it won't penalize your ability to respawn.</span>")


/mob/living/simple_animal/possessed_object/New(var/atom/loc as obj)
	..()

	if(!istype(loc, /obj/item)) // Some silly motherfucker spawned us directly via the game panel.
		message_admins("<span class='adminnotice'>Posessed object improperly spawned, deleting.</span>") // So silly admins with debug off will see the message too and not spam these things.
		log_runtime(EXCEPTION("[src] spawned manually, no object to assign attributes to."), src)
		qdel(src)

	var/turf/possessed_loc = get_turf(loc)
	if(!istype(possessed_loc)) // Will this ever happen? Who goddamn knows.
		message_admins("<span class='adminnotice'>Posessed object could not find turf, deleting.</span>") // So silly admins with debug off will see the message too and not spam these things.
		log_runtime(EXCEPTION("[src] attempted to find a turf to spawn on, and could not."), src)
		qdel(src)

	possessed_item = loc
	forceMove( possessed_loc )
	possessed_item.forceMove(src) // We'll keep the actual item inside of us until we die.

	update_icon(1)

	visible_message("<span class='shadowling'>[src] rises into the air and begins to float!</span>") // Inform those around us that shit's gettin' spooky.
	animate_ghostly_presence(src, -1, 20, 1)


/mob/living/simple_animal/possessed_object/get_active_hand() // So that our attacks count as attacking with the item we've possessed.
	return possessed_item


/mob/living/simple_animal/possessed_object/IsAdvancedToolUser() // So we can shoot guns (Mostly ourselves), among other things.
	return TRUE


/mob/living/simple_animal/possessed_object/get_access() // If we've possessed an ID card we've got access to lots of fun things!
	if(istype(possessed_item, /obj/item/card/id))
		var/obj/item/card/id/possessed_id = possessed_item
		. = possessed_id.access


/mob/living/simple_animal/possessed_object/ClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(!istype(loc, /turf)) // If we're inside a card machine or something similar then you're stuck.
		return

	name = spirit_name

	if(A == src) // If we're clicking ourself we should not attack ourself.
		possessed_item.attack_self(src)
	else
		..()

	if( possessed_item.loc != src )
		if ( isturf(possessed_item.loc) ) // If we've, say, placed the possessed item on the table move onto the table ourselves instead and put it back inside of us.
			forceMove(possessed_item.loc)
			possessed_item.forceMove(src)
		else // If we're inside a toolbox or something, we are inside the item rather than the item inside us. This is so people can see the item in the toolbox.
			forceMove( possessed_item )

	update_icon()

/mob/living/simple_animal/possessed_object/proc/update_icon(update_pixel_xy = 0)
	name = possessed_item.name // Take on all the attributes of the item we've possessed.
	real_name = name
	desc = possessed_item.desc
	icon = possessed_item.icon
	icon_living = possessed_item.icon_state
	icon_state = possessed_item.icon_state
	dir = possessed_item.dir
	if(update_pixel_xy)
		pixel_x = possessed_item.pixel_x
		pixel_y = possessed_item.pixel_y
	color = possessed_item.color
	overlays = possessed_item.overlays
	set_opacity(possessed_item.opacity)
