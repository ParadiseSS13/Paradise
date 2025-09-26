//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

// Greed
/// Greed's slot machine: Used in the Greed ruin. Deals damage on each use, with a successful use giving a d20 of fate.
/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/computer.dmi'
	icon_state = "slots"
	anchored = TRUE
	density = TRUE
	/// Variable that tracks the screen we display.
	var/icon_screen = "slots_screen"
	/// Should we be emitting light?
	var/brightness_on = TRUE
	/// The probability the player has to win.
	var/win_prob = 5
	/// The maximum amount of curses we will allow a player to have before disallowing them to use the machine.
	var/max_curse_amount = 5
	/// machine's reward when you hit jackpot
	var/prize = /obj/structure/cursed_money
	/// should we be applying the cursed status effect?
	var/status_effect_on_roll = TRUE
	/// Length of the cooldown between the machine being used and being able to spin the machine again.
	var/cooldown_length = 30 SECONDS
	/// Are we currently in use? Anti-spam prevention measure.
	var/in_active_use = FALSE
	/// Cooldown between pulls of the cursed slot machine.
	COOLDOWN_DECLARE(spin_cooldown)

/obj/structure/cursed_slot_machine/Initialize(mapload)
	. = ..()
	update_appearance()
	set_light(brightness_on)

/obj/structure/cursed_slot_machine/attack_hand(mob/user)
	if(!ishuman(user))
		return

	if(!check_and_set_usage(user))
		return

	user.visible_message(
		"<span class='warning'>[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!</span>",
		"<span class='warning'>You feel a draining as you pull the lever, but you know it'll be worth it.</span>")

	icon_screen = "slots_screen_working"
	update_appearance()
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 5 SECONDS)

/obj/structure/cursed_slot_machine/update_overlays()
	. = ..()
	var/overlay_state = icon_screen
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, src)

/// Validates that the user can use the cursed slot machine. User is the person using the slot machine. Returns TRUE if we can, FALSE otherwise.
/obj/structure/cursed_slot_machine/proc/check_and_set_usage(mob/living/carbon/human/user)
	if(in_active_use)
		to_chat(user, "<span class='warning'>The machine is already spinning!</span>")
		return FALSE

	var/signal_value = SEND_SIGNAL(user, COMSIG_CURSED_SLOT_MACHINE_USE, max_curse_amount)

	if(!COOLDOWN_FINISHED(src, spin_cooldown) || (signal_value & SLOT_MACHINE_USE_POSTPONE))
		to_chat(user, "<span class='danger'>The machine doesn't engage. You get the compulsion to try again in a few seconds.</span>")
		return FALSE

	if(signal_value & SLOT_MACHINE_USE_CANCEL) // failsafe in case we don't want to let the machine be used for some reason (like if we're maxed out on curses but not getting gibbed)
		atom_say("We're sorry, but we can no longer serve you at this establishment.")
		return FALSE

	in_active_use = TRUE
	return TRUE

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/carbon/human/user)
	icon_screen = initial(icon_screen)
	update_appearance()

	in_active_use = FALSE
	COOLDOWN_START(src, spin_cooldown, cooldown_length)

	if(!prob(win_prob))
		if(status_effect_on_roll && isnull(user.has_status_effect(/datum/status_effect/cursed)))
			user.apply_status_effect(/datum/status_effect/cursed)

		SEND_SIGNAL(user, COMSIG_CURSED_SLOT_MACHINE_LOST)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return

	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, FALSE)
	new prize(get_turf(src))
	if(user)
		to_chat(user, "<span class='boldwarning'>You've hit the jackpot!!! Laughter echoes around you as your reward appears in the machine's place.</span>")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CURSED_SLOT_MACHINE_WON)
	qdel(src)

/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "moneybag"
	density = TRUE

/obj/structure/cursed_money/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 600)

/obj/structure/cursed_money/proc/collapse()
	visible_message("<span class='warning'>[src] falls in on itself, \
		canvas rotting away and contents vanishing.</span>")
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	user.visible_message("<span class='warning'>[user] opens the bag and \
		and removes a die. The bag then vanishes.</span>",
		"<span class='boldwarning'>You open the bag...!</span>\n\
		<span class='danger'>And see a bag full of dice. Confused, \
		you take one... and the bag vanishes.</span>")
	var/turf/T = get_turf(user)
	var/obj/item/dice/d20/fate/one_use/critical_fail = new(T)
	user.put_in_hands(critical_fail)
	collapse()

// Gluttony
/// Gluttony's wall: Used in the Gluttony ruin. Only lets the overweight through.
/obj/effect/gluttony
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	density = TRUE
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'
	color = rgb(145, 150, 0)

/obj/effect/gluttony/CanPass(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT || HAS_TRAIT(H, TRAIT_FAT))
			H.visible_message("<span class='warning'>[H] pushes through [src]!</span>", "<span class='notice'>You've seen and eaten worse than this.</span>")
			return TRUE
		else
			to_chat(H, "<span class='warning'>You're repulsed by even looking at [src]. Only a pig could force themselves to go through it.</span>")
	if(ismorph(mover))
		return TRUE
	else
		return FALSE

// Pride
/// Pride's mirror: Used in the Pride ruin.
/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><b>The ground splits beneath [user] as [user.p_their()] hand leaves the mirror!</b></span>", \
	"<span class='notice'>Perfect. Much better! Now <i>nobody</i> will be able to resist yo-</span>")

	var/turf/T = get_turf(user)
	if(!user.Adjacent(src)) // Trying to escape?
		var/turf/return_turf = locate(x, y - 1, z) // To the south one to account for the fact the mirror is on a wall
		var/mob/living/carbon/human/fool = user
		if(return_turf && fool)
			to_chat(fool, "<span class='colossus'><b>You dare try to play me for a fool?</b></span>")
			fool.monkeyize()
			fool.forceMove(return_turf)
			return
	T.ChangeTurf(/turf/simulated/floor/chasm/space_ruin)
	if(user.Adjacent(src))
		var/turf/simulated/floor/chasm/space_ruin/C = T
		C.drop(user)

// Envy
/// Envy's knife: Found in the Envy ruin. Attackers take on the appearance of whoever they strike.
/obj/item/kitchen/knife/envy
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	worn_icon_state = "knife"
	inhand_icon_state = "knife"
	force = 18
	w_class = WEIGHT_CLASS_NORMAL
	new_attack_chain = TRUE

/obj/item/kitchen/knife/envy/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(user))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user)
			user.visible_message("<span class='warning'>[user]'s appearance shifts into [H]'s!</span>", \
			"<span class='boldannounceic'>[H.p_they(TRUE)] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't.</span>")

// Sloth
/obj/item/paper/fluff/stations/lavaland/sloth/note
	name = "note from sloth"
	icon_state = "paper_words"
	info = "have not gotten around to finishing my cursed item yet sorry - sloth"
