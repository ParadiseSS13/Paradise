#define INVISIBILITY_MINIMUM 0 //not really minimum, but we will lie
#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING_AI 24

// Normal cult runes
#define INVISIBILITY_RUNES 25
#define SEE_INVISIBLE_LIVING 25

// Hidden cult runes
#define INVISIBILITY_HIDDEN_RUNES 30
#define SEE_INVISIBLE_HIDDEN_RUNES 30

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.

#define INVISIBILITY_SPIRIT 50
#define SEE_SPIRITS 50

/// Only observers can see this
#define INVISIBILITY_HIGH INVISIBILITY_OBSERVER - 1
/// Observer's vision without ghost vision
#define SEE_INVISIBLE_OBSERVER_NO_OBSERVERS SEE_INVISIBLE_OBSERVER - 1
/// Observer's invisibility
#define INVISIBILITY_OBSERVER 60
/// Observer's vision with ghost vision
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100

//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6

#define BORGMESON (1<<0)
#define BORGTHERM (1<<1)
#define BORGXRAY  (1<<2)

#define SECHUD 1
#define MEDHUD 2
#define ANTAGHUD 3

//for clothing visor toggles, these determine which vars to toggle
#define VISOR_FLASHPROTECT	(1<<0)
#define VISOR_TINT			(1<<1)
#define VISOR_VISIONFLAGS	(1<<2) //all following flags only matter for glasses
#define VISOR_DARKNESSVIEW	(1<<3)
#define VISOR_INVISVIEW		(1<<4)

// Should AI eyes be counted for get_mobs_in_view?
#define AI_EYE_EXCLUDE 0
#define AI_EYE_REQUIRE_HEAR 1
#define AI_EYE_INCLUDE 2
