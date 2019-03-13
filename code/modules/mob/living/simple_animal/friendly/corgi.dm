//Corgi
/mob/living/simple_animal/pet/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/corgi = 3)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5
	childtype = /mob/living/simple_animal/pet/corgi/puppy
	simplespecies = /mob/living/simple_animal/pet/corgi
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY
	var/shaved = 0
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger
	var/default_atmos_requirements = 0
	var/last_eaten = 0

/mob/living/simple_animal/pet/corgi/New()
	..()
	default_atmos_requirements = src.atmos_requirements
	regenerate_icons()
	if(gender == NEUTER)
		gender = pick(MALE, FEMALE)

/mob/living/simple_animal/pet/corgi/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/corgi/show_inv(mob/user as mob)
	user.set_machine(src)
	if(user.stat) return

	var/dat = {"<table>"}

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];[inventory_head?"remove_inv":"add_inv"]=head'>[(inventory_head && !(inventory_head.flags&ABSTRACT)) ? inventory_head : "<font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];[inventory_back?"remove_inv":"add_inv"]=back'>[(inventory_back && !(inventory_back.flags&ABSTRACT)) ? inventory_back : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(can_collar)
		dat += "<tr><td>&nbsp;</td></tr>"
		dat += "<tr><td><B>Collar:</B></td><td><A href='?src=[UID()];item=[slot_collar]'>[(collar && !(collar.flags&ABSTRACT)) ? collar : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(facehugger)
		dat += "<tr><td><B>Facehugger:</B></td><td><A href='?src=[UID()];remove_hugger=1'>[facehugger]</A></td></tr>"
	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/pet/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				to_chat(user, "<span class='warning'>[src] is wearing too much armor! You can't cause [p_them()] any damage.</span>")
				visible_message("<span class='danger'> [user] hits [src] with [O], however [src] is too armored.</span>")
			else
				to_chat(user, "<span class='warning'>[src] is wearing too much armor! You can't reach [p_their()] skin.</span>")
				visible_message("[user] gently taps [src] with [O].")
			if(health>0 && prob(15))
				custom_emote(1, "looks at [user] with [pick("an amused","an annoyed","a confused","a resentful", "a happy", "an excited")] expression.")
			return

	if(istype(O, /obj/item/razor))
		if(shaved)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>")
			return
		user.visible_message("[user] starts to shave [src] using \the [O].", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, 50 * O.toolspeed, target = src))
			user.visible_message("[user] shaves [src]'s hair using \the [O].")
			playsound(loc, O.usesound, 20, 1)
			shaved = 1
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()

/mob/living/simple_animal/pet/corgi/Topic(href, href_list)
	if(usr.stat) return
	if((!ishuman(usr) && !isrobot(usr)) || !Adjacent(usr))
		return
	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					if(inventory_head.flags & NODROP)
						to_chat(usr, "<span class='warning'>\The [inventory_head] is stuck too hard to [src] for you to remove!</span>")
						return
					name = real_name
					desc = initial(desc)
					speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
					speak_emote = list("barks", "woofs")
					emote_hear = list("barks", "woofs", "yaps","pants")
					emote_see = list("shakes its head", "shivers")
					desc = "It's a corgi."
					set_light(0)
					mutations.Remove(BREATHLESS)
					atmos_requirements = default_atmos_requirements
					minbodytemp = initial(minbodytemp)
					inventory_head.loc = src.loc
					inventory_head = null
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
			if("back")
				if(inventory_back)
					if(inventory_back.flags & NODROP)
						to_chat(usr, "<span class='warning'>\The [inventory_back] is stuck too hard to [src] for you to remove!</span>")
						return
					inventory_back.loc = src.loc
					inventory_back = null
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
		show_inv(usr)
	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand(),usr)

			if("back")
				if(inventory_back)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()

					if(!item_to_add)
						usr.visible_message("[usr] pets [src].","<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
						return
					if(istype(item_to_add,/obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/suit/armor/vest/blueshield,
						/obj/item/clothing/suit/space/deathsquad,
						/obj/item/clothing/suit/space/hardsuit/engineering,
						/obj/item/radio,
						/obj/item/radio/off,
						/obj/item/clothing/suit/cardborg,
						/obj/item/tank/oxygen,
						/obj/item/tank/air,
						/obj/item/extinguisher,
					)

					if( ! ( item_to_add.type in allowed_types ) )
						to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s back, but [p_they()] shake[p_s()] it off!</span>")
						if(!usr.drop_item())
							to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!</span>")
							return
						item_to_add.loc = loc
						if(prob(25))
							step_rand(item_to_add)
						for(var/i in list(1,2,4,8,4,8,4,dir))
							dir = i
							sleep(1)
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					regenerate_icons()
		show_inv(usr)
//Removing facehuggers
	else if(href_list["remove_hugger"])
		if(!facehugger)
			return
		var/obj/item/F = facehugger
		F.forceMove(loc)
		facehugger = null
		to_chat(usr, "<span class='notice'>You remove [F] from [src]'s face. [src] pants for air and barks.</span>")
		regenerate_icons()
		show_inv(usr)
	else
		..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
/mob/living/simple_animal/pet/corgi/proc/place_on_head(obj/item/item_to_add, var/mob/user as mob)

	if(istype(item_to_add,/obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("[user] pets [src].","<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		return


	var/valid = 0

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.
	if(istype(item_to_add, /obj/item/clothing/accessory/scarf))
		valid = 1
	else
		switch(item_to_add.type)
			if( /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/head/that, /obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/hardhat, /obj/item/clothing/head/collectable/hardhat, /obj/item/clothing/head/hardhat/white,
					/obj/item/paper)
				valid = 1

			if(/obj/item/clothing/head/helmet)
				name = "Sergeant [real_name]"
				desc = "The ever-loyal, the ever-vigilant."
				valid = 1

			if(/obj/item/clothing/head/chefhat,	/obj/item/clothing/head/collectable/chef)
				name = "Sous chef [real_name]"
				desc = "Your food will be taste-tested.  All of it."
				valid = 1

			if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
				name = "Captain [real_name]"
				desc = "Probably better than the last captain."
				valid = 1

			if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
				name = "Runtime"
				emote_see = list("coughs up a furball", "stretches")
				emote_hear = list("purrs")
				speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
				desc = "It's a cute little kitty-cat! ... wait ... what the hell?"
				valid = 1

			if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
				name = "Hoppy"
				emote_see = list("twitches its nose", "hops around a bit")
				desc = "This is Hoppy. It's a corgi-...urmm... bunny rabbit"
				valid = 1

			if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
				name = "Yann"
				desc = "Mon dieu! C'est un chien!"
				speak = list("le woof!", "le bark!", "JAPPE!!")
				emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")
				valid = 1

			if(/obj/item/clothing/head/det_hat)
				name = "Detective [real_name]"
				desc = "[name] sees through your lies..."
				emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.")
				valid = 1

			if(/obj/item/clothing/head/nursehat)
				name = "Nurse [real_name]"
				desc = "[name] needs 100cc of beef jerky... STAT!"
				valid = 1

			if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
				name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
				desc = "Yaarghh!! Thar' be a scurvy dog!"
				emote_see = list("hunts for treasure.","stares coldly...","gnashes his tiny corgi teeth!")
				emote_hear = list("growls ferociously!", "snarls.")
				speak = list("Arrrrgh!!","Grrrrrr!")
				valid = 1

			if(/obj/item/clothing/head/ushanka)
				name = "[pick("Comrade","Commissar","Glorious Leader")] [real_name]"
				desc = "A follower of Karl Barx."
				emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vanguardism.")
				valid = 1

			if(/obj/item/clothing/head/warden, /obj/item/clothing/head/collectable/police)
				name = "Officer [real_name]"
				emote_see = list("drools.","looks for donuts.")
				desc = "Stop right there criminal scum!"
				valid = 1

			if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
				name = "Grandwizard [real_name]"
				speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
				valid = 1

			if(/obj/item/clothing/head/cardborg)
				name = "Borgi"
				speak = list("Ping!","Beep!","Woof!")
				emote_see = list("goes rogue.", "sniffs out non-humans.")
				desc = "Result of robotics budget cuts."
				valid = 1

			if(/obj/item/bedsheet)
				name = "\improper Ghost"
				speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
				emote_see = list("stumbles around.", "shivers.")
				emote_hear = list("howls!","groans.")
				desc = "Spooky!"
				valid = 1

			if(/obj/item/clothing/head/helmet/space/santahat)
				name = "Santa's Corgi Helper"
				emote_hear = list("barks Christmas songs.", "yaps merrily!")
				emote_see = list("looks for presents.", "checks his list.")
				desc = "He's very fond of milk and cookies."
				valid = 1

			if(/obj/item/clothing/head/soft)
				name = "Corgi Tech [real_name]"
				desc = "The reason your yellow gloves have chew-marks."
				valid = 1

			if(/obj/item/clothing/head/hardhat/reindeer)
				name = "[real_name] the red-nosed Corgi"
				emote_hear = list("lights the way!", "illuminates.", "yaps!")
				desc = "He has a very shiny nose."
				set_light(1)
				valid = 1

			if(/obj/item/clothing/head/sombrero)
				name = "Segnor [real_name]"
				desc = "You must respect elder [real_name]"
				valid = 1

			if(/obj/item/clothing/head/hopcap)
				name = "Lieutenant [real_name]"
				desc = "Can actually be trusted to not run off on his own."
				valid = 1

			if(/obj/item/clothing/head/helmet/space/deathsquad)
				name = "Trooper [real_name]"
				desc = "That's not red paint. That's real corgi blood."
				valid = 1

			if(/obj/item/clothing/head/helmet/space/hardsuit/engineering)
				name = "Space Explorer [real_name]"
				desc = "That's one small step for a corgi. One giant yap for corgikind."
				valid = 1
				mutations.Add(BREATHLESS)
				atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
				minbodytemp = 0

			if(/obj/item/clothing/mask/fakemoustache)
				name = "Definitely Not [real_name]"
				desc = "That's Definitely Not [real_name]"
				valid = 1
			
			if(/obj/item/clothing/head/beret/centcom/officer, /obj/item/clothing/head/beret/centcom/officer/navy)
				name = "Blueshield [real_name]"
				desc = "Will stand by you until the bitter end."
				emote_see = list("stands with pride.", "growls heroically.")
				valid = 1

	if(valid)
		if(user && !user.drop_item())
			to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
			return 0
		if(health <= 0)
			to_chat(user, "<span class ='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("[user] puts [item_to_add] on [real_name]'s head.  [src] looks at [user] and barks once.",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head.  [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.loc = src
		src.inventory_head = item_to_add
		regenerate_icons()

	else
		if(user && !user.drop_item())
			to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
			return 0
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but [p_they()] shake[p_s()] it off!</span>")
		item_to_add.loc = loc
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			dir = i
			sleep(1)

	return valid


//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID

/mob/living/simple_animal/pet/corgi/Ian/process_ai()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				spawn(0)
					stop_automated_movement = 1
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)

					if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
						if(movement_target.loc.x < src.x)
							dir = WEST
						else if(movement_target.loc.x > src.x)
							dir = EAST
						else if(movement_target.loc.y < src.y)
							dir = SOUTH
						else if(movement_target.loc.y > src.y)
							dir = NORTH
						else
							dir = SOUTH

						if(!Adjacent(movement_target)) //can't reach food through windows.
							return

						if(isturf(movement_target.loc) )
							movement_target.attack_animal(src)
						else if(ishuman(movement_target.loc) )
							if(prob(20))
								custom_emote(1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			custom_emote(1, pick("dances around.","chases its tail!"))
			spin(20, 1)

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/pet/corgi/regenerate_icons()
	overlays.Cut()
	if(inventory_head)
		var/image/head_icon
		if(health <= 0)
			head_icon = image('icons/mob/corgi_head.dmi', icon_state = inventory_head.icon_state, dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = image('icons/mob/corgi_head.dmi', icon_state = inventory_head.icon_state)
		overlays += head_icon
	if(inventory_back)
		var/image/back_icon
		if(health <= 0)
			back_icon = image('icons/mob/corgi_back.dmi', icon_state = inventory_back.icon_state, dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = image('icons/mob/corgi_back.dmi', icon_state = inventory_back.icon_state)
		overlays += back_icon
	if(facehugger)
		if(istype(src, /mob/living/simple_animal/pet/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")
	..(0)

/mob/living/simple_animal/pet/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	shaved = 0
	density = 0
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL

//puppies cannot wear anything.
/mob/living/simple_animal/pet/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>You can't fit this on [src]!</span>")
		return
	..()



//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID

//Lisa already has a cute bow!
/mob/living/simple_animal/pet/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>[src] already has a cute bow!</span>")
		return
	..()

/mob/living/simple_animal/pet/corgi/Lisa/process_ai()
	..()

	make_babies()

	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1, pick("dances around.","chases her tail."))
			spin(20, 1)

/mob/living/simple_animal/pet/corgi/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)	wuv(1,M)
		if(INTENT_HARM)	wuv(-1,M)

/mob/living/simple_animal/pet/corgi/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the corgi) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				custom_emote(1, "yaps happily!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				custom_emote(1, "growls!")

/mob/living/simple_animal/pet/corgi/Ian/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	var/emagged = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = 1
	deathmessage = "blows apart!"

/mob/living/simple_animal/pet/corgi/Ian/borgi/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		spawn (1000)
			src.explode()

/mob/living/simple_animal/pet/corgi/Ian/borgi/proc/explode()
	for(var/mob/M in viewers(src, null))
		if(M.client)
			M.show_message("<span class='warning'>[src] makes an odd whining noise.</span>")
	sleep(10)
	explosion(get_turf(src), 0, 1, 4, 7)
	death()

/mob/living/simple_animal/pet/corgi/Ian/borgi/proc/shootAt(var/atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()
	return

/mob/living/simple_animal/pet/corgi/Ian/borgi/Life(seconds, times_fired)
	..()
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10,src)
		if(target)
			shootAt(target)

	//spark for no reason
	if(prob(5))
		do_sparks(3, 1, src)

/mob/living/simple_animal/pet/corgi/Ian/borgi/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)
