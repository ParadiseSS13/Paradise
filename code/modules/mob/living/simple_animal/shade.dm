/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches the"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = list("cult")
	status_flags = CANPUSH
	loot = list(/obj/item/reagent_containers/food/snacks/ectoplasm)
	del_on_death = 1
	deathmessage = "lets out a contented sigh as their form unwinds."


/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		if(O.force)
			var/damage = O.force
			if(O.damtype == STAMINA)
				damage = 0
			health -= damage
			user.visible_message("<span class='boldwarning'>[src] has been attacked with the [O] by [user]. </span>")
		else
			user.visible_message("<span class='warning'>[user] gently taps [src] with the [O]. </span>", "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
	return

/mob/living/simple_animal/shade/sword
	universal_speak = 1
	faction = list("neutral")
