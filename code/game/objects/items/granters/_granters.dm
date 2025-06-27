/**
 * Books that teach things.
 *
 * (Intrinsic actions like bar flinging, spells like fireball or smoke, or martial arts)
 */
/obj/item/book/granter
	/// Flavor messages displayed to mobs reading the granter
	var/list/remarks = list()
	/// Controls how long a mob must keep the book in his hand to actually successfully learn
	var/pages_to_mastery = 3
	/// Sanity, whether it's currently being read
	var/reading = FALSE
	/// The amount of uses on the granter.
	var/uses = 1
	/// The time it takes to read the book
	var/reading_time = 5 SECONDS
	/// The sounds played as the user's reading the book.
	var/list/book_sounds = list(
		'sound/effects/pageturn1.ogg',
		'sound/effects/pageturn2.ogg',
		'sound/effects/pageturn3.ogg'
	)

/obj/item/book/granter/Initialize(mapload, datum/cachedbook/CB, _copyright, _protected)
	. = ..()
	RegisterSignal(src, COMSIG_ACTIVATE_SELF, TYPE_PROC_REF(/datum, signal_cancel_activate_self))

/obj/item/book/granter/activate_self(mob/user)
	if(..())
		return
	if(reading)
		to_chat(user, "<span class='warning'>You're already reading this!</span>")
		return FINISH_ATTACK
	if(!user.has_vision())
		to_chat(user, "<span class='warning'>You are blind and can't read anything!</span>")
		return FINISH_ATTACK
	if(!isliving(user))
		return FINISH_ATTACK
	if(!can_learn(user))
		return FINISH_ATTACK

	if(uses <= 0)
		recoil(user)
		return FINISH_ATTACK

	on_reading_start(user)
	reading = TRUE
	for(var/i in 1 to pages_to_mastery)
		if(!turn_page(user))
			on_reading_stopped(user)
			reading = FALSE
			return CONTINUE_ATTACK
	if(do_after(user, reading_time, src))
		uses--
		on_reading_finished(user)
	reading = FALSE

/// Called when the user starts to read the granter.
/obj/item/book/granter/proc/on_reading_start(mob/living/user)
	to_chat(user, "<span class='notice'>You start reading [name]...</span>")

/// Called when the reading is interrupted without finishing.
/obj/item/book/granter/proc/on_reading_stopped(mob/living/user)
	to_chat(user, "<span class='notice'>You stop reading...</span>")

/// Called when the reading is completely finished. This is where the actual granting should happen.
/obj/item/book/granter/proc/on_reading_finished(mob/living/user)
	to_chat(user, "<span class='notice'>You finish reading [name]!</span>")

/// The actual "turning over of the page" flavor bit that happens while someone is reading the granter.
/obj/item/book/granter/proc/turn_page(mob/living/user)
	playsound(user, pick(book_sounds), 30, TRUE)

	if(!do_after(user, reading_time, src))
		return FALSE

	to_chat(user, "<span class='notice'>[length(remarks) ? pick(remarks) : "You keep reading..."]</span>")
	return TRUE

/// Effects that occur whenever the book is read when it has no uses left.
/obj/item/book/granter/proc/recoil(mob/living/user)
	return

/// Checks if the user can learn whatever this granter... grants
/obj/item/book/granter/proc/can_learn(mob/living/user)
	return TRUE

// Generic action giver
/obj/item/book/granter/action
	/// The typepath of action that is given
	var/datum/action/granted_action
	/// The name of the action, formatted in a more text-friendly way.
	var/action_name = ""

/obj/item/book/granter/action/can_learn(mob/living/user)
	if(!granted_action)
		CRASH("Someone attempted to learn [type], which did not have an action set.")
	if(locate(granted_action) in user.actions)
		to_chat(user, "<span class='warning'>You already know all about [action_name]!</span>")
		return FALSE
	return TRUE

/obj/item/book/granter/action/on_reading_start(mob/living/user)
	to_chat(user, "<span class='notice'>You start reading about [action_name]...</span>")

/obj/item/book/granter/action/on_reading_finished(mob/living/user)
	to_chat(user, "<span class='notice'>You feel like you've got a good handle on [action_name]!</span>")
	// Action goes on the mind as the user actually learns the thing in your brain
	var/datum/action/new_action = new granted_action(user.mind || user)
	new_action.Grant(user)

// Generic action giver
/obj/item/book/granter/spell
	/// The typepath of spell that is given
	var/datum/spell/granted_spell
	/// The name of the spell, formatted in a more text-friendly way
	var/spell_name = ""

/obj/item/book/granter/spell/on_reading_finished(mob/living/user)
	if(!user.mind)
		return
	to_chat(user, "<span class='notice'>You feel like you've got a good handle on [spell_name]!</span>")
	user.mind.AddSpell(new granted_spell(null))
