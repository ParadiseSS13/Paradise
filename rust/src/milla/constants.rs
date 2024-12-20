/// How many Z levels we allow before being suspicious that the wrong number was sent.
pub(crate) const MAX_Z_LEVELS: i32 = 10;

/// How big is the map? Assumed square.
pub(crate) const MAP_SIZE: usize = 255;

/// The temperature of space, in Kelvin
pub(crate) const TCMB: f32 = 2.725;

/// 0 degrees Celsius, in Kelvin
pub(crate) const T0C: f32 = 273.15;

/// 20 degrees Celsius, in Kelvin
pub(crate) const T20C: f32 = T0C + 20.0;

/// How well does heat transfer in ideal circumstances?
pub(crate) const OPEN_HEAT_TRANSFER_COEFFICIENT: f32 = 0.4;

/// The constant R from the ideal gas equation.
pub(crate) const R_IDEAL_GAS_EQUATION: f32 = 8.31;

/// How big a tile is, in liters.
pub(crate) const TILE_VOLUME: f32 = 2500.0;

/// How many moles of toxins are needed for a fire to exist. For reasons, this is also how hany
/// moles are needed to be visible.
pub(crate) const TOXINS_MIN_VISIBILITY_MOLES: f32 = 0.5;

/// How many moles are needed to make sleeping gas visible.
pub(crate) const SLEEPING_GAS_VISIBILITY_MOLES: f32 = 1.0;

/// How much stuff needs to react before we think hotspots and BYOND care.
pub(crate) const REACTION_SIGNIFICANCE_MOLES: f32 = 0.01;

/// How hot does it need to be for Agent B to work?
pub(crate) const AGENT_B_CONVERSION_TEMP: f32 = 900.0;

/// How hot does it need to be for sleeping gass to break down?
pub(crate) const SLEEPING_GAS_BREAKDOWN_TEMP: f32 = 1400.0;

/// Index for oxygen in gas list.
pub(crate) const GAS_OXYGEN: usize = 0;

/// Index for carbon dioxide in gas list.
pub(crate) const GAS_CARBON_DIOXIDE: usize = 1;

/// Index for nitrogen in gas list.
pub(crate) const GAS_NITROGEN: usize = 2;

/// Index for toxins in gas list.
pub(crate) const GAS_TOXINS: usize = 3;

/// Index for sleeping agent in gas list.
pub(crate) const GAS_SLEEPING_AGENT: usize = 4;

/// Index for agent b in gas list.
pub(crate) const GAS_AGENT_B: usize = 5;

/// How many gases are there?
pub(crate) const GAS_COUNT: usize = GAS_AGENT_B + 1;

/// The two axes, Y and X. The order is arbitrary, but may break things if changed.
pub(crate) const AXES: [(i32, i32); 2] = [(1, 0), (0, 1)];

/// The index of the X axis in AXES.
pub(crate) const AXIS_X: usize = 0;
/// The index of the Y axis in AXES.
pub(crate) const AXIS_Y: usize = 1;

/// The four directions: up, down, right, and left. The order is arbitrary, but may break things if changed.
pub(crate) const DIRECTIONS: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, -1), (0, 1)];

/// Gives the axis for each direction.
pub(crate) const DIRECTION_AXIS:  [usize; 4] = [0, 0, 1, 1];

/// Index for incoming gas.
pub(crate) const GAS_FLOW_IN: usize = 0;

/// Index for outgoing gas.
pub(crate) const GAS_FLOW_OUT: usize = 1;

// The numbers here are completely wrong for actual gases, but they're what LINDA used, so we'll
// keep them for now.

// The specific heat of oxygen, in joules per kelvin-mole.
pub(crate) const SPECIFIC_HEAT_OXYGEN: f32 = 20.0;

// The specific heat of carbon dioxide, in joules per kelvin-mole.
pub(crate) const SPECIFIC_HEAT_CARBON_DIOXIDE: f32 = 30.0;

// The specific heat of nitrogen, in joules per kelvin-mole.
pub(crate) const SPECIFIC_HEAT_NITROGEN: f32 = 20.0;

// The specific heat of toxins, in joules per kelvin-mole.
pub(crate) const SPECIFIC_HEAT_TOXINS: f32 = 200.0;

// The specific heat of sleeping agent, in joules per kelvin-mole.
pub(crate) const SPECIFIC_HEAT_SLEEPING_AGENT: f32 = 40.0;

// The specific heat of agent b, in joules per kelvin-mole.
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

/// How hot does it need to be for a plasma fire to start?
pub(crate) const PLASMA_BURN_MIN_TEMP: f32 = 100.0 + T0C;

/// How hot does it need to be for a plasma fire to work as well as possible?
pub(crate) const PLASMA_BURN_OPTIMAL_TEMP: f32 = 1370.0 + T0C;

/// How much of the plasma are we willing to burn each tick?
pub(crate) const PLASMA_BURN_MAX_RATIO: f32 = 0.01;

/// How much of the plasma do we burn anyway if the ratio would make it really small?
pub(crate) const PLASMA_BURN_MIN_MOLES: f32 = 0.1;

/// How much of a boost to burn ratio do we give to hotspots?
pub(crate) const PLASMA_BURN_HOTSPOT_RATIO_BOOST: f32 = 10.0;

/// How much oxygen do we use per plasma?
pub(crate) const PLASMA_BURN_OXYGEN_PER_PLASMA: f32 = 0.4;

/// How much thermal energy is produced, in joules per mole of agent b.
pub(crate) const AGENT_B_CONVERSION_ENERGY: f32 = 20_000.0;

/// How much thermal energy is produced, in joules per mole of sleeping agent.
pub(crate) const NITROUS_BREAKDOWN_ENERGY: f32 = 200_000.0;

/// How much thermal energy is produced, in joules per mole of sleeping toxins.
pub(crate) const PLASMA_BURN_ENERGY: f32 = 3_000_000.0;

/// We allow small deviations in tests as our spring chain solution is not exact.
#[cfg(test)]
pub(crate) const TEST_TOLERANCE: f32 = 0.1;

/// Lose this amount of heat energy per tick if above 100 C.
pub(crate) const SPACE_COOLING_CAPACITY: f32 = 2000.0;

/// Tiles with less than this much gas will become empty.
pub(crate) const MINIMUM_NONZERO_MOLES: f32 = 0.1;

/// How many iterations of gas flow are we willing to run per tick?
pub(crate) const MAX_ITERATIONS: usize = 100;

/// When we stop caring about gas changes and end iteration, in moles on a single tile.
pub(crate) const GAS_CHANGE_SIGNIFICANCE: f32 = 0.01;

/// When we stop caring about gas changes and end iteration, roughly as a fraction of the gas.
pub(crate) const GAS_CHANGE_SIGNIFICANCE_FRACTION: f32 = 0.001;

/// When we stop caring about thermal energy changes and end iteration, in thermal energy on a
/// single tile.
pub(crate) const THERMAL_CHANGE_SIGNIFICANCE: f32 = 0.1;

/// When we stop caring about thermal energy changes and end iteration, roughly as a fraction of
/// the thermal energy.
pub(crate) const THERMAL_CHANGE_SIGNIFICANCE_FRACTION: f32 = 0.001;

/// How strongly we want to diffuse gas types across equal pressure tiles.
pub(crate) const DIFFUSION_FACTOR: f32 = 0.5;

/// How strongly we want the pressure+wind bias to move gases across tiles.
pub(crate) const BIAS_FACTOR: f32 = 10.0;

/// How much the previous tick's wind contributes to this tick's bias.
pub(crate) const OLD_WIND_FACTOR: f32 = 0.95;
/// How much this tick's pressure difference contributes to this tick's bias.
pub(crate) const NEW_PRESSURE_FACTOR: f32 = 0.1;

/// How much are we willing to bias?
pub(crate) const MAX_BIAS: f32 = 1.0;

/// How fast should temperature flow?
pub(crate) const TEMPERATURE_FLOW_RATE: f32 = 100.0;

/// Balancing factor to adjust the strength of wind reported to BYOND.
pub(crate) const WIND_MULTIPLIER: f32 = 1.0;

/// The smallest temperature allowed for the purpose of caluclating pressure.
/// Prevents weirdness from absolute-zero gas having no pressure at all.
pub(crate) const MINIMUM_TEMPERATURE_FOR_PRESSURE: f32 = 1.0;
