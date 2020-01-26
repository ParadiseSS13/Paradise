/obj/item/dart_cartridge
	name = "dart cartridge"
	desc = "A rack of hollow darts."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "darts-5"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	var/darts = 5

/obj/item/dart_cartridge/update_icon()
	if(!darts)
		icon_state = "darts-0"
	else if(darts > 5)
		icon_state = "darts-5"
	else
		icon_state = "darts-[darts]"
	return 1

/obj/item/gun/dartgun
	name = "dart gun"
	desc = "A small gas-powered dartgun, capable of delivering chemical cocktails swiftly across short distances."
	icon_state = "dartgun-empty"

	var/list/beakers = list() //All containers inside the gun.
	var/list/mixing = list() //Containers being used for mixing.
	var/obj/item/dart_cartridge/cartridge = null //Container of darts.
	var/max_beakers = 3
	var/dart_reagent_amount = 15
	var/containers_type = /obj/item/reagent_containers/glass/beaker
	var/list/starting_chems = null

/obj/item/gun/dartgun/update_icon()
	if(!cartridge)
		icon_state = "dartgun-e"
		return 1

	if(!cartridge.darts)
		icon_state = "dartgun-0"
	else if(cartridge.darts > 5)
		icon_state = "dartgun-5"
	else
		icon_state = "dartgun-[cartridge.darts]"
	return 1

/obj/item/gun/dartgun/New()
	..()
	if(starting_chems)
		for(var/chem in starting_chems)
			var/obj/B = new containers_type(src)
			B.reagents.add_reagent(chem, 50)
			beakers += B
	cartridge = new /obj/item/dart_cartridge(src)
	update_icon()

/obj/item/gun/dartgun/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		if(beakers.len)
			. += "<span class='notice'>[src] contains:</span>"
			for(var/obj/item/reagent_containers/glass/beaker/B in beakers)
				if(B.reagents && B.reagents.reagent_list.len)
					for(var/datum/reagent/R in B.reagents.reagent_list)
						. += "<span class='notice'>[R.volume] units of [R.name]</span>"

/obj/item/gun/dartgun/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/dart_cartridge))

		var/obj/item/dart_cartridge/D = I

		if(!D.darts)
			to_chat(user, "<span class='warning'>[D] is empty.</span>")
			return 0

		if(cartridge)
			if(cartridge.darts <= 0)
				src.remove_cartridge()
			else
				to_chat(user, "<span class='warning'>There's already a cartridge in [src].</span>")
				return 0

		user.drop_item()
		cartridge = D
		D.forceMove(src)
		to_chat(user, "<span class='notice'>You slot [D] into [src].</span>")
		update_icon()
		return
	if(istype(I, /obj/item/reagent_containers/glass))
		if(!istype(I, containers_type))
			to_chat(user, "<span class='warning'>[I] doesn't seem to fit into [src].</span>")
			return
		if(beakers.len >= max_beakers)
			to_chat(user, "<span class='warning'>[src] already has [max_beakers] beakers in it - another one isn't going to fit!</span>")
			return
		var/obj/item/reagent_containers/glass/beaker/B = I
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [B] is stuck to you!</span>")
			return
		B.forceMove(src)
		beakers += B
		to_chat(user, "<span class='notice'>You slot [B] into [src].</span>")
		src.updateUsrDialog()
	else
		return ..()

/obj/item/gun/dartgun/can_shoot()
	if(!cartridge)
		return 0
	else
		return cartridge.darts

/obj/item/gun/dartgun/proc/has_selected_beaker_reagents()
	return 0

/obj/item/gun/dartgun/proc/remove_cartridge()
	if(cartridge)
		to_chat(usr, "<span class='notice'>You pop the cartridge out of [src].</span>")
		var/obj/item/dart_cartridge/C = cartridge
		C.forceMove(get_turf(src))
		C.update_icon()
		cartridge = null
		src.update_icon()

/obj/item/gun/dartgun/proc/get_mixed_syringe()
	if(!cartridge)
		return 0
	if(!cartridge.darts)
		return 0

	var/obj/item/reagent_containers/syringe/dart = new(src)

	if(mixing.len)
		var/mix_amount = dart_reagent_amount/mixing.len
		for(var/obj/item/reagent_containers/glass/beaker/B in mixing)
			B.reagents.trans_to(dart,mix_amount)

	return dart

/obj/item/gun/dartgun/proc/fire_dart(atom/target, mob/user)
	if(locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/reagent_containers/syringe/S = get_mixed_syringe()
		if(!S)
			to_chat(user, "<span class='warning'>There are no darts in [src]!</span>")
			return
		if(!S.reagents)
			to_chat(user, "<span class='warning'>There are no reagents available!</span>")
			return
		cartridge.darts--
		src.update_icon()
		S.reagents.trans_to(D, S.reagents.total_volume)
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		D.reagents.set_reacting(FALSE)
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!istype(M,/mob/living/carbon)) continue
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if(istype(M, /mob))
						if(!iscarbon(user))
							M.LAssailant = null
						else
							M.LAssailant = user

					add_attack_logs(user, M, "Shot with dartgun containing [R]")

					if(D.reagents)
						D.reagents.trans_to(M, 15)
					to_chat(M, "<span class='danger'>You feel a slight prick.</span>")

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if(D) spawn(10) qdel(D)

		return

/obj/item/gun/dartgun/afterattack(atom/target, mob/living/user, flag, params)
	if(!isturf(target.loc) || target == user)
		return
	..()

/obj/item/gun/dartgun/attack_self(mob/user)
	user.set_machine(src)
	var/dat = "<b>[src] mixing control:</b><br><br>"

	if(beakers.len)
		var/i = 1
		for(var/obj/item/reagent_containers/glass/beaker/B in beakers)
			dat += "Beaker [i] contains: "
			if(B.reagents && B.reagents.reagent_list.len)
				for(var/datum/reagent/R in B.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
				if(check_beaker_mixing(B))
					dat += text("<A href='?src=[UID()];stop_mix=[i]'><font color='green'>Mixing</font></A> ")
				else
					dat += text("<A href='?src=[UID()];mix=[i]'><font color='red'>Not mixing</font></A> ")
			else
				dat += "nothing."
			dat += " \[<A href='?src=[UID()];eject=[i]'>Eject</A>\]<br>"
			i++
	else
		dat += "There are no beakers inserted!<br><br>"

	if(cartridge)
		if(cartridge.darts)
			dat += "The dart cartridge has [cartridge.darts] shots remaining."
		else
			dat += "<font color='red'>The dart cartridge is empty!</font>"
		dat += " \[<A href='?src=[UID()];eject_cart=1'>Eject</A>\]"

	user << browse(dat, "window=dartgun")
	onclose(user, "dartgun", src)

/obj/item/gun/dartgun/proc/check_beaker_mixing(var/obj/item/B)
	if(!mixing || !beakers)
		return 0
	for(var/obj/item/M in mixing)
		if(M == B)
			return 1
	return 0

/obj/item/gun/dartgun/Topic(href, href_list)
	src.add_fingerprint(usr)
	if(href_list["stop_mix"])
		var/index = text2num(href_list["stop_mix"])
		if(index <= beakers.len)
			for(var/obj/item/M in mixing)
				if(M == beakers[index])
					mixing -= M
					break
	else if(href_list["mix"])
		var/index = text2num(href_list["mix"])
		if(index <= beakers.len)
			mixing += beakers[index]
	else if(href_list["eject"])
		var/index = text2num(href_list["eject"])
		if(index <= beakers.len)
			if(beakers[index])
				var/obj/item/reagent_containers/glass/beaker/B = beakers[index]
				to_chat(usr, "<span class='notice'>You remove [B] from [src].</span>")
				mixing -= B
				beakers -= B
				B.forceMove(get_turf(src))
	else if(href_list["eject_cart"])
		remove_cartridge()
	src.updateUsrDialog()
	return

/obj/item/gun/dartgun/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(cartridge)
		spawn(0)
			fire_dart(target,user)
	else
		to_chat(usr, "<span class='warning'>[src] is empty.</span>")


/obj/item/gun/dartgun/vox
	name = "alien dart gun"
	desc = "A small gas-powered dartgun, fitted for nonhuman hands."

/obj/item/gun/dartgun/vox/medical
	starting_chems = list("silver_sulfadiazine","styptic_powder","charcoal")

/obj/item/gun/dartgun/vox/raider
	starting_chems = list("space_drugs","ether","haloperidol")

/obj/effect/syringe_gun_dummy //moved this shitty thing here
	name = ""
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

/obj/effect/syringe_gun_dummy/New()
	create_reagents(15)
