// Signals for /mob/living

/// from mob/living/Life(): (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"

/// from mob/living/handle_message_mode(): (message_mode, list/message_pieces, verb, used_radios)
#define COMSIG_LIVING_HANDLE_MESSAGE_MODE "living_handle_message_mode"
	#define COMPONENT_FORCE_WHISPER (1<<0)

/// from mob/living/CanPass(): (atom/movable/mover, turf/target, height)
#define COMSIG_LIVING_CAN_PASS "living_can_pass"
	#define COMPONENT_LIVING_PASSABLE (1<<0)
