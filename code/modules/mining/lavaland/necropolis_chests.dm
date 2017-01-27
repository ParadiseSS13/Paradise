//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrateopen"
	icon_closed = "necrocrate"
	
/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/New()
	..()
	// uncomment me once these items are being implemented
	/*var/loot = rand(1,25)
	switch(loot) 
		if(1)
			new /obj/item/device/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/suit/space/hardsuit/cult(src)
		if(3)
			new /obj/item/device/soulstone/anybody(src)
		if(4)
			new /obj/item/weapon/katana/cursed(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/weapon/reagent_containers/glass/bottle/potion/flight(src)
		if(7)
			new /obj/item/weapon/pickaxe/diamond(src)
		if(8)
			new /obj/item/clothing/head/culthood(src)
			new /obj/item/clothing/suit/cultrobes(src)
			new /obj/item/weapon/bedsheet/cult(src)
		if(9)
			new /obj/item/organ/brain/alien(src)
		if(10)
			new /obj/item/organ/heart/cursed(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker(src)
		if(13)
			new /obj/item/weapon/sord(src)
		if(14)
			new /obj/item/weapon/nullrod/scythe/talking(src)
		if(15)
			new /obj/item/weapon/nullrod/armblade(src)
		if(16)
			new /obj/item/weapon/guardiancreator(src)
		if(17)
			new /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs(src)
		if(18)
			new /obj/item/device/warp_cube/red(src)
		if(19)
			new /obj/item/device/wisp_lantern(src)
		if(20)
			new /obj/item/device/immortality_talisman(src)
		if(21)
			new /obj/item/weapon/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23)
			new /obj/item/weapon/grenade/clusterbuster/inferno(src)
		if(24)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/hell(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor(src)
		if(25)
			new /obj/item/weapon/spellbook/oneuse/summonitem(src)*/

///Bosses

//Dragon

/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/New()
	..()
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/weapon/melee/ghost_sword(src)
		if(2)
			new /obj/item/weapon/lava_staff(src)
		if(3)
			new /obj/item/weapon/spellbook/oneuse/sacredflame(src)
			new /obj/item/weapon/gun/magic/wand/fireball(src)
		if(4)
			new /obj/item/weapon/dragons_blood(src)

/obj/item/weapon/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	item_state = "spectral"
	flags = CONDUCT
	sharp = 1
	edge = 1
	w_class = 4
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/weapon/melee/ghost_sword/New()
	..()
	spirits = list()
	processing_objects.Add(src)
	poi_list |= src

/obj/item/weapon/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = initial(G.invisibility)
	spirits.Cut()
	processing_objects.Remove(src)
	poi_list -= src
	. = ..()

/obj/item/weapon/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising their [src], calling for your help!", enter_link="<a href=?src=[UID()];follow=1>(Click to help)</a>", source = user, action = NOTIFY_FOLLOW)

	summon_cooldown = world.time + 600

/obj/item/weapon/melee/ghost_sword/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/weapon/melee/ghost_sword/process()
	ghost_check()

/obj/item/weapon/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	
	for(var/mob/dead/observer/O in player_list)
		if(is_type_in_list(O.following, contents))
			ghost_counter++
			O.invisibility = 0
			current_spirits |= O

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = initial(G.invisibility)

	spirits = current_spirits

	return ghost_counter

/obj/item/weapon/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = Clamp((ghost_counter * 4), 0, 75)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirits!</span>")
	..()

/obj/item/weapon/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	var/ghost_counter = ghost_check()
	final_block_chance += Clamp((ghost_counter * 5), 0, 75)
	owner.visible_message("<span class='danger'>[owner] is protected by a ring of [ghost_counter] ghosts!</span>")
	return ..()

// Blood

/obj/item/weapon/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/weapon/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,3)

	switch(random)
		if(1)
			to_chat(user, "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>")
			H.set_species("Skeleton")
		if(2)
			to_chat(user, "<span class='danger'>Power courses through you! You can now shift your form at will.")
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(3)
			to_chat(user, "<span class='danger'>You feel like you could walk straight through lava now.</span>")
			H.weather_immunities |= "lava"

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaley.")
	stage3	= list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4	= list("<span class='danger'>Your blood burns.</span>")
	stage5	= list("<span class='danger'>You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser
	
//Lava Staff

/obj/item/weapon/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = 4
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/unsimulated/floor/lava // /turf/simulated/floor/plating/lava/smooth once Lavaland turfs are added
	var/transform_string = "lava"
	var/reset_turf_type = /turf/simulated/floor/plating/airless/asteroid // /turf/simulated/floor/plating/asteroid/basalt once Lavaland turfs are added
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/banned_turfs

/obj/item/weapon/lava_staff/New()
	. = ..()
	banned_turfs = typecacheof(list(/turf/space/transit, /turf/unsimulated))

/obj/item/weapon/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(target in view(user.client.view, get_turf(user)))

		var/turf/simulated/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/overlay/temp/lavastaff/L = new /obj/effect/overlay/temp/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message("<span class='danger'>[user] points [src] at [T]!</span>")
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				user.visible_message("<span class='danger'>[user] turns \the [T] into [transform_string]!</span>")
				message_admins("[key_name_admin(user)] fired the lava staff at [get_area(target)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>).")
				log_game("[key_name(user)] fired the lava staff at [get_area(target)] ([T.x], [T.y], [T.z]).")
				T.ChangeTurf(turf_type)
				timer = world.time + create_cooldown
				qdel(L)
			else
				timer = world.time
				qdel(L)
				return
		else
			user.visible_message("<span class='danger'>[user] turns \the [T] into [reset_string]!</span>")
			T.ChangeTurf(reset_turf_type)
			timer = world.time + reset_cooldown
		playsound(T,'sound/magic/Fireball.ogg', 200, 1)

/obj/effect/overlay/temp/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50
	
// Bubblegum
	
/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/New()
	..()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/mayhem(src)
		if(2)
			new /obj/item/blood_contract(src)
		if(3)
			new /obj/item/weapon/gun/magic/staff/spellblade(src)
		
// Mayhem
		
/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(H)
			B.mineEffect(H)
	to_chat(user, "<span class='notice'>You shatter the bottle!</span>")
	playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
	qdel(src)
	
// Blood Contract

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death."
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return
		
	used = TRUE
	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in player_list

	if(!choice)
		used = FALSE
		return
	else if(!isliving(choice))
		to_chat(user, "[choice] is already dead!")
		used = FALSE
		return
	else
		var/mob/living/L = choice

		message_admins("[key_name_admin(L)] has been marked for death by [key_name_admin(user)].")
		log_admin("[key_name(L)] has been marked for death by [key_name(user)].")

		var/datum/objective/survive/survive = new
		survive.owner = L.mind
		L.mind.objectives += survive
		to_chat(L, "<span class='userdanger'>You've been marked for death! Don't let the demons get you!</span>")
		L.color = "#FF0000"
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(L)
			B.mineEffect(L)

		for(var/mob/living/carbon/human/H in player_list)
			if(H == L)
				continue
			to_chat(H, "<span class='userdanger'>You have an overwhelming desire to kill [L]. They have been marked red! Go kill them!</span>")
			H.put_in_hands(new /obj/item/weapon/kitchen/knife/butcher(H))

	qdel(src)
	
// Legion

// Staff of Storms

/obj/item/weapon/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = 4
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/storm_type = /datum/weather/ash_storm
	var/storm_cooldown = 0

/obj/item/weapon/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		to_chat(user, "<span class='warning'>The staff is still recharging!</span>")
		return

	var/area/user_area = get_area(user)
	var/datum/weather/A
	var/z_level_name = space_manager.levels_by_name[user.z]
	for(var/V in weather_master.existing_weather)
		var/datum/weather/W = V
		if(W.target_z == z_level_name && W.area_type == user_area.type)
			A = W
			break
	if(A)

		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>")
				return
			user.visible_message("<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>", \
			"<span class='notice'>You hold [src] skyward, dispelling the storm!</span>")
			playsound(user, 'sound/magic/Staff_Change.ogg', 200, 0)
			A.wind_down()
			return
	else
		A = new storm_type
		A.name = "staff storm"
		A.area_type = user_area.type
		A.target_z = z_level_name
		A.telegraph_duration = 100
		A.end_duration = 100

	user.visible_message("<span class='warning'>[user] holds [src] skywards as red lightning crackles into the sky!</span>", \
	"<span class='notice'>You hold [src] skyward, calling down a terrible storm!</span>")
	playsound(user, 'sound/magic/Staff_Change.ogg', 200, 0)
	A.telegraph()
	storm_cooldown = world.time + 200
	
// Hierophant

//Hierophant

/obj/item/weapon/hierophant_staff
	name = "Hierophant's staff"
	desc = "A large club with intense magic power infused into it."
	icon_state = "hierophant_staff"
	item_state = "hierophant_staff"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	w_class = 4
	force = 20
	hitsound = "swing_hit"
	//hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 101 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/timer = 0 //what our current cooldown is
	var/blast_range = 3 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/rune //the associated rune we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/weapon/hierophant_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		spawn(0)
			aoe_burst(T, user)
		add_logs(user, target, "fired 3x3 blast at", src)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			spawn(0)
				cardinal_blasts(T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				new /obj/effect/overlay/temp/hierophant/chaser(get_turf(user), user, target, 1.5, friendly_fire_check)
				add_logs(user, target, "fired a chaser at", src)
			else
				spawn(0)
					cardinal_blasts(T, user) //otherwise, just do cardinal blast
				add_logs(user, target, "fired cardinal blast at", src)
		else
			to_chat(user, "<span class='warning'>That target is out of range!</span>") //too far away

/obj/item/weapon/hierophant_staff/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_unfriendly_fire) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		to_chat(user, "<span class='warning'>You toggle friendly fire [friendly_fire_check ? "off":"on"]!</span>")
		return
	if(user.get_active_hand() != src && user.get_inactive_hand() != src) //you need to hold the staff to teleport
		to_chat(user, "<span class='warning'>You need to hold the staff in your hands to [rune ? "teleport with it" : "create a rune"]!</span>")
		return
	if(!rune)
		if(isturf(user.loc))
			user.visible_message("<span class='hierophant_warning'>[user] holds [src] carefully in front of them, moving it in a strange pattern...</span>", \
			"<span class='notice'>You start creating a hierophant rune to teleport to...</span>")
			timer = world.time + 51
			if(do_after(user, 50, target = user))
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/Blind.ogg', 200, 1, -4)
				new /obj/effect/overlay/temp/hierophant/telegraph/teleport(T, user)
				var/obj/effect/hierophant/H = new/obj/effect/hierophant(T)
				rune = H
				user.update_action_buttons_icon()
				user.visible_message("<span class='hierophant_warning'>[user] creates a strange rune beneath them!</span>", \
				"<span class='hierophant'>You create a hierophant rune, which you can teleport yourself and any allies to at any time!</span>\n\
				<span class='notice'>You can remove the rune to place a new one by striking it with the staff.</span>")
			else
				timer = world.time
		else
			to_chat(user, "<span class='warning'>You need to be on solid ground to produce a rune!</span>")
		return
	if(get_dist(user, rune) <= 2) //rune too close abort
		to_chat(user, "<span class='warning'>You are too close to the rune to teleport to it!</span>")
		return
	if(is_blocked_turf(get_turf(rune)))
		to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("<span class='hierophant_warning'>[user] starts to glow faintly...</span>")
	timer = world.time + 50
	if(do_after(user, 40, target = user) && rune)
		var/turf/T = get_turf(rune)
		var/turf/source = get_turf(user)
		if(is_blocked_turf(T))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			return
		new /obj/effect/overlay/temp/hierophant/telegraph(T, user)
		new /obj/effect/overlay/temp/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/blink.ogg', 200, 1)
		//playsound(T,'sound/magic/Wand_Teleport.ogg', 200, 1)
		playsound(source,'sound/magic/blink.ogg', 200, 1)
		//playsound(source,'sound/machines/AirlockOpen.ogg', 200, 1)
		if(!do_after(user, 3, target = user) || !rune) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			return
		if(is_blocked_turf(T))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The rune is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			return
		add_logs(user, rune, "teleported self from ([source.x],[source.y],[source.z]) to")
		new /obj/effect/overlay/temp/hierophant/telegraph/teleport(T, user)
		new /obj/effect/overlay/temp/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			var/obj/effect/overlay/temp/hierophant/blast/B = new /obj/effect/overlay/temp/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/overlay/temp/hierophant/blast/B = new /obj/effect/overlay/temp/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			spawn(0)
				teleport_mob(source, L, T, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
	else
		timer = world.time
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/weapon/hierophant_staff/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || is_blocked_turf(turf_to_teleport_to))
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades out!</span>")
	sleep(2)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades in!</span>")
	if(user != M)
		add_logs(user, M, "teleported", null, "from ([source.x],[source.y],[source.z])")

/obj/item/weapon/hierophant_staff/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/overlay/temp/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	new /obj/effect/overlay/temp/hierophant/blast(T, user, friendly_fire_check)
	for(var/d in cardinal)
		spawn(0)
			blast_wall(T, d, user)

/obj/item/weapon/hierophant_staff/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		new /obj/effect/overlay/temp/hierophant/blast(J, user, friendly_fire_check)
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/weapon/hierophant_staff/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/overlay/temp/hierophant/telegraph(T, user)
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		new /obj/effect/overlay/temp/hierophant/blast(t, user, friendly_fire_check)