/obj/item/flag
	name = "flag"
	desc = "It's a flag."
	icon = 'icons/obj/flag.dmi'
	icon_state = "ntflag"
	lefthand_file = 'icons/mob/inhands/flags_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/flags_righthand.dmi'
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	custom_fire_overlay = "fire"
	var/rolled = FALSE

/obj/item/flag/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	. = ..()
	if(W.get_heat() && !(resistance_flags & ON_FIRE))
		user.visible_message("<span class='notice'>[user] lights [src] with [W].</span>", "<span class='notice'>You light [src] with [W].</span>", "<span class='warning'>You hear a low whoosh.</span>")
		fire_act()

/obj/item/flag/attack_self__legacy__attackchain(mob/user)
	rolled = !rolled
	user.visible_message("<span class='notice'>[user] [rolled ? "rolls up" : "unfurls"] [src].</span>", "<span class='notice'>You [rolled ? "roll up" : "unfurl"] [src].</span>", "<span class='warning'>You hear fabric rustling.</span>")
	update_icon()

/obj/item/flag/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = FALSE)
	..()
	update_icon()

/obj/item/flag/extinguish()
	..()
	update_icon()

/obj/item/flag/update_icon_state()
	icon_state = "[get_flag_icon()][rolled ? "_rolled" : ""]"
	inhand_icon_state = "[get_flag_icon()][resistance_flags & ON_FIRE ? "_fire" : ""]"
	custom_fire_overlay = "[initial(custom_fire_overlay)][rolled ? "_rolled" : ""]"
	if(ismob(loc))
		var/mob/mob = loc
		mob.update_inv_r_hand()
		mob.update_inv_l_hand()

/obj/item/flag/proc/get_flag_icon()
	return initial(icon_state)

/obj/item/flag/nt
	name = "\improper Nanotrasen flag"
	desc = "A flag proudly boasting the logo of NT."

/obj/item/flag/clown
	name = "\improper Clown Unity flag"
	desc = "The universal banner of clowns everywhere. It smells faintly of bananas."
	icon_state = "clownflag"

/obj/item/flag/mime
	name = "\improper Mime Unity flag"
	desc = "The standard by which all mimes march to war, as cold as ice and silent as the grave."
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

/obj/item/flag/species/nian
	name ="\improper Nian flag"
	desc = "An eccentric handmade standard, luxuriously soft due to exotic silks and embossed with lustrous gold. Although inspired by the pride that Nianae take in their baubles, it ultimately feels melancholic. Beauty knows no pain, afterall."
	icon_state = "nianflag"

//Department Flags

/obj/item/flag/cargo
	name = "\improper Cargonia flag"
	desc = "The flag of the independent, sovereign nation of Cargonia. Merely glimpsing this majestic banner fills you with the urge to buy enough guns to equip a small army."
	icon_state = "cargoflag"

/obj/item/flag/med
	name = "\improper Medistan flag"
	desc = "The flag of the independent, sovereign nation of Medistan. Looking at this beautiful white and green banner fills you with a powerful compulsion to file malpractice lawsuits."
	icon_state = "medflag"

/obj/item/flag/sec
	name = "\improper Brigston flag"
	desc = "The flag of the independent, sovereign nation of Brigston. The red of the flag represents blood shed in defense of the station, the amount of which varies heavily between shifts."
	icon_state = "secflag"

/obj/item/flag/rnd
	name = "\improper Scientopia flag"
	desc = "The flag of the independent, sovereign nation of Scientopia. Looking at this laminated beauty of a flag fills you with an irresstible urge to perform SCIENCE!."
	icon_state = "rndflag"

/obj/item/flag/atmos
	name = "\improper Atmosia flag"
	desc = "The flag of the independent, sovereign nation of Atmosia. This flag has survived dozens of plasmafires, and will endure more, if Atmosia has any say in things."
	icon_state = "atmosflag"

/obj/item/flag/command
	name = "\improper Command flag"
	desc = "The flag of the independent, sovereign nation of Command. Apparently the budget was all spent on this flag, rather than a creative name."

//Antags

/obj/item/flag/grey
	name = "\improper Greytide flag"
	desc = "A banner made from an old grey jumpsuit."
	icon_state = "greyflag"

/obj/item/flag/syndi
	name = "\improper Syndicate flag"
	desc = "A flag proudly boasting the crimson and black colors of the Syndicate, the largest organized criminal entity in the Sector."
	icon_state = "syndiflag"

/obj/item/flag/wiz
	name = "\improper Wizard Federation flag"
	desc = "A flag proudly boasting the logo of the Wizard Federation, a loose collection of magical terrorist cells."
	icon_state = "wizflag"

/obj/item/flag/cult
	name = "\improper Nar'Sie Cultist flag"
	desc = "A flag proudly boasting the unholy symbols of the Cult of Nar'sie. Merely possessing this flag is illegal in many polities."
	icon_state = "cultflag"

/obj/item/flag/ussp
	name = "\improper USSP flag"
	desc = "A flag proudly flying the hammer & sickle of the USSP, a powerful socialist nation in the Sector's North."
	icon_state = "usspflag"

/obj/item/flag/solgov
	name = "\improper Trans-Solar Federation flag"
	desc = "A flag proudly flying the golden sun of the Trans-Solar Federation, the militaristic de-facto superpower of the sector, based on Earth."
	icon_state = "solgovflag"

//Chameleon

/obj/item/flag/chameleon
	name = "chameleon flag"
	desc = "A poor recreation of the official NT flag. It seems to shimmer a little."
	origin_tech = "syndicate=1;magnets=4"
	var/updated_icon_state = null
	var/used = FALSE
	var/obj/item/grenade/boobytrap = null
	var/mob/trapper = null

/obj/item/flag/chameleon/New()
	updated_icon_state = icon_state
	..()

/obj/item/flag/chameleon/attack_self__legacy__attackchain(mob/user)
	if(used)
		return ..()

	var/list/flag_types = typesof(/obj/item/flag) - list(/obj/item/flag, /obj/item/flag/chameleon, /obj/item/flag/chameleon/depot)
	var/list/flag = list()

	for(var/flag_type in flag_types)
		var/obj/item/flag/F = new flag_type
		flag[capitalize(F.name)] = F

	var/list/show_flag = list("EXIT" = null) + sortList(flag)

	var/input_flag = tgui_input_list(user, "Choose a flag to disguise this as.", "Choose a flag.", show_flag)
	if(!input_flag)
		return

	if(user && (src in user.GetAllContents()))
		var/obj/item/flag/chosen_flag = flag[input_flag]

		if(chosen_flag && !used)
			name = chosen_flag.name
			icon_state = chosen_flag.icon_state
			updated_icon_state = icon_state
			desc = chosen_flag.desc
			used = TRUE

/obj/item/flag/chameleon/attackby__legacy__attackchain(obj/item/I, mob/user, params)
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
	else if(I.get_heat() && !(resistance_flags & ON_FIRE) && boobytrap && trapper)
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
		addtimer(CALLBACK(src, PROC_REF(prime_boobytrap)), boobytrap.det_time)
	else
		..()

/obj/item/flag/chameleon/proc/prime_boobytrap()
	boobytrap.forceMove(get_turf(loc))
	boobytrap.prime()
	boobytrap = null
	burn()

/obj/item/flag/chameleon/get_flag_icon()
	return updated_icon_state

/obj/item/flag/chameleon/depot/New()
	..()
	boobytrap = new /obj/item/grenade/gas/plasma(src)
