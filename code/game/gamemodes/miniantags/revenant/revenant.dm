//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Wreck havoc with haunting themed abilities
//Admin-spawn or random event

#define INVISIBILITY_REVENANT 45
#define REVENANT_NAME_FILE "revenant_names.json"

/mob/living/simple_animal/revenant
	name = "revenant" //The name shown on examine
	real_name = "revenant" //The name shown in dchat
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	mob_biotypes = MOB_SPIRIT
	sentience_type = SENTIENCE_BOSS // no reviving funny ghost
	incorporeal_move = INCORPOREAL_MOVE_HOLY_BLOCK
	see_invisible = INVISIBILITY_REVENANT
	invisibility = INVISIBILITY_REVENANT
	health =  INFINITY //Revenants don't use health, they use essence instead
	maxHealth =  INFINITY
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	response_help   = "passes through"
	response_disarm = "swings at"
	response_harm   = "punches"
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	friendly = "touches"
	status_flags = 0
	wander = FALSE
	density = FALSE
	move_resist = INFINITY
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	initial_traits = list(TRAIT_FLYING)
	contains_xeno_organ = TRUE
	ignore_generic_organs = TRUE
	surgery_container = /datum/xenobiology_surgery_container/revenant
	faction = list("revenant")

	/// The revenant's idle icon
	var/icon_idle = "revenant_idle"
	/// The revenant's revealed icon
	var/icon_reveal = "revenant_revealed"
	/// The revenant's stunned icon
	var/icon_stun = "revenant_stun"
	/// The revant's icon while draining mobs
	var/icon_drain = "revenant_draining"

	///The resource of revenants. Max health is equal to three times this amount
	var/essence = 75
	///The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regen_cap = 75
	///If the revenant regenerates essence or not; 1 for yes, 0 for no
	var/essence_regenerating = TRUE
	///How much essence regenerates
	var/essence_regen_amount = 5
	///How much essence the revenant has stolen
	var/essence_accumulated = 0
	///If the revenant can take damage from normal sources.
	var/revealed = FALSE
	///How long the revenant is revealed for, is about 2 seconds times this var.
	var/unreveal_time = 0
	///How long the revenant is stunned for, is about 2 seconds times this var.
	var/unstun_time = 0
	///If the revenant's abilities are blocked by a chaplain's power.
	var/inhibited = FALSE
	///How much essence the revenant has drained.
	var/essence_drained = 0
	///If the revenant is draining someone.
	var/draining = FALSE
	/// contains a list of UIDs of mobs who have been drained. cannot drain the same mob twice.
	var/list/drained_mobs = list()
	///How many perfect, regen-cap increasing souls the revenant has.
	var/perfectsouls = 0
	/// Are we currently dying? extra check against becomming incorporeal
	var/dying = FALSE

/mob/living/simple_animal/revenant/Life(seconds, times_fired)
	..()
	if(revealed && essence <= 0)
		dying = TRUE
		death()
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence = min(essence_regen_cap, essence+essence_regen_amount)
	if(unreveal_time && world.time >= unreveal_time && !dying)
		unreveal_time = 0
		revealed = FALSE
		incorporeal_move = INCORPOREAL_MOVE_HOLY_BLOCK
		invisibility = INVISIBILITY_REVENANT
		to_chat(src, "<span class='revennotice bold'>You are once more concealed.</span>")
	if(unstun_time && world.time >= unstun_time && !dying)
		unstun_time = 0
		notransform = FALSE
		to_chat(src, "<span class='revennotice bold'>You can move again!</span>")
	update_spooky_icon()

/mob/living/simple_animal/revenant/ex_act(severity)
	return TRUE //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE //You are a ghost, atmos and grill makes sparks, and you make your own shocks with lights.

/mob/living/simple_animal/revenant/adjustHealth(amount, updating_health = TRUE)
	if(!revealed)
		return
	essence = max(0, essence-amount)
	if(!essence)
		to_chat(src, "<span class='revendanger'>You feel your essence fraying!</span>")

/mob/living/simple_animal/revenant/say(message)
	if(!message)
		return
	log_say(message, src)
	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), intentional = TRUE)

	say_dead(message)

/mob/living/simple_animal/revenant/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Current essence:", "[essence]/[essence_regen_cap]E")
	status_tab_data[++status_tab_data.len] = list("Stolen essence:", "[essence_accumulated]E")
	status_tab_data[++status_tab_data.len] = list("Stolen perfect souls:", "[perfectsouls]")

/mob/living/simple_animal/revenant/Initialize(mapload)
	. = ..()
	if(!mapload)
		var/list/built_name = list()
		built_name += pick(strings(REVENANT_NAME_FILE, "spirit_type"))
		built_name += " of "
		built_name += pick(strings(REVENANT_NAME_FILE, "adjective"))
		built_name += pick(strings(REVENANT_NAME_FILE, "theme"))
		var/combined_name = built_name.Join("")
		name = combined_name
		real_name = combined_name

	flags_2 |= RAD_NO_CONTAMINATE_2
	remove_from_all_data_huds()
	giveSpells()
	RegisterSignal(src, COMSIG_BODY_TRANSFER_TO, PROC_REF(make_revenant_antagonist))

/mob/living/simple_animal/revenant/proc/make_revenant_antagonist(revenant)
	SIGNAL_HANDLER // COMSIG_BODY_TRANSFER_TO
	mind.assigned_role = SPECIAL_ROLE_REVENANT
	mind.special_role = SPECIAL_ROLE_REVENANT
	giveObjectivesandGoals()

/mob/living/simple_animal/revenant/proc/giveObjectivesandGoals()
	if(!mind)
		return
	mind.wipe_memory() // someone kill this and give revenants their own minds please
	SEND_SOUND(src, sound('sound/effects/ghost.ogg'))
	var/list/messages = list()
	messages.Add("<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>")
	messages.Add("<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>")
	messages.Add("<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>")
	messages.Add("<b>You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.</b>")
	messages.Add("<b>To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.</b>")
	messages.Add("<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>")
	messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Revenant)</span>")

	SSticker.mode.traitors |= mind //Necessary for announcing
	mind.add_mind_objective(/datum/objective/revenant)
	mind.add_mind_objective(/datum/objective/revenant_fluff)
	messages.Add(mind.prepare_announce_objectives(FALSE))
	to_chat(src, chat_box_red(messages.Join("<br>")))

/mob/living/simple_animal/revenant/proc/giveSpells()
	AddSpell(new /datum/spell/night_vision/revenant)
	AddSpell(new /datum/spell/revenant_transmit)
	AddSpell(new /datum/spell/aoe/revenant/defile)
	AddSpell(new /datum/spell/aoe/revenant/malfunction)
	AddSpell(new /datum/spell/aoe/revenant/overload)
	AddSpell(new /datum/spell/aoe/revenant/haunt_object)
	AddSpell(new /datum/spell/aoe/revenant/hallucinations)


/mob/living/simple_animal/revenant/dust()
	return death()

/mob/living/simple_animal/revenant/gib()
	return death()

/mob/living/simple_animal/revenant/death()
	if(!revealed)
		return FALSE
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE

	to_chat(src, "<span class='revendanger'>NO! No... it's too late, you can feel your essence breaking apart...</span>")
	notransform = TRUE
	revealed = TRUE
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, TRUE)
	visible_message("<span class='warning'>[src] lets out a waning screech as violet mist swirls around its dissolving body!</span>")
	icon_state = "revenant_draining"
	animate(src, alpha = 0, time = 3 SECONDS)
	visible_message("<span class='danger'>[src]'s body breaks apart into a fine pile of blue dust.</span>")
	ghostize(GHOST_FLAGS_OBSERVE_ONLY)
	name = "ectoplasm"
	desc = "A pile of clumpy dust from a restless spirit"
	alpha = 255
	icon_state = "revenant_ectoplasm"
	move_resist = null
	return ..()

/mob/living/simple_animal/revenant/attack_by(obj/item/W, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(istype(W, /obj/item/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='revendanger'>As \the [W] passes through you, you feel your essence draining away!</span>")
		adjustBruteLoss(25) //hella effective
		inhibited = TRUE
		spawn(30)
			inhibited = FALSE

		return FINISH_ATTACK

/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(holy_check(src))
		return
	var/turf/T = get_turf(src)
	if(iswallturf(T))
		to_chat(src, "<span class='revenwarning'>You cannot use abilities from inside of a wall.</span>")
		return FALSE
	if(inhibited)
		to_chat(src, "<span class='revenwarning'>Your powers have been suppressed by nulling energy!</span>")
		return FALSE
	if(!change_essence_amount(essence_cost, 1))
		to_chat(src, "<span class='revenwarning'>You lack the essence to use that ability.</span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = FALSE, source)
	if(essence + essence_amt <= 0)
		return
	essence = max(0, essence + essence_amt)
	if(essence_amt > 0)
		essence_accumulated = max(0, essence_accumulated + essence_amt)
	if(!silent)
		if(essence_amt > 0)
			to_chat(src, "<span class='revennotice'>Gained [essence_amt]E from [source].</span>")
		else
			to_chat(src, "<span class='revenminor'>Lost [essence_amt]E from [source].</span>")
	return TRUE

/mob/living/simple_animal/revenant/proc/reveal(time)
	if(time <= 0)
		return
	revealed = TRUE
	invisibility = 0
	incorporeal_move = NO_INCORPOREAL_MOVE
	if(!unreveal_time)
		to_chat(src, "<span class='revendanger'>You have been revealed!</span>")
		unreveal_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You have been revealed!</span>")
		unreveal_time = unreveal_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/stun(time)
	if(time <= 0)
		return
	notransform = TRUE
	if(!unstun_time)
		to_chat(src, "<span class='revendanger'>You cannot move!</span>")
		unstun_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You cannot move!</span>")
		unstun_time = unstun_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/update_spooky_icon()
	if(dying)
		return

	if(!revealed)
		icon_state = icon_idle
		return

	if(!notransform)
		icon_state = icon_reveal
		return

	if(draining)
		icon_state = icon_drain
		return

	// No other state is happening, therefore we are stunned
	icon_state = icon_stun


/datum/objective/revenant
	needs_target = FALSE
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(350, 600)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()

/datum/objective/revenant/check_completion()
	var/total_essence = 0
	for(var/datum/mind/M in get_owners())
		if(!istype(M.current, /mob/living/simple_animal/revenant) || QDELETED(M.current))
			continue
		var/mob/living/simple_animal/revenant/R = M.current
		total_essence += R.essence_accumulated
	if(total_essence < targetAmount)
		return FALSE
	return TRUE

/datum/objective/revenant_fluff
	needs_target = FALSE

/datum/objective/revenant_fluff/New()
	var/list/explanationTexts = list("Assist and exacerbate existing threats at critical moments.", \
									"Cause as much chaos and anger as you can without being killed.", \
									"Damage and render as much of the station rusted and unusable as possible.", \
									"Disable and cause malfunctions in as many machines as possible.", \
									"Ensure that any holy weapons are rendered unusable.", \
									"Hinder the crew while attempting to avoid being noticed.", \
									"Make the crew as miserable as possible.", \
									"Make the clown as miserable as possible.", \
									"Make the captain as miserable as possible.", \
									"Make the AI as miserable as possible.", \
									"Annoy the ones that insult you the most.", \
									"Whisper ghost jokes into peoples heads.", \
									"Help the crew in critical situations, but take your payments in souls.", \
									"Prevent the use of energy weapons where possible.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenant_fluff/check_completion()
	return TRUE

//no longer used
/obj/item/ectoplasm
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ectoplasm/examine(mob/user)
	. = ..()
	. += "<span class='revennotice'>Lifeless ectoplasm, still faintly glimmering in the light. From what was once a spirit seeking revenge on the station.</span>"

#undef INVISIBILITY_REVENANT
#undef REVENANT_NAME_FILE
