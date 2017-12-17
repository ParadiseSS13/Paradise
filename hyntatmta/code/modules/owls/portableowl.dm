/obj/machinery/portableowl //Код переносных флешеров довольно интересный
	name = "Owl"
	desc = "Ehh, This is not a real owl..."
	icon = 'hyntatmta/icons/obj/owls.dmi'
	icon_state = "owl"
	var/base_state = "owl"
	anchored = 0
	density = 1
	var/last_flash = 0
	var/flash_prob = 80

	proc/flash()
		if (src.last_flash && world.time < src.last_flash + 10)
			return

		playsound(src.loc, "sound/misc/hoot.ogg", 100, 1)
		flick("[base_state]_flash", src)
		src.last_flash = world.time

	HasProximity(atom/movable/AM as mob|obj)
		if (src.last_flash && world.time < src.last_flash + 10)
			return

		if (iscarbon(AM))
			var/mob/living/carbon/M = AM
			if ((M.m_intent != "walk") && (src.anchored))
				if (M.client) //Чтобы не орали на мобов без клиентов, очевидно.
					if (prob(flash_prob))
						src.flash()

//Сову можно спиздить и переставить!! The future is now, old man.

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/wrench))
			add_fingerprint(user)
			src.anchored = !src.anchored

			if (!src.anchored)
				user.show_message(text("<span style=\"color:red\">[src] can now be moved.</span>"))

			else if (src.anchored)
				user.show_message(text("<span style=\"color:red\">[src] is now secured.</span>"))

	attack_hand(user)
		if (src.anchored)
			if (src.last_flash && world.time < src.last_flash + 10)
				return

			src.flash()

/obj/machinery/portableowl/attached
	anchored = 1

/obj/machinery/portableowl/judgementowl
	name = "Hooty McJudgementowl"
	desc = "A grumpy looking owl."
	icon_state = "judgementowl1"
	base_state = "judgementowl1"
	anchored = 1

	New()
		..()
		base_state = "judgementowl[rand(1,32)]" //MULTI ICON DRIFTING!
		icon_state = base_state

	process()
		..()
		if (prob(10))
			var/list/mobsnearby = list()
			for (var/mob/M in view(7,src))
				if (isobserver(M)) //Мы не хотим чтобы сова орала на гостов.
					continue
				mobsnearby.Add("[M.name]")
			var/mob/M1 = null
			if (mobsnearby.len > 0)
				M1 = pick(mobsnearby)
			if (M1 && prob(50))
				src.visible_message("<span style=\"color:red\"><b>[src]</b> frowns at [M1].</span>") //КАР КАР КАР КАР КАР КАР КАР КАР КАР КАР КАР