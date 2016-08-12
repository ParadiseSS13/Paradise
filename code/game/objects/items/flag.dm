/obj/item/flag
	icon = 'icons/obj/flag.dmi'
	w_class = 4
	burntime = 20
	burn_state = FLAMMABLE

/obj/item/flag/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(is_hot(W) && burn_state != ON_FIRE)
		user.visible_message("<span class='notice'>[user] lights the [name] with [W].</span>")
		fire_act()

/obj/item/flag/proc/update_icons()
	overlays = null
	overlays += image('icons/obj/flag.dmi', src , "fire")
	item_state = "[icon_state]_fire"

/obj/item/flag/nt
	name = "Nanotrasen flag"
	desc = "A flag proudly boasting the logo of NT."
	icon_state = "ntflag"

/obj/item/flag/clown
	name = "Clown Planet flag"
	desc = "The banner of His Majesty, King Squiggles the Eighth."
	icon_state = "clownflag"

/obj/item/flag/mime
	name = "Mime Revolution flag"
	desc = "The banner of the glorious revolutionary forces fighting the oppressors on Clown Planet."
	icon_state = "mimeflag"

/obj/item/flag/pony
	name = "Equestria flag"
	desc = "The flag of the independent, sovereign nation of Equestria, whatever the fuck that is."
	icon_state = "ponyflag"

/obj/item/flag/ian
	name = "Ian flag"
	desc = "The banner of Ian, because SQUEEEEE."
	icon_state = "ianflag"


//Species flags

/obj/item/flag/species/slime
	name = "Slime People flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	icon_state = "slimeflag"

/obj/item/flag/species/skrell
	name = "Skrell flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	icon_state = "skrellflag"

/obj/item/flag/species/vox
	name = "Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	icon_state = "voxflag"

/obj/item/flag/species/machine
	name = "Synthetics flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	icon_state = "machineflag"

/obj/item/flag/species/diona
	name = "Diona flag"
	desc = "A flag proudly proclaiming the superior heritage of Dionae."
	icon_state = "dionaflag"

/obj/item/flag/species/human
	name = "Human flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	icon_state = "humanflag"

/obj/item/flag/species/greys
	name = "Greys flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	icon_state = "greysflag"

/obj/item/flag/species/kidan
	name = "Kidan flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	icon_state = "kidanflag"

/obj/item/flag/species/taj
	name = "Tajaran flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajaran."
	icon_state = "tajflag"

/obj/item/flag/species/unathi
	name = "Unathi flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	icon_state = "unathiflag"

/obj/item/flag/species/vulp
	name = "Vulpkanin flag"
	desc = "A flag proudly proclaiming the superior heritage of Vulpkanin."
	icon_state = "vulpflag"

/obj/item/flag/species/drask
	name = "Drask flag"
	desc = "A flag proudly proclaiming the superior heritage of Drask."
	icon_state = "draskflag"

//Department Flags

/obj/item/flag/cargo
	name = "Cargonia flag"
	desc = "The flag of the independent, sovereign nation of Cargonia."
	icon_state = "cargoflag"

/obj/item/flag/med
	name = "Medistan flag"
	desc = "The flag of the independent, sovereign nation of Medistan."
	icon_state = "medflag"

/obj/item/flag/sec
	name = "Brigston flag"
	desc = "The flag of the independent, sovereign nation of Brigston."
	icon_state = "secflag"

/obj/item/flag/rnd
	name = "Scientopia flag"
	desc = "The flag of the independent, sovereign nation of Scientopia."
	icon_state = "rndflag"

/obj/item/flag/atmos
	name = "Atmosia flag"
	desc = "The flag of the independent, sovereign nation of Atmosia."
	icon_state = "atmosflag"

/obj/item/flag/command
	name = "Commandzikstan flag"
	desc = "The flag of the independent, sovereign nation of Commandzikstan."
	icon_state = "ntflag"

//Antags

/obj/item/flag/grey
	name = "Greytide flag"
	desc = "A banner made from an old grey jumpsuit."
	icon_state = "greyflag"

/obj/item/flag/syndi
	name = "Syndicate flag"
	desc = "A flag proudly boasting the logo of the Syndicate, in defiance of NT."
	icon_state = "syndiflag"

/obj/item/flag/wiz
	name = "Wizard Federation flag"
	desc = "A flag proudly boasting the logo of the Wizard Federation, sworn enemies of NT."
	icon_state = "wizflag"

/obj/item/flag/cult
	name = "Nar'Sie Cultist flag"
	desc = "A flag proudly boasting the logo of the cultists, sworn enemies of NT."
	icon_state = "cultflag"
	
//Chameleon

/obj/item/flag/chameleon
	name = "Chameleon flag"
	desc = "A poor recreation of the official NT flag. It seems to shimmer a little."
	icon_state = "ntflag"
	origin_tech = "materials=3;magnets=4;syndicate=4"
	var/used = 0
	
/obj/item/flag/chameleon/attack_self(mob/user)
	if(used)
		return

	var/list/flag_types = typesof(/obj/item/flag) - list(src.type, /obj/item/flag)
	var/list/flag = list()

	for(var/flag_type in flag_types)
		var/obj/item/flag/F = new flag_type
		flag[capitalize(F.name)] = F

	var/list/show_flag = list("EXIT" = null) + sortList(flag)

	var/input_flag = input(user, "Choose a flag to disguise as.", "Choose a flag.") in show_flag

	if(user && src in user.contents)

		var/obj/item/flag/chosen_flag = flag[input_flag]

		if(chosen_flag)
			name = chosen_flag.name
			icon_state = chosen_flag.icon_state
			desc = chosen_flag.desc
			used = 1
			
/obj/item/flag/chameleon/burn()
	explosion(loc,1,2,4,4, flame_range = 4)
	qdel(src)