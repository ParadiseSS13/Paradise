/obj/machinery/washing_machine
	name = "\improper washing machine"
	desc = "An advanced washer and dryer all rolled up into one.\nGets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	active_power_usage = 1000

	var/state = 1
		//1 = empty, open door
		//2 = empty, closed door
		//3 = full, open door
		//4 = full, closed door
		//5 = running
		//6 = blood, open door
		//7 = blood, closed door
		//8 = blood, running
	/// if the door is open
	var/open = TRUE
	/// full means it contains any items at all, not meaning its reached its capacity
	var/full = FALSE
	/// if the washing machine is currently cleaning
	var/running = FALSE
	/// if the washing machine is filled with blood
	var/bloody = FALSE
	/// If the hacking panel is accessible (screwdriver'd)
	var/panel = FALSE

	var/mob_blood_dna // wip
	// The object affecting dyeing color (crayons, stamps, armbands)
	var/obj/crayon

	// How much damage a single cycle should do, 20 is just enough damage to kill Ian
	var/washing_damage = 20
	// How long a single cycle should take
	var/washing_time = 15 SECONDS
	// How often to damage the occupant
	var/damage_time = 1 SECONDS
	// Sounds made when occupant is damaged
	var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
	// How long it'll take to resist out
	var/resist_time = 5 SECONDS

/obj/machinery/washing_machine/Initialize()
	. = ..()
	update_icon()

/obj/machinery/sleeper/power_change()
	..()
	update_icon()

/obj/machinery/washing_machine/AltClick(mob/living/user)
	Wash(user)

/obj/machinery/washing_machine/proc/Wash(mob/living/user)
	if(!istype(user))
		return
	if(stat & NOPOWER)
		to_chat(usr, "<span class='notice'>[src] isn't powered.</span>")
		return
	if(running)
		to_chat(usr, "<span class='notice'>[src] is already running.</span>")
		return
	if(open && bloody)
		if(!full)
			to_chat(user, "<span class='notice'>You start [src] to clean it out.</span>")
		else
			to_chat(user, "<span class='notice'>You start [src], covering the contents inside with blood.</span>") // THIS DOESNT WORK YET
	else
		if(!full)
			to_chat(user, "<span class='notice'>[src] is empty, there is nothing to clean.</span>")
			return

	playsound(src, 'sound/machines/click.ogg', 25)
	running = TRUE
	open = FALSE

	var/mob/living/M = locate(/mob/living, contents)
	if(M)
		if(user == M)
			to_chat(M, "<span class='warning'>You activate [src] and quickly close the door on yourself!</span>")
		bloody = TRUE
		update_icon()
		add_attack_logs(user, M, "activated a washing machine with them inside")
		to_chat(M, "<span class='userdanger'>Your body into the walls repeatedly as [src] spins!</span>")
		for(var/I in 1 to (washing_time / damage_time))
			if(prob(33))
				M.emote("scream")
			M.adjustBruteLoss(washing_damage / (washing_time / damage_time))
			playsound(src, pick(hit_sound), 10)
			sleep(damage_time)
			I++
		M.AdjustConfused(3 SECONDS)
	else
		update_icon()
		for(var/I in 1 to (washing_time / damage_time))
			playsound(src, 'sound/weapons/jug_filled_impact.ogg', 10)
			sleep(damage_time)

	if(!bloody) // if its filled with blood, its not gonna clean blood
		for(var/atom/A in contents)
			A.clean_blood()

	//Tanning! // why?
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		qdel(HH)
	dyeing()

/obj/machinery/washing_machine/proc/dyeing()
	if(crayon)
		var/wash_color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			wash_color = CR.colourName
		else if(istype(crayon,/obj/item/stamp))
			var/obj/item/stamp/ST = crayon
			wash_color = ST.item_color
		else if(istype(crayon,/obj/item/clothing/accessory/armband))
			var/obj/item/clothing/accessory/armband/AR = crayon
			wash_color = AR.item_color

		if(wash_color)
			for(var/obj/item/Item in contents)
				var/shouldbreak
				if(istype(Item, /obj/item/clothing)) //if not dyeable, skip this item
					for(var/T in typesof(/obj/item/clothing))
						var/obj/item/clothing/X = new T
						if(Item == X)
							if(!X.dyeable)
								shouldbreak = TRUE
							break
				if(shouldbreak)
					continue
				if(istype(Item, /obj/item/clothing))
					dyethis(Item, wash_color, TRUE)
				else
					dyethis(Item, wash_color, FALSE)
		QDEL_NULL(crayon)

	running = FALSE
	if(!full)
		bloody = FALSE
	else
		playsound(src, 'sound/weapons/jug_filled_impact.ogg', 10)
	update_icon()
	sleep(5) // todo: replace this with a callback
	if(stat & NOPOWER)
		playsound(src, 'sound/machines/terminal_off.ogg', 45)
	else
		playsound(src, 'sound/machines/defib_success.ogg', 25)

/obj/machinery/washing_machine/proc/dyethis(var/obj/item/Item, wash_color, clothing = TRUE) // god this is nasty
	// Things that are acceptable to dye
	var/list/dyeablethings = list(/obj/item/clothing/under/plasmaman, /obj/item/clothing/head/helmet/space/plasmaman, /obj/item/clothing/under, /obj/item/clothing/gloves/color, /obj/item/clothing/shoes, /obj/item/clothing/mask/bandana, /obj/item/clothing/head/soft, /obj/item/clothing/head/beanie, /obj/item/clothing/accessory/scarf, /obj/item/bedsheet, /obj/item/storage/wallet/color, /obj/item/toy/carpplushie)
	var/list/possible = list()
	for(var/obj/item/Path in dyeablethings) // for every item in contents, check every it against every dyeablething, then check that for every subtype (god what the fuck)
		if(istype(Item, Path))
			for(var/T in typesof(Path))
				var/obj/item/J = new T // for the love of god change the variable name
				if(clothing)
					var/obj/item/clothing/J2 = T // this one too
					if(!initial(J2.dyeable))
						continue
				if((wash_color == J.item_color))
					possible += J
				qdel(J)
			if(possible)
				var/obj/item/Why = pick(possible)
				to_chat(world, "[possible.Join(", ")]")
				to_chat(world, "[Why]")
				Item.item_state = Why.item_state
				Item.icon_state = Why.icon_state
				Item.item_color = Why.item_color
				Item.name = Why.name
				Item.desc = Why.desc
				Item.desc += "\nThe colors seem slightly dodgy."
				break
			else
				to_chat(world, "this is a bug")

/obj/machinery/washing_machine/update_icon()
	if(bloody)
		if(running)
			state = 8
		else
			if(open)
				state = 6
			else
				state = 7
	else
		if(running)
			state = 5
		else
			if(full)
				if(open)
					state = 3
				else
					state = 4
			else
				if(open)
					state = 1
				else
					state = 2

	icon_state = "wm_[state]"
	cut_overlays()
	if(panel)
		add_overlay("wires")
	else
		if(stat & NOPOWER)
			if(running)
				add_overlay("power0")
		else
			add_overlay("power1")

/obj/machinery/washing_machine/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/spray/cleaner) || istype(W, /obj/item/soap))
		user.visible_message("<span class='notice'>[user] starts to clean [src].</span>", "<span class='notice'>You start to clean [src].</span>")
		if(do_after(user, W.toolspeed SECONDS, target = src))
			user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
			bloody = FALSE
			update_icon()
			return
	if(bloody && open)
		to_chat(user, "<span class='warning'>[src] is filled with blood! It won't clean anything until the blood is cleaned out.</span>")
	if(default_unfasten_wrench(user, W))
		power_change()
		return
	if(istype(W,/obj/item/toy/crayon) || istype(W,/obj/item/stamp) || istype(W,/obj/item/clothing/accessory/armband))
		if(open && !bloody)
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.forceMove(src)
				update_icon()
			else
				return ..()
		else
			return ..()
	else if(istype(W,/obj/item/grab))
		if(open && !full)
			var/obj/item/grab/G = W
			if((ishuman(G.assailant) && isanimal(G.affecting) && !ishostile(G.affecting) && !isbot(G.affecting)) || (ishuman(G.assailant) && ishuman(G.affecting) && HAS_TRAIT(G.affecting, TRAIT_DWARF)))
				if(ishuman(G.assailant) && ishuman(G.affecting) && HAS_TRAIT(G.affecting, TRAIT_DWARF) && (G.state < GRAB_AGGRESSIVE))
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				else
					visible_message("<span class='notice'>[user] starts putting [G.affecting.name] into [src].</span>")
					if(do_after(user, 20, target = G.affecting))
						visible_message("<span class='warning'>[user] puts [G.affecting.name] into [src].</span>")
						add_fingerprint(user)
						G.affecting.forceMove(src)
						qdel(G)
						full = TRUE
			update_icon()
		else
			if(!open)
				to_chat(user, "<span class='notice'>[src]'s door is closed.</span>")
			else
				if(full)
					to_chat(user, "<span class='notice'>[src] is already full.</span>")
				else
					to_chat(user, "<span class='notice'>You can't fit [W] in [src].</span>")
			return ..()
	else
		var/list/allowed = list(/obj/item/stack/sheet/hairlesshide, W,/obj/item/clothing/under, /obj/item/clothing/mask, /obj/item/clothing/head, /obj/item/clothing/gloves, /obj/item/clothing/shoes, /obj/item/clothing/suit, /obj/item/bedsheet, /obj/item/storage/wallet)
		var/list/prohibited = list(/obj/item/clothing/suit/space, /obj/item/clothing/suit/syndicatefake, /obj/item/clothing/suit/bomb_suit, /obj/item/clothing/suit/armor, /obj/item/clothing/mask/gas, /obj/item/clothing/head/syndicatefake, /obj/item/clothing/head/helmet, /obj/item/clothing/suit/cyborg_suit, /obj/item/clothing/mask/cigarette)
		var/goahead // there has to be a better way to do this
		for(var/I in 1 to length(prohibited))
			if(istype(W, allowed[I]))
				goahead = TRUE
		if(!goahead)
			return ..()
		if(!istype(W, (/obj/item/clothing/head/helmet/space/plasmaman)))
			for(var/I in 1 to length(prohibited))
				if(istype(W, prohibited[I]))
					to_chat(user, "[W] is not washing machine safe.")
					return
		if(istype(W, /obj/item/clothing/gloves/color/black/krav_maga/sec))
			to_chat(user, "<span class='warning'>Washing these gloves would fry the electronics!</span>")
			return
		if(W.flags && NODROP) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in [src]!</span>")
			return

		if(length(contents) < 10)
			var/mob/living/M
			if(!M) // no placing items in the machine if theres a mob inside
				if(open && !bloody)
					user.drop_item()
					W.forceMove(src)
					full = TRUE
				else
					to_chat(user, "<span class='notice'>You can't put [W] in right now.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is is occupied by [M], there's no extra space.</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		update_icon()


/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	if(running) // States 5 and 8
		to_chat(usr, "<span class='warning'>[src] is busy.</span>")
		return
	if(bloody)
		if(open) // 6
			to_chat(usr, "<span class='notice'>[src] only contains blood, there is nothing to remove from it.</span>")
		else // 7
			if(locate(/mob, contents))
				var/mob/Mob = locate(/mob, contents)
				if(!ishuman(Mob) && Mob.stat == DEAD)
					Mob.gib()
					to_chat(usr, "<span class='narsie'>You monster.</span>")
			for(var/atom/movable/Obj in contents) // it empties here because gibs would explode when opening the door
				Obj.forceMove(loc)
			crayon = null
			full = FALSE
			open = TRUE
			playsound(src, 'sound/machines/click.ogg', 25)
	else
		if(full)
			if(open) // 3
				to_chat(usr, "<span class='notice'>You empty [src].</span>")
				for(var/atom/movable/Obj in contents)
					Obj.forceMove(loc)
				crayon = null
				full = FALSE
			else // 4
				to_chat(usr, "<span class='notice'>You open the door on [src].</span>")
				open = TRUE
				playsound(src, 'sound/machines/click.ogg', 25)
		else
			if(open) // 1
				to_chat(usr, "<span class='notice'>[src] is empty, there is nothing to remove from it.</span>")
				for(var/atom/movable/Obj in contents) // We'll try anyways, just in case
					Obj.forceMove(loc)
				crayon = null
			else // 2
				to_chat(usr, "<span class='notice'>You open the door on [src].</span>")
				open = TRUE
				playsound(src, 'sound/machines/click.ogg', 25)

	update_icon()

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	var/contentsjoined = contents.Join(", ")
	if(running)
		if(bloody)
			if(length(contents) == 0)
				. += "<span class='warning'>[src] filled with blood!</span>"
			else
				. += "<span class='warning'>[src] has [length(contents)] object\s inside and tons of blood!</span>"
		else
			. += "<span class='notice'>[src] has [length(contents)] object\s inside.</span>"
		if(stat & NOPOWER)
			. += "<span class='warning'>[src] is running on emergency power.</span>"
	else
		if(length(contents))
			. += "<span class='notice'>[src] contains [contentsjoined].</span>"
		else
			. += "<span class='notice'>[src] is empty.</span>"
		if(bloody)
			. += "<span class='warning'>[src] filled with blood!</span>"
		if(stat & NOPOWER)
			. += "<span class='warning'>[src] has no power.</span>"
		. += "<span class='notice'>You can Alt-Click to start [src].</span>"

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 5)
	dropContents()
	qdel(src)

/obj/machinery/washing_machine/MouseDrop_T(atom/movable/O, mob/user)
	var/mob/living/L = O
	if(running)
		to_chat(usr, "<span class='warning'>[src] is busy.</span>")
		return
	if(ishuman(user) && ishuman(L) && HAS_TRAIT(L, TRAIT_DWARF) && (user != L))
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return
	if(full)
		if((ishuman(user) && isanimal(L) && !ishostile(L) && !isbot(L)) || (ishuman(user) && HAS_TRAIT(L, TRAIT_DWARF)))
			to_chat(user, "<span class='warning'>[src] needs to be empty to fit [L] inside.</span>")
			return
	if(open && !bloody && !full)
		if((ishuman(user) && isanimal(L) && !ishostile(L) && !isbot(L)) || (ishuman(user) && HAS_TRAIT(L, TRAIT_DWARF)))
			if(L == user)
				visible_message("[user] starts climbing into [src].")
			else
				visible_message("[user] starts putting [L] into [src].")
			if(do_after(user, 20, target = src))
				if(!L)
					return
				L.forceMove(src)
				add_fingerprint(user)
				if(user.pulling == L)
					user.stop_pulling()
				full = TRUE
				update_icon()

/obj/machinery/washing_machine/container_resist(mob/living/L) // This is buggy, still needs further testing
	if(open)
		if(L.loc == src)
			L.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!open)
		L.visible_message("<span class='notice'>You start kicking on the [src]'s door, trying to get it to open.</span>", "<span class='notice'>[L] starts kicking on the [src]'s door.</span>")
		if(do_after(L, resist_time, target = src))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || open) //src/user destroyed OR user dead/unconcious OR user no longer in src OR src opened
				to_chat(world, "its already open")
				return

			L.visible_message("<span class='danger'>[L] breaks out of [src]!</span>", 1)

			for(var/atom/movable/Obj in contents)
				Obj.forceMove(loc)
			open = TRUE
			crayon = null
			full = FALSE
			update_icon()
