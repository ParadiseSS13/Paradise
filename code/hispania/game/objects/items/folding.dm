/obj/item/kitchen/knife/folding
	name = "pocketknife"
	desc = "A small folding knife."
	icon = 'icons/hispania/obj/folding_knife.dmi'
	icon_state = "knife_preview"
	item_state = null
	w_class = WEIGHT_CLASS_TINY
	force = 0.2 //force of folded obj
	throwforce = 2
	attack_verb = list("prodded", "tapped")
	hitsound = "swing_hit"
	materials = list(MAT_METAL=12000)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	sharp = FALSE

	var/throwfoldedforce = 12
	var/foldedforce = 12
	var/open = FALSE
	var/takes_colour = TRUE
	var/hardware_closed = "basic_hardware_closed"
	var/hardware_open = "basic_hardware"
	var/handle_icon = "basic_handle"

	var/unique_reskin = TRUE //allows one-time reskinning
	var/reskin_used = FALSE
	var/list/options = list()

	var/closed_attack_verbs = list("prodded", "tapped") //initial doesnt work with lists, rip
	var/valid_colors = list(COLOR_DARK_GRAY, COLOR_RED_GRAY, COLOR_BLUE_GRAY, COLOR_DARK_BLUE_GRAY, COLOR_GREEN_GRAY, COLOR_DARK_GREEN_GRAY, COLOR_WHITE)

/obj/item/kitchen/knife/folding/Initialize()
	icon_state = handle_icon
	color = pick(valid_colors)
	update_icon()
	. = ..()

/obj/item/kitchen/knife/folding/attack_self(mob/user)
	open = !open
	update_force()
	update_icon()
	if(open)
		user.visible_message("<span class='warning'>\The [user] opens \the [src].</span>")
		playsound(user, 'sound/weapons/knife_click.ogg', 75, 1)
	else
		user.visible_message("<span class='notice'>\The [user] closes \the [src].</span>")
	add_fingerprint(user)

/obj/item/kitchen/knife/folding/proc/update_force()
	if(open)
		sharp = TRUE
		force = (foldedforce)
		throwforce = (throwfoldedforce)
		hitsound = 'sound/weapons/bladeslice.ogg'
		w_class = WEIGHT_CLASS_NORMAL
		attack_verb = list("slashed", "stabbed")
	else
		throwforce = initial(throwforce)
		force = initial(force)
		sharp = initial(sharp)
		hitsound = initial(hitsound)
		w_class = initial(w_class)
		attack_verb = closed_attack_verbs

/obj/item/kitchen/knife/folding/update_icon()
	if(open)
		overlays.Cut()
		overlays += overlay_image(icon, hardware_open, flags=RESET_COLOR)
		item_state = "knife"
	else
		overlays.Cut()
		overlays += overlay_image(icon, hardware_closed, flags=RESET_COLOR)
		item_state = initial(item_state)

/obj/item/kitchen/knife/folding/attackby(obj/item/O, mob/M)
	..()
	if(istype(O, /obj/item/toy/crayon/spraycan))
		if(unique_reskin && !reskin_used)
			reskin_foldingknife(M)
		else
			to_chat(M, "<span class='warning'>There's already dry paint on the folding knife, You can't re-skin it anymore!")

/obj/item/kitchen/knife/folding/proc/reskin_foldingknife(mob/M)
	var/choice = input(M,"Warning, you can only re-skin your folding knife once!","Reskin Folding Knife") in options

	if(src && choice && !reskin_used && !M.incapacitated() && in_range(M,src))
		if(options[choice] == null)
			return
		color = options[choice]
		to_chat(M, "Your folding knife is now skinned as [choice]. Say hello to your new friend.")
		reskin_used = TRUE
		update_icon()

//Subtypes
/obj/item/kitchen/knife/folding/wood
	name = "peasant knife"
	desc = "A small folding knife with a wooden handle and carbon steel blade. Knives like this have been used on Earth for centuries."
	hardware_closed = "peasant_hardware_closed"
	hardware_open = "peasant_hardware"
	handle_icon = "peasant_handle"
	valid_colors = list(COLOR_BRASS, COLOR_DARK_BROWN, COLOR_REAL_DARK_BROWN, COLOR_RED)

/obj/item/kitchen/knife/folding/wood/New()
	..()
	options["Brass"] = color = COLOR_BRASS
	options["Deep Wood"] = color = COLOR_REAL_DARK_BROWN
	options["Wood"] = color = COLOR_BROWN
	options["Red Wood"] = color = COLOR_RED
	options["Cancel"] = null

/obj/item/kitchen/knife/folding/normal
	name = "folding knife"
	desc = "A small folding knife with a polymer handle and a carbon steel blade. Knives like this have been used on Earth for centuries."
	hardware_closed = "basic_hardware_closed"
	hardware_open = "basic_hardware"
	handle_icon = "basic_handle"
	valid_colors = list("#0f0f2a", "#2a0f0f", "#0f2a0f", COLOR_GRAY20, COLOR_DARK_GUNMETAL, COLOR_WHITE)

/obj/item/kitchen/knife/folding/normal/New()
	..()
	options["Blue Gray"] = color = "#0f0f2a"
	options["Red Gray"] = color = "#2a0f0f"
	options["Green Gray"] = color = "#0f2a0f"
	options["Dark Metal"] = color = COLOR_GRAY20
	options["Gray"] = color = COLOR_DARK_GUNMETAL
	options["Lighter Gray"] = color = COLOR_WHITE
	options["Cancel"] = null

/obj/item/kitchen/knife/folding/combat
	name = "tactical folding knife"
	desc = "A small folding knife with a polymer handle and a blackened steel blade. A military combat utility survival knife."
	hardware_closed = "tacticool_hardware_closed"
	hardware_open = "tacticool_hardware"
	handle_icon = "tacticool_handle"
	foldedforce = 18
	throwfoldedforce = 18
	valid_colors = list("#0f0f2a", "#2a0f0f", "#0f2a0f", COLOR_GRAY20, COLOR_DARK_GUNMETAL, COLOR_WHITE)
	origin_tech = "materials=3;combat=4"

/obj/item/kitchen/knife/folding/combat/New()
	..()
	options["Blue Gray"] = color = "#0f0f2a"
	options["Red Gray"] = color = "#2a0f0f"
	options["Green Gray"] = color = "#0f2a0f"
	options["Dark Metal"] = color = COLOR_GRAY20
	options["Gray"] = color = COLOR_DARK_GUNMETAL
	options["Lighter Gray"] = color = COLOR_WHITE
	options["Cancel"] = null

/obj/item/kitchen/knife/folding/butterfly
	name = "butterfly knife"
	desc = "A basic metal blade concealed in a lightweight plasteel grip. Small enough when folded to fit in a pocket."
	hardware_closed = "bfly_hardware_closed"
	hardware_open = "bfly_hardware"
	handle_icon = "bfly_handle"
	valid_colors = list(COLOR_DARK_GRAY, COLOR_RED_GRAY, COLOR_BLUE_GRAY,COLOR_DARK_BLUE_GRAY,COLOR_GREEN_GRAY,COLOR_DARK_GREEN_GRAY,COLOR_WHITE)

/obj/item/kitchen/knife/folding/butterfly/New()
	..()
	options["Dark Metal"] = color = COLOR_DARK_GRAY
	options["Red Gray"] = color = COLOR_RED_GRAY
	options["Blue Gray"] = color = COLOR_BLUE_GRAY
	options["Darker Blue Gray"] = color = COLOR_DARK_BLUE_GRAY
	options["Green Gray"] = color = COLOR_GREEN_GRAY
	options["Darker Green Gray"] = color = COLOR_DARK_GREEN_GRAY
	options["Lighter Gray"] = color = COLOR_WHITE
	options["Cancel"] = null

/obj/item/kitchen/knife/folding/combat/gangsta
	name = "gangsta switchblade"
	desc = "A classic switchblade with gold engraving. Just holding it makes you feel like a gangster."
	hardware_closed = "switch_hardware_closed"
	hardware_open = "switch_hardware"
	handle_icon = "switch_handle"
	foldedforce = 20
	throwfoldedforce = 20
	valid_colors = list(COLOR_WHITE, COLOR_GOLD, COLOR_GRAY20)

/obj/item/kitchen/knife/folding/combat/gangsta/New()
	..()
	options["White Snowflake"] = color = COLOR_WHITE
	options["Golden Iron"] = color = COLOR_GOLD
	options["Blackout"] = color = COLOR_GRAY20
	options["Cancel"] = null

/obj/item/kitchen/knife/folding/proc/overlay_image(icon,icon_state,color,flags)
	var/image/ret = image(icon,icon_state)
	ret.color = color
	ret.appearance_flags = flags
	return ret
