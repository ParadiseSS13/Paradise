//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0
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
	if(shattered)
		return

	if(ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			AC.flags = APPEARANCE_ALL_BODY
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/proc/shatter()
	if(shattered)
		return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()


/obj/structure/mirror/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(isscrewdriver(I))
		user.visible_message("<span class='notice'>[user] begins to unfasten [src].</span>", "<span class='notice'>You begin to unfasten [src].</span>")
		if(do_after(user, 30 * I.toolspeed, target = src))
			if(shattered)
				user.visible_message("<span class='notice'>[user] drops the broken shards to the floor.</span>", "<span class='notice'>You drop the broken shards on the floor.</span>")
				new /obj/item/shard(get_turf(user))
			else
				user.visible_message("<span class='notice'>[user] carefully places [src] on the floor.</span>", "<span class='notice'>You carefully place [src] on the floor.</span>")
				new /obj/item/mounted/mirror(get_turf(user))
			qdel(src)
			return

	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 70, 1)


/obj/structure/mirror/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(islarva(user))
		return
	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_animal(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	M.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_slime(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/slime/S = user
	if(!S.is_adult)
		return
	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	var/list/choosable_races = list()
	var/vox_picked = FALSE
	var/plasmaman_picked = FALSE

/obj/structure/mirror/magic/New()
	..()

/obj/structure/mirror/magic/badmin/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = new speciestype()
		choosable_races += S.name
	..()

/obj/structure/mirror/magic/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("Name", "Race", "Gender", "Hair", "Eyes")

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

		if("Race")
			var/list/race_list
			if(!choosable_races.len) //default races available handled here because each user has a different list of karma unlocked races
				race_list = list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin")
				if(config.usealienwhitelist)
					for(var/Spec in GLOB.whitelisted_species)
						if(is_alien_whitelisted(user, Spec))
							race_list += Spec
				else
					race_list += GLOB.whitelisted_species
			else
				race_list = choosable_races

			var/datum/species/newrace
			var/oldrace = H.dna.species.name
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in race_list
			newrace = GLOB.all_species[racechoice]
			if(!newrace || (newrace.name == oldrace))
				return

			if(oldrace == "Plasmaman")
				H.unEquip(H.get_item_by_slot(slot_wear_suit))
				H.unEquip(H.get_item_by_slot(slot_head))

			H.set_species(newrace.type)

			if((newrace.name == "Vox" || newrace.name == "Vox Armalis")  && !vox_picked)
				vox_picked = TRUE
				newrace.after_equip_job(null, H)
			if(newrace.name == "Plasmaman" && !plasmaman_picked)
				plasmaman_picked = TRUE
				newrace.after_equip_job(null, H)

			if(newrace.bodyflags & HAS_SKIN_TONE)
				H.s_tone = rand(-120, 20)
			H.update_body()
			H.update_hair()

		if("Gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return
			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "female"
					to_chat(H, "<span class='notice'>Man, you feel like a woman!</span>")
				else
					return

			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "male"
					to_chat(H, "<span class='notice'>Whoa man, you feel like a man!</span>")
				else
					return
			H.update_body()

		if("Hair")
			..() //So you just want to use a mirror then?

		if("Eyes")
			var/new_eye_color = input(H, "Choose your eye colour", "Eye Colour") as color|null
			if(new_eye_color)
				var/eye_color = sanitize_hexcolor(new_eye_color)
				H.change_eye_color(eye_color)
				H.update_body()

/obj/structure/mirror/magic/attackby(obj/item/I, mob/living/user, params)
	return

/obj/structure/mirror/magic/shatter()
	return //can't be broken. it's magic, i ain't gotta explain shit

/obj/item/mounted/mirror
	name = "mirror"
	desc = "Some reflective glass ready to be hung on a wall. Don't break it!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"

/obj/item/mounted/mirror/do_build(turf/on_wall, mob/user)
	var/obj/structure/mirror/M = new /obj/structure/mirror(get_turf(user), get_dir(on_wall, user), 1)
	transfer_prints_to(M, TRUE)
	qdel(src)
