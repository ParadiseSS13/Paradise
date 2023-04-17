/obj/item/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	frequency = AIRLOCK_FREQ
	flags = CONDUCT
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	materials = list(MAT_METAL=10000, MAT_GLASS=2500)
	var/code = 2

/obj/item/radio/electropack/attack_hand(mob/user as mob)
	if(src == user.back)
		to_chat(user, "<span class='notice'>You need help taking this off!</span>")
		return 0
	. = ..()

/obj/item/radio/electropack/Destroy()
	if(istype(src.loc, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/S = src.loc
		if(S.part1 == src)
			S.part1 = null
		else if(S.part2 == src)
			S.part2 = null
		master = null
	return ..()

/obj/item/radio/electropack/attackby(obj/item/W as obj, mob/user as mob, params)
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


/obj/item/radio/electropack/receive_signal(datum/signal/signal)
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
		do_sparks(3, 1, M)

		M.Weaken(5)

	if(master)
		master.receive_signal()
	return


/obj/item/radio/electropack/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Electropack", name, 360, 150, master_ui, state)
		ui.open()

/obj/item/radio/electropack/ui_data(mob/user)
	var/list/data = list()
	data["power"] = on
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	return data

/obj/item/radio/electropack/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("power")
			on = !on
		if("freq")
			var/value = params["freq"]
			if(value)
				frequency = sanitize_frequency(text2num(value) * 10)
				set_frequency(frequency)
			else
				. = FALSE
		if("code")
			var/value = text2num(params["code"])
			if(value)
				value = round(value)
				code = clamp(value, 1, 100)
			else
				. = FALSE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else if(params["reset"] == "code")
				code = initial(code)
			else
				. = FALSE
	if(.)
		add_fingerprint(usr)
