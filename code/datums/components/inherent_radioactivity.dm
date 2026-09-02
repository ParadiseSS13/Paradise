/datum/component/inherent_radioactivity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/radioactivity_alpha
	var/radioactivity_beta
	var/radioactivity_gamma
	/// Contamination cooldown in seconds
	var/contaminate_cd
	var/contained = FALSE
	COOLDOWN_DECLARE(contaminate_cooldown)

/datum/component/inherent_radioactivity/Initialize(_radioactivity_alpha = 0, _radioactivity_beta = 0, _radioactivity_gamma = 0, _contaminate_cd = 1.5)
	radioactivity_alpha = _radioactivity_alpha
	radioactivity_beta = _radioactivity_beta
	radioactivity_gamma = _radioactivity_gamma
	contaminate_cd = _contaminate_cd
	RegisterSignal(parent, list(COMSIG_MOVABLE_IMPACT, COMSIG_ATOM_HITBY), PROC_REF(impact_contaminate))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(try_contaminate_hand))
	if(isitem(parent))
		RegisterSignal(parent, list(COMSIG_ATTACK, COMSIG_ATTACK_OBJ), PROC_REF(impact_contaminate))
	START_PROCESSING(SSradiation, src)

/datum/component/inherent_radioactivity/proc/impact_contaminate(atom/source, atom/target)
	SIGNAL_HANDLER
	if(contaminate_cd <= 0 || COOLDOWN_FINISHED(src, contaminate_cooldown))
		if(radioactivity_alpha)
			target.contaminate_atom(source, radioactivity_alpha, ALPHA_RAD)
		if(radioactivity_beta)
			target.contaminate_atom(source, radioactivity_beta, BETA_RAD)
		if(radioactivity_gamma)
			target.contaminate_atom(source, radioactivity_gamma, GAMMA_RAD)
		if(contaminate_cd > 0)
			COOLDOWN_START(src, contaminate_cooldown, contaminate_cd SECONDS)

/datum/component/inherent_radioactivity/proc/try_contaminate_hand(atom/source, atom/target)
	SIGNAL_HANDLER
	if(contaminate_cd <= 0 || COOLDOWN_FINISHED(src, contaminate_cooldown))
		if(radioactivity_alpha)
			target.contaminate_atom(source, radioactivity_alpha, ALPHA_RAD, HANDS)
		if(radioactivity_beta)
			target.contaminate_atom(source, radioactivity_beta, BETA_RAD, HANDS)
		if(radioactivity_gamma)
			target.contaminate_atom(source, radioactivity_gamma, GAMMA_RAD, HANDS)
		if(contaminate_cd > 0)
			COOLDOWN_START(src, contaminate_cooldown, contaminate_cd SECONDS)

/datum/component/inherent_radioactivity/InheritComponent(datum/component/C, i_am_original, _radioactivity_alpha = 0,  _radioactivity_beta = 0, _radioactivity_gamma = 0, _contaminate_cd = 1.5)
	if(!i_am_original)
		return
	if(C)
		var/datum/component/inherent_radioactivity/other = C
		radioactivity_alpha = other.radioactivity_alpha
		radioactivity_beta = other.radioactivity_beta
		radioactivity_gamma = other.radioactivity_gamma
		contaminate_cd = other.contaminate_cd
	else
		radioactivity_alpha = _radioactivity_alpha
		radioactivity_beta = _radioactivity_beta
		radioactivity_gamma = _radioactivity_gamma
		contaminate_cd = _contaminate_cd

/datum/component/inherent_radioactivity/process()
	if(radioactivity_alpha > 0)
		contaminate_adjacent(parent, radioactivity_alpha, ALPHA_RAD)
		radiation_pulse(parent, 2 * radioactivity_alpha, ALPHA_RAD)
	if(radioactivity_beta > 0)
		contaminate_adjacent(parent, radioactivity_beta, BETA_RAD)
		radiation_pulse(parent, 2 * radioactivity_beta, BETA_RAD)
	if(radioactivity_gamma > 0)
		contaminate_adjacent(parent, radioactivity_gamma, GAMMA_RAD)
		radiation_pulse(parent, 2 * radioactivity_gamma, GAMMA_RAD)

	SSradiation.update_rad_cache_inherent(src)
