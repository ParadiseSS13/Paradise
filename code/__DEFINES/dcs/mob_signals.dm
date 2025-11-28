/**
 * Signals for /mob, /mob/living, and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///called in human/login
#define	COMSIG_HUMAN_LOGIN "human_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of mob/death(): (gibbed)
#define COMSIG_MOB_DEATH "mob_death"
///from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
///from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)

///from base of mob/can_cast_magic(): (mob/user, magic_flags, charge_cost)
#define COMSIG_MOB_RESTRICT_MAGIC "mob_cast_magic"
///from base of mob/can_block_magic(): (mob/user, casted_magic_flags, charge_cost)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_MAGIC_BLOCKED (1<<0)

///from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_ALLOWED "mob_allowed"
///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
	#define COMPONENT_ITEM_NO_ATTACK (1<<0)
///from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_APPLY_DAMAGE	"mob_apply_damage"
///from base of obj/item/afterattack__legacy__attackchain(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
///called when a user willingly drops something (i.e. keybind, or UI action)
#define COMSIG_MOB_WILLINGLY_DROP "mob_willingly_drop"
///called when a user is getting new weapon and we want to remove previous weapon to clear hands
#define COMSIG_MOB_WEAPON_APPEARS "mob_weapon_appears"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	/* #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)

/// Signal fired when an emote is used but before it's executed.
///from /datum/emote/proc/try_run_emote(): (key, intentional)
#define COMSIG_MOB_PREEMOTE "mob_preemote"
	// Use these to block execution of emotes from components.
	/// Return this to block an emote and let the user know the emote is unusable.
	#define COMPONENT_BLOCK_EMOTE_UNUSABLE (1<<0)
	/// Return this to block an emote silently.
	#define COMPONENT_BLOCK_EMOTE_SILENT (1<<1)
/// General signal fired when a mob does any old emote
///from /datum/emote/proc/run_emote(): (key, intentional)
#define COMSIG_MOB_EMOTE "mob_emote"
/// Specific signal used to track when a specific emote is used.
/// From /datum/emote/run_emote(): (P, key, m_type, message, intentional)
#define COMSIG_MOB_EMOTED(emote_key) "mob_emoted_[emote_key]"
/// From /datum/emote/select_param(): (target, key, intentional)
#define COMSIG_MOB_EMOTE_AT "mob_emote_at"
	#define COMPONENT_BLOCK_EMOTE_ACTION (1<<2)

///from base of mob/swap_hand(): (obj/item)
#define COMSIG_MOB_SWAPPING_HANDS "mob_swapping_hands"
	/// Prevent the mob from changing hands
	#define COMPONENT_BLOCK_SWAP (1<<0)

/// Performed after the hands are swapped.
#define COMSIG_MOB_SWAPPED_HANDS "mob_swap_hands"

#define COMSIG_MOB_AUTOMUTE_CHECK "automute_check"
	#define WAIVE_AUTOMUTE_CHECK (1<<0)

///Called when movement intent is toggled.
#define COMSIG_MOVE_INTENT_TOGGLED "move_intent_toggled"

// /mob/living

///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///Sent from defibrillators when everything seems good and the user will be shocked: (defibber, defib_item, ghost)
#define COMSIG_LIVING_PRE_DEFIB "living_pre_defib"
	/// If returned from LIVING_BEFORE_DEFIB or LIVING_DEFIBBED, the defibrillation will fail
	#define COMPONENT_BLOCK_DEFIB (1<<0)
	/// If returned, don't even show the "failed" message, defer to the signal handler to do that.
	#define COMPONENT_DEFIB_OVERRIDE (1<<1)
	/// If returned, allow to revive through false death.
	#define COMPONENT_DEFIB_FAKEDEATH_ACCEPTED (1<<2)
	/// If returned, make the fake death look like a unresponsive ghost.
	#define COMPONENT_DEFIB_FAKEDEATH_DENIED (1<<3)
///send from defibs on ressurection: (defibber, defib_item, ghost)
#define COMSIG_LIVING_DEFIBBED "living_defibbed"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of /obj/item/bodypart/proc/attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_LIVING_ATTACH_LIMB "living_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
///from base of mob/living/health_update()
#define COMSIG_LIVING_HEALTH_UPDATE "living_health_update"
/// Sent during exfiltration to handle guardians
#define COMSIG_SUMMONER_EXTRACTED "summoner_extracted"
///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent when a mob enters a borg charger
#define COMSIG_ENTERED_BORGCHARGER "enter_charger"
///sent when a mob exits a borg charger
#define COMSIG_EXITED_BORGCHARGER "exit_charger"
///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"
///sent from living mobs every tick of fire
#define COMSIG_LIVING_FIRE_TICK "living_fire_tick"
//sent from living mobs when they are ahealed
#define COMSIG_LIVING_AHEAL "living_aheal"
//sent from mobs when they exit their body as a ghost
#define COMSIG_LIVING_GHOSTIZED "ghostized"
//sent from mobs when they re-enter their body as a ghost
#define COMSIG_LIVING_REENTERED_BODY "reentered_body"
//sent from a mob when they set themselves to DNR
#define COMSIG_LIVING_SET_DNR "set_dnr"

// /mob/living/carbon
/// Called from apply_overlay(cache_index, overlay)
#define COMSIG_CARBON_APPLY_OVERLAY "carbon_apply_overlay"
/// Called from remove_overlay(cache_index, overlay)
#define COMSIG_CARBON_REMOVE_OVERLAY "carbon_remove_overlay"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
// none of these are called as of right now, as there is nothing listening for them.
///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_WEAKEN "living_weaken"
///from base of mob/living/Knockdown() (amount, ignore_canstun)
///#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown" // one day
///from base of mob/living/Paralyse() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_PARALYSE "living_paralyse"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/Unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	#define COMPONENT_NO_STUN (1<<0)									//For all of them
///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)
/// from mob/living/*/UnarmedAttack(): (mob/living/source, atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"

///from base of mob/living/Write_Memory()
#define COMSIG_LIVING_WRITE_MEMORY "living_write_memory"
	#define COMPONENT_DONT_WRITE_MEMORY (1<<0)

// /mob/living/simple_animal signals
///from /mob/living/simple_animal/handle_environment()
#define COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT "simpleanimal_handle_environment"

///from of mob/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_DO_MOB_STRIP "do_mob_strip"
#define COMSIG_STRIPPABLE_REQUEST_ITEMS "strippable_request_items"

// Sent when a mob spawner is attacked directly or via projectile.
#define COMSIG_SPAWNER_SET_TARGET "spawner_set_target"

/// From /datum/element/basic_eating/try_eating()
#define COMSIG_MOB_PRE_EAT "mob_pre_eat"
	///cancel eating attempt
	#define COMSIG_MOB_CANCEL_EAT (1<<0)

/// From /datum/status_effect/incapacitating/sleeping/tick()
#define COMSIG_MOB_SLEEP_TICK "mob_sleep_tick"

/// From /datum/element/basic_eating/finish_eating()
#define COMSIG_MOB_ATE "mob_ate"
	///cancel post eating
	#define COMSIG_MOB_TERMINATE_EAT (1<<0)

/// Sent from /proc/do_after if someone starts a do_after action bar.
#define COMSIG_DO_AFTER_BEGAN "mob_do_after_began"
/// Sent from /proc/do_after once a do_after action completes, whether via the bar filling or via interruption.
#define COMSIG_DO_AFTER_ENDED "mob_do_after_ended"

// ghost signals

/// from observer_base/do_observe(): (mob/now_followed)
#define COMSIG_GHOST_START_OBSERVING "ghost_start_observing"
/// from observer_base/do_observe(): (mob/no_longer_following)
#define COMSIG_GHOST_STOP_OBSERVING "ghost_stop_observing"

// other signals

/// called when a living mob's stun status is cleared: ()
#define COMSIG_LIVING_CLEAR_STUNS "living_clear_stuns"
/// called when something needs to force a mindflayer to retract their weapon implants
#define COMSIG_FLAYER_RETRACT_IMPLANTS "flayer_retract_implants"

/// Sent from datum/spell/ethereal_jaunt/cast, before the mob enters jaunting as a pre-check: (mob/jaunter)
#define COMSIG_MOB_PRE_JAUNT "spell_mob_pre_jaunt"
	#define COMPONENT_BLOCK_JAUNT (1<<0)

/// from remove_ventcrawler(): (mob/living/crawler)
#define COMSIG_LIVING_EXIT_VENTCRAWL "living_exit_ventcrawl"

/// From base of /client/Move(): (new_loc, direction)
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	/// The argument of move_args which corresponds to the loc we're moving to
	#define MOVE_ARG_NEW_LOC 1
	/// The arugment of move_args which dictates our movement direction
	#define MOVE_ARG_DIRECTION 2

#define COMSIG_LIVING_RESTING "living_resting"

/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_BEFRIENDED "living_befriended"

/// From /mob/living/unfriend() : (mob/living/old_friend)
#define COMSIG_LIVING_UNFRIENDED "living_unfriended"

/// From the base of /datum/component/callouts/proc/callout_picker(mob/user, atom/clicked_atom): (datum/callout_option/callout, atom/target)
#define COMSIG_MOB_CREATED_CALLOUT "mob_created_callout"

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_PRE_ATTACK_RANGED "basicmob_pre_attack_ranged"
	#define COMPONENT_CANCEL_RANGED_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //! Cancel to prevent the attack from happening

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_POST_ATTACK_RANGED "basicmob_post_attack_ranged"

/// From base of /datum/action/cooldown/proc/PreActivate(), sent to the action owner: (datum/action/cooldown/activated)
#define COMSIG_MOB_ABILITY_STARTED "mob_ability_base_started"
	/// Return to block the ability from starting / activating
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// From base of /datum/action/cooldown/proc/PreActivate(), sent to the action owner: (datum/action/cooldown/finished)
#define COMSIG_MOB_ABILITY_FINISHED "mob_ability_base_finished"

/// From base of /datum/action/cooldown/proc/set_statpanel_format(): (list/stat_panel_data)
#define COMSIG_ACTION_SET_STATPANEL "ability_set_statpanel"

/// Fired by a mob which has been grabbed by a goliath
#define COMSIG_GOLIATH_TENTACLED_GRABBED "goliath_tentacle_grabbed"
/// Fired by a goliath tentacle which is returning to the earth
#define COMSIG_GOLIATH_TENTACLE_RETRACTING 	"goliath_tentacle_retracting"

/// Called from /mob/living/carbon/help_shake_act, before any hugs have occurred. (mob/living/helper)
#define COMSIG_CARBON_PRE_MISC_HELP "carbon_pre_misc_help"
	/// Stops the rest of help act (hugging, etc) from occurring
	#define COMPONENT_BLOCK_MISC_HELP (1<<0)

/// From base of /client/Move(): (direction, old_dir)
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"
