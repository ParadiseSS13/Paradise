//yes i did stealfrom blobcode...
/obj/effect/bloodnode
	name = "blood pustilue"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodnode"
	var/health = 100
	anchored = 1
	density = 1
	var/lastblood = 0
	var/nodecount = 0



	New(loc, var/h = 100)
		nodecount +=1
		processing_objects.Add(src)
		..(loc, h)

	Destroy()
		nodecount -= 1
		processing_objects.Remove(src)
		..()
		return

	process()
		if(lastblood == 0 || (world.time - lastblood) > 600)
			src.visible_message("pulse!")
			var/obj/effect/decal/cleanable/blood/splatter/blooddecal = new (src.loc)
			playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
			//throw that then use a gibspawner
			new /obj/effect/gibspawner/human(get_turf(src))
			var/atom/bloodtarget = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
			blooddecal.throw_at(get_edge_target_turf(bloodtarget,pick(alldirs)),rand(5,15),5)
			lastblood += world.time
		return


	proc/Delete()
		qdel(src)

	update_icon()
		src.visible_message("[health]")
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/gib.ogg', 50, 1)
			new /obj/effect/gibspawner/human(get_turf(src))
			Delete()
			return
		return

	ex_act(severity)
		var/damage = 150
		health -= ((damage - (severity * 5)))
		update_icon()
		return


	bullet_act(var/obj/item/projectile/Proj)
		..()
		health -= (Proj.damage)
		update_icon()
		return 0


	attackby(var/obj/item/weapon/W, var/mob/living/user, params)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		playsound(get_turf(src), 'sound/effects/attackblob.ogg', 50, 1)
		//new /datum/artifact_effect/badfeeling/DoEffectTouch(user)
		src.visible_message("\red <B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = 0
		switch(W.damtype)
			if("fire")
				damage = (W.force)
				if(istype(W, /obj/item/weapon/weldingtool))
					playsound(get_turf(src), 'sound/items/Welder.ogg', 100, 1)
			if("brute")
				damage = (W.force)

		health -= damage
		update_icon()
		return

	attack_hand(var/mob/user)
		user << "You REALLY do not want to touch that bare handed."
		return


	attack_animal(mob/living/simple_animal/M as mob)
		M.changeNext_move(CLICK_CD_MELEE)
		M.do_attack_animation(src)
		playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
		src.visible_message("<span class='danger'>The [src.name] has been attacked by \the [M]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(!damage) // Avoid divide by zero errors
			return
		damage = max(damage)
		health -= damage
		update_icon()
		return
