/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing-pink"
	icon_living = "otherthing-pink"
	icon_dead = "otherthing-pink-dead"
	health = 125
	maxHealth = 125
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 30
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("screams")
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether", "mining", "cult")
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	weather_immunities = list("lava","ash")
	obj_damage = 30
	environment_smash = 2
	minbodytemp = 0
	heat_damage_per_tick = 20
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	mob_size = MOB_SIZE_LARGE

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	var/static/list/migo_sounds
	deathmessage = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
	. = ..()
	migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/voice/bcreep.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss1.ogg', 'sound/voice/mpatchedup.ogg', 'sound/voice/mfeelbetter.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heartbeat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/goonstation/effects/screech.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/goonstation/misc/airraid_loop.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/chainsaw.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/gunshots/gunshot_silenced.ogg', 'sound/weapons/gunshots/gunshot.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlock_close.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlock_open.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/ambience/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/poweroff.ogg', 'sound/ai/radiation.ogg', 'sound/ai/shuttlecalled.ogg', 'sound/ai/shuttledock.ogg', 'sound/ai/shuttlerecalled.ogg', 'sound/ai/aimalf.ogg', 'sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen10.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg') //hahahaha fuck you code divers

/mob/living/simple_animal/hostile/netherworld/migo/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 10
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody)
	faction = list("nether", "mining", "cult")
	var/blankckey = null

/obj/structure/spawner/nether/Initialize(mapload)
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	..()
	if(iscultist(user))
		to_chat(user, "A direct link to another dimension full of creatures very happy to see your God again. <span class='notice'>They are patiently waiting to be re-enlisted.</span>") //By touching the portal on harm or disarm intent, you will recall all the monsters spawned by the portal. By touching it on help or grab intent, you will be able to move it around.</span>")
	else
		to_chat(user, "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>")

/obj/structure/spawner/nether/attack_hand(mob/user)
	. = ..()
/*	if(iscultist(user)) // Touched by cultist
		if((user.a_intent == "help") || (user.a_intent == "grab")) // Grab around
			if(move_resist == initial(move_resist))
				to_chat(user, "<span class='notice'>As you touch the portal, you notice you can drag it around!</span>")
				move_resist = 1000
				spawn_time = 1800 //3 minutes
			else
				to_chat(user, "<span class='notice'>You anchor the portal in place!</span>")
				move_resist = initial(move_resist)
				user.stop_pulling()
				spawn_time = initial(spawn_time)
		if((user.a_intent == "harm") || (user.a_intent == "disarm")) // Kill all the creatures so they can be respawned where needed, but damage the portal...
			for(var/mob/living/M in spawned_mobs)
				if(M)
					M.gib()
			to_chat(user, "<span class='notice'>All the monsters spawned by the portal disappear in an explosion of gore, returning to the nether!</span>")*/
	if(!iscultist(user))
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
							"<span class='userdanger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/obj/structure/spawner/nether/process()
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			M.adjustBruteLoss(60)
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M.real_name]"
				blank.desc = "It's [M.real_name], but [M.p_their()] flesh has an ashy texture, and [M.p_their()] face is featureless save an eerie smile."
				blank.maxHealth = 150
				blank.health = 150
				blank.melee_damage_upper = 15
				visible_message("<span class='warning'>[M.real_name] reemerges from the link!</span>")
				if((blankckey) && (blankckey == M.ckey))
					blank.ckey = blankckey
					blankckey = null
					to_chat(blank, "<span class='biggerdanger'>Hatred courses through you... you can't give up your spirit... not yet. Help your newfound compatriots complete their objectives!</span>")
					SSticker.mode.add_cultist(blank.mind, 1)
					blank.mind.special_role = "Cultist"
				qdel(M)
				blankckey = null

/*/obj/structure/spawner/nether/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/grab) && get_dist(src,user)<2)
		if(iscultist(user))
			var/obj/item/grab/G = W
			if(iscultist(G.affecting))
				return
			if(!ishuman(G.affecting))
				return
			if(!G.affecting.ckey)
				return
			if(G.state<3)
				to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				return
			else
				G.affecting.loc = src.loc
				G.affecting.Weaken(5)
				visible_message("<span class='warning'>[G.assailant] shoves [G.affecting] into the portal!</span>")
				contents.Add(G.affecting)
				blankckey = G.affecting.ckey // Doing it on purpose will let the person control the blank body
				to_chat(G.affecting, "<span class='biggerdanger'>ARGHHH--</span>")
		else
			to_chat(user, "<span class='warning'>Come here yourself!</span>")
			return*/