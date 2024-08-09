/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	pressure_resistance = 10

	// Will be determined based on mob size if left null. Done in living/proc/determine_move_and_pull_forces()
	move_resist = null
	move_force = null
	pull_force = null

	/// Flag to enable these making trees semi-transparent if behind them
	flags_2 = CRITICAL_ATOM_2

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0	//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0	//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/staminaloss = 0 //Stamina damage, or exhaustion. You recover it slowly naturally, and are stunned if it gets too high. Holodeck and hallucinations deal this.


	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	/// Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = NO_INCORPOREAL_MOVE

	var/now_pushing = null

	var/atom/movable/cameraFollow = null

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/floating = FALSE
	var/mob_size = MOB_SIZE_HUMAN
	// What type of mob is this
	var/mob_biotypes = MOB_ORGANIC
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..

	var/ventcrawler = VENTCRAWLER_NONE
	var/list/icon/pipes_shown = list()
	var/last_played_vent

	var/smoke_delay = 0 //used to prevent spam with smoke reagent reaction on mob.

	var/step_count = 0

	var/list/butcher_results = null

	var/list/weather_immunities = list()

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/gene_stability = DEFAULT_GENE_STABILITY
	var/ignore_gene_stability = 0

	var/list/say_log = list() //a log of what we've said, plain text, no spans or junk, essentially just each individual "message"
	var/list/emote_log = list() //like say_log but for emotes

	var/blood_volume = 0 //how much blood the mob has
	hud_possible = list(HEALTH_HUD,STATUS_HUD,SPECIALROLE_HUD)

	var/list/status_effects //a list of all status effects the mob has

	var/deathgasp_on_death = FALSE

	var/stun_absorption = null //converted to a list of stun absorption sources this mob has when one is added
	var/stam_regen_start_time = 0 //used to halt stamina regen temporarily
	/// A multiplier for the ammount of time it takes for someone to regenerate stamina damage.
	var/stamina_regen_block_modifier = 1
	var/stam_paralyzed = FALSE //knocks you down

	/// Number of degrees of rotation of a mob. 0 means no rotation, up-side facing NORTH. 90 means up-side rotated to face EAST, and so on.
	VAR_PROTECTED/lying_angle = 0
	/// if a mob is choosing to lay down
	var/resting = FALSE
	var/body_position = STANDING_UP
	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

	/// Used for preventing attacks on admin-frozen mobs.
	var/frozen = null
	/// Used for keeping track of previous sleeping value with admin freeze.
	var/admin_prev_sleeping = 0

	/// the type of holder that will be created when a mob gets scooped up
	var/holder_type

	/// This can either be a numerical direction or a soft object reference (UID). It makes the mob always face towards the selected thing.
	var/forced_look = null

	var/datum/language/default_language

	var/datum/middleClickOverride/middleClickOverride = null

	/// Famous last words -- if succumbing, what the user's last words were
	var/last_words

	///This variable is the chance for a mob to automatically dodge a bullet. Useful for admins, and applied to some mobs by default, such as the malfunctioning drone mobs.
	var/advanced_bullet_dodge_chance = 0

	/*
	Taste Vars
	*/
	/// Stores a var of the last world time we tasted something. used so we don't spam people messages while they eat
	var/last_taste_time
	/// Stores a var of the last tast message we got. used so we don't spam people messages while they eat
	var/last_taste_text
