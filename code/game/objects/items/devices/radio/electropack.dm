/obj/item/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon = 'icons/obj/radio.dmi'
	icon_state = "electropack"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2500)
	/// The integrated signaler
	var/obj/item/assembly/signaler/electropack/integrated_signaler

/obj/item/electropack/Initialize(mapload)
	. = ..()
	integrated_signaler = new /obj/item/assembly/signaler/electropack(src, src) // Loc and the integrated one

/obj/item/electropack/Destroy()
	integrated_signaler.owning_pack = null
	QDEL_NULL(integrated_signaler)

	if(istype(loc, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/S = loc
		if(S.part1 == src)
			S.part1 = null

		else if(S.part2 == src)
			S.part2 = null

		master = null

	return ..()

/obj/item/electropack/attack_hand(mob/user)
	if(src == user.back)
		to_chat(user, "<span class='notice'>You need help taking this off!</span>")
		return FALSE

	..()

/obj/item/electropack/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/electropack/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	..()

	if(istype(W, /obj/item/clothing/head/helmet))
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit(user)
		A.icon = 'icons/obj/assemblies.dmi'

		if(!user.unequip(W))
			to_chat(user, "<span class='notice'>\the [W] is stuck to your hand, you cannot attach it to \the [src]!</span>")
			return

		W.forceMove(A)
		W.master = A
		A.part1 = W

		user.transfer_item_to(src, A)
		master = A
		A.part2 = src

		user.put_in_hands(A)
		A.add_fingerprint(user)
		if(src.flags & NODROP)
			A.set_nodrop(TRUE)


/obj/item/electropack/proc/handle_shock()
	if(istype(master, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = master
		SK.shock_invoke()

	if(isliving(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='danger'>You feel a sharp shock!</span>")
		do_sparks(3, 1, M)

		M.Weaken(10 SECONDS)

// This should honestly just proxy the UI to the internal signaler
/obj/item/electropack/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/electropack/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electropack", name)
		ui.open()

/obj/item/electropack/ui_data(mob/user)
	var/list/data = list()
	data["power"] = integrated_signaler.receiving
	data["frequency"] = integrated_signaler.frequency
	data["code"] = integrated_signaler.code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	return data

/obj/item/electropack/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("power")
			integrated_signaler.receiving = !integrated_signaler.receiving

		if("freq")
			var/value = params["freq"]
			if(value)
				integrated_signaler.frequency = sanitize_frequency(value)
			else
				. = FALSE

		if("code")
			var/value = text2num(params["code"])
			if(value)
				value = round(value)
				integrated_signaler.code = clamp(value, 1, 100)
			else
				. = FALSE

		if("reset")
			if(params["reset"] == "freq")
				integrated_signaler.frequency = initial(integrated_signaler.frequency)
			else if(params["reset"] == "code")
				integrated_signaler.code = initial(integrated_signaler.code)
			else
				. = FALSE

	if(.)
		add_fingerprint(usr)

// Electropack signaller type
/obj/item/assembly/signaler/electropack
	frequency = AIRLOCK_FREQ
	code = 2
	receiving = TRUE
	var/obj/item/electropack/owning_pack

/obj/item/assembly/signaler/electropack/Initialize(mapload, holding_electropack)
	. = ..()
	owning_pack = holding_electropack

/obj/item/assembly/signaler/electropack/signal_callback()
	if(owning_pack)
		owning_pack.handle_shock()

/obj/item/assembly/signaler/electropack/Destroy()
	owning_pack = null
	return ..()
