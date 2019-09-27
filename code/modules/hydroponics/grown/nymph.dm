/obj/item/seeds/nymph
	name = "pack of diona nymph seeds"
	desc = "These seeds grow into diona nymphs."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Nymph Pod"
	product = /obj/item/reagent_containers/food/snacks/grown/nymph_pod
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1
	reagents_add = list("plantmatter" = 0.1)
	var/twitched = FALSE //Allows ghosts to cause this seed packet to twitch, on a 10 second cooldown.

// If the nymph pods are fully grown, allow ghosts that click on them to spawn as a nymph (decreases yield by 1 and kills the plant when yield reaches 0)
/obj/item/seeds/nymph/attack_ghost(mob/dead/observer/O)
	if(!planted_tray)
		if(!twitched)
			visible_message("[src] twitches slightly, as if pushed by a gentle breeze.")
			twitched = TRUE
			spawn(100)
				twitched = FALSE
		return
	if(!planted_tray.harvest) 
		to_chat(O, "[src] is not yet ready.")
		return
	if(planted_tray.dead)
		to_chat(O, "[src] is dead!")
		return
	if(!(O in GLOB.respawnable_list))
		to_chat(O, "You are not permitted to rejoin the round.")
		return
	else if(cannotPossess(O))
		to_chat(O, "You have enabled antag HUD and are unable to re-enter the round.")
		return
	var/nymph_ask = alert("Become a Diona Nymph? You will not be able to be cloned!", "Diona Nymph Pod", "Yes", "No")
	if(nymph_ask == "No" || !src || QDELETED(src))
		return
	if(planted_tray.myseed && yield > 0 && !planted_tray.dead)
		adjust_yield(-1)
		var/mob/living/simple_animal/diona/D = new /mob/living/simple_animal/diona(get_turf(planted_tray))
		if(O.mind)
			O.mind.transfer_to(D)
			GLOB.non_respawnable_keys -= O.ckey
			O.reenter_corpse()
		visible_message(D, "A new diona nymph emerges from the pod, its antennae waving excitedly.")
		if(yield <= 0)
			visible_message("The seed pod withers away, now merely an empty husk.")
			planted_tray.plantdies()
		GLOB.respawnable_list += usr
	else
		to_chat(O, "The seed pod is no longer functional.")

/obj/item/reagent_containers/food/snacks/grown/nymph_pod
	seed = /obj/item/seeds/nymph
	name = "nymph pod"
	desc = "A peculiar wriggling pod with a grown nymph inside. Crack it open to let the nymph out."
	icon_state = "mushy"
	bitesize_mod = 2

/obj/item/reagent_containers/food/snacks/grown/nymph_pod/attack_self(mob/user)
	new /mob/living/simple_animal/diona(get_turf(user))
	to_chat(user, "<span class='notice'>You crack open [src] letting the nymph out.</span>")
	user.drop_item()
	qdel(src)