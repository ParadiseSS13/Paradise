/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = NO_POWER_USE
	anchored = TRUE
	density = TRUE

	var/charges = 1
	var/insisting = FALSE

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user)
	. = ..()

	if(.)
		return ..()

	if(charges <= 0)
		to_chat(user, "<span class='warning'>The Wish Granter lies silent.</span>")
		return TRUE

	else if(!ishuman(user))
		to_chat(user, "<span class='warning'>You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's..</span>")
		return

	else if(is_special_character(user))
		to_chat(user, "<span class='warning'>Even to a heart as dark as yours, you know nothing good will come of this. Something instinctual makes you pull away.</span>")

	else if(!insisting)
		to_chat(user, "<span class='warning'>Your first touch makes the Wish Granter stir, listening to you. Are you really sure you want to do this?</span>")
		insisting = TRUE

	else
		to_chat(user, "<span class='notice'>You speak. [pick("I want the station to disappear", "Humanity is corrupt, mankind must be destroyed", "I want to be rich", "I want to rule the world", "I want immortality.")]. The Wish Granter answers.</span>")
		to_chat(user, "<span class='notice'>Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first.</span>")

		charges--
		insisting = FALSE

		user.mind.add_antag_datum(/datum/antagonist/wishgranter)

		to_chat(user, "You have a very bad feeling about this.")
		
/obj/machinery/wish_granter/super
	name = "super wish granter"
	var/list/types = list()
	
/obj/machinery/wish_granter/super/attack_hand(mob/living/carbon/user)
	. = ..()

	if(.)
		return ..()

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.</warning>")
		return TRUE

	if(is_special_character(user) || jobban_isbanned(user, ROLE_TRAITOR) || jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>Something instinctual makes you pull away.</span>")
		return TRUE
	
	to_chat(user, "<span class='notice'>Your touch makes the Wish Granter stir. Are you really sure you want to do this?</span>")
	
	for(var/supname in GLOB.all_superheroes)
		types += supname

	var/wish
	if(types.len == 1)
		wish = pick(types)
	else
		wish = input("You want to become...", "Wish") as null|anything in types

	if(!wish || user.stat == DEAD || (get_dist(src, user) > 4)) // Another check after the input to check if someone already used it, closed it, or if they're dead, or if they ran off.
		return

	var/datum/superheroes/S = GLOB.all_superheroes[wish]
	if(S.activated)
		to_chat(user,"<span class='warning'>There can only be one! Pick something else!</span>")
		return

	S.create(user)
	S.activated = TRUE //sets this superhero as taken so we don't have duplicates

	playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
	visible_message("<span class='notice'>The wishgranter fades into mist..</span>")
	add_attack_logs(null, user, "Became [GLOB.all_superheroes[wish]]")
	notify_ghosts("[GLOB.all_superheroes[wish]] has appeared in [get_area(user)].", source = user)
	qdel(src)
