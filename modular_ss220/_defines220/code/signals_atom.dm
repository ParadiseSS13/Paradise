/// called by /obj/structure/table/do_climb() : (/datum/component/clumsy_climb)
#define COMSIG_CLIMBED_ON 	"climb_on"
/// called by /datum/emote/living/dance/run_emote() : (/datum/component/clumsy_climb)
#define COMSIG_DANCED_ON 	"dance_on"
/// called by /datum/species/spec_attack_hand() : (/datum/component/gadom_cargo) (/datum/component/gadom_living)
#define COMSIG_GADOM_UNLOAD "gadom_unload"
/// called by /datum/surgery_step/finish_carapace/end_step() : (/datum/component/carapace_shell)
#define COMSIG_SURGERY_REPAIR "surgery_repair"
/// called by /datum/surgery/bone_repair/carapace_shell/can_start() : (/datum/component/carapace_shell)
#define COMSIG_SURGERY_STOP "surgery_stop"
	#define SURGERY_STOP (1<<0)
