/**
 * Signals for /mob/living/carbon and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
/// From /mob/living/carbon/swap_hand(): Called when the user swaps their active hand
#define COMSIG_CARBON_SWAP_HANDS "carbon_swap_hands"
/// From /mob/living/carbon/toggle_throw_mode()
#define COMSIG_CARBON_TOGGLE_THROW "carbon_toggle_throw"
/// From /mob/living/carbon/human/hitby()
#define COMSIG_CARBON_THROWN_ITEM_CAUGHT "carbon_thrown_item_caught"
/// From /mob/living/carbon/flash_eyes()
#define COMSIG_CARBON_FLASH_EYES "carbon_flash_eyes"
/// From /mob/living/carbon/update_handcuffed()
#define COMSIG_CARBON_UPDATE_HANDCUFFED "carbon_update_handcuff"
/// From /mob/living/carbon/regenerate_icons()
#define COMSIG_CARBON_REGENERATE_ICONS "carbon_regen_icons"
/// From /mob/living/carbon/enter_stamcrit()
#define COMSIG_CARBON_ENTER_STAMINACRIT "carbon_enter_staminacrit"
/// From /mob/living/carbon/update_stamina()
#define COMSIG_CARBON_EXIT_STAMINACRIT "carbon_exit_staminacrit"
/// From /mob/living/carbon/handle_status_effects()
#define COMSIG_CARBON_STAMINA_REGENERATED "carbon_stamina_regenerated"


///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
// called after DNA is updated
#define COMSIG_HUMAN_UPDATE_DNA "human_update_dna"
/// From mob/living/carbon/human/change_body_accessory(): (mob/living/carbon/human/H, body_accessory_style)
#define COMSIG_HUMAN_CHANGE_BODY_ACCESSORY "human_change_body_accessory"
	#define COMSIG_HUMAN_NO_CHANGE_APPEARANCE (1<<0)
/// From mob/living/carbon/human/change_head_accessory(): (mob/living/carbon/human/H, head_accessory_style)
#define COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY "human_change_head_accessory"
//sent from living mobs when they parry
#define COMSIG_HUMAN_PARRY "human_parry"
///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMP "living_mob_bump"
///From mob/living/carbon/human/do_suicide()
#define COMSIG_HUMAN_SUICIDE_ACT "human_suicide_act"
/// Sent from mob/living/carbon/human/do_cpr(): (mob/living/carbon/human/H, new_seconds_of_life)
#define COMSIG_HUMAN_RECEIVE_CPR "human_receive_cpr"

///From mob/living/carbon/human/attackedby(): (mob/living/carbon/human/attacker). Also found on species/disarm and species/harm
#define COMSIG_HUMAN_ATTACKED "human_attacked"

///from /mob/living/carbon/human/proc/check_shields(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
#define COMSIG_HUMAN_CHECK_SHIELDS "human_check_shields"
	#define SHIELD_BLOCK (1<<0)

///from /mob/living/carbon/human/create_mob_hud()
#define COMSIG_HUMAN_CREATE_MOB_HUD "human_create_mob_hud"

/// Sent at the end of /human/electrocute_act()
#define COMSIG_HUMAN_ELECTROCUTE_POST_ACT "human_electrocute_post_act"
/// Sent near the start of /human/emp_act() in the event of the mob having TRAIT_EMP_RESIST
#define COMSIG_HUMAN_EMP_RESIST_SIGNAL "human_emp_resist_signal"
/// Sent near the start of /human/emp_act() in the event of the mob having TRAIT_EMP_IMMUNE
#define COMSIG_HUMAN_EMP_IMMUNE_SIGNAL "human_emp_immune_signal"
/// Sent at the end of /human/emp_act()
#define COMSIG_HUMAN_EMP_POST_ACT "human_emp_post_act"

// Species signals, putting here because it fits best
/// Sent at the end of /species/spec_electrocute_act()
#define COMSIG_SPECIES_SPEC_ELECTROCUTE_POST_ACT "species_spec_electrocute_post_act"
