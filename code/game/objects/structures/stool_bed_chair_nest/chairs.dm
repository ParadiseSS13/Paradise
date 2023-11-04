/obj/structure/chair	// fuck you Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	layer = OBJ_LAYER
	can_buckle = TRUE
	buckle_lying = FALSE // you sit in a chair, not lay
	anchored = TRUE
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	buckle_offset = 0
	face_while_pulling = FALSE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up
	var/movable = FALSE // For mobility checks
	var/propelled = FALSE // Check for fire-extinguisher-driven chairs
	var/comfort = 0
	/// Used to handle rotation properly, should only be 1, 4, or 8
	var/possible_dirs = 4

/obj/structure/chair/examine(mob/user)
	. = ..()
	. += "<span class='info'>You can <b>Alt-Click</b> [src] to rotate it.</span>"

/obj/structure/chair/narsie_act()
	if(prob(20))
		var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/structure/chair/Move(atom/newloc, direct)
	..()
	handle_rotation()

/obj/structure/chair/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, "<span class='notice'>[SK] is not ready to be attached!</span>")
			return
		user.drop_item()
		var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(get_turf(src), SK)
		playsound(src.loc, W.usesound, 50, 1)
		E.dir = dir
		SK.loc = E
		SK.master = E
		qdel(src)
		return
	return ..()

/obj/structure/chair/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>Try as you might, you can't figure out how to deconstruct [src].</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/chair/deconstruct()
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(buildstacktype && (!(flags & NODECONSTRUCT)))
		new buildstacktype(loc, buildstackamount)
	..()

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || has_buckled_mobs())
			return
		if(usr.incapacitated())
			to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
			return
		if(!usr.has_right_hand() && !usr.has_left_hand())
			to_chat(usr, "<span class='warning'>You try to grab the chair, but you are missing both of your hands!</span>")
			return
		if(usr.get_active_hand() && usr.get_inactive_hand())
			to_chat(usr, "<span class='warning'>You try to grab the chair, but your hands are already full!</span>")
			return
		if(!ishuman(usr))
			return
		usr.visible_message("<span class='notice'>[usr] grabs \the [src.name].</span>", "<span class='notice'>You grab \the [src.name].</span>")
		var/C = new item_chair(loc)
		usr.put_in_hands(C)
		qdel(src)
		return
	. = ..()

/obj/structure/chair/attack_hand(mob/user)
	if(user.Move_Pulled(src))
		return
	return ..()

/obj/structure/chair/attack_tk(mob/user as mob)
	if(!anchored || has_buckled_mobs() || !isturf(user.loc))
		..()
	else
		rotate()

/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(possible_dirs == 8) // We don't want chairs with corner dirs to sit over mobs, it is handled by armrests
		layer = OBJ_LAYER
		return
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/post_buckle_mob(mob/living/M)
	. = ..()
	handle_layer()

/obj/structure/chair/post_unbuckle_mob()
	. = ..()
	handle_layer()

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/structure/chair/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	rotate()

/obj/structure/chair/attack_ghost(mob/user)
	if(GLOB.configuration.general.ghost_interaction)
		rotate()
		return
	..()

/obj/structure/chair/proc/rotate()
	setDir(turn(dir, (360 / possible_dirs)))
	handle_rotation()

// Chair types
/obj/structure/chair/light
	name = "chair"
	icon_state = "chair_greyscale"
	resistance_flags = FLAMMABLE
	item_chair = /obj/item/chair/light

/obj/structure/chair/wood
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	icon_state = "wooden_chair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 3
	buildstacktype = /obj/item/stack/sheet/wood
	item_chair = /obj/item/chair/wood

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255, 255, 255)
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	var/image/armrest = null

/obj/structure/chair/comfy/corp
	color = null
	icon_state = "comfychair_corp"

/obj/structure/chair/comfy/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/comfy/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/comfy/brown
	color = rgb(141,70,0)

/obj/structure/chair/comfy/red
	color = rgb(218,2,10)

/obj/structure/chair/comfy/teal
	color = rgb(0,234,250)

/obj/structure/chair/comfy/black
	color = rgb(60,60,60)

/obj/structure/chair/comfy/green
	color = rgb(1,196,8)

/obj/structure/chair/comfy/purp
	color = rgb(112,2,176)

/obj/structure/chair/comfy/blue
	color = rgb(2,9,210)

/obj/structure/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/chair/office
	anchored = FALSE
	movable = TRUE
	item_chair = null
	buildstackamount = 5

/obj/structure/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a more sturdy looking buckling system, for smoother flights."
	icon_state = "shuttle_chair"

/obj/structure/chair/comfy/shuttle/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "shuttle_chair_armrest")

/obj/structure/chair/office/Bump(atom/A)
	..()
	if(!has_buckled_mobs())
		return

	if(propelled)
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			unbuckle_mob(buckled_mob)
			buckled_mob.throw_at(A, 3, propelled)
			buckled_mob.Weaken(12 SECONDS)
			buckled_mob.Stuttering(12 SECONDS)
			buckled_mob.take_organ_damage(10)
			playsound(loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
			buckled_mob.visible_message("<span class='danger'>[buckled_mob] crashed into [A]!</span>")

/obj/structure/chair/office/light
	icon_state = "officechair_white"

/obj/structure/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/chair/barber
	icon_state = "barber_chair"
	buildstackamount = 1
	item_chair = null

// Sofas

/obj/structure/chair/sofa
	name = "sofa"
	icon_state = "sofamiddle"
	color = rgb(141,70,0) //this sprite and benches support coloring currently
	anchored = TRUE
	item_chair = null
	buildstackamount = 1
	var/image/armrest = null
	var/colorable = TRUE

/obj/structure/chair/sofa/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/sofa/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!colorable)
		return
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		var/new_color = C.colour
		var/list/hsl = rgb2hsl(hex2num(copytext(new_color, 2, 4)), hex2num(copytext(new_color, 4, 6)), hex2num(copytext(new_color, 6, 8)))
		hsl[3] = max(hsl[3], 0.4)
		var/list/rgb = hsl2rgb(arglist(hsl))
		color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"
	if(color)
		cut_overlay(armrest)
		armrest = GetArmrest()
		update_armrest()

/obj/structure/chair/sofa/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/sofa/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/sofa/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/chair/sofa/corner
	icon_state = "sofacorner"
	possible_dirs = 8

/obj/structure/chair/sofa/corp
	name = "sofa"
	desc = "Soft and cushy."
	icon_state = "corp_sofamiddle"
	color = null
	colorable = FALSE

/obj/structure/chair/sofa/corp/left
	icon_state = "corp_sofaend_left"

/obj/structure/chair/sofa/corp/right
	icon_state = "corp_sofaend_right"

/obj/structure/chair/sofa/corp/corner
	icon_state = "corp_sofacorner"
	possible_dirs = 8

/obj/structure/chair/sofa/pew
	name = "pew"
	desc = "Rigid and uncomfortable, perfect for keeping you awake and alert."
	icon_state = "pewmiddle"
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5
	color = null
	colorable = FALSE

/obj/structure/chair/sofa/pew/left
	icon_state = "pewend_left"

/obj/structure/chair/sofa/pew/right
	icon_state = "pewend_right"

/obj/structure/chair/sofa/bench
	name = "bench"
	desc = "You sit in this. Either by will or force."
	icon_state = "bench_middle_mapping"
	base_icon_state = "bench_middle"
	///icon for the cover seat
	var/image/cover
	///cover seat color
	var/cover_color = rgb(255,255,255)
	color = null
	colorable = FALSE

/obj/structure/chair/sofa/bench/Initialize(mapload)
	icon_state = base_icon_state //so the rainbow seats for mapper clarity are not in-game
	GetCover()
	return ..()

/obj/structure/chair/sofa/bench/proc/GetCover()
	if(cover)
		cut_overlay(cover)
	cover = mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_cover", color = cover_color) //this supports colouring, but not the base bench
	add_overlay(cover)

/obj/structure/chair/sofa/bench/handle_layer()
	return

/obj/structure/chair/sofa/bench/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		cover_color = C.colour
	if(cover_color)
		GetCover()

/obj/structure/chair/sofa/bench/left
	icon_state = "bench_left_mapping"
	base_icon_state = "bench_left"

/obj/structure/chair/sofa/bench/right
	icon_state = "bench_right_mapping"
	base_icon_state = "bench_right"

/obj/structure/chair/sofa/bamboo
	name = "bamboo bench"
	desc = "Not the most comfortable, but vegan!"
	icon_state = "bamboo_sofamiddle"
	color = null
	colorable = FALSE
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	buildstacktype = /obj/item/stack/sheet/wood

/obj/structure/chair/sofa/bamboo/left
	icon_state = "bamboo_sofaend_left"

/obj/structure/chair/sofa/bamboo/right
	icon_state = "bamboo_sofaend_right"

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = FALSE
	item_chair = /obj/item/chair/stool

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/structure/chair/stool/bamboo
	name = "bamboo stool"
	desc = "Not the most comfortable, but vegan!"
	icon_state = "bamboo_stool"
	item_chair = /obj/item/chair/stool/bamboo
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	buildstacktype = /obj/item/stack/sheet/wood

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	item_state = "chair"
	lefthand_file = 'icons/mob/inhands/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50
	materials = list(MAT_METAL = 2000)
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/light
	icon_state = "chair_greyscale_toppled"
	origin_type = /obj/structure/chair/light

/obj/item/chair/stool
	name = "stool"
	icon = 'icons/obj/chairs.dmi'
	icon_state = "stool_toppled"
	item_state = "stool"
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	item_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/bamboo
	name = "bamboo stool"
	desc = "Not the most comfortable, but vegan!"
	item_state = "bamboo_stool"
	icon_state = "bamboo_stool_toppled"
	origin_type = /obj/structure/chair/stool/bamboo

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	if(QDELETED(src))
		return
	for(var/obj/A in get_turf(loc))
		if(istype(A, /obj/structure/chair))
			to_chat(user, "<span class='warning'>There is already \a [A] here.</span>")
			return

	user.visible_message("<span class='notice'>[user] rights [src].</span>", "<span class='notice'>You right [src].</span>")
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.setDir(user.dir)
	qdel(src)

/obj/item/chair/proc/smash(mob/living/user)
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically dissapears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	qdel(src)

/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>[owner] fends off [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/chair/afterattack(atom/target, mob/living/carbon/user, proximity)
	..()
	if(!proximity)
		return
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user] smashes \the [src] to pieces against \the [target]</span>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(C.health < C.maxHealth*0.5)
				C.Weaken(12 SECONDS)
				C.Stuttering(12 SECONDS)
				playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		smash(user)

/obj/item/chair/stool/attack(mob/M as mob, mob/user as mob)
	if(prob(5) && isliving(M))
		user.visible_message("<span class='danger'>[user] breaks [src] over [M]'s back!.</span>")
		user.unEquip(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		qdel(src)
		var/mob/living/T = M
		T.Weaken(10 SECONDS)
		return
	..()

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	item_state = "woodenchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	materials = null
	break_chance = 50

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/structure/chair/old
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks REALLY uncomfortable."
	icon_state = "chairold"
	item_chair = null

// Brass chair
/obj/structure/chair/brass
	name = "brass chair"
	desc = "A spinny chair made of brass. It looks uncomfortable."
	icon_state = "brass_chair"
	max_integrity = 150
	buildstacktype = /obj/item/stack/tile/brass
	buildstackamount = 1
	item_chair = null
	var/turns = 0

/obj/structure/chair/brass/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/chair/brass/process()
	setDir(turn(dir,-90))
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	turns++
	if(turns >= 8)
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/brass/AltClick(mob/living/user)
	turns = 0
	if(!istype(user) || user.incapacitated() || !in_range(src, user))
		return
	if(!isprocessing)
		user.visible_message("<span class='notice'>[user] spins [src] around, and Ratvarian technology keeps it spinning FOREVER.</span>", \
		"<span class='notice'>Automated spinny chairs. The pinnacle of Ratvarian technology.</span>")
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message("<span class='notice'>[user] stops [src]'s uncontrollable spinning.</span>", \
		"<span class='notice'>You grab [src] and stop its wild spinning.</span>")
		STOP_PROCESSING(SSfastprocess, src)
