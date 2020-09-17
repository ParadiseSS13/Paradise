#define INSTRUMENT_MIN_OCTAVE 1
#define INSTRUMENT_MAX_OCTAVE 9
#define INSTRUMENT_MIN_KEY 0
#define INSTRUMENT_MAX_KEY 127

/// Max number of playing notes per instrument.
#define CHANNELS_PER_INSTRUMENT 128

/// Distance multiplier that makes us not be impacted by 3d sound as much. This is a multiplier so lower it is the closer we will pretend to be to people.
#define INSTRUMENT_DISTANCE_FALLOFF_BUFF 0.2
/// How many tiles instruments have no falloff for
#define INSTRUMENT_DISTANCE_NO_FALLOFF 3

/// Maximum length a note should ever go for
#define INSTRUMENT_MAX_TOTAL_SUSTAIN (5 SECONDS)

/// These are per decisecond.
#define INSTRUMENT_EXP_FALLOFF_MIN			1.025		//100/(1.025^50) calculated for [INSTRUMENT_MIN_SUSTAIN_DROPOFF] to be 30.
#define INSTRUMENT_EXP_FALLOFF_MAX			10

/// Minimum volume for when the sound is considered dead.
#define INSTRUMENT_MIN_SUSTAIN_DROPOFF 0.1

#define SUSTAIN_LINEAR 1
#define SUSTAIN_EXPONENTIAL 2

// /datum/instrument instrument_flags
#define INSTRUMENT_LEGACY (1<<0)					//Legacy instrument. Implies INSTRUMENT_DO_NOT_AUTOSAMPLE
#define INSTRUMENT_DO_NOT_AUTOSAMPLE (1<<1)			//Do not automatically sample
