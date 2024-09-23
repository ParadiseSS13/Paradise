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
	var/min_time_between_pops = CLICK_CD_MELEE
	/// The longest possible length between fires.
	var/max_time_between_pops = 20 DECISECONDS
	/// Whether or not to play a smoke sound before going off
	var/play_fuse_sound = TRUE

/obj/item/grenade/firecracker/prime()
	. = ..()
	if(play_fuse_sound)
		playsound(src, 'sound/effects/smoke.ogg', 10, TRUE, -3)
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
	play_fuse_sound = FALSE

	/// The sounds which this grenade can select.
	var/static/list/possible_sounds = list(
		"revolver" = 'sound/weapons/gunshots/gunshot_strong.ogg',
		"armblade" = 'sound/weapons/armblade.ogg',
		"laser" = 'sound/weapons/laser.ogg',
		"sniper" = 'sound/weapons/gunshots/gunshot_sniper.ogg',
		"pistol" = 'sound/weapons/gunshots/gunshot_pistol.ogg',
		"blob" = 'sound/effects/splat.ogg',
		"bite" = 'sound/weapons/bite.ogg',
		"chainsaw" = 'sound/weapons/chainsaw.ogg'
	)

	/// The currently selected sound for the decoy.
	var/selected_sound = "revolver"

/obj/item/grenade/firecracker/decoy/Initialize(mapload)
	. = ..()
	selected_sound = possible_sounds[1]

/obj/item/grenade/firecracker/decoy/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src))
		return
	. += "[src] will sound like \a <span class='warning'>[selected_sound]</span>."
	. += "<span class='notice'>Alt-Click</span> to change the imitated sound."
	. += "<span class='notice'>Alt-Shift-Click</span> to change the frequency of the sound."

/obj/item/grenade/firecracker/decoy/AltClick(mob/user)
	. = ..()
	if(!user.Adjacent(src))
		return
	var/selected = tgui_input_list(user, "Choose the decoy sound.", items = possible_sounds)
	if(!user.Adjacent(src))
		to_chat(user, "<span class='warning'>You're too far from [src] to set the sound now!</span>")
		return
	if(selected)
		selected_sound = selected
		sound_effect = possible_sounds[selected]
		to_chat(user, "<span class='notice'>[src] will now sound like \a [selected].</span>")

/obj/item/grenade/firecracker/decoy/AltShiftClick(mob/user)
	. = ..()
	if(!user.Adjacent(src))
		return
	var/min_between_pops_input = tgui_input_number(user, "Select the minimum time between pops (in 1/10s of a second).", "Minimum time", min_time_between_pops, 50, 2)
	if(!user.Adjacent(src))
		to_chat(user, "<span class='notice'>You need to be closer to [src] to set this!</span>")
		return
	min_time_between_pops = min_between_pops_input
	var/max_between_pops_input = tgui_input_number(user, "Select the maximum time between pops (in 1/10s of a second).", "Maximum time", max_time_between_pops, 50, 2)
	if(!user.Adjacent(src))
		to_chat(user, "<span class='notice'>You need to be closer to [src] to set this!</span>")
		return

	max_time_between_pops = max_between_pops_input
