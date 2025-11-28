/mob/living/basic/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attack_verb_simple = "lacerate"
	attack_verb_continuous = "lacerates"
	speed = 0
	death_message = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'
	/// List of sounds the migo can make
	var/static/list/migo_sounds
	/// Will the migo dodge?
	var/dodge_prob = 10
	surgery_container = /datum/xenobiology_surgery_container/migo

/mob/living/basic/netherworld/migo/Initialize(mapload)
	. = ..()
	migo_sounds = list(
		'sound/items/bubblewrap.ogg',
		'sound/items/change_jaws.ogg',
		'sound/items/crowbar.ogg',
		'sound/items/drink.ogg',
		'sound/items/deconstruct.ogg',
		'sound/items/change_drill.ogg',
		'sound/items/dodgeball.ogg',
		'sound/items/eatfood.ogg',
		'sound/items/screwdriver.ogg',
		'sound/items/weeoo1.ogg',
		'sound/items/wirecutter.ogg',
		'sound/items/welder.ogg',
		'sound/items/zip.ogg',
		'sound/items/rped.ogg',
		'sound/items/ratchet.ogg',
		'sound/items/polaroid1.ogg',
		'sound/items/pshoom.ogg',
		'sound/items/airhorn.ogg',
		'sound/voice/bcreep.ogg',
		'sound/voice/biamthelaw.ogg',
		'sound/voice/ed209_20sec.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss6.ogg',
		'sound/voice/mpatchedup.ogg',
		'sound/voice/mfeelbetter.ogg',
		'sound/weapons/sear.ogg',
		'sound/ambience/antag/tatoralert.ogg',
		'sound/mecha/nominal.ogg',
		'sound/mecha/weapdestr.ogg',
		'sound/mecha/critdestr.ogg',
		'sound/mecha/imag_enh.ogg',
		'sound/effects/adminhelp.ogg',
		'sound/effects/alert.ogg',
		'sound/effects/attackblob.ogg',
		'sound/effects/bamf.ogg',
		'sound/effects/blobattack.ogg',
		'sound/effects/break_stone.ogg',
		'sound/effects/bubbles.ogg',
		'sound/effects/bubbles2.ogg',
		'sound/effects/clang.ogg',
		'sound/effects/clownstep2.ogg',
		'sound/effects/dimensional_rend.ogg',
		'sound/effects/doorcreaky.ogg',
		'sound/effects/empulse.ogg',
		'sound/effects/explosionfar.ogg',
		'sound/effects/explosion1.ogg',
		'sound/effects/grillehit.ogg',
		'sound/effects/genetics.ogg',
		'sound/effects/heartbeat.ogg',
		'sound/effects/hyperspace_begin.ogg',
		'sound/effects/hyperspace_end.ogg',
		'sound/goonstation/effects/screech.ogg',
		'sound/effects/phasein.ogg',
		'sound/effects/picaxe1.ogg',
		'sound/effects/sparks1.ogg',
		'sound/effects/smoke.ogg',
		'sound/effects/splat.ogg',
		'sound/effects/snap.ogg',
		'sound/effects/tendril_destroyed.ogg',
		'sound/effects/supermatter.ogg',
		'sound/misc/desceration-01.ogg',
		'sound/misc/desceration-02.ogg',
		'sound/misc/desceration-03.ogg',
		'sound/misc/bloblarm.ogg',
		'sound/goonstation/misc/airraid_loop.ogg',
		'sound/misc/interference.ogg',
		'sound/misc/notice1.ogg',
		'sound/misc/notice2.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/misc/slip.ogg',
		'sound/weapons/armbomb.ogg',
		'sound/weapons/chainsaw.ogg',
		'sound/weapons/emitter.ogg',
		'sound/weapons/emitter2.ogg',
		'sound/weapons/blade1.ogg',
		'sound/weapons/bladeslice.ogg',
		'sound/weapons/blastcannon.ogg',
		'sound/weapons/blaster.ogg',
		'sound/weapons/bulletflyby3.ogg',
		'sound/weapons/circsawhit.ogg',
		'sound/weapons/cqchit2.ogg',
		'sound/weapons/drill.ogg',
		'sound/weapons/genhit1.ogg',
		'sound/weapons/gunshots/gunshot_silenced.ogg',
		'sound/weapons/gunshots/gunshot.ogg',
		'sound/weapons/handcuffs.ogg',
		'sound/weapons/homerun.ogg',
		'sound/weapons/kenetic_accel.ogg',
		'sound/machines/fryer/deep_fryer_emerge.ogg',
		'sound/machines/airlock_alien_prying.ogg',
		'sound/machines/airlock_close.ogg',
		'sound/machines/airlockforced.ogg',
		'sound/machines/airlock_open.ogg',
		'sound/machines/alarm.ogg',
		'sound/machines/blender.ogg',
		'sound/machines/boltsdown.ogg',
		'sound/machines/boltsup.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/buzz-two.ogg',
		'sound/machines/chime.ogg',
		'sound/machines/defib_charge.ogg',
		'sound/machines/defib_failed.ogg',
		'sound/machines/defib_ready.ogg',
		'sound/machines/defib_zap.ogg',
		'sound/machines/deniedbeep.ogg',
		'sound/machines/ding.ogg',
		'sound/machines/disposalflush.ogg',
		'sound/machines/door_close.ogg',
		'sound/machines/door_open.ogg',
		'sound/machines/engine_alert1.ogg',
		'sound/machines/engine_alert2.ogg',
		'sound/machines/hiss.ogg',
		'sound/machines/honkbot_evil_laugh.ogg',
		'sound/machines/juicer.ogg',
		'sound/machines/ping.ogg',
		'sound/ambience/signal.ogg',
		'sound/machines/synth_no.ogg',
		'sound/machines/synth_yes.ogg',
		'sound/machines/terminal_alert.ogg',
		'sound/machines/twobeep.ogg',
		'sound/machines/ventcrawl.ogg',
		'sound/machines/warning-buzzer.ogg',
		'sound/ai/outbreak5.ogg',
		'sound/ai/outbreak7.ogg',
		'sound/ai/alert.ogg',
		'sound/ai/radiation.ogg',
		'sound/ai/eshuttle_call.ogg',
		'sound/ai/eshuttle_dock.ogg',
		'sound/ai/eshuttle_recall.ogg',
		'sound/ai/aimalf.ogg',
		'sound/ambience/ambigen1.ogg',
		'sound/ambience/ambigen3.ogg',
		'sound/ambience/ambigen4.ogg',
		'sound/ambience/ambigen5.ogg',
		'sound/ambience/ambigen6.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/hallucinations/over_here1.ogg',
		'sound/hallucinations/over_here2.ogg',
		'sound/hallucinations/over_here3.ogg'
	)

/// Makes the migo more likely to dodge around the more damaged it is
/mob/living/basic/netherworld/migo/proc/update_dodge_chance(health_ratio)
	dodge_prob = LERP(50, 10, health_ratio)

/mob/living/basic/netherworld/migo/proc/make_migo_sound()
	playsound(src, pick(migo_sounds), 50, TRUE)

/mob/living/basic/netherworld/migo/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	make_migo_sound()

/mob/living/basic/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		make_migo_sound()

/mob/living/basic/netherworld/migo/Move(atom/newloc, dir, step_x, step_y)
	if(!ckey && prob(dodge_prob) && moving_diagonally == 0 && isturf(loc) && isturf(newloc) && stat != DEAD)
		return dodge(newloc, dir)
	else
		return ..()

/mob/living/basic/netherworld/migo/proc/dodge(moving_to, move_direction)
	// Assuming we move towards the target we want to swerve toward them to get closer
	var/cdir = turn(move_direction, 45)
	var/ccdir = turn(move_direction, -45)
	. = Move(get_step(loc, pick(cdir, ccdir)))
	if(!.)// Can't dodge there so we just carry on
		. = Move(moving_to, move_direction)

