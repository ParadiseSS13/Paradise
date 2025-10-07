//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 100
	var/list/ui_users = list()
	var/broken_icon_state = "mirror_broke"

/obj/structure/mirror/organ

/obj/structure/mirror/Initialize(mapload, newdir = SOUTH, building = FALSE)
	. = ..()
	if(building)
		switch(newdir)
			if(NORTH)
				pixel_y = -32
			if(SOUTH)
				pixel_y = 32
			if(EAST)
				pixel_x = -32
			if(WEST)
				pixel_x = 32
	GLOB.mirrors += src

/obj/structure/mirror/Destroy()
	QDEL_LIST_ASSOC_VAL(ui_users)
	GLOB.mirrors -= src
	return ..()

/obj/structure/mirror/attack_hand(mob/user)
	if(broken)
		return

	if(ishuman(user))
		var/datum/ui_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror"
			AC.flags = APPEARANCE_ALL_BODY
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!broken && !(flags & NODECONSTRUCT))
		icon_state = broken_icon_state
		if(!mapload)
			playsound(src, "shatter", 70, TRUE)
		if(desc == initial(desc))
			desc = "Oh no, seven years of bad luck!"
		broken = TRUE
		GLOB.mirrors -= src

/obj/structure/mirror/organ/obj_break(damage_flag, mapload)
	playsound(src, "shatter", 70, TRUE)
	qdel(src)

/obj/structure/mirror/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begins to unfasten [src].</span>", "<span class='notice'>You begin to unfasten [src].</span>")
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	if(broken)
		user.visible_message("<span class='notice'>[user] drops the broken shards to the floor.</span>", "<span class='notice'>You drop the broken shards on the floor.</span>")
		new /obj/item/shard(get_turf(user))
	else
		user.visible_message("<span class='notice'>[user] carefully places [src] on the floor.</span>", "<span class='notice'>You carefully place [src] on the floor.</span>")
		new /obj/item/mounted/mirror(get_turf(user))
	qdel(src)

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)


/obj/item/mounted/mirror
	name = "mirror"
	desc = "Some reflective glass ready to be hung on a wall. Don't break it!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"

/obj/item/mounted/mirror/do_build(turf/on_wall, mob/user)
	var/obj/structure/mirror/M = new /obj/structure/mirror(get_turf(user), get_dir(on_wall, user), 1)
	transfer_prints_to(M, TRUE)
	qdel(src)

/obj/structure/mirror/magic
	name = "magic mirror"
	icon_state = "magic_mirror"
	broken_icon_state = "magic_mirror_broke"
	var/options = list("Name", "Body", "Voice")
	var/organ_warn = FALSE
	var/actually_magical = TRUE

/obj/structure/mirror/magic/Initialize(mapload, newdir, building)
	. = ..()
	RegisterSignal(src, COMSIG_ATTACK_BY, TYPE_PROC_REF(/datum, signal_cancel_attack_by))

/obj/structure/mirror/magic/attack_hand(mob/user)
	if(!ishuman(user) || broken)
		return

	var/mob/living/carbon/human/H = user
	var/choice = tgui_input_list(user, "Something to change?", "Magical Grooming", options)

	switch(choice)
		if("Name")
			var/newname = copytext(sanitize(input(H, "Who are we again?", "Name change", H.name) as null|text),1,MAX_NAME_LEN)

			if(!newname)
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

			if(newname)
				curse(user)

		if("Body")
			if(organ_warn)
				to_chat(user, "<span class='boldwarning'>Using the mirror will destroy any non biochip implants in you!</span>")
			var/list/race_list = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Grey", "Drask")
			if(actually_magical)
				race_list = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Grey", "Drask", "Vox", "Plasmaman", "Kidan", "Slime People")

			var/datum/ui_module/appearance_changer/AC = ui_users[user]
			if(!AC)
				AC = new(src, user)
				AC.name = "Magic Mirror"
				AC.flags = APPEARANCE_ALL
				AC.whitelist = race_list
				ui_users[user] = AC
			if(user.Adjacent(src))
				AC.ui_interact(user)

		if("Voice")
			var/voice_choice = tgui_input_list(user, "Perhaps...", "Voice effects", list("Comic Sans", "Wingdings", "Swedish", "Chav", "Mute"))
			var/voice_mutation
			switch(voice_choice)
				if("Comic Sans")
					voice_mutation = GLOB.comicblock
				if("Wingdings")
					voice_mutation = GLOB.wingdingsblock
				if("Swedish")
					voice_mutation = GLOB.swedeblock
				if("Chav")
					voice_mutation = GLOB.chavblock
				if("Mute")
					voice_mutation = GLOB.muteblock
			if(voice_mutation)
				if(H.dna.GetSEState(voice_mutation))
					H.dna.SetSEState(voice_mutation, FALSE)
					singlemutcheck(H, voice_mutation, MUTCHK_FORCED)
				else
					H.dna.SetSEState(voice_mutation, TRUE)
					singlemutcheck(H, voice_mutation, MUTCHK_FORCED)

			if(voice_choice)
				curse(user)

/obj/structure/mirror/magic/ui_close(mob/user)
	curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return

/obj/structure/mirror/magic/nuclear
	name = "M.A.G.I.C mirror"
	desc = "The M.A.G.I.C mirror will let you change your species in a flash! Be careful, any implants (not biochips) in you will be destroyed on use."
	options = list("Body")
	organ_warn = TRUE
	actually_magical = FALSE

