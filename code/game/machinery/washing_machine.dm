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
	var/open = TRUE
	var/full = FALSE // full means it contains any items at all, not meaning its reached its capacity
	var/running = FALSE
	var/bloody = FALSE
	var/panel = FALSE

	var/mobblooddna
	var/obj/crayon

	var/washing_damage = 20 // how much damage a single cycle should do // 20 is just enough damage to kill Ian
	var/washing_time = 15 SECONDS // how long a single cycle should take
	var/damage_time = 1 SECONDS // how often to damage the occupant
	var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg') // sounds made when occupant is damaged
	var/resist_time = 5 SECONDS

/obj/machinery/washing_machine/Initialize()
	. = ..()
	update_icon()

/obj/machinery/sleeper/power_change()
	..()
	update_icon()

/obj/machinery/washing_machine/AltClick(mob/living/user)
	if(!istype(usr, /mob/living))
		return
	if(stat & NOPOWER)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 15)
		to_chat(usr, "<span class='notice'>\The [src] isn't powered.</span>")
		return
	if(running)
		to_chat(usr, "<span class='notice'>\The [src] is already running.</span>")
		return
	if(open && bloody)
		if(!full)
			to_chat(usr, "<span class='notice'>You start \the [src] to clean it out.</span>")
		else
			to_chat(usr, "<span class='notice'>You start \the [src], covering the contents inside with blood.</span>")
	else
		if(!full)
			to_chat(usr, "<span class='notice'>\The [src] is empty, there is nothing to clean.</span>")
			return

	playsound(src, 'sound/machines/click.ogg', 25)
	running = TRUE
	open = FALSE
	if(locate(/mob,contents))
		var/mob/living/M = locate(/mob,contents)
		if(user == M)
			to_chat(M, "<span class='warning'>You activate \the [src] and quickly close the door on yourself!</span>")
		bloody = TRUE
		update_icon()
		add_attack_logs(user, M, "activated a washing machine with them inside")
		to_chat(M, "<span class='userdanger'>\The [src] slams your body into the walls repeatedly as the washing machine spins!</span>")
		for(var/I in 1 to (washing_time/damage_time))
			if(prob(33))
				M.emote("scream")
			M.adjustBruteLoss(washing_damage/(washing_time/damage_time))
			playsound(src, pick(hit_sound), 10)
			sleep(damage_time)
			I++
		M.AdjustConfused(3 SECONDS)
	else
		update_icon()
		for(var/I in 1 to (washing_time/damage_time))
			playsound(src, 'sound/weapons/jug_filled_impact.ogg', 10)
			sleep(damage_time)
			I++

	if(!bloody) // if its filled with blood, its not gonna clean blood
		for(var/atom/A in contents)
			A.clean_blood()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		qdel(HH)

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
			var/list/newcontents = list()
			var/shouldbreak
			for(var/obj/item/O in contents) //dyeable tags
				if(istype(O, /obj/item/clothing))
					for(var/T in typesof(/obj/item/clothing))
						var/obj/item/clothing/X = new T
						if(O == X)
							if(!X.dyeable)
								shouldbreak = TRUE
							break
				if(shouldbreak)
					continue
				if(istype(O, /obj/item/clothing/under/plasmaman)) // plasmaman suits need to be before jumpsuits so they are not processed as a jumpsuit
					for(var/T in typesof(/obj/item/clothing/under/plasmaman))
						var/obj/item/clothing/under/plasmaman/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/head/helmet/space/plasmaman)) // plasmaman suits need to be before jumpsuits so they are not processed as a jumpsuit
					for(var/T in typesof(/obj/item/clothing/head/helmet/space/plasmaman))
						var/obj/item/clothing/head/helmet/space/plasmaman/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/under)) // jumpsuits
					for(var/T in typesof(/obj/item/clothing/under))
						var/obj/item/clothing/under/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/gloves/color)) //gloves
					for(var/T in typesof(/obj/item/clothing/gloves/color))
						var/obj/item/clothing/gloves/color/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/shoes)) //shoes
					for(var/T in typesof(/obj/item/clothing/shoes))
						var/obj/item/clothing/shoes/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/mask/bandana)) //bandanas
					for(var/T in typesof(/obj/item/clothing/mask/bandana))
						var/obj/item/clothing/mask/bandana/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/head/soft)) // soft-caps
					for(var/T in typesof(/obj/item/clothing/head/soft))
						var/obj/item/clothing/head/soft/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/head/beanie)) // non-striped beanies
					for(var/T in typesof(/obj/item/clothing/head/beanie))
						var/obj/item/clothing/head/beanie/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/clothing/accessory/scarf)) // scarves
					for(var/T in typesof(/obj/item/clothing/accessory/scarf))
						var/obj/item/clothing/accessory/scarf/J = new T
						if((wash_color == J.item_color) && J.dyeable)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/bedsheet)) // bedsheets
					for(var/T in typesof(/obj/item/bedsheet))
						var/obj/item/bedsheet/J = new T
						if(wash_color == J.item_color)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/storage/wallet/color)) // only for wallets from the arcade
					for(var/T in typesof(/obj/item/storage/wallet/color))
						var/obj/item/storage/wallet/color/J = new T
						if(wash_color == J.item_color)
							qdel(O)
							newcontents += J
							break
				if(istype(O, /obj/item/toy/carpplushie)) // carp plushies! was gonna add for fox plushies but their pathing makes it not an option currently
					for(var/T in typesof(/obj/item/toy/carpplushie))
						var/obj/item/toy/carpplushie/J = new T
						if(wash_color == J.item_color)
							qdel(O)
							newcontents += J
							break
			for(var/I in 1 to (length(newcontents)))
				contents += newcontents[I]
		QDEL_NULL(crayon)

	running = FALSE
	if(!full)
		bloody = FALSE
	else
		playsound(src, 'sound/weapons/jug_filled_impact.ogg', 25)
	update_icon()
	sleep(5)
	if(stat & NOPOWER)
		playsound(src, 'sound/machines/terminal_off.ogg', 45)
	else
		playsound(src, 'sound/machines/defib_success.ogg', 25)

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
		if(do_after(user, 10 * W.toolspeed, target = src))
			user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
	if(bloody && open)
		to_chat(user, "<span class='warning'>\The [src] is filled with blood! It won't clean anything until the blood is cleaned out.</span>")
	if(default_unfasten_wrench(user, W))
		power_change()
		return
	if(istype(W,/obj/item/toy/crayon) || istype(W,/obj/item/stamp) || istype(W,/obj/item/clothing/accessory/armband))
		if(open && !bloody)
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
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
					visible_message("[user] starts putting [G.affecting.name] into \the [src].")
					if(do_after(user, 20, target = G.affecting))
						visible_message("[user] puts [G.affecting.name] into \the [src].")
						add_fingerprint(user)
						G.affecting.loc = src
						qdel(G)
						full = TRUE
			update_icon()
		else
			if(!open)
				to_chat(user, "<span class='notice'>\The [src]'s door is closed.</span>")
			else
				if(full)
					to_chat(user, "<span class='notice'>\The [src] is already full.</span>")
				else
					to_chat(user, "<span class='notice'>You can't fit [W] in \the [src].</span>")
			return ..()
	else if(istype(W,/obj/item/stack/sheet/hairlesshide) || \
		istype(W,/obj/item/clothing/under) || \
		istype(W,/obj/item/clothing/mask) || \
		istype(W,/obj/item/clothing/head) || \
		istype(W,/obj/item/clothing/gloves) || \
		istype(W,/obj/item/clothing/shoes) || \
		istype(W,/obj/item/clothing/suit) || \
		istype(W,/obj/item/bedsheet) || \
		istype(W,/obj/item/storage/wallet)) // yes forget your wallet in the washing machine

		var/list/prohibited = list(/obj/item/clothing/suit/space, /obj/item/clothing/suit/syndicatefake, /obj/item/clothing/suit/bomb_suit, /obj/item/clothing/suit/armor, /obj/item/clothing/mask/gas, /obj/item/clothing/head/syndicatefake, /obj/item/clothing/head/helmet, /obj/item/clothing/suit/cyborg_suit, /obj/item/clothing/mask/cigarette)
		if(!istype(W, (/obj/item/clothing/head/helmet/space/plasmaman)))
			for(var/I in 1 to length(prohibited))
				if(istype(W, prohibited[I]))
					to_chat(user, "This item does not fit.")
					return
		if(istype(W, /obj/item/clothing/gloves/color/black/krav_maga/sec))
			to_chat(user, "<span class='warning'>Washing these gloves would fry the electronics!</span>")
			return
		if(W.flags & NODROP) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 10)
			if(!locate(/mob,contents)) // no placing items in the machine if theres a mob inside
				if(open && !bloody)
					user.drop_item()
					W.loc = src
					full = TRUE
				else
					to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
			else
				to_chat(user, "<span class='notice'>The washing machine is is occupied by [locate(/mob,contents)], there's no extra space.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
		update_icon()
	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	if(running) // States 5 and 8
		to_chat(usr, "<span class='warning'>\The [src] is busy.</span>")
	else
		if(bloody)
			if(open) // 6
				to_chat(usr, "<span class='notice'>\The [src] only contains blood, there is nothing to remove from it.</span>")
			else // 7
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					if(!ishuman(M) && M.stat == DEAD)
						M.gib()
						to_chat(usr, "<span class='narsie'>You monster.</span>")
				for(var/atom/movable/O in contents) // it empties here because gibs would explode when opening the door
					O.loc = src.loc
				crayon = null
				full = FALSE
				open = TRUE
				playsound(src, 'sound/machines/click.ogg', 25)
		else
			if(full)
				if(open) // 3
					to_chat(usr, "<span class='notice'>You empty \the [src].</span>")
					for(var/atom/movable/O in contents)
						O.loc = src.loc
					crayon = null
					full = FALSE
				else // 4
					to_chat(usr, "<span class='notice'>You open the door on \the [src].</span>")
					open = TRUE
					playsound(src, 'sound/machines/click.ogg', 25)
			else
				if(open) // 1
					to_chat(usr, "<span class='notice'>\The [src] is empty, there is nothing to remove from it.</span>")
					for(var/atom/movable/O in contents) // We'll try anyways, just in case
						O.loc = src.loc
					crayon = null
				else // 2
					to_chat(usr, "<span class='notice'>You open the door on \the [src].</span>")
					open = TRUE
					playsound(src, 'sound/machines/click.ogg', 25)

	update_icon()

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	var/contentsjoined = contents.Join(", ")
	if(running)
		if(bloody)
			if(length(contents) == 0)
				. += "<span class='warning'>\The [src] filled with blood!</span>"
			else if(length(contents) > 1)
				. += "<span class='warning'>\The [src] has [length(contents)] objects inside and tons of blood!</span>"
			else
				. += "<span class='warning'>\The [src] has 1 object inside and tons of blood!</span>"
		else
			if(length(contents) != 1)
				. += "<span class='notice'>\The [src] has [length(contents)] objects inside.</span>"
			else
				. += "<span class='notice'>\The [src] has 1 object inside.</span>"
		if(stat & NOPOWER)
			. += "<span class='warning'>\The [src] is running on emergency power.</span>"
	else
		if(length(contents))
			. += "<span class='notice'>\The [src] contains [contentsjoined].</span>"
		else
			. += "<span class='notice'>\The [src] is empty.</span>"
		if(bloody)
			. += "<span class='warning'>\The [src] filled with blood!</span>"
		if(stat & NOPOWER)
			. += "<span class='warning'>\The [src] has no power.</span>"
		. += "<span class='notice'>You can Alt-Click to start \the [src].</span>"

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 5)
	dropContents()
	qdel(src)

/obj/machinery/washing_machine/MouseDrop_T(atom/movable/O, mob/user)
	var/mob/living/L = O
	if(running)
		to_chat(usr, "<span class='warning'>\The [src] is busy.</span>")
		return
	if(ishuman(user) && ishuman(L) && HAS_TRAIT(L, TRAIT_DWARF) && (user != L))
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return
	if(full)
		to_chat(user, "<span class='warning'>\The [src] needs to be empty to fit [L] inside.</span>")
		return
	if(open && !bloody && !full)
		if((ishuman(user) && isanimal(L) && !ishostile(L) && !isbot(L)) || (ishuman(user) && HAS_TRAIT(L, TRAIT_DWARF)))
			if(L == user)
				visible_message("[user] starts climbing into \the [src].")
			else
				visible_message("[user] starts putting [L] into \the [src].")
			if(do_after(user, 20, target = src))
				if(!L)
					return
				L.forceMove(src)
				add_fingerprint(user)
				if(user.pulling == L)
					user.stop_pulling()
				full = TRUE
				update_icon()

/obj/machinery/washing_machine/container_resist(mob/living/L)
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

			L.visible_message("<span class='danger'>\the [usr] breaks out of \the [src]!</span>", 1)

			for(var/atom/movable/O in contents)
				O.loc = src.loc
			open = TRUE
			crayon = null
			full = FALSE
			update_icon()
