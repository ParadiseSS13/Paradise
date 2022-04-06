/obj/item/flag
	name = "flag"
	desc = "It's a flag."
	icon = 'icons/obj/flag.dmi'
	icon_state = "ntflag"
	lefthand_file = 'icons/mob/inhands/flags_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/flags_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	var/rolled = FALSE

/obj/item/flag/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(is_hot(W) && !(resistance_flags & ON_FIRE))
		user.visible_message("<span class='notice'>[user] lights [src] with [W].</span>", "<span class='notice'>You light [src] with [W].</span>", "<span class='warning'>You hear a low whoosh.</span>")
		fire_act()

/obj/item/flag/attack_self(mob/user)
	rolled = !rolled
	user.visible_message("<span class='notice'>[user] [rolled ? "rolls up" : "unfurls"] [src].</span>", "<span class='notice'>You [rolled ? "roll up" : "unfurl"] [src].</span>", "<span class='warning'>You hear fabric rustling.</span>")
	update_icon()

/obj/item/flag/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = FALSE)
	..()
	update_icon()

/obj/item/flag/extinguish()
	..()
	update_icon()

/obj/item/flag/update_icon()
	overlays.Cut()
	updateFlagIcon()
	item_state = icon_state
	if(rolled)
		icon_state = "[icon_state]_rolled"
	if(resistance_flags & ON_FIRE)
		item_state = "[item_state]_fire"
	if((resistance_flags & ON_FIRE) && rolled)
		overlays += image('icons/obj/flag.dmi', src , "fire_rolled")
	else if((resistance_flags & ON_FIRE) && !rolled)
		overlays += image('icons/obj/flag.dmi', src , "fire")
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/flag/proc/updateFlagIcon()
	icon_state = initial(icon_state)

/obj/item/flag/nt
	name = "\improper Nanotrasen flag"
	desc = "A flag proudly boasting the logo of NT."
	icon_state = "ntflag"

/obj/item/flag/clown
	name = "\improper Clown Planet flag"
	desc = "The banner of His Majesty, King Squiggles the Eighth."
	icon_state = "clownflag"

/obj/item/flag/mime
	name = "\improper Mime Revolution flag"
	desc = "The banner of the glorious revolutionary forces fighting the oppressors on Clown Planet."
	icon_state = "mimeflag"

/obj/item/flag/ian
	name = "\improper Ian flag"
	desc = "The banner of Ian, because SQUEEEEE."
	icon_state = "ianflag"


//Species flags

/obj/item/flag/species/slime
	name = "\improper Slime People flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	icon_state = "slimeflag"

/obj/item/flag/species/skrell
	name = "\improper Skrell flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	icon_state = "skrellflag"

/obj/item/flag/species/vox
	name = "\improper Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	icon_state = "voxflag"

/obj/item/flag/species/machine
	name = "\improper Synthetics flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	icon_state = "machineflag"

/obj/item/flag/species/diona
	name = "\improper Diona flag"
	desc = "A flag proudly proclaiming the superior heritage of Dionae."
	icon_state = "dionaflag"

/obj/item/flag/species/human
	name = "\improper Human flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	icon_state = "humanflag"

/obj/item/flag/species/greys
	name = "\improper Greys flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	icon_state = "greysflag"

/obj/item/flag/species/kidan
	name = "\improper Kidan flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	icon_state = "kidanflag"

/obj/item/flag/species/taj
	name = "\improper Tajaran flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajaran."
	icon_state = "tajflag"

/obj/item/flag/species/unathi
	name = "\improper Unathi flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	icon_state = "unathiflag"

/obj/item/flag/species/vulp
	name = "\improper Vulpkanin flag"
	desc = "A flag proudly proclaiming the superior heritage of Vulpkanin."
	icon_state = "vulpflag"

/obj/item/flag/species/drask
	name = "\improper Drask flag"
	desc = "A flag proudly proclaiming the superior heritage of Drask."
	icon_state = "draskflag"

/obj/item/flag/species/plasma
	name = "\improper Plasmaman flag"
	desc = "A flag proudly proclaiming the superior heritage of Plasmamen."
	icon_state = "plasmaflag"

//Department Flags

/obj/item/flag/cargo
	name = "\improper Cargonia flag"
	desc = "The flag of the independent, sovereign nation of Cargonia."
	icon_state = "cargoflag"

/obj/item/flag/med
	name = "\improper Medistan flag"
	desc = "The flag of the independent, sovereign nation of Medistan."
	icon_state = "medflag"

/obj/item/flag/sec
	name = "\improper Brigston flag"
	desc = "The flag of the independent, sovereign nation of Brigston."
	icon_state = "secflag"

/obj/item/flag/rnd
	name = "\improper Scientopia flag"
	desc = "The flag of the independent, sovereign nation of Scientopia."
	icon_state = "rndflag"

/obj/item/flag/atmos
	name = "\improper Atmosia flag"
	desc = "The flag of the independent, sovereign nation of Atmosia."
	icon_state = "atmosflag"

/obj/item/flag/command
	name = "\improper Command flag"
	desc = "The flag of the independent, sovereign nation of Command."
	icon_state = "ntflag"

//Antags

/obj/item/flag/grey
	name = "\improper Greytide flag"
	desc = "A banner made from an old grey jumpsuit."
	icon_state = "greyflag"

/obj/item/flag/syndi
	name = "\improper Syndicate flag"
	desc = "A flag proudly boasting the logo of the Syndicate, in defiance of NT."
	icon_state = "syndiflag"

/obj/item/flag/wiz
	name = "\improper Wizard Federation flag"
	desc = "A flag proudly boasting the logo of the Wizard Federation, sworn enemies of NT."
	icon_state = "wizflag"

/obj/item/flag/cult
	name = "\improper Nar'Sie Cultist flag"
	desc = "A flag proudly boasting the logo of the cultists, sworn enemies of NT."
	icon_state = "cultflag"

//Chameleon

/obj/item/flag/chameleon
	name = "chameleon flag"
	desc = "A poor recreation of the official NT flag. It seems to shimmer a little."
	icon_state = "ntflag"
	origin_tech = "syndicate=1;magnets=4"
	var/updated_icon_state = null
	var/used = FALSE
	var/obj/item/grenade/boobytrap = null
	var/mob/trapper = null

/obj/item/flag/chameleon/New()
	updated_icon_state = icon_state
	..()

/obj/item/flag/chameleon/attack_self(mob/user)
	if(used)
		return ..()

	var/list/flag_types = typesof(/obj/item/flag) - list(/obj/item/flag, /obj/item/flag/chameleon, /obj/item/flag/chameleon/depot)
	var/list/flag = list()

	for(var/flag_type in flag_types)
		var/obj/item/flag/F = new flag_type
		flag[capitalize(F.name)] = F

	var/list/show_flag = list("EXIT" = null) + sortList(flag)

	var/input_flag = input(user, "Choose a flag to disguise as.", "Choose a flag.") in show_flag

	if(user && (src in user.contents))

		var/obj/item/flag/chosen_flag = flag[input_flag]

		if(chosen_flag && !used)
			name = chosen_flag.name
			icon_state = chosen_flag.icon_state
			updated_icon_state = icon_state
			desc = chosen_flag.desc
			used = TRUE

/obj/item/flag/chameleon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grenade) && !boobytrap)
		if(user.drop_item())
			boobytrap = I
			trapper = user
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You hide [I] in [src]. It will detonate some time after the flag is lit on fire.</span>")
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			log_game("[key_name(user)] has hidden [I] in [src] ready for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
			investigate_log("[key_name(user)] has hidden [I] in [src] ready for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).", INVESTIGATE_BOMB)
			add_attack_logs(user, src, "has hidden [I] ready for detonation in", ATKLOG_MOST)
	else if(is_hot(I) && !(resistance_flags & ON_FIRE) && boobytrap && trapper)
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		log_game("[key_name_admin(user)] has lit [src] trapped with [boobytrap] by [key_name_admin(trapper)] at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
		investigate_log("[key_name_admin(user)] has lit [src] trapped with [boobytrap] by [key_name_admin(trapper)] at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has lit (booby trapped with [boobytrap]", ATKLOG_FEW)
		burn()
	else
		return ..()

/obj/item/flag/chameleon/screwdriver_act(mob/user, obj/item/I)
	if(!boobytrap || user != trapper)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove [boobytrap] from [src].</span>")
	boobytrap.forceMove(get_turf(src))
	boobytrap = null
	trapper = null

/obj/item/flag/chameleon/burn()
	if(boobytrap)
		fire_act()
		addtimer(CALLBACK(src, .proc/prime_boobytrap), boobytrap.det_time)
	else
		..()

/obj/item/flag/chameleon/proc/prime_boobytrap()
	boobytrap.forceMove(get_turf(loc))
	boobytrap.prime()
	boobytrap = null
	burn()

/obj/item/flag/chameleon/updateFlagIcon()
	icon_state = updated_icon_state

/obj/item/flag/chameleon/depot/New()
	..()
	boobytrap = new /obj/item/grenade/gas/plasma(src)
