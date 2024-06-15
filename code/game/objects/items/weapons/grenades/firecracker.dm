/obj/item/grenade/firecracker
	name = "fire-cracker"
	desc = "A firework that's great at making a lot of noise."
	det_time = 2 SECONDS
	/// The effect that will be randomly played at intervals.
	var/sound_effect = 'sound/weapons/gunshots/gunshot_strong.ogg'
	/// The minimum number of times it will fire.
	var/min_pops = 5
	/// The maximum number of times it fires.
	var/max_pops = 20
	/// How long, at least, we'll end up between pops.
	var/min_time_between_pops = 5 DECISECONDS
	/// The longest possible length between fires.
	var/max_time_between_pops = 20 DECISECONDS


/obj/item/grenade/firecracker/prime()
	. = ..()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	INVOKE_ASYNC(src, PROC_REF(start_popping), TRUE)

/obj/item/grenade/firecracker/proc/start_popping(del_after = FALSE)
	for(var/i in 0 to rand(min_pops, max_pops))
		playsound(src, sound_effect, 100, TRUE)
		sleep(rand(min_time_between_pops, max_time_between_pops))
	if(del_after)
		qdel(src)

/obj/item/grenade/firecracker/decoy
	name = "decoy grenade"
	desc = "A grenade capable of imitating many different sounds."

	var/list/possible_sounds = list(
		"revolver" = 'sound/weapons/gunshots/gunshot_strong.ogg',
		"armblade" = 'sound/weapons/armblade.ogg',
		"laser" = 'sound/weapons/laser.ogg',
		"sniper" = 'sound/weapons/gunshots/gunshot_sniper.ogg',
		"pistol" = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	)

	var/selected_sound = "revolver"

/obj/item/grenade/firecracker/decoy/Initialize(mapload)
	. = ..()
	selected_sound = possible_sounds[1]

/obj/item/grenade/firecracker/decoy/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src))
		return
	. += "<span class='notice'>[src] will sound like \a [selected_sound].</span>"
	. += "<span class='notice'>Alt-Click to change the imitated sound.</span>"

/obj/item/grenade/firecracker/decoy/AltClick(mob/user)
	. = ..()
	var/selected = tgui_input_list(user, "Choose the decoy sound.", items = possible_sounds)
	sound_effect = possible_sounds[selected] || sound_effect
	to_chat(user, "<span class='notice'>[src] will now sound like \a [selected_sound].</span>")

/obj/item/grenade/firecracker/decoy/AltShiftClick(mob/user)
	. = ..()
	min_time_between_pops = tgui_input_number(user, "Select the minimum time between pops (in 1/10s of a second).", "Minimum time", min_time_between_pops, 50, 2)
	max_time_between_pops = tgui_input_number(user, "Select the maximum time between pops (in 1/10s of a second).", "Maximum time", max_time_between_pops, 50, 2)

