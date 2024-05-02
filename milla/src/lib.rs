// This is the MILLA atmospherics system, a successor to LINDA.
// MILLA stands for Multi-threaded, Improved, Low-Level Atmospherics
// (Or it's just a Psychonauts reference.)
// Some folks have also taken to calling it funnymos, after the author, FunnyMan.
//
// MILLA takes the majority of atmos out of BYOND and puts it here, in Rust code.
// It stores its own model of the air distribution, and BYOND will call in to view and make
// adjustments, as well as to trigger atmos ticks.
//
// Search for #[byondapi::bind] to find the functions exposed to BYOND.

use byondapi::{byond_string, prelude::*, Error};
use eyre::{eyre, Result};
use std::array::TryFromSliceError;
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use std::sync::RwLock;
use std::sync::{Mutex, OnceLock};
use std::thread;
use std::thread::ScopedJoinHandle;

// Simple logging function, appends to ./rust_log.txt
#[allow(dead_code)]
fn write_log<T: AsRef<[u8]>>(x: T) {
    let mut f = File::options()
        .create(true)
        .append(true)
        .open("./milla_log.txt")
        .unwrap();
    writeln!(&mut f, "{}", String::from_utf8_lossy(x.as_ref())).unwrap();
}

// Panic handler that dumps info out to ./rust_panic.txt (overwriting) if we crash.
fn setup_panic_handler() {
    std::panic::set_hook(Box::new(|info| {
        std::fs::write("./milla_panic.txt", format!("Panic {:#?}", info)).unwrap();
    }))
}

const T0C: f32 = 273.15;
const T20C: f32 = T0C + 20.0;
const OPEN_HEAT_TRANSFER_COEFFICIENT: f32 = 0.4;
const R_IDEAL_GAS_EQUATION: f32 = 8.31; //kPa*L/(K*mol)
const ONE_ATMOSPHERE: f32 = 101.325; //kPa
const TILE_VOLUME: f32 = 2500.0; //liters
const STANDARD_TILE_MOLES: f32 = TILE_VOLUME * ONE_ATMOSPHERE / (T20C * R_IDEAL_GAS_EQUATION);
const STANDARD_OXYGEN_PERCENTAGE: f32 = 0.21;
const STANDARD_NITROGEN_PERCENTAGE: f32 = 0.79;
const STANDARD_OXYGEN_MOLES: f32 = STANDARD_OXYGEN_PERCENTAGE * STANDARD_TILE_MOLES;
const STANDARD_NITROGEN_MOLES: f32 = STANDARD_NITROGEN_PERCENTAGE * STANDARD_TILE_MOLES;
const LAVALAND_OXYGEN_MOLES: f32 = 8.0;
const LAVALAND_NITROGEN_MOLES: f32 = 14.0;

const MAP_SIZE: usize = 255;

// Tile is exposed to space, and will lose all of its air every tick.
// This is the default.
const ATMOS_MODE_SPACE: i32 = 0;
// Tile is sealed and will not lose air to space, but has no special effects.
#[allow(dead_code)]
const ATMOS_MODE_SEALED: i32 = 1;
// Tile is exposed to Lavaland air.
const ATMOS_MODE_LAVALAND: i32 = 2;
// Tile is exposed to Earth-like air.
const ATMOS_MODE_EARTHLIKE: i32 = 3;

// Whether gas flow is blocked in each direction.
const ATMOS_BLOCKED_NORTH: usize = 0;
const ATMOS_BLOCKED_EAST: usize = 1;
const ATMOS_BLOCKED_SOUTH: usize = 2;
const ATMOS_BLOCKED_WEST: usize = 3;
// This is an enum, see above.
const ATMOS_MODE: usize = 4;
// What temperature is the external environment, if any?
const ATMOS_EXTERNAL_TEMPERATURE: usize = 5;
// Gas amounts, in moles.
const ATMOS_OXYGEN: usize = 6;
const ATMOS_CARBON_DIOXIDE: usize = 7;
const ATMOS_NITROGEN: usize = 8;
const ATMOS_TOXINS: usize = 9;
const ATMOS_SLEEPING_AGENT: usize = 10;
const ATMOS_AGENT_B: usize = 11;
// Thermal energy, in joules.
const ATMOS_THERMAL_ENERGY: usize = 12;
// The thermal conductivity in each direction. Starts at OPEN_HEAT_TRANSFER_COEFFICIENT, but can be
// reduced by the tile and its contents.
const ATMOS_SUPERCONDUCTIVITY_NORTH: usize = 13;
const ATMOS_SUPERCONDUCTIVITY_EAST: usize = 14;
const ATMOS_SUPERCONDUCTIVITY_SOUTH: usize = 15;
const ATMOS_SUPERCONDUCTIVITY_WEST: usize = 16;
// How much heat capacity the tile itself adds, in joules per kelvin, in addition to any air on it.
const ATMOS_INNATE_HEAT_CAPACITY: usize = 17;

// How many gases are there?
const GAS_COUNT: usize = ATMOS_AGENT_B - ATMOS_OXYGEN + 1;
// Where is the first one?
const GAS_OFFSET: usize = ATMOS_OXYGEN;
// The total number of atmos fields.
const ATMOS_DEPTH: usize = ATMOS_INNATE_HEAT_CAPACITY + 1;

// The two axes, Y and X. The order is arbitrary, but will break the copy from active to inactive
// if changed.
const AXES: [(i32, i32); 2] = [(0, 1), (1, 0)];
// The four cardinal directions. The order is arbitrary, and doesn't matter.
const DIRECTIONS: [(i32, i32); 4] = [(0, 1), (1, 0), (0, -1), (-1, 0)];

// The specific heat of each gas, in joules per kelvin-mole.
// The numbers here are completely wrong for actual gases, but they're what LINDA used, so we'll
// keep them for now.
const SPECIFIC_HEAT_OXYGEN: f32 = 20.0;
const SPECIFIC_HEAT_CARBON_DIOXIDE: f32 = 30.0;
const SPECIFIC_HEAT_NITROGEN: f32 = 20.0;
const SPECIFIC_HEAT_TOXINS: f32 = 200.0;
const SPECIFIC_HEAT_SLEEPING_AGENT: f32 = 40.0;
const SPECIFIC_HEAT_AGENT_B: f32 = 300.0;

// Convenience array, so we can add loop through gases and calculate heat capacity.
const SPECIFIC_HEATS: [f32; GAS_COUNT] = [
    SPECIFIC_HEAT_OXYGEN,
    SPECIFIC_HEAT_CARBON_DIOXIDE,
    SPECIFIC_HEAT_NITROGEN,
    SPECIFIC_HEAT_TOXINS,
    SPECIFIC_HEAT_SLEEPING_AGENT,
    SPECIFIC_HEAT_AGENT_B,
];

// Plasmafire constants, see usage for details.
const PLASMA_BURN_MIN_TEMP: f32 = 100.0 + T0C;
const PLASMA_BURN_OPTIMAL_TEMP: f32 = 1370.0 + T0C;
const PLASMA_BURN_MAX_OXYGEN_AVAILABILITY: f32 = 10.0;
const PLASMA_BURN_MAX_RATIO: f32 = 0.25;
const PLASMA_BURN_WORST_OXYGEN_PER_PLASMA: f32 = 1.4;
const PLASMA_BURN_BEST_OXYGEN_PER_PLASMA: f32 = 0.4;

// How much thermal energy each reaction produces, in joules per mole of "fuel", whichever gas that
// is.
const AGENT_B_CONVERSION_ENERGY: f32 = 20_000.0;
const NITROUS_BREAKDOWN_ENERGY: f32 = 200_000.0;
const PLASMA_BURN_ENERGY: f32 = 3_000_000.0;

// Which of the two buffers is active?
enum ActiveBuffer {
    A,
    B,
}

// The value that's used to determine which buffer is active.
//
// Data type explanation:
// * OnceLock is how we make a safe static variable, by ensuring it will be initialized exactly
//   once.
// * Mutex lets us read and write that variable safely across threads.
// * It's fundamentally an ActiveBuffer enum value.
static BUFFER_FLIPPER: OnceLock<Mutex<ActiveBuffer>> = OnceLock::new();

// The two buffers that we flip between.
// Whichever buffer is active represents the current tick, and is the only thing BYOND can see.
// Normally, the active buffer is read-write.
//
// During tick(), things change:
// * The active buffer is now read-only, as it represents the values from the previous tick.
// * The inactive buffer is now available read-write, as it represents the values of the next tick,
//   the ones we're currently computing.
// Note that we do read some values from the inactive buffer here, as they are intermediate results
// during computation.
//
// Data type explanation:
// * OnceLock and Mutex are used as in BUFFER_FLIPPER.
// * HashMap maps Z-levels to their buffer.
// * RwLock allows us to borrow the buffers independently of each other, so we can thread across
//   them.
// * Box places the data on the heap, so we don't overflow our stack.
// * Each buffer is fundamentally a large array of f32s.
static ATMOS_A: OnceLock<
    Mutex<HashMap<i32, RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>>>,
> = OnceLock::new();
static ATMOS_B: OnceLock<
    Mutex<HashMap<i32, RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>>>,
> = OnceLock::new();

// The list of interesting tiles, built during tick() and fetched by BYOND before the next tick.
//
// Data type explanation:
// * OnceLock and Mutex are used as in BUFFER_FLIPPER.
// * It's fundamentally a vector of InterestingTile structs.
static INTERESTING_TILES: OnceLock<Mutex<Vec<InterestingTile>>> = OnceLock::new();

// Fetches the active buffer map, the HashMap in either ATMOS_A or ATMOS_B, initializing the HashMap
// if needed.
fn get_active_atmos_buffer_map(
) -> &'static Mutex<HashMap<i32, RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>>> {
    let flipper = BUFFER_FLIPPER.get_or_init(|| Mutex::new(ActiveBuffer::A));
    match *flipper.lock().unwrap() {
        ActiveBuffer::A => ATMOS_A.get_or_init(|| Mutex::new(HashMap::new())),
        ActiveBuffer::B => ATMOS_B.get_or_init(|| Mutex::new(HashMap::new())),
    }
}

// Fetches the inactive buffer map, the HashMap in either ATMOS_A or ATMOS_B, initializing the
// HashMap if needed.
fn get_inactive_atmos_buffer_map(
) -> &'static Mutex<HashMap<i32, RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>>> {
    let flipper = BUFFER_FLIPPER.get_or_init(|| Mutex::new(ActiveBuffer::A));
    match *flipper.lock().unwrap() {
        ActiveBuffer::A => ATMOS_B.get_or_init(|| Mutex::new(HashMap::new())),
        ActiveBuffer::B => ATMOS_A.get_or_init(|| Mutex::new(HashMap::new())),
    }
}

// Flips wether ATMOS_A or ATMOS_B is active.
fn flip_buffers() {
    let flipper = BUFFER_FLIPPER.get_or_init(|| Mutex::new(ActiveBuffer::A));
    let mut active = flipper.lock().unwrap();
    match *active {
        ActiveBuffer::A => *active = ActiveBuffer::B,
        ActiveBuffer::B => *active = ActiveBuffer::A,
    }
}

// Fetches the inactive buffer map, the HashMap in either ATMOS_A or ATMOS_B, initializing the
// HashMap if needed.
fn get_interesting_tiles_vector() -> &'static Mutex<Vec<InterestingTile>> {
    INTERESTING_TILES.get_or_init(|| Mutex::new(Vec::new()))
}

// Ensures the buffer map has a buffer for the given Z level.
macro_rules! init_atmos {
    ( $buffer_map: ident, $z: expr ) => {
        if !$buffer_map.contains_key(&$z) {
            let atmos_lock = RwLock::new(Box::new([0.0; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]));
            {
                let mut atmos = atmos_lock.write().unwrap();
                for x in 0..MAP_SIZE as i32 {
                    for y in 0..MAP_SIZE as i32 {
                        // Tiles mostly start at zeroes.
                        let tile_atmos: &mut [f32; ATMOS_DEPTH] = (&mut atmos
                            [calc_index(x, y, 0)..calc_index(x, y, ATMOS_DEPTH)])
                            .try_into()
                            .unwrap();
                        // Except for superconductivity, which starts at the maximum.
                        tile_atmos[ATMOS_SUPERCONDUCTIVITY_NORTH] = OPEN_HEAT_TRANSFER_COEFFICIENT;
                        tile_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] = OPEN_HEAT_TRANSFER_COEFFICIENT;
                        tile_atmos[ATMOS_SUPERCONDUCTIVITY_SOUTH] = OPEN_HEAT_TRANSFER_COEFFICIENT;
                        tile_atmos[ATMOS_SUPERCONDUCTIVITY_WEST] = OPEN_HEAT_TRANSFER_COEFFICIENT;
                    }
                }
            }
            $buffer_map.insert($z, atmos_lock);
        }
    };
}

// Fetches the buffer out of the buffer map, creating it if need be, and strips it down to just the
// boxed array.
macro_rules! get_atmos {
    ( $var: ident, $buffer_map: ident, $z: expr ) => {
        init_atmos!($buffer_map, $z);
        // Sometimes we need this mutable, sometimes not, so allow it to be mut
        // even if it's unneeded.
        #[allow(unused_mut)]
        let mut $var = $buffer_map.get(&$z).unwrap().write().unwrap();
    };
}

// Fetches the buffer out of the buffer map, without initializing or stripping off the RwLock.
// Prefer gat_atmos if you can use it.
macro_rules! get_atmos_raw {
    ( $var: ident, $buffer: ident, $z: expr ) => {
        let $var = $buffer.get(&$z).unwrap();
    };
}

// Extracts a small array for a given tile out of the buffer's big array.
macro_rules! get_tile {
    ( $var: ident, $atmos: expr, $x: expr, $y: expr ) => {
        let $var: &[f32; ATMOS_DEPTH] = (&$atmos
            [calc_index($x, $y, 0)..calc_index($x, $y, ATMOS_DEPTH)])
            .try_into()
            .unwrap();
    };
}

// Extracts a small mutable array for a given tile out of the buffer's big array.
macro_rules! get_mutable_tile {
    ( $var: ident, $atmos: expr, $x: expr, $y: expr ) => {
        let $var: &mut [f32; ATMOS_DEPTH] = (&mut $atmos
            [calc_index($x, $y, 0)..calc_index($x, $y, ATMOS_DEPTH)])
            .try_into()
            .unwrap();
    };
}

// Returns an Option<[f32; ATMOS_DEPTH]> that is the get_tile result for the tile, if it's valid,
// or None otherwise.
macro_rules! maybe_get_tile {
    ( $atmos: expr, $x: expr, $y: expr ) => {
        if $x < 0 || $x >= MAP_SIZE as i32 || $y < 0 || $y >= MAP_SIZE as i32 {
            None
        } else {
            Some(
                (&$atmos[calc_index($x, $y, 0)..calc_index($x, $y, ATMOS_DEPTH)])
                    .try_into()
                    .unwrap(),
            )
        }
    };
}

// Calculates the index of the specified position in any buffer's array.
fn calc_index(x: i32, y: i32, offset: usize) -> usize {
    usize::try_from(x).unwrap() * MAP_SIZE * ATMOS_DEPTH
        + usize::try_from(y).unwrap() * ATMOS_DEPTH
        + offset
}

// Turns a BYOND number into an Option<f32>.
// The option will be None if the number was null or NaN.
fn byond_to_option_f32(value: ByondValue) -> Result<Option<f32>, Error> {
    if value.is_null() {
        Ok(None)
    } else {
        Ok(f32_to_option_f32(value.get_number()?))
    }
}

// Turns a BYOND number into an Option<f32>, clamping it to the specified bounds.
// The option will be None if the number was null or NaN.
fn bounded_byond_to_option_f32(
    value: ByondValue,
    min_value: f32,
    max_value: f32,
) -> Result<Option<f32>, Error> {
    if value.is_null() {
        Ok(None)
    } else {
        Ok(f32_to_option_f32(
            value.get_number()?.max(min_value).min(max_value),
        ))
    }
}

// Wraps an f32 into an Option<f32> by converting NaN into None.
fn f32_to_option_f32(value: f32) -> Option<f32> {
    if value.is_nan() {
        None
    } else {
        Some(value)
    }
}

// BYOND API for setting the atmos details of a tile.
#[byondapi::bind]
fn set_tile_atmos(
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
    blocked_north: ByondValue,
    blocked_east: ByondValue,
    blocked_south: ByondValue,
    blocked_west: ByondValue,
    atmos_mode: ByondValue,
    external_temperature: ByondValue,
    oxygen: ByondValue,
    carbon_dioxide: ByondValue,
    nitrogen: ByondValue,
    toxins: ByondValue,
    sleeping_agent: ByondValue,
    agent_b: ByondValue,
    temperature: ByondValue,
    _innate_heat_capacity: ByondValue,
) {
    setup_panic_handler();
    internal_set_tile_atmos(
        f32::try_from(x)? as i32 - 1,
        f32::try_from(y)? as i32 - 1,
        f32::try_from(z)? as i32,
        byond_to_option_f32(blocked_north)?,
        byond_to_option_f32(blocked_east)?,
        byond_to_option_f32(blocked_south)?,
        byond_to_option_f32(blocked_west)?,
        byond_to_option_f32(atmos_mode)?,
        byond_to_option_f32(external_temperature)?,
        bounded_byond_to_option_f32(oxygen, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(carbon_dioxide, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(nitrogen, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(toxins, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(sleeping_agent, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(agent_b, 0.0, f32::INFINITY)?,
        bounded_byond_to_option_f32(temperature, 0.0, f32::INFINITY)?,
        None,
        // Temporarily disabled to better match the existing system.
        //bounded_byond_to_option_f32(innate_heat_capacity, 0.0, f32::INFINITY)?,
        Some(0.0),
    );
    Ok(Default::default())
}

// BYOND API for setting the atmos blocking characteristics of a tile.
// Like set_tile_atmos, just with a smaller set of fields.
#[byondapi::bind]
fn set_tile_atmos_blocking(
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
    blocked_north: ByondValue,
    blocked_east: ByondValue,
    blocked_south: ByondValue,
    blocked_west: ByondValue,
) {
    setup_panic_handler();
    internal_set_tile_atmos(
        f32::try_from(x)? as i32 - 1,
        f32::try_from(y)? as i32 - 1,
        f32::try_from(z)? as i32,
        byond_to_option_f32(blocked_north)?,
        byond_to_option_f32(blocked_east)?,
        byond_to_option_f32(blocked_south)?,
        byond_to_option_f32(blocked_west)?,
        None,
        None,
        None,
        None,
        None,
        None,
        None,
        None,
        None,
        None,
        None,
    );
    Ok(Default::default())
}

// Rust version of setting the atmos details of a tile.
fn internal_set_tile_atmos(
    x: i32,
    y: i32,
    z: i32,
    blocked_north: Option<f32>,
    blocked_east: Option<f32>,
    blocked_south: Option<f32>,
    blocked_west: Option<f32>,
    atmos_mode: Option<f32>,
    external_temperature: Option<f32>,
    oxygen: Option<f32>,
    carbon_dioxide: Option<f32>,
    nitrogen: Option<f32>,
    toxins: Option<f32>,
    sleeping_agent: Option<f32>,
    agent_b: Option<f32>,
    temperature: Option<f32>,
    thermal_energy: Option<f32>,
    innate_heat_capacity: Option<f32>,
) {
    let locked = get_active_atmos_buffer_map().lock();
    match locked {
        Err(ref e) => println!("{}", e),
        _ => (),
    }
    let mut buffer = locked.unwrap();
    get_atmos!(atmos, buffer, z);
    get_mutable_tile!(tile_atmos, atmos, x, y);
    if blocked_north.is_some() {
        tile_atmos[ATMOS_BLOCKED_NORTH] = blocked_north.unwrap();
    }
    if blocked_east.is_some() {
        tile_atmos[ATMOS_BLOCKED_EAST] = blocked_east.unwrap();
    }
    if blocked_south.is_some() {
        tile_atmos[ATMOS_BLOCKED_SOUTH] = blocked_south.unwrap();
    }
    if blocked_west.is_some() {
        tile_atmos[ATMOS_BLOCKED_WEST] = blocked_west.unwrap();
    }
    if atmos_mode.is_some() {
        tile_atmos[ATMOS_MODE] = atmos_mode.unwrap();
    }
    if external_temperature.is_some() {
        tile_atmos[ATMOS_EXTERNAL_TEMPERATURE] = external_temperature.unwrap();
    }
    if oxygen.is_some() {
        tile_atmos[ATMOS_OXYGEN] = oxygen.unwrap();
    }
    if carbon_dioxide.is_some() {
        tile_atmos[ATMOS_CARBON_DIOXIDE] = carbon_dioxide.unwrap();
    }
    if nitrogen.is_some() {
        tile_atmos[ATMOS_NITROGEN] = nitrogen.unwrap();
    }
    if toxins.is_some() {
        tile_atmos[ATMOS_TOXINS] = toxins.unwrap();
    }
    if sleeping_agent.is_some() {
        tile_atmos[ATMOS_SLEEPING_AGENT] = sleeping_agent.unwrap();
    }
    if agent_b.is_some() {
        tile_atmos[ATMOS_AGENT_B] = agent_b.unwrap();
    }
    // Done sooner because we need innate heat capacity to calculate thermal energy from
    // temperature.
    if innate_heat_capacity.is_some() {
        tile_atmos[ATMOS_INNATE_HEAT_CAPACITY] = innate_heat_capacity.unwrap();
    }
    if temperature.is_some() {
        tile_atmos[ATMOS_THERMAL_ENERGY] = temperature.unwrap() * heat_capacity(tile_atmos);
    }
    if thermal_energy.is_some() {
        tile_atmos[ATMOS_THERMAL_ENERGY] = thermal_energy.unwrap();
    }
}

// BYOND API for fetching the atmos details of a tile.
#[byondapi::bind]
fn get_tile_atmos(x: ByondValue, y: ByondValue, z: ByondValue) {
    setup_panic_handler();
    let rust_x = f32::try_from(x)? as i32 - 1;
    let rust_y = f32::try_from(y)? as i32 - 1;
    let rust_z = f32::try_from(z)? as i32;
    let mut tile_atmos = internal_get_tile_atmos(rust_x, rust_y, rust_z)?.clone();
    // Convert thermal energy to temperature for BYOND.
    tile_atmos[ATMOS_THERMAL_ENERGY] /= heat_capacity(&tile_atmos);
    if tile_atmos[ATMOS_THERMAL_ENERGY].is_nan() {
        tile_atmos[ATMOS_THERMAL_ENERGY] = 0.0;
    }
    Ok(tile_atmos
        .iter()
        .map(|v| ByondValue::from(*v))
        .collect::<Vec<ByondValue>>()
        .as_slice()
        .try_into()?)
}

// Rust version of fetching the atmos details of a tile.
fn internal_get_tile_atmos(
    x: i32,
    y: i32,
    z: i32,
) -> Result<[f32; ATMOS_DEPTH], TryFromSliceError> {
    let mut buffer = get_active_atmos_buffer_map().lock().unwrap();
    get_atmos!(atmos, buffer, z);
    Ok(atmos[calc_index(x, y, 0)..calc_index(x, y, ATMOS_DEPTH)].try_into()?)
}

// A tile that we consider interesting for some reason.
#[derive(Debug, Copy, Clone)]
struct InterestingTile {
    x: i32,
    y: i32,
    z: i32,
    // These represent the net force generated by air flowing out of the tile along each axis.
    // For a tile losing air equally in all directions, they will be zero.
    // For a tile losing air towards positive X only, flow_x will be the air pressure moved.
    flow_x: f32,
    flow_y: f32,
    // How much "fuel" was burnt, across all reaction types, in the prior tick.
    fuel_burnt: f32,
}

// Converts an InterestingTile into a short BYOND list.
// (It'd be a datum, but we don't have access to those.)
impl TryFrom<InterestingTile> for ByondValue {
    type Error = Error;

    fn try_from(value: InterestingTile) -> Result<Self, Self::Error> {
        let result = ByondValue::new_list()?;
        result.write_list(&[
            // +1 here to convert from our 0-indexing to BYOND's 1-indexing.
            ByondValue::from((value.x + 1) as f32),
            ByondValue::from((value.y + 1) as f32),
            ByondValue::from(value.z as f32),
            ByondValue::from(value.flow_x),
            ByondValue::from(value.flow_y),
            ByondValue::from(value.fuel_burnt),
        ])?;
        Ok(result)
    }
}

// BYOND API for getting a list of interesting turfs this tick.
// There are three kinds:
// * Turfs that are hot eough to cause fires.
// * Turfs that just passed the threshold for showing plasma or sleeping gas.
// * Turfs with strong airflow out.
#[byondapi::bind]
fn get_interesting_tiles() {
    setup_panic_handler();
    let interesting_tiles = get_interesting_tiles_vector().lock().unwrap();
    let initial_interesting_tiles = interesting_tiles.len();
    let byond_interesting_tiles = interesting_tiles
        .iter()
        .map(|v| ByondValue::try_from(*v))
        .flatten()
        .collect::<Vec<ByondValue>>();
    if byond_interesting_tiles.len() != initial_interesting_tiles {
        return Err(eyre!(
            "Unable to convert all values, is BYOND out of memory?"
        ));
    }
    Ok(byond_interesting_tiles.as_slice().try_into()?)
}

// BYOND API for getting a single random interesting tile.
#[byondapi::bind]
fn get_random_interesting_tile() {
    setup_panic_handler();
    let interesting_tiles = get_interesting_tiles_vector().lock().unwrap();
    let length = interesting_tiles.len() as f32;
    let random: f32 = rand::random();
    let chosen = (random * length) as usize;
    Ok(ByondValue::try_from(interesting_tiles[chosen])?)
}

// Calculates the pressure flow out from this tile to the two neighboring tiles on this axis.
// For a tile losing air equally in all directions, flow will be zero.
// For a tile losing air towards positive only, flow will be the air pressure moved.
fn calculate_flow(
    maybe_negative_tile: Option<&[f32; ATMOS_DEPTH]>,
    tile: &[f32; ATMOS_DEPTH],
    maybe_positive_tile: Option<&[f32; ATMOS_DEPTH]>,
    is_x: bool,
) -> f32 {
    let mut flow = 0.0;
    let my_pressure = pressure(tile);
    match maybe_negative_tile {
        Some(negative_tile) => {
            // Make sure air can pass this way.
            let mut permeable = true;
            if is_x {
                permeable = permeable && negative_tile[ATMOS_BLOCKED_EAST] <= 0.0;
                permeable = permeable && tile[ATMOS_BLOCKED_WEST] <= 0.0;
            } else {
                permeable = permeable && negative_tile[ATMOS_BLOCKED_NORTH] <= 0.0;
                permeable = permeable && tile[ATMOS_BLOCKED_SOUTH] <= 0.0;
            }
            let negative_pressure = pressure(negative_tile);
            if permeable && negative_pressure < my_pressure {
                // Causes flow in the negative direction.
                flow += pressure(negative_tile) - my_pressure;
            }
        }
        None => (),
    }
    match maybe_positive_tile {
        Some(positive_tile) => {
            // Make sure air can pass this way.
            let mut permeable = true;
            if is_x {
                permeable = permeable && positive_tile[ATMOS_BLOCKED_WEST] <= 0.0;
                permeable = permeable && tile[ATMOS_BLOCKED_EAST] <= 0.0;
            } else {
                permeable = permeable && positive_tile[ATMOS_BLOCKED_SOUTH] <= 0.0;
                permeable = permeable && tile[ATMOS_BLOCKED_NORTH] <= 0.0;
            }
            let positive_pressure = pressure(positive_tile);
            if permeable && positive_pressure < my_pressure {
                // Causes flow in the positive direction.
                flow += my_pressure - pressure(positive_tile)
            }
        }
        None => (),
    }
    flow
}

// BYOND API for capping the superconductivity of a tile.
#[byondapi::bind]
fn reduce_superconductivity(
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
    north: ByondValue,
    east: ByondValue,
    south: ByondValue,
    west: ByondValue,
) {
    let rust_x = f32::try_from(x)? as i32 - 1;
    let rust_y = f32::try_from(y)? as i32 - 1;
    let rust_z = f32::try_from(z)? as i32;
    let rust_north = bounded_byond_to_option_f32(north, 0.0, 1.0)?;
    let rust_east = bounded_byond_to_option_f32(east, 0.0, 1.0)?;
    let rust_south = bounded_byond_to_option_f32(south, 0.0, 1.0)?;
    let rust_west = bounded_byond_to_option_f32(west, 0.0, 1.0)?;
    internal_reduce_superconductivity(
        rust_x, rust_y, rust_z, rust_north, rust_east, rust_south, rust_west,
    );
    Ok(Default::default())
}

// Rust version of capping the superconductivity of a tile.
// We never increase superconductivity, only reduce it, because it represents how much heat flow has
// been restricted by the tiles and objects on them.
fn internal_reduce_superconductivity(
    x: i32,
    y: i32,
    z: i32,
    north: Option<f32>,
    east: Option<f32>,
    south: Option<f32>,
    west: Option<f32>,
) {
    let mut buffer = get_active_atmos_buffer_map().lock().unwrap();
    get_atmos!(atmos, buffer, z);
    let tile_atmos: &mut [f32; ATMOS_DEPTH] = (&mut atmos
        [calc_index(x, y, 0)..calc_index(x, y, ATMOS_DEPTH)])
        .try_into()
        .unwrap();
    if north.is_some() {
        let index = ATMOS_SUPERCONDUCTIVITY_NORTH;
        tile_atmos[index] = tile_atmos[index].min(north.unwrap());
    }
    if east.is_some() {
        let index = ATMOS_SUPERCONDUCTIVITY_EAST;
        tile_atmos[index] = tile_atmos[index].min(east.unwrap());
    }
    if south.is_some() {
        let index = ATMOS_SUPERCONDUCTIVITY_SOUTH;
        tile_atmos[index] = tile_atmos[index].min(south.unwrap());
    }
    if west.is_some() {
        let index = ATMOS_SUPERCONDUCTIVITY_WEST;
        tile_atmos[index] = tile_atmos[index].min(west.unwrap());
    }
}

// BYOND API for resetting the superconductivity of a tile.
#[byondapi::bind]
fn reset_superconductivity(x: ByondValue, y: ByondValue, z: ByondValue) {
    let rust_x = f32::try_from(x)? as i32 - 1;
    let rust_y = f32::try_from(y)? as i32 - 1;
    let rust_z = f32::try_from(z)? as i32;
    internal_reset_superconductivity(rust_x, rust_y, rust_z);
    Ok(Default::default())
}

// Rust version of resetting the superconductivity of a tile.
fn internal_reset_superconductivity(x: i32, y: i32, z: i32) {
    let mut buffer = get_active_atmos_buffer_map().lock().unwrap();
    get_atmos!(atmos, buffer, z);
    let tile_atmos: &mut [f32; ATMOS_DEPTH] = (&mut atmos
        [calc_index(x, y, 0)..calc_index(x, y, ATMOS_DEPTH)])
        .try_into()
        .unwrap();
    tile_atmos[ATMOS_SUPERCONDUCTIVITY_NORTH] = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile_atmos[ATMOS_SUPERCONDUCTIVITY_SOUTH] = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile_atmos[ATMOS_SUPERCONDUCTIVITY_WEST] = OPEN_HEAT_TRANSFER_COEFFICIENT;
}

// BYOND API for starting an atmos tick.
#[byondapi::bind]
fn spawn_tick_thread() {
    setup_panic_handler();
    thread::spawn(|| {
        tick();
    });
    Ok(Default::default())
}

// Counts the number of adjacent tiles that can share atmos with this tile, i.e. have no blockers
// on either tile.
fn count_connected_dirs(
    active_atmos: Box<&[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>,
    x: i32,
    y: i32,
) -> i32 {
    let mut connected_dirs = 0;

    let my_atmos: &[f32; ATMOS_DEPTH] = active_atmos
        [calc_index(x, y, 0)..calc_index(x, y, ATMOS_DEPTH)]
        .try_into()
        .unwrap();
    for (dx, dy) in DIRECTIONS {
        if x + dx < 0 || x + dx >= MAP_SIZE as i32 || y + dy < 0 || y + dy >= MAP_SIZE as i32 {
            continue;
        }
        let their_atmos: &[f32; ATMOS_DEPTH] = active_atmos
            [calc_index(x + dx, y + dy, 0)..calc_index(x + dx, y + dy, ATMOS_DEPTH)]
            .try_into()
            .unwrap();

        if dx > 0 && my_atmos[ATMOS_BLOCKED_EAST] <= 0.0 && their_atmos[ATMOS_BLOCKED_WEST] <= 0.0 {
            connected_dirs += 1;
        } else if dy > 0
            && my_atmos[ATMOS_BLOCKED_NORTH] <= 0.0
            && their_atmos[ATMOS_BLOCKED_SOUTH] <= 0.0
        {
            connected_dirs += 1;
        } else if dx < 0
            && my_atmos[ATMOS_BLOCKED_WEST] <= 0.0
            && their_atmos[ATMOS_BLOCKED_EAST] <= 0.0
        {
            connected_dirs += 1;
        } else if dy < 0
            && my_atmos[ATMOS_BLOCKED_SOUTH] <= 0.0
            && their_atmos[ATMOS_BLOCKED_NORTH] <= 0.0
        {
            connected_dirs += 1;
        }
    }

    connected_dirs
}

// Runs a single tick of the atmospherics model, multi-threaded by Z level.
fn tick() {
    // Psssh, that was interesting *last* tick.
    {
        let mut interesting_tiles = get_interesting_tiles_vector().lock().unwrap();
        interesting_tiles.clear();
    }

    let mut active_buffer_map = get_active_atmos_buffer_map().lock().unwrap();
    let mut inactive_buffer_map = get_inactive_atmos_buffer_map().lock().unwrap();

    // Collect the Z levels so we don't try to double-borrow active_buffer.
    let mut z_levels = Vec::<i32>::new();
    for z in (*active_buffer_map).keys() {
        z_levels.push(*z);
    }

    // Ensure all the buffers are initialized so we don't need mutable
    // access to the HashMap in the next loop.
    for z in z_levels.iter() {
        init_atmos!(active_buffer_map, *z);
        init_atmos!(inactive_buffer_map, *z);
    }

    // The scope tells Rust that all the threads we create here will end by the time the scope
    // closes. This allows us to pass things into them that are only borrowed for the lifetime of
    // this function.
    thread::scope(|s| {
        // Force the buffers to be captured by reference, despite the `move`
        // in the thread spawn.
        let active_buffer_map = &active_buffer_map;
        let inactive_buffer_map = &inactive_buffer_map;

        // Handle each Z level in its own thread.
        let mut handles = Vec::<ScopedJoinHandle<()>>::new();
        for z in z_levels {
            handles.push(s.spawn(move || {
                get_atmos_raw!(active_atmos, active_buffer_map, z);
                get_atmos_raw!(inactive_atmos, inactive_buffer_map, z);
                tick_z_level(active_atmos, inactive_atmos, z);
            }));
        }

        // Wait for all Z levels to complete.
        for handle in handles {
            handle.join().unwrap();
        }
    });

    flip_buffers();
}

// Runs a single tick of one Z level's atmospherics model.
fn tick_z_level(
    active_atmos_lock: &RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>,
    inactive_atmos_lock: &RwLock<Box<[f32; MAP_SIZE * MAP_SIZE * ATMOS_DEPTH]>>,
    z: i32,
) {
    let active_atmos = active_atmos_lock.read().unwrap();
    let mut inactive_atmos = inactive_atmos_lock.write().unwrap();
    for y in 0..MAP_SIZE as i32 {
        for x in 0..MAP_SIZE as i32 {
            get_tile!(my_atmos, active_atmos, x, y);
            let my_connected_dirs = count_connected_dirs(Box::new(&active_atmos), x, y);

            // Handle copying the origin to the inactive buffer.
            if x == 0 && y == 0 {
                get_mutable_tile!(my_inactive_atmos, inactive_atmos, x, y);
                for i in 0..ATMOS_DEPTH {
                    my_inactive_atmos[i] = my_atmos[i];
                }
            }

            // Handle gas and heat exchange with neighbors.
            for (dx, dy) in AXES {
                if x + dx >= MAP_SIZE as i32 || y + dy >= MAP_SIZE as i32 {
                    continue;
                }

                get_tile!(their_atmos, active_atmos, x + dx, y + dy);
                let their_connected_dirs =
                    count_connected_dirs(Box::new(&active_atmos), x + dx, y + dy);

                let my_inactive_atmos: &mut [f32; ATMOS_DEPTH];
                let their_inactive_atmos: &mut [f32; ATMOS_DEPTH];
                // Split borrow to get both at the same time.
                // https://doc.rust-lang.org/nomicon/borrow-splitting.html
                unsafe {
                    let ptr = inactive_atmos.as_mut_ptr();
                    my_inactive_atmos =
                        (std::slice::from_raw_parts_mut(ptr.add(calc_index(x, y, 0)), ATMOS_DEPTH))
                            .try_into()
                            .unwrap();
                    their_inactive_atmos = (std::slice::from_raw_parts_mut(
                        ptr.add(calc_index(x + dx, y + dy, 0)),
                        ATMOS_DEPTH,
                    ))
                    .try_into()
                    .unwrap();
                }

                // y == 0 handles copying the bottow row to the inactive buffer, before the
                // (1, 0) axis (which is the only one that runs for it).
                // dy == 1 handles copying all other rows to the inactive buffer, before
                // the (0, 1) axis (which runs first).
                for i in 0..ATMOS_DEPTH {
                    if y == 0 || dy == 1 {
                        their_inactive_atmos[i] = their_atmos[i];
                    }
                }

                // Bail if we shouldn't share air this way, but still run superconductivity.
                if dx > 0
                    && (my_atmos[ATMOS_BLOCKED_EAST] > 0.0 || their_atmos[ATMOS_BLOCKED_WEST] > 0.0)
                {
                    superconduct(my_inactive_atmos, their_inactive_atmos, true);
                    continue;
                }
                if dy > 0
                    && (my_atmos[ATMOS_BLOCKED_NORTH] > 0.0
                        || their_atmos[ATMOS_BLOCKED_SOUTH] > 0.0)
                {
                    superconduct(my_inactive_atmos, their_inactive_atmos, false);
                    continue;
                }

                // Calculate the amount of air and thermal energy transferred.
                let my_change = share_air(
                    my_atmos,
                    their_atmos,
                    my_connected_dirs,
                    their_connected_dirs,
                );

                // Transfer it.
                for i in 0..ATMOS_DEPTH {
                    my_inactive_atmos[i] += my_change[i];
                    their_inactive_atmos[i] -= my_change[i];
                }

                // Run superconductivity.
                superconduct(my_inactive_atmos, their_inactive_atmos, dx > 0);
            }

            // Simple access now that the split borrow is done.
            get_mutable_tile!(my_inactive_atmos, inactive_atmos, x, y);

            match my_atmos[ATMOS_MODE] as i32 {
                ATMOS_MODE_SPACE => {
                    // Space tiles lose all gas and thermal energy every tick.
                    for gas in 0..GAS_COUNT {
                        my_inactive_atmos[GAS_OFFSET + gas] = 0.0;
                    }
                    my_inactive_atmos[ATMOS_THERMAL_ENERGY] = 0.0;
                }
                ATMOS_MODE_LAVALAND => {
                    // Handle heat and air exchange with Lavaland.
                    let mut their_atmos: [f32; ATMOS_DEPTH] = [
                        // No need to care about atmos connectivity for a virtual tile.
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        // No need to care about the atmos mode for a virtual tile.
                        0.0,
                        // Dude, we ARE the external temperature!
                        0.0,
                        // Lavaland gasses.
                        LAVALAND_OXYGEN_MOLES,
                        0.0,
                        LAVALAND_NITROGEN_MOLES,
                        0.0,
                        0.0,
                        0.0,
                        // Will be calculated later.
                        0.0,
                        // We only conduct WEST from here, but no harm in setting all of these.
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        // Also doesn't matter, since we already calculated thermal energy.
                        0.0,
                    ];
                    their_atmos[ATMOS_THERMAL_ENERGY] =
                        my_atmos[ATMOS_EXTERNAL_TEMPERATURE] * heat_capacity(&their_atmos);

                    // Calculate the amount of air and thermal energy transferred.
                    let my_change = share_air(
                        // Planetary atmos is aggressive and does a 1-connected-direction share
                        // with the otherwise-final air.
                        my_inactive_atmos,
                        &their_atmos,
                        1,
                        1,
                    );

                    // Transfer it.
                    for i in 0..ATMOS_DEPTH {
                        my_inactive_atmos[i] += my_change[i];
                    }

                    // Temporarily override the tile's superconductivity, since there's no UP.
                    let real_superconductivity = my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST];
                    my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] =
                        OPEN_HEAT_TRANSFER_COEFFICIENT;
                    // Superconduct with planetary atmos.
                    superconduct(my_inactive_atmos, &mut their_atmos, true);

                    // Restore original superconductivity
                    my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] = real_superconductivity;
                }
                ATMOS_MODE_EARTHLIKE => {
                    // Handle heat and air exchange with Lavaland.
                    let mut their_atmos: [f32; ATMOS_DEPTH] = [
                        // No need to care about atmos connectivity for a virtual tile.
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        // No need to care about the atmos mode for a virtual tile.
                        0.0,
                        // Dude, we ARE the external temperature!
                        0.0,
                        // Earthlike gasses.
                        STANDARD_OXYGEN_MOLES,
                        0.0,
                        STANDARD_NITROGEN_MOLES,
                        0.0,
                        0.0,
                        0.0,
                        // Will be calculated later.
                        0.0,
                        // We only conduct WEST from here, but no harm in setting all of these.
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        OPEN_HEAT_TRANSFER_COEFFICIENT,
                        // Also doesn't matter, since we already calculated thermal energy.
                        0.0,
                    ];
                    their_atmos[ATMOS_THERMAL_ENERGY] =
                        my_atmos[ATMOS_EXTERNAL_TEMPERATURE] * heat_capacity(&their_atmos);

                    // Calculate the amount of air and thermal energy transferred.
                    let my_change = share_air(
                        // Planetary atmos is aggressive and does a 1-connected-direction share
                        // with the otherwise-final air.
                        my_inactive_atmos,
                        &their_atmos,
                        1,
                        1,
                    );

                    // Transfer it.
                    for i in 0..ATMOS_DEPTH {
                        my_inactive_atmos[i] += my_change[i];
                    }

                    // Temporarily override the tile's superconductivity, since there's no UP.
                    let real_superconductivity = my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST];
                    my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] =
                        OPEN_HEAT_TRANSFER_COEFFICIENT;
                    // Superconduct with planetary atmos.
                    superconduct(my_inactive_atmos, &mut their_atmos, true);

                    // Restore original superconductivity
                    my_inactive_atmos[ATMOS_SUPERCONDUCTIVITY_EAST] = real_superconductivity;
                }
                // Do nothing in ATMOS_MODE_SEALED.
                _ => (),
            }

            // Track how much "fuel" was burnt across all reactions.
            let mut fuel_burnt = 0.0;

            // Handle reactions
            // Agent B converting CO2 to O2
            if temperature(my_inactive_atmos) > 900.0 {
                let co2_converted = (my_inactive_atmos[ATMOS_CARBON_DIOXIDE] * 0.75)
                    .min(my_inactive_atmos[ATMOS_TOXINS] * 0.25)
                    .min(my_inactive_atmos[ATMOS_AGENT_B] * 0.05);

                my_inactive_atmos[ATMOS_CARBON_DIOXIDE] -= co2_converted;
                my_inactive_atmos[ATMOS_OXYGEN] += co2_converted;
                my_inactive_atmos[ATMOS_AGENT_B] -= co2_converted * 0.05;
                my_inactive_atmos[ATMOS_THERMAL_ENERGY] +=
                    co2_converted * AGENT_B_CONVERSION_ENERGY;
                fuel_burnt += co2_converted;
            }
            // Nitrous Oxide breaking down into nitrogen and oxygen.
            if temperature(my_inactive_atmos) > 1400.0 {
                let reaction_percent = (0.00002
                    * (temperature(my_inactive_atmos)
                        - (0.00001 * (temperature(my_inactive_atmos).powi(2)))))
                .min(1.0)
                .max(0.0);
                let nitrous_decomposed = reaction_percent * my_inactive_atmos[ATMOS_SLEEPING_AGENT];

                my_inactive_atmos[ATMOS_SLEEPING_AGENT] -= nitrous_decomposed;
                my_inactive_atmos[ATMOS_NITROGEN] += nitrous_decomposed;
                my_inactive_atmos[ATMOS_OXYGEN] += nitrous_decomposed / 2.0;
                my_inactive_atmos[ATMOS_THERMAL_ENERGY] +=
                    NITROUS_BREAKDOWN_ENERGY * nitrous_decomposed;
                fuel_burnt += nitrous_decomposed;
            }
            // Plasmafire!
            const SIGNIFICANCE: f32 = 0.01;
            if my_inactive_atmos[ATMOS_TOXINS] > SIGNIFICANCE && my_inactive_atmos[ATMOS_OXYGEN] > SIGNIFICANCE && temperature(my_inactive_atmos) > PLASMA_BURN_MIN_TEMP{
                // How efficient is the burn?
                // Linear scaling fom 0 to 1 as temperatue goes from minimum to optimal.
                let efficiency = ((temperature(my_inactive_atmos) - PLASMA_BURN_MIN_TEMP)
                    / (PLASMA_BURN_OPTIMAL_TEMP - PLASMA_BURN_MIN_TEMP))
                    .max(0.0)
                    .min(1.0);

                // How much oxygen do we consume per plasma burnt?
                // Linear scaling from worst to best as efficiency goes from 0 to 1.
                let oxygen_per_plasma = PLASMA_BURN_WORST_OXYGEN_PER_PLASMA
                    + (PLASMA_BURN_BEST_OXYGEN_PER_PLASMA - PLASMA_BURN_WORST_OXYGEN_PER_PLASMA)
                        * efficiency;

                // How much plasma is available to burn?
                // Capped by oxygen availability. Significantly more oxygen is required than is
                // consumed. This means that the oxygen-to-plasm ratio will increase while
                // burning.
                let burnable_plasma = my_inactive_atmos[ATMOS_TOXINS]
                    .min(my_inactive_atmos[ATMOS_OXYGEN] / PLASMA_BURN_MAX_OXYGEN_AVAILABILITY);

                // Actual burn amount.
                let plasma_burnt = efficiency * PLASMA_BURN_MAX_RATIO * burnable_plasma;

                my_inactive_atmos[ATMOS_TOXINS] -= plasma_burnt;
                my_inactive_atmos[ATMOS_CARBON_DIOXIDE] += plasma_burnt;
                my_inactive_atmos[ATMOS_OXYGEN] -= plasma_burnt * oxygen_per_plasma;
                my_inactive_atmos[ATMOS_THERMAL_ENERGY] += PLASMA_BURN_ENERGY * plasma_burnt;
                fuel_burnt += plasma_burnt;
            }

            // Sanitize the tile, to avoid negative/NaN spread.
            for i in 0..ATMOS_DEPTH {
                if my_inactive_atmos[i].is_nan() {
                    // Reset back to the last value, in the hopes that it's safe.
                    my_inactive_atmos[i] = my_atmos[i];
                } else if my_inactive_atmos[i] < 0.0 {
                    my_inactive_atmos[i] = 0.0;
                }
            }

            // Handle interesting tiles.
            let mut interesting: bool = false;

            if (my_inactive_atmos[ATMOS_TOXINS] >= 0.5) != (my_atmos[ATMOS_TOXINS] >= 0.5) {
                // Crossed the toxins visibility threshold.
                interesting = true;
            } else if (my_inactive_atmos[ATMOS_SLEEPING_AGENT] >= 1.0)
                != (my_atmos[ATMOS_SLEEPING_AGENT] >= 1.0)
            {
                // Crossed the sleeping agent visibility threshold.
                interesting = true;
            }

            let temperature =
                my_inactive_atmos[ATMOS_THERMAL_ENERGY] / heat_capacity(my_inactive_atmos);
            if temperature > T0C + 100.0 {
                match my_inactive_atmos[ATMOS_MODE] as i32 {
                    ATMOS_MODE_LAVALAND | ATMOS_MODE_EARTHLIKE => {
                        if my_inactive_atmos[ATMOS_EXTERNAL_TEMPERATURE] + 1.0 >= temperature {
                            // It's ALWAYS hot here. Not interesting.
                        } else {
                            // Oh, hey, we're even hotter, and can start fires.
                            // That's interesting.
                            interesting = true;
                        }
                    }
                    // Anywhere else is interesting if it can start fires.
                    _ => interesting = true,
                }
            }

            let flow_x = calculate_flow(
                maybe_get_tile!(active_atmos, x - 1, y),
                my_atmos,
                maybe_get_tile!(active_atmos, x + 1, y),
                true,
            );
            if flow_x.abs() > 1.0 {
                // Pressure flowing out of this tile along the X axis.
                interesting = true;
            }

            let flow_y = calculate_flow(
                maybe_get_tile!(active_atmos, x, y - 1),
                my_atmos,
                maybe_get_tile!(active_atmos, x, y + 1),
                false,
            );
            // I would square root this, but since we're comparing against 1, it doesn't
            // matter.
            if flow_x.powi(2) + flow_y.powi(2) > 1.0 {
                // Pressure flowing out of this tile along the Y axis.
                interesting = true;
            }

            if !interesting {
                // Boooooring.
                continue;
            }

            // :eyes:
            let mut interesting_tiles = get_interesting_tiles_vector().lock().unwrap();
            interesting_tiles.push(InterestingTile {
                x: x,
                y: y,
                z: z,
                flow_x: flow_x,
                flow_y: flow_y,
                fuel_burnt: fuel_burnt,
            });
        }
    }
}

// Calculates the airflow between two connected tiles.
fn share_air(
    mine: &[f32; ATMOS_DEPTH],
    theirs: &[f32; ATMOS_DEPTH],
    my_connected_dirs: i32,
    their_connected_dirs: i32,
) -> [f32; ATMOS_DEPTH] {
    let mut delta_atmos: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];

    // Since we're moving bits of gas independantly, we need to know the temperature of the gas
    // mix.
    let my_old_temperature = temperature(mine);
    let their_old_temperature = temperature(theirs);

    // Each gas is handled separately. This is dumb, but it's how LINDA did it, so it's used in V1.
    for gas in 0..GAS_COUNT {
        delta_atmos[GAS_OFFSET + gas] =
            theirs[GAS_OFFSET + gas] - mine[GAS_OFFSET + gas];
        if delta_atmos[GAS_OFFSET + gas] > 0.0 {
            // Gas flowing in from the other tile, limit by its connected_dirs.
            delta_atmos[GAS_OFFSET + gas] /= (their_connected_dirs + 1) as f32;
            // Heat flowing in.
            delta_atmos[ATMOS_THERMAL_ENERGY] +=
                SPECIFIC_HEATS[gas] * delta_atmos[GAS_OFFSET + gas] * their_old_temperature;
        } else {
            // Gas flowing out from this tile, limit by our connected_dirs.
            delta_atmos[GAS_OFFSET + gas] /= (my_connected_dirs + 1) as f32;
            // Heat flowing out.
            delta_atmos[ATMOS_THERMAL_ENERGY] +=
                SPECIFIC_HEATS[gas] * delta_atmos[GAS_OFFSET + gas] * my_old_temperature;
        }
    }

    delta_atmos
}

// Calculates the heat capacity of a tile.
fn heat_capacity(tile_atmos: &[f32; ATMOS_DEPTH]) -> f32 {
    let mut heat_capacity = 0.0;
    for gas in 0..GAS_COUNT {
        heat_capacity += tile_atmos[GAS_OFFSET + gas] * SPECIFIC_HEATS[gas];
    }
    heat_capacity += tile_atmos[ATMOS_INNATE_HEAT_CAPACITY];
    heat_capacity
}

// Calculates the temperature of a tile.
fn temperature(tile_atmos: &[f32; ATMOS_DEPTH]) -> f32 {
    let temperature = tile_atmos[ATMOS_THERMAL_ENERGY] / heat_capacity(tile_atmos);
    if temperature.is_nan() {
        return 0.0;
    }
    temperature
}

// Calculates the pressure of a tile.
fn pressure(tile_atmos: &[f32; ATMOS_DEPTH]) -> f32 {
    let mut heat_capacity = 0.0;
    let mut moles = 0.0;
    for gas in 0..GAS_COUNT {
        heat_capacity += tile_atmos[GAS_OFFSET + gas] * SPECIFIC_HEATS[gas];
        moles += tile_atmos[GAS_OFFSET + gas];
    }
    heat_capacity += tile_atmos[ATMOS_INNATE_HEAT_CAPACITY];
    let temperature = tile_atmos[ATMOS_THERMAL_ENERGY] / heat_capacity;

    moles * temperature * R_IDEAL_GAS_EQUATION / TILE_VOLUME
}

// Performs superconduction between two superconductivity-connected tiles.
fn superconduct(
    my_atmos: &mut [f32; ATMOS_DEPTH],
    their_atmos: &mut [f32; ATMOS_DEPTH],
    is_east: bool,
) {
    // Superconduction is scaled to the smaller directional superconductivity setting of the two
    // tiles.
    let mut transfer_coefficient: f32;
    if is_east {
        transfer_coefficient =
            my_atmos[ATMOS_SUPERCONDUCTIVITY_EAST].min(their_atmos[ATMOS_SUPERCONDUCTIVITY_WEST]);
    } else {
        transfer_coefficient =
            my_atmos[ATMOS_SUPERCONDUCTIVITY_NORTH].min(their_atmos[ATMOS_SUPERCONDUCTIVITY_SOUTH]);
    }

    let my_heat_capacity = heat_capacity(my_atmos);
    let their_heat_capacity = heat_capacity(their_atmos);
    if transfer_coefficient <= 0.0 || my_heat_capacity <= 0.0 || their_heat_capacity <= 0.0 {
        // Nothing to do.
        return;
    }

    // Temporary workaround to match LINDA better for high temperatures.
    if temperature(my_atmos) > T20C || temperature(their_atmos) > T20C {
        transfer_coefficient = (transfer_coefficient * 100.0).min(OPEN_HEAT_TRANSFER_COEFFICIENT);
    }

    // This is the formula from LINDA. I have no idea if it's a good one, I just copied it.
    let conduction = transfer_coefficient
        * (temperature(my_atmos) - temperature(their_atmos))
        * my_heat_capacity
        * their_heat_capacity
        / (my_heat_capacity + their_heat_capacity);
    my_atmos[ATMOS_THERMAL_ENERGY] -= conduction;
    their_atmos[ATMOS_THERMAL_ENERGY] += conduction;
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use crate::tests::Tile::*;
    use crate::*;

    // We allow small deviations, so that floating point precision doesn't cause problems.
    const TEST_TOLERANCE: f32 = 0.00001;

    // The model should start empty.
    #[test]
    fn initial_zero() {
        // test_z is used throughout to split the tests into different Z levels, because they all
        // run on the same model, in random order.
        let test_z = 1;

        let result_tile = internal_get_tile_atmos(1, 2, test_z).unwrap();
        for i in 0..ATMOS_DEPTH {
            let result = result_tile[i];
            match i {
                // Superconductivity should start at the maximum.
                ATMOS_SUPERCONDUCTIVITY_NORTH..=ATMOS_SUPERCONDUCTIVITY_WEST => {
                    assert_eq!(result, OPEN_HEAT_TRANSFER_COEFFICIENT)
                }
                // Everything else should be zero.
                _ => assert_eq!(result, 0.0, "{}", i),
            }
        }
    }

    // The data set by internal_set_tile_atmos() should be retrieved by internal_get_tile_atmos().
    #[test]
    fn set_get_loop() {
        let test_z = 2;

        // Set some arbitrary data.
        internal_set_tile_atmos(
            1,
            2,
            test_z,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            None,
            Some(1.0),
        );

        // Check that we got the same data back.
        {
            let result = internal_get_tile_atmos(1, 2, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(result[GAS_OFFSET + gas], 0.0, "{}", gas);
                } else {
                    assert_eq!(result[GAS_OFFSET + gas], 1.0, "{}", gas);
                }
            }
            assert_eq!(result[ATMOS_THERMAL_ENERGY], 0.0);
            assert_eq!(result[ATMOS_INNATE_HEAT_CAPACITY], 1.0);
        }

        // Set a different set of arbitrary data.
        internal_set_tile_atmos(
            1,
            1,
            test_z,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            None,
            Some(1.0),
            None,
        );

        // Check that we got the same data back.
        {
            let result = internal_get_tile_atmos(1, 1, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(result[GAS_OFFSET + gas], 1.0, "{}", gas);
                } else {
                    assert_eq!(result[GAS_OFFSET + gas], 0.0, "{}", gas);
                }
            }
            assert_eq!(result[ATMOS_THERMAL_ENERGY], 1.0);
            assert_eq!(result[ATMOS_INNATE_HEAT_CAPACITY], 0.0);
        }
    }

    // flip_buffers() should alternate us betweeen two buffers, and changes should be preserved
    // when we switch back to the original one.
    #[test]
    fn flip_works() {
        let test_z = 3;

        // Write some arbitrary data to the first buffer.
        internal_set_tile_atmos(
            1,
            2,
            test_z,
            None,
            None,
            None,
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            None,
            Some(1.0),
        );

        flip_buffers();

        // Verify that the second buffer is still empty.
        {
            let result = internal_get_tile_atmos(1, 2, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                assert_eq!(result[GAS_OFFSET + gas], 0.0, "{}", gas);
            }
            assert_eq!(result[ATMOS_THERMAL_ENERGY], 0.0);
            assert_eq!(result[ATMOS_INNATE_HEAT_CAPACITY], 0.0);
        }

        // Write a different set of arbitrary data to the second buffer.
        internal_set_tile_atmos(
            1,
            1,
            test_z,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
            None,
            Some(1.0),
            None,
        );

        flip_buffers();

        // Verify that what we wrote to the first buffer is still there.
        {
            let result = internal_get_tile_atmos(1, 2, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(result[GAS_OFFSET + gas], 0.0, "{}", gas);
                } else {
                    assert_eq!(result[GAS_OFFSET + gas], 1.0, "{}", gas);
                }
            }
            assert_eq!(result[ATMOS_THERMAL_ENERGY], 0.0);
            assert_eq!(result[ATMOS_INNATE_HEAT_CAPACITY], 1.0);
        }

        flip_buffers();

        // Verify that what we wrote to the second buffer is still there.
        {
            let result = internal_get_tile_atmos(1, 1, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(result[GAS_OFFSET + gas], 1.0, "{}", gas);
                } else {
                    assert_eq!(result[GAS_OFFSET + gas], 0.0, "{}", gas);
                }
            }
            assert_eq!(result[ATMOS_THERMAL_ENERGY], 1.0);
            assert_eq!(result[ATMOS_INNATE_HEAT_CAPACITY], 0.0);
        }
    }

    // share_air() should do nothing to two space tiles.
    #[test]
    fn share_nothing() {
        let atmos_a: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        let atmos_b: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];

        let delta_atmos = share_air(&atmos_a, &atmos_b, 1, 1);
        for i in 0..ATMOS_DEPTH {
            assert_eq!(delta_atmos[i], 0.0, "{}", i);
        }
    }

    // share_air() should do nothing to two matching tiles.
    #[test]
    fn share_equilibrium() {
        let mut atmos_a: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_a[ATMOS_OXYGEN] = 80.0;
        atmos_a[ATMOS_NITROGEN] = 20.0;
        atmos_a[ATMOS_THERMAL_ENERGY] = 100.0;
        let mut atmos_b: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_b[ATMOS_OXYGEN] = 80.0;
        atmos_b[ATMOS_NITROGEN] = 20.0;
        atmos_b[ATMOS_THERMAL_ENERGY] = 100.0;

        let delta_atmos = share_air(&atmos_a, &atmos_b, 1, 1);
        for i in 0..ATMOS_DEPTH {
            assert_eq!(delta_atmos[i], 0.0, "{}", i);
        }
    }

    // share_air() should split air into 2 equal parts with connected_dirs of 1.
    #[test]
    fn share_splits_air_cd1() {
        let mut atmos_a: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_a[ATMOS_OXYGEN] = 100.0;
        atmos_a[ATMOS_THERMAL_ENERGY] = 100.0;
        let atmos_b: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];

        let delta_atmos = share_air(&atmos_a, &atmos_b, 1, 1);
        for i in 0..ATMOS_DEPTH {
            if i == ATMOS_OXYGEN {
                assert_eq!(delta_atmos[i], -50.0);
            } else if i == ATMOS_THERMAL_ENERGY {
                assert_eq!(delta_atmos[i], -50.0);
            } else {
                assert_eq!(delta_atmos[i], 0.0, "{}", i);
            }
        }
    }

    // share_air() should split air into 5 equal parts with connected_dirs of 4.
    #[test]
    fn share_splits_air_cd4() {
        let mut atmos_a: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_a[ATMOS_OXYGEN] = 100.0;
        atmos_a[ATMOS_THERMAL_ENERGY] = 100.0;
        let atmos_b: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];

        let delta_atmos = share_air(&atmos_a, &atmos_b, 4, 4);
        for i in 0..ATMOS_DEPTH {
            if i == ATMOS_OXYGEN {
                assert_eq!(delta_atmos[i], -20.0);
            } else if i == ATMOS_THERMAL_ENERGY {
                assert_eq!(delta_atmos[i], -20.0);
            } else {
                assert_eq!(delta_atmos[i], 0.0, "{}", i);
            }
        }
    }

    // superconduct() should transfer part of the thermal energy between two tiles that differ
    // only in thermal energy.
    #[test]
    fn superconduct_temperature() {
        let mut atmos_a: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_a[ATMOS_OXYGEN] = 80.0;
        atmos_a[ATMOS_NITROGEN] = 20.0;
        atmos_a[ATMOS_THERMAL_ENERGY] = 100.0;
        atmos_a[ATMOS_SUPERCONDUCTIVITY_EAST] = OPEN_HEAT_TRANSFER_COEFFICIENT;
        let mut atmos_b: [f32; ATMOS_DEPTH] = [0.0; ATMOS_DEPTH];
        atmos_b[ATMOS_OXYGEN] = 80.0;
        atmos_b[ATMOS_NITROGEN] = 20.0;
        atmos_b[ATMOS_THERMAL_ENERGY] = 200.0;
        atmos_b[ATMOS_SUPERCONDUCTIVITY_WEST] = OPEN_HEAT_TRANSFER_COEFFICIENT;

        superconduct(&mut atmos_a, &mut atmos_b, true);

        // These values are arbitrary, they're just what we get right now.
        // Update them if the calculations changed intentionally.
        assert_eq!(atmos_a[ATMOS_THERMAL_ENERGY], 120.0);
        assert_eq!(atmos_b[ATMOS_THERMAL_ENERGY], 180.0);
    }

    // Testing function for setting the initial state of the air in a region.
    fn set_pattern<F>(pattern: &[&str], legend: F, z: i32)
    where
        F: Fn(char) -> Tile,
    {
        for inv_y in 0..pattern.len() {
            // Reverse the Y direction, so +Y is up, like in the game.
            let y = pattern.len() - inv_y - 1;
            for x in 0..pattern[inv_y].len() {
                match legend(pattern[inv_y].chars().nth(x).unwrap()) {
                    Wall => create_wall(x as i32, y as i32, z, 0.0, 0.0, 0.0),
                    SuperconductingWall(temperature, superconductivity, heat_capacity) => {
                        create_wall(
                            x as i32,
                            y as i32,
                            z,
                            temperature,
                            superconductivity,
                            heat_capacity,
                        )
                    }
                    Air(values) => create_air(x as i32, y as i32, z, values),
                    // Vacuum is equivalent to an Air tile with nothing set in it.
                    Vacuum => create_air(x as i32, y as i32, z, Box::new([])),
                    _ => internal_reduce_superconductivity(
                        x as i32,
                        y as i32,
                        z,
                        Some(0.0),
                        Some(0.0),
                        Some(0.0),
                        Some(0.0),
                    ),
                }
            }
        }
    }

    // Testing function for cheking that the resulting air is what we expect.
    fn expect_pattern<F>(pattern: &[&str], legend: F, z: i32)
    where
        F: Fn(char) -> Tile,
    {
        for inv_y in 0..pattern.len() {
            // Reverse the Y direction, so +Y is up, like in the game.
            let y = pattern.len() - inv_y - 1;
            for x in 0..pattern[inv_y].len() {
                let actual = internal_get_tile_atmos(x as i32, y as i32, z).unwrap();
                match legend(pattern[inv_y].chars().nth(x).unwrap()) {
                    Anything => (),
                    Air(values) => {
                        // Check each of the values that we care about.
                        let value_map: HashMap<usize, f32> = values.iter().cloned().collect();
                        for i in 0..ATMOS_DEPTH {
                            match value_map.get(&i) {
                                Some(value) => assert!(
                                    // We allow small deviations, so that floating point precision
                                    // doesn't cause problems.
                                    (actual[i] - *value).abs() < TEST_TOLERANCE,
                                    "{}@({}, {}): {} != {}",
                                    i,
                                    x,
                                    y,
                                    actual[i],
                                    *value
                                ),
                                None => (),
                            }
                        }
                    }
                    SuperconductingWall(thermal_energy, _, _) => {
                        // Walls should never have any gas.
                        for gas in 0..GAS_COUNT {
                            assert_eq!(actual[GAS_OFFSET + gas], 0.0, "({}, {}) {}", x, y, gas);
                        }
                        // Superconducting walls should have the expected thermal energy.
                        assert!(
                            // We allow small deviations, so that floating point precision doesn't
                            // cause problems.
                            (actual[ATMOS_THERMAL_ENERGY] - thermal_energy).abs() < TEST_TOLERANCE,
                            "({}, {}): {} != {}",
                            x,
                            y,
                            actual[ATMOS_THERMAL_ENERGY],
                            thermal_energy
                        );
                    }
                    Wall => {
                        // Walls should never have any gas.
                        for gas in 0..GAS_COUNT {
                            assert_eq!(actual[GAS_OFFSET + gas], 0.0, "({}, {}) {}", x, y, gas);
                        }
                        // Normal walls should have no thermal energy.
                        assert_eq!(actual[ATMOS_THERMAL_ENERGY], 0.0, "({}, {})", x, y);
                    }
                    _ => {
                        // Space should never have any gas.
                        for gas in 0..GAS_COUNT {
                            assert_eq!(actual[GAS_OFFSET + gas], 0.0, "({}, {}) {}", x, y, gas);
                        }
                        // Space should have no thermal energy.
                        assert_eq!(actual[ATMOS_THERMAL_ENERGY], 0.0, "({}, {})", x, y);
                    }
                }
            }
        }
    }

    // Used to create Air tiles.
    fn create_air(x: i32, y: i32, z: i32, values: Box<[(usize, f32)]>) {
        let mut value_map: HashMap<usize, f32> = values.iter().cloned().collect();
        // Air tiles are sealed by default.
        if !value_map.contains_key(&ATMOS_MODE) {
            value_map.insert(ATMOS_MODE, ATMOS_MODE_SEALED as f32);
        }
        internal_set_tile_atmos(
            x,
            y,
            z,
            value_map.get(&ATMOS_BLOCKED_NORTH).copied(),
            value_map.get(&ATMOS_BLOCKED_EAST).copied(),
            value_map.get(&ATMOS_BLOCKED_SOUTH).copied(),
            value_map.get(&ATMOS_BLOCKED_WEST).copied(),
            value_map.get(&ATMOS_MODE).copied(),
            value_map.get(&ATMOS_EXTERNAL_TEMPERATURE).copied(),
            value_map.get(&ATMOS_OXYGEN).copied(),
            value_map.get(&ATMOS_CARBON_DIOXIDE).copied(),
            value_map.get(&ATMOS_NITROGEN).copied(),
            value_map.get(&ATMOS_TOXINS).copied(),
            value_map.get(&ATMOS_SLEEPING_AGENT).copied(),
            value_map.get(&ATMOS_AGENT_B).copied(),
            None,
            value_map.get(&ATMOS_THERMAL_ENERGY).copied(),
            value_map.get(&ATMOS_INNATE_HEAT_CAPACITY).copied(),
        );
    }

    // Used to create Wall and SuperconductingWall tiles.
    fn create_wall(
        x: i32,
        y: i32,
        z: i32,
        thermal_energy: f32,
        superconductivity: f32,
        heat_capacity: f32,
    ) {
        internal_set_tile_atmos(
            x,
            y,
            z,
            // Block all four directions.
            Some(1.0),
            Some(1.0),
            Some(1.0),
            Some(1.0),
            // Walls are sealed.
            Some(ATMOS_MODE_SEALED as f32),
            // External temperature doesn't matter in sealed mode.
            None,
            // Walls have no gas (the default).
            None,
            None,
            None,
            None,
            None,
            None,
            // We set thermal energy, not temperature.
            None,
            // Apply the specified thermal energy and heat capacity.
            Some(thermal_energy),
            Some(heat_capacity),
        );
        internal_reduce_superconductivity(
            x,
            y,
            z,
            Some(superconductivity),
            Some(superconductivity),
            Some(superconductivity),
            Some(superconductivity),
        );
    }

    enum Tile {
        // This tile allows atmos to pass, but is always vacuum.
        Space,
        // This tile does not allow atmos to pass, and is always vacuum.
        Wall,
        // This tile does not allow atmos to pass and is always vacuum, but superconducts.
        // Parameters: thermal energy, superconductivity, innate heat capacity
        SuperconductingWall(f32, f32, f32),
        // This tile allows atmos to pass, is sealed, and has the specified air.
        // ATMOS_MODE can be overridden, e.g. to ATMOS_MODE_LAVALAND
        Air(Box<[(usize, f32)]>),
        // This tile allows atmos to pass, is sealed, and starts with no air.
        // In check_pattern, acts as Space.
        Vacuum,
        // We don't check this tile.
        // In set_pattern, acts as Space.
        #[allow(dead_code)]
        Anything,
    }

    // The empty comments from here on out are to force rustfmt to preserve
    // line breaks, rather than compressing things into a single line.
    // This is especially important for the pattern, which should visually
    // look like a grid.
    //
    // rustfmt provides a #[rustfmt::skip] directive that we could use,
    // unfortunately, the compiler won't let it be applied in the middle of
    // the code right now. It formats right, it just won't compile.

    // Air should split evenly to surrounding vacuum tiles.
    #[test]
    fn tick_splits_air() {
        let test_z = 4;

        set_pattern(
            &[
                "#######", //
                "#     #", //
                "#     #", //
                "#  X  #", //
                "#     #", //
                "#     #", //
                "#######", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "#######", //
                "#     #", //
                "#  x  #", //
                "# xxx #", //
                "#  x  #", //
                "#     #", //
                "#######", //
            ],
            |c: char| match c {
                'x' => Air(Box::new([
                    (ATMOS_OXYGEN, 20.0), //
                    (ATMOS_THERMAL_ENERGY, 20.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );
    }

    // Air should not flow into walls.
    #[test]
    fn tick_respects_walls() {
        let test_z = 5;

        set_pattern(
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );
    }

    // Air should flow properly into dead-end tiles.
    #[test]
    fn tick_handles_different_connections() {
        let test_z = 6;

        set_pattern(
            &[
                "#####", //
                "## ##", //
                "# X #", //
                "## ##", //
                "#####", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "#####", //
                "##x##", //
                "#xxx#", //
                "##x##", //
                "#####", //
            ],
            |c: char| match c {
                'x' => Air(Box::new([
                    (ATMOS_OXYGEN, 20.0), //
                    (ATMOS_THERMAL_ENERGY, 20.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );
    }

    // Four equal dead-end tiles around a vacuum should distribute air evenly between all 5 tiles.
    // Temp: Or not, because we're matching MILLA behavior.
    #[test]
    fn tick_merges_properly() {
        let test_z = 7;

        set_pattern(
            &[
                "#####", //
                "##X##", //
                "#X X#", //
                "##X##", //
                "#####", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "#####", //
                "##x##", //
                "#x!x#", //
                "##x##", //
                "#####", //
            ],
            |c: char| match c {
                '!' => Air(Box::new([
                    (ATMOS_OXYGEN, 200.0), //
                    (ATMOS_THERMAL_ENERGY, 200.0),
                ])),
                'x' => Air(Box::new([
                    (ATMOS_OXYGEN, 50.0), //
                    (ATMOS_THERMAL_ENERGY, 50.0),
                ])),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );
    }

    // Energy should be transferred into superconducting walls.
    #[test]
    fn tick_superconducts_into_walls() {
        let test_z = 8;

        set_pattern(
            &[
                "######", //
                "##XS##", //
                "#S##X#", //
                "#X##S#", //
                "##SX##", //
                "######", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                'S' => SuperconductingWall(0.0, OPEN_HEAT_TRANSFER_COEFFICIENT, 2000.0),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "######", //
                "##xS##", //
                "#S##x#", //
                "#x##S#", //
                "##Sx##", //
                "######", //
            ],
            |c: char| match c {
                'x' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    // This value is arbitrary, it's just what we get right now.
                    // Update it if the calculations changed intentionally.
                    (ATMOS_THERMAL_ENERGY, 80.0),
                ])),
                // The first value is arbitrary, it's just what we get right now.
                // Update it if the calculations changed intentionally.
                'S' => SuperconductingWall(20.0, OPEN_HEAT_TRANSFER_COEFFICIENT, 2000.0),
                '#' => Wall,
                _ => Vacuum,
            },
            test_z,
        );
    }

    // Air should flow into a space tile, and be deleted.
    #[test]
    fn tick_empties_space() {
        let test_z = 9;

        set_pattern(
            &[
                "#####", //
                "##X##", //
                "#X X#", //
                "##X##", //
                "#####", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 100.0), //
                    (ATMOS_THERMAL_ENERGY, 100.0),
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "#####", //
                "##x##", //
                "#x x#", //
                "##x##", //
                "#####", //
            ],
            |c: char| match c {
                'x' => Air(Box::new([
                    (ATMOS_OXYGEN, 50.0), //
                    (ATMOS_THERMAL_ENERGY, 50.0),
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );
    }

    // Air should tend towards the external temperature, if any.
    #[test]
    fn tick_affected_by_external_temperature() {
        let test_z = 10;

        set_pattern(
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 8.0),                      //
                    (ATMOS_NITROGEN, 14.0),                   //
                    (ATMOS_THERMAL_ENERGY, 0.0),              //
                    (ATMOS_MODE, ATMOS_MODE_LAVALAND as f32), //
                    (ATMOS_EXTERNAL_TEMPERATURE, 100.0),
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "###", //
                "#Y#", //
                "###", //
            ],
            |c: char| match c {
                'Y' => Air(Box::new([
                    (ATMOS_OXYGEN, 8.0),    //
                    (ATMOS_NITROGEN, 14.0), //
                    // This value is arbitrary, it's just what we get right now.
                    // Update it if the calculations changed intentionally.
                    (ATMOS_THERMAL_ENERGY, 8_800.0),
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );
    }

    // Air should exchange with lavaland atmosphere.
    #[test]
    fn tick_affected_by_lavaland_atmosphere() {
        let test_z = 11;

        set_pattern(
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 0.0),                      //
                    (ATMOS_NITROGEN, 0.0),                    //
                    (ATMOS_MODE, ATMOS_MODE_LAVALAND as f32), //
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "###", //
                "#Y#", //
                "###", //
            ],
            |c: char| match c {
                'Y' => Air(Box::new([
                    // Gain 50% of Lavaland air.
                    (ATMOS_OXYGEN, 4.0),   //
                    (ATMOS_NITROGEN, 7.0), //
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );
    }

    // Air should exchange with Earth-like atmosphere.
    #[test]
    fn tick_affected_by_eartlike_air() {
        let test_z = 12;

        set_pattern(
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            |c: char| match c {
                'X' => Air(Box::new([
                    (ATMOS_OXYGEN, 0.0),                       //
                    (ATMOS_NITROGEN, 0.0),                     //
                    (ATMOS_MODE, ATMOS_MODE_EARTHLIKE as f32), //
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );

        tick();

        expect_pattern(
            &[
                "###", //
                "#Y#", //
                "###", //
            ],
            |c: char| match c {
                'Y' => Air(Box::new([
                    // Gain 50% of standard air.
                    (ATMOS_OXYGEN, STANDARD_OXYGEN_MOLES / 2.0), //
                    (ATMOS_NITROGEN, STANDARD_NITROGEN_MOLES / 2.0), //
                ])),
                '#' => Wall,
                _ => Space,
            },
            test_z,
        );
    }
}
