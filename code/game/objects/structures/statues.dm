/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = 1
	anchored = 0
	max_integrity = 100
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/metal

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(!(flags & NODECONSTRUCT))
		if(default_unfasten_wrench(user, W))
			return
		if(istype(W, /obj/item/gun/energy/plasmacutter))
			playsound(src, W.usesound, 100, 1)
			user.visible_message("[user] is slicing apart the [name]...", \
								 "<span class='notice'>You are slicing apart the [name]...</span>")
			if(do_after(user, 40 * W.toolspeed * gettoolspeedmod(user), target = src))
				if(!loc)
					return
				user.visible_message("[user] slices apart the [name].", \
									 "<span class='notice'>You slice apart the [name].</span>")
				deconstruct(TRUE)
			return
	return ..()


/obj/structure/statue/welder_act(mob/user, obj/item/I)
	if(anchored)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)


/obj/structure/statue/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	user.visible_message("[user] rubs some dust off from the [name]'s surface.", \
						 "<span class='notice'>You rub some dust off from the [name]'s surface.</span>")

/obj/structure/statue/CanAtmosPass()
	return !density

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/statue/uranium/Bumped(atom/user)
	radiate()
	..()

/obj/structure/statue/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			last_event = world.time
			active = null

/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/xeno
	name = "statue of a xenomorph"
	icon_state = "xeno"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/statue/plasma/bullet_act(obj/item/projectile/P)
	if(!QDELETED(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
			if(P.firer)
				add_attack_logs(P.firer, src, "Ignited by firing with [P.name]", ATKLOG_FEW)
				investigate_log("was <span class='warning'>ignited</span> by [key_name_log(P.firer)] with [P.name]",INVESTIGATE_ATMOS)
			else
				message_admins("A plasma statue was ignited with [P.name] at [ADMIN_COORDJMP(loc)]. No known firer.")
				add_game_logs("A plasma statue was ignited with [P.name] at [COORD(loc)]. No known firer.")
			PlasmaBurn()
	..()

/obj/structure/statue/plasma/attackby(obj/item/W, mob/user, params)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		add_attack_logs(user, src, "Ignited using [W]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
		ignite(is_hot(W))
		return
	return ..()

/obj/structure/statue/plasma/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	user.visible_message("<span class='danger'>[user] sets [src] on fire!</span>",\
						"<span class='danger'>[src] disintegrates into a cloud of plasma!</span>",\
						"<span class='warning'>You hear a 'whoompf' and a roar.</span>")
	add_attack_logs(user, src, "ignited using [I]", ATKLOG_FEW)
	investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
	ignite(2500)

/obj/structure/statue/plasma/proc/PlasmaBurn()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 160)
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."

/obj/structure/statue/silver/md
	name = "statue of a medical doctor"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue."

/obj/structure/statue/diamond/captain
	name = "statue of THE captain"
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram"
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core"
	icon_state = "ai2"

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	var/spam_flag = 0

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/user)
	honk()
	..()

/obj/structure/statue/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"

/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "Похоже, что это древняя мраморная статуя. Девушка имеет длинные косы, которые спускаются по всему телу до пола. В руках она держит ящик инструментов. Пожалуй, это лучшее изображение женщины, которое вы когда-либо видели. Художник должен действительно быть мастером своего дела. Жаль что рука сломана."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/obj/structure/statue/tranquillite
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/tranquillite
	desc = "..."

/obj/structure/statue/tranquillite/mime
	name = "statue of a mime"
	icon_state = "mime"

/obj/structure/statue/tranquillite/mime/AltClick(mob/user)//has 4 dirs
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return
	setDir(turn(dir, 90))

/obj/structure/statue/kidanstatue
	name = "Obsidian Kidan warrior statue"
	desc = "A beautifully carved and menacing statue of a Kidan warrior made out of obsidian. It looks very heavy."
	icon_state = "kidan"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/chickenstatue
	name = "Bronze Chickenman Statue"
	desc = "An antique and oriental-looking statue of a Chickenman made of bronze."
	icon_state = "chicken"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/russian_mulebot
	desc = "Like a MULEbot, but more Russian and less functional.";
	icon = 'icons/obj/aibots.dmi';
	icon_state = "mulebot0";
	name = "OXENbot"
	anchored = TRUE
	oreAmount = 10

/obj/structure/statue/elwycco
	name = "Unknown Hero"
	desc = "Похоже это какой-то очень важный человек, или очень значимый для многих людей. Вы замечаете огроменный топор в его руках, с выгравированным числом 220. Что это число значит? Каждый понимает по своему, однако по слухам оно означает количество его жертв. \n Надпись на табличке - Мы с тобой, Шустрила! Аве, Легион!"
	icon_state = "elwycco"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/thaumicnik
	name = "Unknown Hero"
	desc = "Перед собою вы наблюдаете интересного молодого человека, который держит в руках чертежи станции очень похожие на станцию Керберос. Возможно он как то принимал участие в разработке или в конструировании этой станции. В другой же руке вы замечаете планшет с листком, на котором расписаны какие-то даты и заметки к ним. Все что удается вам разглядеть, так это заголовок *event-times* на листочке. \n Надпись на табличке - Один из главных инженеров, принимающих участие в разработке передовой научно-исследовательской станции Kerberos."
	icon_state = "thaumicnik"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/hooker
	name = "Unknown Hero"
	desc = "Возможно вы и не встречали подобного героя, ведь он всегда ходит в маске, и в белом техническом халате. Скорее всего, он все еще скрывается среди экипажа, но уже другой личностью. \n Надпись на табличке - Герой, который пожертвовав собою, уничтожил угрозу станции. Награжден посмертно."
	icon_state = "hooker"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/artchair
	name = "Unknown Hero"
	desc = "Еще один герой корп. NanoTrasen. Вы замечаете интересную деталь, что спинка стула похожа на тюремное окошко. Так же на нем почему-то присутствует кровь, которая уже налегает слоями и хранится около года. По всей видимости этот стул символизирует какую то личность, которая внесла большой вклад в развитие и поддержание нашей галактической системы. \n Надпись на табличке - Спасибо тебе за все, мы всегда были и будем рады тебе."
	icon_state = "artchair"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/furukai
	name = "София Вайт"
	desc = "Загадочная девушка, ныне одна из множества офицеров синдиката. Получившая столь высокую позицию не за связи, а за свои способности. \
			Движимая местью за потерю родной сестры из-за коррупционных верхушек Нанотрейзен, она вступила в Синдикат,  \
			где стала известна и как способный агент и как отличный инженер. Хоть ее позывной и отсылал на пушистых, в душе она их ненавидела..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "furukai"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/ell_good
	name = "Mr.Буум"
	desc = "Загадочный клоун с жёлтым оттенком кожи и выразительными зелёными глазами. Лучший двойной агент синдиката умудрявшийся захватить власть множества объектов. \
			Его имя часто произносят неправильно из-за чего его заслуги по документам принадлежат сразу нескольким Буумам. \
			Так же знаменит тем, что убедил руководство НТ тратить время, силы и средства, на золотой унитаз."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/mooniverse
	name = "Неизвестный агент"
	desc = "Информация на табличке под статуей исцарапана и нечитабельна..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

////////////////////////////////

/obj/structure/snowman
	name = "snowman"
	desc = "Seems someone made a snowman here."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "snowman"
	anchored = TRUE
	density = TRUE
	max_integrity = 50

/obj/structure/snowman/built
	desc = "Just like the ones you remember from childhood!"

/obj/structure/snowman/built/Destroy()
	new /obj/item/reagent_containers/food/snacks/grown/carrot(drop_location())
	new /obj/item/grown/log(drop_location())
	new /obj/item/grown/log(drop_location())
	return ..()

/obj/structure/snowman/built/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/snowball) && obj_integrity < max_integrity)
		to_chat(user, "<span class='notice'>You patch some of the damage on [src] with [I].</span>")
		obj_integrity = max_integrity
		qdel(I)
	else
		return ..()

/obj/structure/snowman/built/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	qdel(src)

