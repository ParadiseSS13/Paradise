//yes i did stealfrom blobcode...
/obj/effect/bloodnode
	name = "blood pustilue"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	var/health = 100
	anchored = 1
	density = 1
	var/lastblood = 0
	var/nodecount = 0
	var/datum/artifact_effect/paranoia = new /datum/artifact_effect/badfeeling



/obj/effect/bloodnode/New(loc, var/h = 100)
	nodecount +=1
	processing_objects.Add(src)
	NodeColor()
	..(loc, h)


/obj/effect/bloodnode/Destroy()
	nodecount -= 1
	processing_objects.Remove(src)
	..()

/obj/effect/bloodnode/process()
	if(lastblood == 0 || (world.time - lastblood) > 600)
		//src.visible_message("pulse!")//debug
		var/obj/effect/decal/cleanable/blood/splatter/blooddecal = new (src.loc)
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		//throw that then use a gibspawner
		new /obj/effect/gibspawner/human(get_turf(src))
		var/atom/bloodtarget = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
		blooddecal.throw_at(get_edge_target_turf(bloodtarget,pick(alldirs)),rand(5,15),5)
		lastblood += world.time

/obj/effect/bloodnode/proc/NodeColor()//Stealing from NEW blob code...
	overlays.Cut()
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = "#7F0000"
	overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	C.color = "#FF4C4C"
	overlays += C



/obj/effect/bloodnode/update_icon()
	//src.visible_message("[health]")
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/gib.ogg', 50, 1)
		new /obj/effect/gibspawner/human(get_turf(src))
		qdel(src)


/obj/effect/bloodnode/ex_act(severity)
	var/damage = 150
	health -= ((damage - (severity * 5)))
	update_icon()


/obj/effect/bloodnode/bullet_act(var/obj/item/projectile/Proj)
	..()
	health -= (Proj.damage)
	update_icon()
	return 0


/obj/effect/bloodnode/attackby(var/obj/item/weapon/W, var/mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(get_turf(src), 'sound/effects/attackblob.ogg', 50, 1)
	src.visible_message("<span class='danger'>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = 0
	switch(W.damtype)
		if("fire")
			damage = (W.force)
			if(istype(W, /obj/item/weapon/weldingtool))
				playsound(get_turf(src), 'sound/items/Welder.ogg', 100, 1)
		if("brute")
			if(prob(25))
				paranoia.DoEffectTouch(user)
			damage = (W.force)

	health -= damage
	update_icon()


/obj/effect/bloodnode/attack_hand(var/mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(prob(25))
		paranoia.DoEffectTouch(user)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	var/damage = rand(5,10)
	if(!damage) // Avoid divide by zero errors
		return
	src.visible_message("<span class='danger'>\The [src.name] has been punched by [user]!</span>")
	damage = max(damage)
	health -= damage
	update_icon()



/obj/effect/bloodnode/attack_animal(mob/living/simple_animal/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	src.visible_message("<span class='danger'>\The [src.name] has been attacked by \the [M]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage) // Avoid divide by zero errors
		return
	damage = max(damage)
	health -= damage
	update_icon()

