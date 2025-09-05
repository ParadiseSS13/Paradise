/mob/living/basic/possessed_object
	name = "possessed object"
	var/spirit_name = "mysterious force" // What we call ourselves in attack messages.
	mob_biotypes = MOB_SPIRIT
	health = 50
	maxHealth = 50
	pass_flags = PASSTABLE 	// Floating past tables is pretty damn spooky.
	status_flags = null 	// No canpush to prevent grabs ...
	density = FALSE 		//  ... But a density of 0 means we won't be blocking anyone's way.
	healable = FALSE			// Animated with SPACE NECROMANCY, mere mortal medicines cannot heal such an object.
	universal_speak = TRUE	// Tell the humans spooky things about the afterlife
	ai_controller = null // We don't give this mob a controller, as usually they're player controlled. Rev versions get a special controller.
	speak_emote = list("mumbles", "moans", "whispers", "laments", "screeches")
	no_spin_thrown = TRUE
	basic_mob_flags = DEL_ON_DEATH
	weather_immunities = list("ash")
	/// The probability % of us escaping if stuffed into a bag/toolbox/etc
	var/escape_chance = 10
	/// What is the actual item we are "possessing"
	var/obj/item/possessed_item
	/// Is this item possessed by a revenant?
	var/revenant_possessed = FALSE

/mob/living/basic/possessed_object/examine(mob/user)
	. = possessed_item.examine(user)
	if(health > (maxHealth / 30))
		. += "<span class='warning'>[src] appears to be floating without any support!</span>"
	else
		. += "<span class='warning'>[src] appears to be having trouble staying afloat!</span>"


/mob/living/basic/possessed_object/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	..()
	animate_ghostly_presence(src, -1, 20, 1) // Restart the floating animation after the attack animation, as it will be cancelled.


/mob/living/basic/possessed_object/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE) // Silly motherfuckers think they can pull things.
	if(show_message)
		to_chat(src, "<span class='warning'>You are unable to pull [AM]!</span>")


/mob/living/basic/possessed_object/ghost() // Ghosting will return the object to normal, and will not disqualify the ghoster from various mid-round antag positions.
	var/response = tgui_alert(src, "End your possession of this object? (It will not stop you from respawning later)", "Are you sure you want to ghost?", list("Ghost", "Stay in body"))
	if(response != "Ghost")
		return
	lay_down()
	var/mob/dead/observer/ghost = ghostize()
	ghost.timeofdeath = world.time
	death(0) // Turn back into a regular object.

/mob/living/basic/possessed_object/death(gibbed)
	if(can_die())
		ghostize()
		// if gibbed, the item goes with the ghost
		if(!gibbed && possessed_item.loc == src)
			// Put the normal item back once the EVIL SPIRIT has been vanquished from it. If it's not already in place
			visible_message("<span type='notice'>The spooky aura in [src] dissipates!</span>")
			possessed_item.forceMove(loc)
			possessed_item.throwforce = initial(possessed_item.throwforce)

	return ..()

/mob/living/basic/possessed_object/Life(seconds, times_fired)
	..()

	if(!possessed_item) // If we're a donut and someone's eaten us, for instance.
		death(1)

	if(possessed_item.loc != src)
		if(isturf(possessed_item.loc)) // If we've, say, placed the possessed item on the table move onto the table ourselves instead and put it back inside of us.
			forceMove(possessed_item.loc)
			possessed_item.forceMove(src)
		else // If we're inside a toolbox or something, we are inside the item rather than the item inside us. This is so people can see the item in the toolbox.
			forceMove(possessed_item)

	if(l_hand) // Incase object interactions put things directly into our hands. (Like cameras, or gun magizines)
		drop_l_hand()
	if(r_hand)
		drop_r_hand()

	if(!isturf(loc) && prob(escape_chance)) //someone has stuffed us in their bag, or picked us up? Time to escape
		visible_message("<span class='notice'>[src] refuses to be contained!</span>")
		forceMove(get_turf(src))
		if(possessed_item.loc != src) //safety so the item doesn't somehow become detatched from us while doing this
			possessed_item.forceMove(src)

/mob/living/basic/possessed_object/Login()
	..()
	to_chat(src, "<span class='notice'><b>Your spirit has entered [src] and possessed it.</b><br>You are able to do most things a humanoid would be able to do with a [src] in their hands.<br>If you want to end your ghostly possession, use the '<b>ghost</b>' verb, it won't penalize your ability to respawn.</span>")


/mob/living/basic/possessed_object/Initialize(mapload)
	. = ..()

	if(!isitem(loc)) // Some silly motherfucker spawned us directly via the game panel.
		message_admins("<span class='adminnotice'>Possessed object improperly spawned, deleting.</span>") // So silly admins with debug off will see the message too and not spam these things.
		stack_trace("[src] spawned manually, no object to assign attributes to.")
		qdel(src)

	var/turf/possessed_loc = get_turf(loc)
	if(!istype(possessed_loc)) // Will this ever happen? Who goddamn knows.
		message_admins("<span class='adminnotice'>Possessed object could not find turf, deleting.</span>") // So silly admins with debug off will see the message too and not spam these things.
		stack_trace("[src] attempted to find a turf to spawn on, and could not.")
		qdel(src)

	possessed_item = loc
	forceMove(possessed_loc)
	possessed_item.forceMove(src) // We'll keep the actual item inside of us until we die.


	update_icon(UPDATE_NAME)
	throwforce = possessed_item.throwforce
	armor_penetration_flat = possessed_item.armor_penetration_flat
	armor_penetration_percentage = possessed_item.armor_penetration_percentage
	melee_damage_lower = max(0, possessed_item.force - 5)
	melee_damage_upper = possessed_item.force + 5

	visible_message("<span class='notice'>[src] rises into the air and begins to float!</span>") // Inform those around us that shit's gettin' spooky.
	animate_ghostly_presence(src, -1, 20, 1)


/mob/living/basic/possessed_object/get_active_hand() // So that our attacks count as attacking with the item we've possessed.
	if(revenant_possessed)
		return ..()
	return possessed_item


/mob/living/basic/possessed_object/IsAdvancedToolUser() // So we can shoot guns (Mostly ourselves), among other things.
	return TRUE


/mob/living/basic/possessed_object/get_access() // If we've possessed an ID card we've got access to lots of fun things!
	if(istype(possessed_item, /obj/item/card/id))
		var/obj/item/card/id/possessed_id = possessed_item
		. = possessed_id.access


/mob/living/basic/possessed_object/ClickOn(atom/A, params)
	if(client && client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(!isturf(loc)) // If we're inside a card machine or something similar then you're stuck.
		return

	name = spirit_name

	if(A == src) // If we're clicking ourself we should not attack ourself.
		possessed_item.attack_self__legacy__attackchain(src)
	else
		..()

	if(possessed_item.loc != src)
		if(isturf(possessed_item.loc)) // If we've, say, placed the possessed item on the table move onto the table ourselves instead and put it back inside of us.
			forceMove(possessed_item.loc)
			possessed_item.forceMove(src)
		else // If we're inside a toolbox or something, we are inside the item rather than the item inside us. This is so people can see the item in the toolbox.
			forceMove(possessed_item)

	update_icon()

/mob/living/basic/possessed_object/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	animate_ghostly_presence(src, -1, 20, 1)

/mob/living/basic/possessed_object/update_icon(update_pixel_xy = 0)
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
	return ..(NONE)

/mob/living/basic/possessed_object/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/nullrod))
		visible_message("<span type='notice'>[O] dispels the spooky aura!</span>")
		death()

		return ITEM_INTERACT_COMPLETE

/mob/living/basic/possessed_object/throw_impact(atom/hit_atom, throwingdatum)
	// Don't call parent here as the mob isn't doing the hitting, technically
	return possessed_item.throw_impact(hit_atom, throwingdatum)

/mob/living/basic/possessed_object/revenant
	maxHealth = 40
	health = 40
	melee_attack_cooldown_min = 4 SECONDS
	melee_attack_cooldown_max = 5 SECONDS
	faction = list("revenant")
	speed = -1
	a_intent = INTENT_HARM
	escape_chance = 100
	revenant_possessed = TRUE
	ai_controller = /datum/ai_controller/basic_controller/revenant

/mob/living/basic/possessed_object/revenant/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)
	throwforce = min(possessed_item.throwforce + 5, 15) // Damage it should do? throwforce+5 or 15, whichever is lower
	melee_damage_lower = min(possessed_item.throwforce + 5, 15)
	melee_damage_upper = melee_damage_lower
	var/outline_size = min((throwforce / 15) * 3, 3)
	add_filter("haunt_glow", 2, list("type" = "outline", "color" = "#7A4FA9", "size" = outline_size)) // Give it spooky purple outline
	ADD_TRAIT(src, TRAIT_DODGE_ALL_OBJECTS, "Revenant")
	ai_controller.set_ai_status(AI_STATUS_OFF)
	addtimer(CALLBACK(src, PROC_REF(begin_poltergheist)), 1 SECONDS, TIMER_UNIQUE) // Short warm-up for floaty ambience

/mob/living/basic/possessed_object/revenant/proc/begin_poltergheist()
	ai_controller.set_ai_status(AI_STATUS_ON)

/datum/ai_controller/basic_controller/revenant
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/swirl_around_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
