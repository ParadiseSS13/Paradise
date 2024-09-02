/**
 * Signals for /mob/living/carbon and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
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
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
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
