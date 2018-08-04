/datum/component/jestosterone
	var/mob_is_clown //Is the affected mob a clown?

/datum/component/jestosterone/Initialize(mob/user, is_this_mob_a_clown)
	mob_is_clown = is_this_mob_a_clown
	if(mob_is_clown)
		to_chat(user, "<span class='notice'>Whatever that was, it feels great!</span>")
	else
		to_chat(user, "<span class='warning'>Something doesn't feel right...</span>")
	RegisterSignal(COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/mob_was_attacked)
	RegisterSignal(COMSIG_ITEM_ATTACK, .proc/mob_was_attacked)
	RegisterSignal(COMSIG_ATOM_ATTACK_ALIEN, .proc/mob_was_attacked)
	RegisterSignal(COMSIG_ON_MOB_LIFE, .proc/process_jestosterone)

/datum/component/jestosterone/proc/on_move(mob/user)
	playsound(user.loc, "clownstep", 25, 1) //Yes, this means that if you put jestosterone inside an alien, it will squeak. Also it stacks with shoes, THE HORROR!

/datum/component/jestosterone/proc/mob_was_attacked(mob/user)
	to_chat(user, "was attacked")
	playsound(user.loc, 'sound/items/bikehorn.ogg', 50, 1)

/datum/component/jestosterone/proc/process_jestosterone(mob/living/user)
	if(prob(10))
		user.emote("giggle")
	if(mob_is_clown)
		user.adjustBruteLoss(-1.5 * REAGENTS_EFFECT_MULTIPLIER) //Screw those pesky clown beatings!
	else
		user.AdjustDizzy(10, 0, 500)
		user.Druggy(15)
		if(prob(10))
			user.EyeBlurry(5)
		if(prob(6))
			var/list/clown_message = list("You feel light-headed.",
			"You can't see straight.",
			"You feel about as funny as the station clown.",
			"Bright colours and rainbows cloud your vision.",
			"Your funny bone aches.",
			"You can hear bike horns in the distance.",
			"You feel like <em>SHOUTING</em>!",
			"Sinister laughter echoes in your ears.",
			"Your legs feel like jelly.",
			"You feel like telling a pun.")
			to_chat(user, "<span class='warning'>[pick(clown_message)]</span>")
