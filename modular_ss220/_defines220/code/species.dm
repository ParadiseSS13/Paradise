#define isnucleation(A) (is_species(A, /datum/species/nucleation))

//MATERIAL CLASS FOR RACE EAT
#define MATERIAL_CLASS_NONE     0
#define MATERIAL_CLASS_CLOTH    1
#define MATERIAL_CLASS_TECH		2
#define MATERIAL_CLASS_SOAP		3
#define MATERIAL_CLASS_RAD		4
#define MATERIAL_CLASS_PLASMA	5

/// Базовое время погрузки ящиков/мобов на куклу
#define GADOM_BASIC_LOAD_TIMER 2 SECONDS

#define isserpentid(A) (is_species(A, /datum/species/serpentid))

/// Трейт ТТСа для робо рас
#define TTS_TRAIT_ROBOTIZE "tts_trait_robotize"

/mob/living/carbon/human
	var/atom/movable/loaded = null
	var/mob/living/passenger = null
