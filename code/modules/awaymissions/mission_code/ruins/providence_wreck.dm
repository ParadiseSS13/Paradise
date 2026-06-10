/obj/structure/environmental_storytelling_holopad/providence
	speaking_name = "Captain Charon"

/obj/structure/environmental_storytelling_holopad/providence/start_message(mob/living/carbon/human/H)
	activated = TRUE
	QDEL_NULL(proximity_monitor)
	icon_state = "holopad1"
	update_icon(UPDATE_OVERLAYS)
	var/obj/effect/overlay/hologram = new(get_turf(src))
	our_holo = hologram
	hologram.icon = getHologramIcon(icon('icons/mob/simple_human.dmi', "captain_charon"), colour = null, opacity = 0.8, colour_blocking = TRUE) // This is more offputting. Also in colour more and less transparent.
	hologram.alpha = 166
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hologram.layer = FLY_LAYER
	hologram.anchored = TRUE
	hologram.name = speaking_name
	hologram.set_light(2)
	hologram.bubble_icon = "swarmer"
	hologram.pixel_y = 16
	for(var/I in things_to_say)
		hologram.atom_say("[I]")
		sleep(loop_sleep_time)
	qdel(hologram)
	icon_state = initial(icon_state)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/environmental_storytelling_holopad/providence/bridge
	things_to_say = list(
		"Log. This is Captain Charon... Of the independant vessel 'Providence'...",
		"Hrk... That thing... it got me good. Hah. I got it better.",
		"Eckart didn't make it. They got him. I haven't heard the screams for hours now...",
		"This place - it's hell. It's truly hell.",
		"I'm locking down the ship. That's all I can do now.",
		"If anyone heard any of my recordings, you can use the device here to disable the lockdown... but it'll probably attract the beasts to you while it works.",
		"If nobody did... Hah, then why am I still talking?",
		"Captain Charon, signing off... Please, before this place takes me too."
	)

/obj/structure/environmental_storytelling_holopad/providence/last_stand
	things_to_say = list(
		"Log. This is Captain Charon of the independant vessel 'Providence...",
		"The noises are growing closer. We've already seen assailants from some tribal species and other creatures.",
		"They're probing our defenses - looking for a way in. We've locked down the damaged sections from what's still intact. That'll buy us time.",
		"Eckart is proving to be a good skirmisher, but he's running low on shells.",
		"While he buys us time, we've begun to fortify this room. We'll hold out. I promised my crew that much.",
		"Captain Charon, signing off. If you see miss Protheros, tell her I love her very much."
	)

/obj/structure/environmental_storytelling_holopad/providence/crew_quarters
	things_to_say = list(
		"Log. This is Captain Charon of the independant vessel 'Providence.",
		"It's not looking good. Most of the crew were badly injured in the crash.",
		"We've got what doctors are still mobile running triage, but that's not the worst of it.",
		"Lieutenant Eckart took an old spacesuit out to look around, and he came back. Said he heard noises.",
		"Nothing good can come of that, no sir. What crew remain alive have taken up arms. We're not going to die down here.",
		"Captain Charon, signing off."
	)

/obj/structure/environmental_storytelling_holopad/providence/communications
	things_to_say = list(
		"Log. This is Captain Charon of the independant vessel 'Providence.",
		"We've sent out a distress signal. Best we can do now is wait.",
		"The back half of the ship is gone. That hole in the ground... it doesn't end.",
		"Sergeant Kenefick shined a targeting laser into the hole, and the rangefinder wouldn't stop ticking.",
		"We've lost all contact with engineering, and a chunk of our medical deck is gone.",
		"I believe we can pull through though. Things seem rough, but we've toughed through worse.",
		"Captain Charon, signing off."
	)

/obj/structure/providence_lockdown_controller
	name = "lockdown controller"
	desc = "A machine that controls the heavy blast doors all around the ship. Reversing this should unlock the entire ship for exploration."
	icon = 'icon/obj/machines/mining_machines.dmi'
	icon_state = "asteroid_magnet"
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// How long does it take to remove the lockdown
	var/lockdown_time = 8 MINUTES
	/// Number of waves
	var/wave_count = 4
	/// Minimum mobs per wave
	var/wave_mob_min = 3
	/// Max mobs per wave
	var/wave_mob_max = 6
	/// Mobs that can spawn in the wave
	var/list/wave_mobs = list(

	)
	/// Mob faction
	var/mob_faction = "providence_attackers"
