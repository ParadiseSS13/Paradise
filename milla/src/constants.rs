pub(crate) const MAX_Z_LEVELS: i32 = 10;

pub(crate) const T0C: f32 = 273.15;

pub(crate) const T20C: f32 = T0C + 20.0;

pub(crate) const OPEN_HEAT_TRANSFER_COEFFICIENT: f32 = 0.4;

pub(crate) const R_IDEAL_GAS_EQUATION: f32 = 8.31;

//kPa
pub(crate) const TILE_VOLUME: f32 = 2500.0;

pub(crate) const TOXINS_VISIBILITY_MOLES: f32 = 0.5;

pub(crate) const SLEEPING_GAS_VISIBILITY_MOLES: f32 = 1.0;

pub(crate) const REACTION_SIGNIFICANCE_MOLES: f32 = 0.01;

pub(crate) const AGENT_B_CONVERSION_TEMP: f32 = 900.0;

pub(crate) const SLEEPING_GAS_BREAKDOWN_TEMP: f32 = 1400.0;

pub(crate) const MAP_SIZE: usize = 255;

// Gas amounts, in moles.
pub(crate) const GAS_OXYGEN: usize = 0;

pub(crate) const GAS_CARBON_DIOXIDE: usize = 1;

pub(crate) const GAS_NITROGEN: usize = 2;

pub(crate) const GAS_TOXINS: usize = 3;

pub(crate) const GAS_SLEEPING_AGENT: usize = 4;

pub(crate) const GAS_AGENT_B: usize = 5;

// How many gases are there?
pub(crate) const GAS_COUNT: usize = GAS_AGENT_B + 1;

// The two axes, Y and X. The order is arbitrary, but will break the copy from active to inactive
// if changed.
pub(crate) const AXES: [(i32, i32); 2] = [(0, 1), (1, 0)];

// The four cardinal directions. The order is arbitrary, and doesn't matter.
pub(crate) const DIRECTIONS: [(i32, i32); 4] = [(0, 1), (1, 0), (0, -1), (-1, 0)];

// The specific heat of each gas, in joules per kelvin-mole.
// The numbers here are completely wrong for actual gases, but they're what LINDA used, so we'll
// keep them for now.
pub(crate) const SPECIFIC_HEAT_OXYGEN: f32 = 20.0;

pub(crate) const SPECIFIC_HEAT_CARBON_DIOXIDE: f32 = 30.0;

pub(crate) const SPECIFIC_HEAT_NITROGEN: f32 = 20.0;

pub(crate) const SPECIFIC_HEAT_TOXINS: f32 = 200.0;

pub(crate) const SPECIFIC_HEAT_SLEEPING_AGENT: f32 = 40.0;

pub(crate) const SPECIFIC_HEAT_AGENT_B: f32 = 300.0;

// Convenience array, so we can add loop through gases and calculate heat capacity.
pub(crate) const SPECIFIC_HEATS: [f32; GAS_COUNT] = [
    SPECIFIC_HEAT_OXYGEN,
    SPECIFIC_HEAT_CARBON_DIOXIDE,
    SPECIFIC_HEAT_NITROGEN,
    SPECIFIC_HEAT_TOXINS,
    SPECIFIC_HEAT_SLEEPING_AGENT,
    SPECIFIC_HEAT_AGENT_B,
];

// Plasmafire constants, see usage for details.
pub(crate) const PLASMA_BURN_MIN_TEMP: f32 = 100.0 + T0C;

pub(crate) const PLASMA_BURN_OPTIMAL_TEMP: f32 = 1370.0 + T0C;

pub(crate) const PLASMA_BURN_REQUIRED_OXYGEN_AVAILABILITY: f32 = 10.0;

pub(crate) const PLASMA_BURN_MAX_RATIO: f32 = 0.25;

pub(crate) const PLASMA_BURN_WORST_OXYGEN_PER_PLASMA: f32 = 1.4;

pub(crate) const PLASMA_BURN_BEST_OXYGEN_PER_PLASMA: f32 = 0.4;

// How much thermal energy each reaction produces, in joules per mole of "fuel", whichever gas that
// is.
pub(crate) const AGENT_B_CONVERSION_ENERGY: f32 = 20_000.0;

pub(crate) const NITROUS_BREAKDOWN_ENERGY: f32 = 200_000.0;

pub(crate) const PLASMA_BURN_ENERGY: f32 = 3_000_000.0;

/// We allow small deviations in tests, so that floating point precision doesn't cause problems.
#[cfg(test)]
pub(crate) const TEST_TOLERANCE: f32 = 0.00001;
