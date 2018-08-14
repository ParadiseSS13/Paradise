/mob/living/simple_animal/pony
	name = "\improper pony"
	desc = "A bound spirit"
	icon = 'icons/mob/pony.dmi'
//	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("whinnys")
	emote_hear = list("excitedly says")
	response_help  = "pets"
	response_disarm = "pushes"
	response_harm   = "kicks"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "sends rainbows of power to"
	minbodytemp = 0
	maxbodytemp = 4000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = 0
	stop_automated_movement = 0
	status_flags = 0
	faction = list("pony")
	status_flags = CANPUSH
	universal_speak = 1

/mob/living/simple_animal/pony/Life()
	..()
	if(stat == 2)
		new /obj/item/reagent_containers/food/snacks/ectoplasm(src.loc)
		src.visible_message("<span class='warning'>[src] lets out a contented sigh as [p_their()] form unwinds.</span>")
		src.ghostize()
		qdel(src)
		return

/mob/living/simple_animal/pony/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		..()

/mob/living/simple_animal/pony/twilight
	name = "Twilight Sparkle"
	real_name = "Twilight Sparkle"
	icon_state = "twilight"
	icon_living = "twilight"

/mob/living/simple_animal/pony/pinkie
	name = "Pinkie Pie"
	real_name = "Pinkie Pie"
	icon_state = "pinkie"
	icon_living = "pinkie"

/mob/living/simple_animal/pony/rainbow
	name = "Rainbow Dash"
	real_name = "Rainbow Dash"
	icon_state = "rainbow"
	icon_living = "rainbow"

mob/living/simple_animal/pony/fluttershy
	name = "Fluttershy"
	real_name = "Fluttershy"
	icon_state = "fluttershy"
	icon_living = "fluttershy"

mob/living/simple_animal/pony/applejack
	name = "Applejack"
	real_name = "Applejack"
	icon_state = "applejack"
	icon_living = "applejack"

mob/living/simple_animal/pony/luna
	name = "Luna"
	real_name = "Luna"
	icon_state = "luna"
	icon_living = "luna"

mob/living/simple_animal/pony/clownie
	name = "Clownie"
	real_name = "Clownie"
	icon_state = "clownie"
	icon_living = "clownie"

mob/living/simple_animal/pony/tia
	name = "Tia"
	real_name = "Tia"
	icon_state = "tia"
	icon_living = "tia"

mob/living/simple_animal/pony/trixie
	name = "Trixie"
	real_name = "Trixie"
	icon_state = "trixie_a_full"
	icon_living = "trixing_a_full"

mob/living/simple_animal/pony/lyra
	name = "Lyra"
	real_name = "Lyra"
	icon_state = "lyra"
	icon_living = "lyra"

mob/living/simple_animal/pony/vinyl
	name = "Vinyl"
	real_name = "Vinyl"
	icon_state = "vinyl"
	icon_living = "vinyl"

mob/living/simple_animal/pony/rarity
	name = "Rarity"
	real_name = "Rarity"
	icon_state = "rarity"
	icon_living = "rarity"

mob/living/simple_animal/pony/whooves
	name = "Whooves"
	real_name = "Whooves"
	icon_state = "whooves"
	icon_living = "whooves"

mob/living/simple_animal/pony/fleur
	name = "Fleur"
	real_name = "Fleur"
	icon_state = "fleur"
	icon_living = "fleur"

mob/living/simple_animal/pony/mac
	name = "Mac"
	real_name = "Mac"
	icon_state = "mac"
	icon_living = "mac"