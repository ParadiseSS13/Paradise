/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by it's charge, ever vigilant."
	speak_emote = list("intones")
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	environment_smash = 0
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	AIStatus = AI_OFF
	butcher_results = list(/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	var/summoned = FALSE
	var/cooldown = 0
	var/damage_transfer = 1 //how much damage from each attack we transfer to the owner
	var/light_on = 0
	var/luminosity_on = 3
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"
	var/magic_fluff_string = " You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!"
	var/tech_fluff_string = "BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!"
	var/bio_fluff_string = "Your scarabs fail to mutate. This shouldn't happen! Submit a bug report!"
	var/admin_fluff_string = "URK URF!"//the wheels on the bus...
	var/adminseal = FALSE
	var/name_color = "white"//only used with protector shields for the time being

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Life(seconds, times_fired) //Dies if the summoner dies
	..()
	if(summoner)
		if(summoner.stat == DEAD)
			to_chat(src, "<span class='danger'>Your summoner has died!</span>")
			visible_message("<span class='danger'>The [src] dies along with its user!</span>")
			ghostize()
			qdel(src)
	snapback()
	if(summoned && !summoner && !adminseal)
		to_chat(src, "<span class='danger'>You somehow lack a summoner! As a result, you dispel!</span>")
		ghostize()
		qdel()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>")
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.loc) //move to summoner's tile, don't recall
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	..()
	snapback()

/mob/living/simple_animal/hostile/guardian/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	to_chat(summoner, "<span class='danger'>Your [name] died somehow!</span>")
	summoner.death()


/mob/living/simple_animal/hostile/guardian/handle_hud_icons_health()
	if(summoner)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(config.health_threshold_dead - summoner.health) / abs(config.health_threshold_dead - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100)
		if(hud_used)
			hud_used.guardianhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"
		med_hud_set_health()
		med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * damage_transfer
	if(summoner)
		if(loc == summoner)
			return
		summoner.adjustBruteLoss(damage)
		if(damage)
			to_chat(summoner, "<span class='danger'>Your [name] is under attack! You take damage!</span>")
			summoner.visible_message("<span class='danger'>Blood sprays from [summoner] as [src] takes damage!</span>")
		if(summoner.stat == UNCONSCIOUS)
			to_chat(summoner, "<span class='danger'>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span>")
			summoner.adjustCloneLoss(damage/2)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)

		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner, "<span class='danger'>Your [src] was blown up!</span>")
		summoner.Weaken(10)// your fermillier has died! ROLL FOR CON LOSS!
	ghostize()
	qdel(src)

//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return
	if(!summoner) return
	if(loc == summoner)
		forceMove(get_turf(summoner))
		src.client.eye = loc
		cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced = FALSE)
	if(cooldown > world.time && !forced)
		return
	if(!summoner) return
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
	forceMove(summoner)
	buckled = null
	cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Communicate(message)
	var/input
	if(!message)
		input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
	else
		input = message
	if(!input) return

	for(var/mob/M in GLOB.mob_list)
		if(M == summoner)
			to_chat(M, "<span class='changeling'><i>[src]:</i> [input]</span>")
			log_say("(GUARDIAN to [key_name(M)]) [input]", src)
		else if(M in GLOB.dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

//override set to true if message should be passed through instead of going to host communication
/mob/living/simple_animal/hostile/guardian/say(message, override = FALSE)
	if(adminseal || override)//if it's an admin-spawned guardian without a host it can still talk normally
		return ..(message)
	Communicate(message)
	

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, "<span class='danger'>You dont have another mode!</span>")


/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input) return

	for(var/mob/M in GLOB.mob_list)
		if(istype (M, /mob/living/simple_animal/hostile/guardian))
			var/mob/living/simple_animal/hostile/guardian/G = M
			if(G.summoner == src)
				to_chat(G, "<span class='changeling'><i>[src]:</i> [input]</span>")
				log_say("(GUARDIAN to [key_name(G)]) [input]", src)

		else if(M in GLOB.dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.mob_list)
		if(G.summoner == src)
			G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."

	src.verbs -= /mob/living/proc/guardian_reset
	for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.mob_list)
		if(G.summoner == src)
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [G.real_name]?", ROLE_GUARDIAN, 0, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				to_chat(G, "Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.")
				to_chat(src, "Your guardian has been successfully reset.")
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize()
				G.key = new_stand.key
			else
				to_chat(src, "There were no ghosts willing to take control. Looks like you're stuck with your Guardian for now.")
				spawn(3000)
					verbs += /mob/living/proc/guardian_reset


/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!light_on)
		set_light(luminosity_on)
		to_chat(src, "<span class='notice'>You activate your light.</span>")
	else
		set_light(0)
		to_chat(src, "<span class='notice'>You deactivate your light.</span>")
	light_on = !light_on

////////Creation

/obj/item/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "You shuffle the deck..."
	var/used_message = "All the cards seem to be blank now."
	var/failure_message = "..And draw a card! It's...blank? Maybe you should try again later."
	var/ling_failure = "The deck refuses to respond to a souless creature such as you."
	var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Assassin", "Lightning", "Charger", "Protector")
	var/random = TRUE
	var/color_list = list("Pink" = "#FFC0CB",
		"Red" = "#FF0000",
		"Orange" = "#FFA500",
		"Green" = "#008000",
		"Blue" = "#0000FF")
	var/name_list = list("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")

/obj/item/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.living_mob_list)
		if(G.summoner == user)
			to_chat(user, "You already have a [mob_name]!")
			return
	if(user.mind && (user.mind.changeling || user.mind.vampire))
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE
	to_chat(user, "[use_message]")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_GUARDIAN, 0, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		to_chat(user, "[failure_message]")
		used = FALSE

/obj/item/guardiancreator/examine(mob/user, distance)
	. = ..()
	if(used)
		to_chat(user, "<span class='notice'>[used_message]</span>")

/obj/item/guardiancreator/proc/spawn_guardian(mob/living/user, key)
	var/guardian_type = "Standard"
	if(random)
		guardian_type = pick(possible_guardians)
	else
		guardian_type = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(guardian_type)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

		if("Assassin")
			pickedtype = /mob/living/simple_animal/hostile/guardian/assassin

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/guardian/beam

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user)
	G.summoner = user
	G.summoned = TRUE
	G.key = key
	to_chat(G, "You are a [mob_name] bound to serve [user.real_name].")
	to_chat(G, "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there.")
	to_chat(G, "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.")
	to_chat(G, "[G.playstyle_string]")
	G.faction = user.faction
	user.verbs += /mob/living/proc/guardian_comm
	user.verbs += /mob/living/proc/guardian_recall
	user.verbs += /mob/living/proc/guardian_reset

	var/color = pick(color_list)
	G.name_color = color_list[color]
	var/picked_name = pick(name_list)
	create_theme(G, user, picked_name, color)

/obj/item/guardiancreator/proc/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[picked_name] [color]"
	G.real_name = "[picked_name] [color]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.magic_fluff_string].")
	
/obj/item/guardiancreator/choose
	random = FALSE

/obj/item/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "You start to power on the injector..."
	used_message = "The injector has already been used."
	failure_message = "<B>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</B>"
	ling_failure = "The holoparasites recoil in horror. They want nothing to do with a creature like you."
	color_list = list("Rose" = "#F62C6B",
		"Peony" = "#E54750",
		"Lily" = "#F6562C",
		"Daisy" = "#ECCD39",
		"Zinnia" = "#89F62C",
		"Ivy" = "#5DF62C",
		"Iris" = "#2CF6B8",
		"Petunia" = "#51A9D4",
		"Violet" = "#8A347C",
		"Lilac" = "#C7A0F6",
		"Orchid" = "#F62CF5")
	name_list = list("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

/obj/item/guardiancreator/tech/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[picked_name] [color]"
	G.real_name = "[picked_name] [color]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.tech_fluff_string].")
	G.speak_emote = list("states")

/obj/item/guardiancreator/tech/check_uplink_validity()
	return !used

/obj/item/guardiancreator/tech/choose
	random = FALSE

/obj/item/guardiancreator/biological
	name = "scarab egg cluster"
	desc = "A parasitic species that will nest in the closest living creature upon birth. While not great for your health, they'll defend their new 'hive' to the death."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	theme = "bio"
	mob_name = "Scarab Swarm"
	use_message = "The eggs begin to twitch..."
	used_message = "The cluster already hatched."
	failure_message = "<B>...but soon settles again. Guess they weren't ready to hatch after all.</B>"
	color_list = list("Rose" = "#F62C6B",
		"Peony" = "#E54750",
		"Lily" = "#F6562C",
		"Daisy" = "#ECCD39",
		"Zinnia" = "#89F62C",
		"Ivy" = "#5DF62C",
		"Iris" = "#2CF6B8",
		"Petunia" = "#51A9D4",
		"Violet" = "#8A347C",
		"Lilac" = "#C7A0F6",
		"Orchid" = "#F62CF5")
	name_list = list("brood", "hive", "nest")

/obj/item/guardiancreator/biological/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[color] [picked_name]"
	G.real_name = "[color] [picked_name]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.bio_fluff_string].")
	G.attacktext = "swarms"
	G.speak_emote = list("chitters")

/obj/item/guardiancreator/biological/choose
	random = FALSE


/obj/item/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Has two modes. Deception: Causes target of attacks to hallucinate. Dispersion: Attacks have a chance to teleport the target randomly. Ignites mobs on touch. Automatically extinguishes the user if they catch fire.<br>
 <br>
 <b>Standard</b>: Devestating close combat attacks and high damage resist. No special powers.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged: Extremely weak, highly spammable projectile attack. Scout: Can not attack, but can move through walls. Can lay surveillance snares in either mode.<br>
 <br>
 <b>Support</b>: Has two modes. Combat: Medium power attacks and damage resist. Healer: Attacks heal damage, but low damage resist and slow movement. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack. Can turn any object into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered.<br>
 <br>
 <b>Assassin</b>: Medium damage with no damage resistance, can enter stealth which massively increases the damage of the next attack causing it to ignore armour.
 <br>
 <b>Charger</b>: Medium damage and defense, very fast and has a special charge attack which damages a target and knocks items out of their hands.
 <br>
 <b>Lightning</b>: Applies lightning chains to any targets on attack with a link to your summoner, lightning chains will shock anyone nearby.
 <br>
 <b>Protector</b>: You will become leashed to your holoparasite instead of them to you. Has two modes, a medium attack/defense mode and a protection mode which greatly reduces incoming damage to the holoparasite.
"}

/obj/item/paper/guardian/update_icon()
	return


/obj/item/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/guardiancreator/tech/choose(src)
	new /obj/item/paper/guardian(src)
	return
