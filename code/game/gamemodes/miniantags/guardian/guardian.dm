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
	melee_damage_lower = 15
	melee_damage_upper = 15
	AIStatus = AI_OFF
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/ectoplasm = 1)
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

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
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
				new /obj/effect/overlay/temp/guardian/phase/out(loc)
				forceMove(summoner.loc) //move to summoner's tile, don't recall
				new /obj/effect/overlay/temp/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	..()
	snapback()

/mob/living/simple_animal/hostile/guardian/death(gibbed)
	..()
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
	new /obj/effect/overlay/temp/guardian/phase/out(get_turf(src))
	forceMove(summoner)
	buckled = null
	cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
	if(!input) return

	for(var/mob/M in mob_list)
		if(M == summoner)
			to_chat(M, "<span class='changeling'><i>[src]:</i> [input]</span>")
			log_say("Guardian Communication: [key_name(src)] -> [key_name(M)] : [input]")
		else if(M in dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, "<span class='danger'>You dont have another mode!</span>")


/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input) return

	for(var/mob/M in mob_list)
		if(istype (M, /mob/living/simple_animal/hostile/guardian))
			var/mob/living/simple_animal/hostile/guardian/G = M
			if(G.summoner == src)
				to_chat(G, "<span class='changeling'><i>[src]:</i> [input]</span>")
				log_say("Guardian Communication: [key_name(src)] -> [key_name(G)] : [input]")

		else if(M in dead_mob_list)
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src]:</i> [input]</span>")

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."

	src.verbs -= /mob/living/proc/guardian_reset
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
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

/obj/item/weapon/guardiancreator
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

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in living_mob_list)
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


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/gaurdiantype = "Standard"
	if(random)
		gaurdiantype = pick(possible_guardians)
	else
		gaurdiantype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(gaurdiantype)

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

	var/color

	//names and their RGB
	var/magic_list = list("Pink" = "#FFC0CB", \
	"Red" = "#FF0000", \
	"Orange" = "#FFA500", \
	"Green" = "#008000", \
	"Blue" = "#0000FF")

	var/tech_list = list("Rose" = "#F62C6B", \
	"Peony" = "#E54750", \
	"Lily" = "#F6562C", \
	"Daisy" = "#ECCD39", \
	"Zinnia" = "#89F62C", \
	"Ivy" = "#5DF62C", \
	"Iris" = "#2CF6B8", \
	"Petunia" = "#51A9D4", \
	"Violet" = "#8A347C", \
	"Lilac" = "#C7A0F6", \
	"Orchid" = "#F62CF5")

	var/picked_name
	var/picked_color = pick("#FFFFFF","#000000","#808080","#A52A2A","#FF0000","#8B0000","#DC143C","#FFA500","#FFFF00","#008000","#00FF00","#006400","#00FFFF","#0000FF","#000080","#008080","#800080","#4B0082")

	switch(theme)
		if("magic")
			color = pick(magic_list)
			G.name_color = magic_list[color]
			picked_name = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")

			G.name = "[picked_name] [color]"
			G.real_name = "[picked_name] [color]"
			G.icon_living = "[theme][color]"
			G.icon_state = "[theme][color]"
			G.icon_dead = "[theme][color]"

			to_chat(user, "[G.magic_fluff_string].")
		if("tech")
			color = pick(tech_list) //technically not colors, just flowers that can be specific colors
			G.name_color = tech_list[color]
			picked_name = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

			G.name = "[picked_name] [color]"
			G.real_name = "[picked_name] [color]"
			G.icon_living = "[theme][color]"
			G.icon_state = "[theme][color]"
			G.icon_dead = "[theme][color]"

			to_chat(user, "[G.tech_fluff_string].")
			G.speak_emote = list("states")
		if("bio")
			G.name_color = picked_color
			G.icon = 'icons/mob/mob.dmi'
			picked_name = pick("brood", "hive", "nest")
			to_chat(user, "[G.bio_fluff_string].")
			G.name = "[picked_name] swarm"
			G.color = picked_color
			G.real_name = "[picked_name] swarm"
			G.icon_living = "headcrab"
			G.icon_state = "headcrab"
			G.attacktext = "swarms"
			G.speak_emote = list("chitters")

/obj/item/weapon/guardiancreator/choose
	random = FALSE

/obj/item/weapon/guardiancreator/tech
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

/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE

/obj/item/weapon/guardiancreator/biological
	name = "scarab egg cluster"
	desc = "A parasitic species that will nest in the closest living creature upon birth. While not great for your health, they'll defend their new 'hive' to the death."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	theme = "bio"
	mob_name = "Scarab Swarm"
	use_message = "The eggs begin to twitch..."
	used_message = "The cluster already hatched."
	failure_message = "<B>...but soon settles again. Guess they weren't ready to hatch after all.</B>"

/obj/item/weapon/guardiancreator/biological/choose
	random = FALSE


/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Ignites mobs on touch. teleports them at random on attack. Automatically extinguishes the user if they catch fire.<br>
 <br>
 <b>Standard</b>:Devestating close combat attacks and high damage resist. No special powers.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged: Extremely weak, highly spammable projectile attack. Scout: Can not attack, but can move through walls. Can lay surveillance snares in either mode.<br>
 <br>
 <b>Support</b>:Has two modes. Combat: Medium power attacks and damage resist. Healer: Attacks heal damage, but low damage resist and slow movemen. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack. Can turn any object into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered.<br>
"}

/obj/item/weapon/paper/guardian/update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose(src)
	new /obj/item/weapon/paper/guardian(src)
	return
