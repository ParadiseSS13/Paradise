/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//Grey
/datum/chemical_reaction/

	slimespawn
		name = "Slime Spawn"
		id = "m_spawn"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/grey
		required_other = 1

		on_reaction(var/datum/reagents/holder)
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!"), 1)
			var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
			S.loc = get_turf(holder.my_atom)


	slimeinaprov
		name = "Slime Epinephrine"
		id = "m_epinephrine"
		result = "epinephrine"
		required_reagents = list("water" = 5)
		result_amount = 3
		required_other = 1
		required_container = /obj/item/slime_extract/grey

		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")


	slimemonkey
		name = "Slime Monkey"
		id = "m_monkey"
		result = null
		required_reagents = list("blood" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/grey
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			for(var/i = 1, i <= 3, i++)
				var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
				M.loc = get_turf(holder.my_atom)

//Green
	slimemutate
		name = "Mutation Toxin"
		id = "mutationtoxin"
		result = "mutationtoxin"
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_other = 1
		required_container = /obj/item/slime_extract/green

//Metal
	slimemetal
		name = "Slime Metal"
		id = "m_metal"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/metal
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal
			M.amount = 15
			M.loc = get_turf(holder.my_atom)
			var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
			P.amount = 5
			P.loc = get_turf(holder.my_atom)

//Gold
	slimecrit
		name = "Slime Crit"
		id = "m_tele"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/gold
		required_other = 1
		on_reaction(var/datum/reagents/holder)

			var/blocked = blocked_mobs //global variable of blocked mobs

			var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

			for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash)

			for(var/i = 1, i <= 5, i++)
				var/chosen = pick(critters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.faction |= "slimesummon"
				C.loc = get_turf(holder.my_atom)
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(C, pick(NORTH,SOUTH,EAST,WEST))
//				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
//					O.show_message(text("\red The slime core fizzles disappointingly,"), 1)


	slimecritlesser
		name = "Slime Crit Lesser"
		id = "m_tele3"
		result = null
		required_reagents = list("blood" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/gold
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently!</span>"), 1)
			spawn(50)

			if(holder && holder.my_atom)

				var/blocked = blocked_mobs

				var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

				playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
					if(M:eyecheck() <= 0)
						flick("e_flash", M.flash)

				var/chosen = pick(critters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.faction |= "neutral"
				C.loc = get_turf(holder.my_atom)

//Silver
	slimebork
		name = "Slime Bork"
		id = "m_tele2"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/silver
		required_other = 1
		on_reaction(var/datum/reagents/holder)

			var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/snacks)
			// BORK BORK BORK

			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

			for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash)

			for(var/i = 1, i <= 4 + rand(1,2), i++)
				var/chosen = pick(borks)
				var/obj/B = new chosen
				if(B)
					B.loc = get_turf(holder.my_atom)
					if(prob(50))
						for(var/j = 1, j <= rand(1, 3), j++)
							step(B, pick(NORTH,SOUTH,EAST,WEST))
	slimedrinks
		name = "Slime Drinks"
		id = "m_tele3"
		result = null
		required_reagents = list("water" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/silver
		required_other = 1
		on_reaction(var/datum/reagents/holder)

			var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/drinks)
			// BORK BORK BORK

			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

			for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash)

			for(var/i = 1, i <= 4 + rand(1,2), i++)
				var/chosen = pick(borks)
				var/obj/B = new chosen
				if(B)
					B.loc = get_turf(holder.my_atom)
					if(prob(50))
						for(var/j = 1, j <= rand(1, 3), j++)
							step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
	slimefrost
		name = "Slime Frost Oil"
		id = "m_frostoil"
		result = "frostoil"
		required_reagents = list("plasma" = 5)
		result_amount = 10
		required_container = /obj/item/slime_extract/blue
		required_other = 1
//Dark Blue
	slimefreeze
		name = "Slime Freeze"
		id = "m_freeze"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/darkblue
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
			sleep(50)
			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
				M.bodytemperature -= 140
				M << "\blue You feel a chill!"

//Orange
	slimecasp
		name = "Slime Capsaicin Oil"
		id = "m_capsaicinoil"
		result = "capsaicin"
		required_reagents = list("blood" = 5)
		result_amount = 10
		required_container = /obj/item/slime_extract/orange
		required_other = 1

	slimefire
		name = "Slime fire"
		id = "m_fire"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/orange
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
			sleep(50)
			var/turf/simulated/T = get_turf(holder.my_atom)
			if(istype(T))
				T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 50)

//Yellow
	slimeoverload
		name = "Slime EMP"
		id = "m_emp"
		result = null
		required_reagents = list("blood" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/yellow
		required_other = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			empulse(get_turf(holder.my_atom), 3, 7)


	slimecell
		name = "Slime Powercell"
		id = "m_cell"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/yellow
		required_other = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/obj/item/weapon/stock_parts/cell/slime/P = new /obj/item/weapon/stock_parts/cell/slime
			P.loc = get_turf(holder.my_atom)

	slimeglow
		name = "Slime Glow"
		id = "m_glow"
		result = null
		required_reagents = list("water" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/yellow
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red The contents of the slime core harden and begin to emit a warm, bright light."), 1)
			var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
			F.loc = get_turf(holder.my_atom)

//Purple

	slimepsteroid
		name = "Slime Steroid"
		id = "m_steroid"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/purple
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
			P.loc = get_turf(holder.my_atom)



	slimejam
		name = "Slime Jam"
		id = "m_jam"
		result = "slimejelly"
		required_reagents = list("sugar" = 5)
		result_amount = 10
		required_container = /obj/item/slime_extract/purple
		required_other = 1


//Dark Purple
	slimeplasma
		name = "Slime Plasma"
		id = "m_plasma"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/darkpurple
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
			P.amount = 10
			P.loc = get_turf(holder.my_atom)

//Red
	slimeglycerol
		name = "Slime Glycerol"
		id = "m_glycerol"
		result = "glycerol"
		required_reagents = list("plasma" = 5)
		result_amount = 8
		required_container = /obj/item/slime_extract/red
		required_other = 1


	slimebloodlust
		name = "Bloodlust"
		id = "m_bloodlust"
		result = null
		required_reagents = list("blood" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/red
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
				slime.rabid = 1
				for(var/mob/O in viewers(get_turf(holder.my_atom), null))
					O.show_message(text("\red The [slime] is driven into a frenzy!."), 1)

//Pink
	slimeppotion
		name = "Slime Potion"
		id = "m_potion"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/pink
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
			P.loc = get_turf(holder.my_atom)


//Black
	slimemutate2
		name = "Advanced Mutation Toxin"
		id = "mutationtoxin2"
		result = "amutationtoxin"
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_other = 1
		required_container = /obj/item/slime_extract/black

//Oil
	slimeexplosion
		name = "Slime Explosion"
		id = "m_explosion"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/oil
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
			sleep(50)
			explosion(get_turf(holder.my_atom), 1 ,3, 6)
//Light Pink
	slimepotion2
		name = "Slime Potion 2"
		id = "m_potion2"
		result = null
		result_amount = 1
		required_container = /obj/item/slime_extract/lightpink
		required_reagents = list("plasma" = 5)
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
			P.loc = get_turf(holder.my_atom)
//Adamantine
	slimegolem
		name = "Slime Golem"
		id = "m_golem"
		result = null
		required_reagents = list("plasma" = 5)
		result_amount = 1
		required_container = /obj/item/slime_extract/adamantine
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			var/obj/effect/goleRUNe/Z = new /obj/effect/goleRUNe
			Z.loc = get_turf(holder.my_atom)
			Z.announce_to_ghosts()
//Bluespace
	slimecrystal
		name = "Slime Crystal"
		id = "m_crystal"
		result = null
		required_reagents = list("blood" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/bluespace
		required_other = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			if(holder.my_atom)
				var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
				BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")
//Cerulean
	slimepsteroid2
		name = "Slime Steroid 2"
		id = "m_steroid2"
		result = null
		required_reagents = list("plasma" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/cerulean
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
			P.loc = get_turf(holder.my_atom)
//Sepia
	slimecamera
		name = "Slime Camera"
		id = "m_camera"
		result = null
		required_reagents = list("plasma" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/sepia
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			var/obj/item/device/camera/P = new /obj/item/device/camera
			P.loc = get_turf(holder.my_atom)


	slimefilm
		name = "Slime Film"
		id = "m_film"
		result = null
		required_reagents = list("blood" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/sepia
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
			P.loc = get_turf(holder.my_atom)
//Pyrite
	slimepaint
		name = "Slime Paint"
		id = "s_paint"
		result = null
		required_reagents = list("plasma" = 1)
		result_amount = 1
		required_container = /obj/item/slime_extract/pyrite
		required_other = 1
		on_reaction(var/datum/reagents/holder)
			feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
			var/list/paints = subtypesof(/obj/item/weapon/reagent_containers/glass/paint)
			var/chosen = pick(paints)
			var/obj/P = new chosen
			if(P)
				P.loc = get_turf(holder.my_atom)