/obj/item/device/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	frequency = 1449
	flags = CONDUCT
	slot_flags = SLOT_BACK
	w_class = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=2500)
	var/code = 2

	is_special = 1

/obj/item/device/radio/electropack/attack_hand(mob/user as mob)
	if(src == user.back)
		to_chat(user, "<span class='notice'>You need help taking this off!</span>")
		return 0
	. = ..()

/obj/item/device/radio/electropack/Destroy()
	if(istype(src.loc, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/S = src.loc
		if(S.part1 == src)
			S.part1 = null
		else if(S.part2 == src)
			S.part2 = null
		master = null
	return ..()

/obj/item/device/radio/electropack/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/clothing/head/helmet))
		if(!b_stat)
			to_chat(user, "<span class='notice'>[src] is not ready to be attached!</span>")
			return
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit( user )
		A.icon = 'icons/obj/assemblies.dmi'

		if(!user.unEquip(W))
			to_chat(user, "<span class='notice'>\the [W] is stuck to your hand, you cannot attach it to \the [src]!</span>")
			return
		W.loc = A
		W.master = A
		A.part1 = W

		user.unEquip(src)
		loc = A
		master = A
		A.part2 = src

		user.put_in_hands(A)
		A.add_fingerprint(user)
		if(src.flags & NODROP)
			A.flags |= NODROP

/obj/item/device/radio/electropack/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["freq"])
		var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
		set_frequency(new_frequency)

	else if(href_list["code"])
		code += text2num(href_list["code"])
		code = round(code)
		code = Clamp(code, 1, 100)

	else if(href_list["power"])
		on = !on

	add_fingerprint(usr)

/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption != code)
		return

	if(ismob(loc) && on)
		var/mob/M = loc
		var/turf/T = M.loc
		if(istype(T, /turf))
			if(!M.moved_recently && M.last_move)
				M.moved_recently = 1
				step(M, M.last_move)
				sleep(50)
				if(M)
					M.moved_recently = 0
		to_chat(M, "<span class='danger'>You feel a sharp shock!</span>")
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, M)
		s.start()

		M.Weaken(5)

	if(master)
		master.receive_signal()
	return


/obj/item/device/radio/electropack/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["power"] = on
	data["freq"] = format_frequency(frequency)
	data["code"] = code

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "radio_electro.tmpl", "[name]", 400, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)