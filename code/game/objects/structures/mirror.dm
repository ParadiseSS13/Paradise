//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	max_integrity = 200
	integrity_failure = 100
	var/list/ui_users = list()

/obj/structure/mirror/New(turf/T, newdir = SOUTH, building = FALSE)
	..()
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

/obj/structure/mirror/attack_hand(mob/user)
	if(broken)
		return

	if(ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			AC.flags = APPEARANCE_ALL_BODY
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!broken && !(flags & NODECONSTRUCT))
		icon_state = "mirror_broke"
		if(!mapload)
			playsound(src, "shatter", 70, TRUE)
		if(desc == initial(desc))
			desc = "Oh no, seven years of bad luck!"
		broken = TRUE

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

/obj/structure/mirror/magic/attack_hand(mob/user)
	if(!ishuman(user) || broken)
		return

	var/mob/living/carbon/human/H = user
	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("Name", "Body", "Voice")

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
			var/list/race_list = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
			if(config.usealienwhitelist)
				for(var/Spec in GLOB.whitelisted_species)
					if(is_alien_whitelisted(H, Spec))
						race_list += Spec
			else
				race_list += GLOB.whitelisted_species

			var/datum/nano_module/appearance_changer/AC = ui_users[user]
			if(!AC)
				AC = new(src, user)
				AC.name = "Magic Mirror"
				AC.flags = APPEARANCE_ALL
				AC.whitelist = race_list
				ui_users[user] = AC
			AC.ui_interact(user)

		if("Voice")
			var/voice_choice = input(user, "Perhaps...", "Voice effects") as null|anything in list("Comic Sans", "Wingdings", "Swedish", "Chav")
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
			if(voice_mutation)
				if(H.dna.GetSEState(voice_mutation))
					H.dna.SetSEState(voice_mutation, FALSE)
					genemutcheck(H, voice_mutation, null, MUTCHK_FORCED)
				else
					H.dna.SetSEState(voice_mutation, TRUE)
					genemutcheck(H, voice_mutation, null, MUTCHK_FORCED)

			if(voice_choice)
				curse(user)

/obj/structure/mirror/magic/on_ui_close(mob/user)
	curse(user)

/obj/structure/mirror/magic/attackby(obj/item/I, mob/living/user, params)
	return

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return
