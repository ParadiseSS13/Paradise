use crate::milla::constants::*;
use atomic_float::AtomicF32;
use bitflags::bitflags;
use byondapi::map::{byond_locatexyz, ByondXYZ};
use byondapi::prelude::*;
use std::collections::HashSet;
use std::ops::Add;
use std::sync::{atomic::AtomicBool, atomic::Ordering::Relaxed, RwLock};

/// Represents a collection of gases, with amounts in moles.
#[derive(Debug)]
pub(crate) struct GasSet {
    pub(crate) values: [f32; GAS_COUNT],
    moles_cache: AtomicF32,
    heat_capacity_cache: AtomicF32,
    dirty: AtomicBool,
}

#[allow(dead_code)]
impl GasSet {
    pub(crate) fn new() -> Self {
        GasSet {
            values: [0.0; GAS_COUNT],
            moles_cache: 0.0.into(),
            heat_capacity_cache: 0.0.into(),
            dirty: true.into(),
        }
    }
    pub(crate) fn oxygen(&self) -> f32 {
        self.values[GAS_OXYGEN]
    }
    pub(crate) fn set_oxygen(&mut self, value: f32) {
        self.values[GAS_OXYGEN] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn carbon_dioxide(&self) -> f32 {
        self.values[GAS_CARBON_DIOXIDE]
    }
    pub(crate) fn set_carbon_dioxide(&mut self, value: f32) {
        self.values[GAS_CARBON_DIOXIDE] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn nitrogen(&self) -> f32 {
        self.values[GAS_NITROGEN]
    }
    pub(crate) fn set_nitrogen(&mut self, value: f32) {
        self.values[GAS_NITROGEN] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn toxins(&self) -> f32 {
        self.values[GAS_TOXINS]
    }
    pub(crate) fn set_toxins(&mut self, value: f32) {
        self.values[GAS_TOXINS] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn sleeping_agent(&self) -> f32 {
        self.values[GAS_SLEEPING_AGENT]
    }
    pub(crate) fn set_sleeping_agent(&mut self, value: f32) {
        self.values[GAS_SLEEPING_AGENT] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn agent_b(&self) -> f32 {
        self.values[GAS_AGENT_B]
    }
    pub(crate) fn set_agent_b(&mut self, value: f32) {
        self.values[GAS_AGENT_B] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn set_dirty(&mut self) {
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn recalculate(&self) {
        let mut moles = 0.0;
        let mut heat_capacity = 0.0;
        for i in 0..GAS_COUNT {
            moles += self.values[i];
            heat_capacity += self.values[i] * SPECIFIC_HEATS[i];
        }
        self.moles_cache.store(moles, Relaxed);
        self.heat_capacity_cache.store(heat_capacity, Relaxed);
        self.dirty.store(false, Relaxed);
    }
    /// The heat capacity of this set of gases, in joules per kelvin.
    #[allow(clippy::needless_range_loop)]
    pub(crate) fn heat_capacity(&self) -> f32 {
        if self.dirty.load(Relaxed) {
            self.recalculate();
        }
        self.heat_capacity_cache.load(Relaxed)
    }
    /// The total number of moles of gas.
    #[allow(clippy::needless_range_loop)]
    pub(crate) fn moles(&self) -> f32 {
        if self.dirty.load(Relaxed) {
            self.recalculate();
        }
        self.moles_cache.load(Relaxed)
    }
    pub(crate) fn copy_from(&mut self, other: &GasSet) {
        for i in 0..GAS_COUNT {
            self.values[i] = other.values[i];
            let dirty = other.dirty.load(Relaxed);
            if dirty {
                self.dirty.store(true, Relaxed);
            } else {
                self.heat_capacity_cache
                    .store(other.heat_capacity_cache.load(Relaxed), Relaxed);
                self.moles_cache
                    .store(other.moles_cache.load(Relaxed), Relaxed);
                self.dirty.store(false, Relaxed);
            }
        }
    }
    pub(crate) fn add_gases(&mut self, other: &Self) {
        for i in 0..GAS_COUNT {
            self.values[i] += other.values[i];
        }
    }
    #[allow(dead_code)]
    pub(crate) fn clear(&mut self) {
        for i in 0..GAS_COUNT {
            self.values[i] = 0.0;
        }
    }
}

impl Clone for GasSet {
    fn clone(&self) -> Self {
        let mut clone = GasSet::new();
        clone.copy_from(self);
        clone
    }
}

impl Add for GasSet {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        let mut result = self.clone();
        result.add_gases(&other);
        result
    }
}

/// Determines the general behavior of a tile.
#[derive(Debug, Copy, Clone, PartialEq)]
pub(crate) enum AtmosMode {
    /// Tile is exposed to space, and will lose all of its air every tick.
    Space,
    /// Tile has no special behavior.
    Sealed,
    /// Tile is exposed to the given environment.
    ExposedTo { environment_id: u8 },
    /// Prevents hot tiles from automatically decaying towards T20C
    NoDecay,
}

impl From<AtmosMode> for ByondValue {
    fn from(value: AtmosMode) -> Self {
        match value {
            AtmosMode::Space => ByondValue::from(0.0),
            AtmosMode::Sealed => ByondValue::from(1.0),
            AtmosMode::ExposedTo { .. } => ByondValue::from(2.0),
            AtmosMode::NoDecay => ByondValue::from(3.0),
        }
    }
}

/// How well a tile conducts heat in each direction.
/// Valid values are 0.0 to 0.4, inclusive.
#[derive(Debug, Copy, Clone)]
pub(crate) struct Superconductivity {
    pub(crate) north: f32,
    pub(crate) east: f32,
    pub(crate) south: f32,
    pub(crate) west: f32,
}

impl Superconductivity {
    pub(crate) fn new() -> Self {
        Superconductivity {
            north: OPEN_HEAT_TRANSFER_COEFFICIENT,
            east: OPEN_HEAT_TRANSFER_COEFFICIENT,
            south: OPEN_HEAT_TRANSFER_COEFFICIENT,
            west: OPEN_HEAT_TRANSFER_COEFFICIENT,
        }
    }
    pub(crate) fn copy_from(&mut self, other: &Superconductivity) {
        self.north = other.north;
        self.east = other.east;
        self.south = other.south;
        self.west = other.west;
    }
}

bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
    pub(crate) struct AirtightDirections: u8 {
        const NORTH = 1 << 0;
        const EAST = 1 << 1;
        const SOUTH = 1 << 2;
        const WEST = 1 << 3;
    }
}

/// A single tile in the atmos model.
#[repr(align(64))]
#[derive(Debug, Clone)]
pub(crate) struct Tile {
    /// Which directions this tile cannot transmit gases in.
    pub(crate) airtight_directions: AirtightDirections,
    /// The gases this tile holds.
    pub(crate) gases: GasSet,
    /// How much thermal energy this tile has, in joules.
    pub(crate) thermal_energy: f32,
    /// The general behavior of this tile.
    pub(crate) mode: AtmosMode,
    /// How well this tile conducts heat in each direction
    pub(crate) superconductivity: Superconductivity,
    /// How much heat capacity the tile itself has, in joules per kelvin.
    pub(crate) innate_heat_capacity: f32,
    /// How hot the tile's hotspot is. A hotspot is a sub-tile reagion that's caught fire.
    pub(crate) hotspot_temperature: f32,
    /// How much of the tile the hotspot covers. 1.0 would be the entire tile.
    pub(crate) hotspot_volume: f32,
    /// How strongly the air in this tile is flowing towards +axis.
    pub(crate) wind: [f32; AXES.len()],
    /// Is there a wall in this direction?
    pub(crate) wall: [bool; AXES.len()],
    pub(crate) gas_flow: [[[f32; 2]; GAS_COUNT]; AXES.len()],
    /// How much fuel was burnt this tick?
    pub(crate) fuel_burnt: f32,
}

impl Tile {
    pub(crate) fn new() -> Self {
        Tile {
            airtight_directions: AirtightDirections::empty(),
            gases: GasSet::new(),
            thermal_energy: 0.0,
            mode: AtmosMode::Space,
            superconductivity: Superconductivity::new(),
            innate_heat_capacity: 0.0,
            hotspot_temperature: 0.0,
            hotspot_volume: 0.0,
            wind: [0.0, 0.0],
            wall: [false, false],
            gas_flow: [[[0.0; 2]; GAS_COUNT]; AXES.len()],
            fuel_burnt: 0.0,
        }
    }
    /// The total heat capacity of this tile and its gases, in joules per kelvin.
    pub(crate) fn heat_capacity(&self) -> f32 {
        self.gases.heat_capacity() + self.innate_heat_capacity
    }
    /// The temperature of this tile, in kelvin.
    pub(crate) fn temperature(&self) -> f32 {
        let heat_capacity = self.heat_capacity();
        if heat_capacity <= 0.0 {
            0.0
        } else {
            self.thermal_energy / heat_capacity
        }
    }
    /// Calculates the pressure of a tile.
    pub(crate) fn pressure(&self) -> f32 {
        if let AtmosMode::Space = self.mode {
            return 0.0;
        }
        let mut heat_capacity = self.gases.heat_capacity();
        heat_capacity += self.innate_heat_capacity;
        if heat_capacity <= 0.0 {
            return 0.0;
        }
        let temperature = self.thermal_energy / heat_capacity;
        self.gases.moles()
            * temperature.max(MINIMUM_TEMPERATURE_FOR_PRESSURE)
            * R_IDEAL_GAS_EQUATION
            / TILE_VOLUME
    }
    /// Calculates the partial pressure of a gas in a tile.
    pub(crate) fn partial_pressure(&self, gas: usize) -> f32 {
        if self.gases.values[gas] <= 0.0 {
            return 0.0;
        }

        self.gases.values[gas]
            * self.temperature().max(MINIMUM_TEMPERATURE_FOR_PRESSURE)
            * R_IDEAL_GAS_EQUATION
            / TILE_VOLUME
    }

    #[allow(clippy::needless_range_loop)]
    pub(crate) fn copy_from(&mut self, other: &Tile) {
        self.airtight_directions = other.airtight_directions;
        self.gases.copy_from(&other.gases);
        self.thermal_energy = other.thermal_energy;
        self.mode = other.mode;
        self.superconductivity.copy_from(&other.superconductivity);
        self.innate_heat_capacity = other.innate_heat_capacity;
        self.hotspot_temperature = other.hotspot_temperature;
        self.hotspot_volume = other.hotspot_volume;
        for axis in 0..AXES.len() {
            self.wind[axis] = other.wind[axis];
            self.wall[axis] = other.wall[axis];
            for gas in 0..GAS_COUNT {
                self.gas_flow[axis][gas][GAS_FLOW_IN] = other.gas_flow[axis][gas][GAS_FLOW_IN];
                self.gas_flow[axis][gas][GAS_FLOW_OUT] = other.gas_flow[axis][gas][GAS_FLOW_OUT];
            }
        }
        self.fuel_burnt = other.fuel_burnt;
    }
}

/// Converts a tile into BYOND values.
/// Must match the order in code/__DEFINES/milla.dm
impl From<&Tile> for Vec<ByondValue> {
    fn from(value: &Tile) -> Self {
        let mut environment_id: u8 = 0;
        if let AtmosMode::ExposedTo {
            environment_id: env,
        } = value.mode
        {
            environment_id = env;
        }
        vec![
            ByondValue::from(value.airtight_directions.bits() as f32),
            ByondValue::from(value.gases.oxygen()),
            ByondValue::from(value.gases.carbon_dioxide()),
            ByondValue::from(value.gases.nitrogen()),
            ByondValue::from(value.gases.toxins()),
            ByondValue::from(value.gases.sleeping_agent()),
            ByondValue::from(value.gases.agent_b()),
            ByondValue::from(value.mode),
            ByondValue::from(environment_id as f32),
            ByondValue::from(value.superconductivity.north),
            ByondValue::from(value.superconductivity.east),
            ByondValue::from(value.superconductivity.south),
            ByondValue::from(value.superconductivity.west),
            ByondValue::from(value.innate_heat_capacity),
            ByondValue::from(value.temperature()),
            ByondValue::from(value.hotspot_temperature),
            ByondValue::from(value.hotspot_volume),
            ByondValue::from(value.wind[AXIS_X]),
            ByondValue::from(value.wind[AXIS_Y]),
            ByondValue::from(value.fuel_burnt),
        ]
    }
}

bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
    pub(crate) struct ReasonFlags: u8 {
        const DISPLAY = 1 << 0;
        const HOT = 1 << 1;
        const WIND = 1 << 2;
    }
}

/// A tile that we consider interesting for some reason.
#[derive(Debug, Clone)]
pub(crate) struct InterestingTile {
    /// The tile itself.
    pub(crate) tile: Tile,
    /// Where the tile is.
    pub(crate) coords: ByondXYZ,
    /// A bitmask of reasons this tile is interesting, values are REASON_*.
    pub(crate) reasons: ReasonFlags,
    /// These represent the net force generated by air winding out of the tile along each axis.
    /// For a tile losing air equally in all directions, they will be zero.
    /// For a tile losing air towards positive X only, wind_x will be the air pressure moved.
    pub(crate) wind_x: f32,
    /// See wind_x.
    pub(crate) wind_y: f32,
}

/// Convert an InterestingTile into a flat vector of ByondValues.
/// This will be assembled into one long list in BYOND.
///
/// It'd be friendlier to make these BYOND lists or even datums, but this way is faster than lists,
/// and datums isn't possible.
///
/// Must match the order in code/__DEFINES/milla.dm
impl From<&InterestingTile> for Vec<ByondValue> {
    fn from(value: &InterestingTile) -> Self {
        let mut ret: Vec<ByondValue> = (&value.tile).into();
        ret.extend(vec![
            byond_locatexyz(value.coords).unwrap(),
            ByondValue::from(value.reasons.bits() as f32),
            ByondValue::from(value.wind_x),
            ByondValue::from(value.wind_y),
        ]);

        ret
    }
}

/// A single Z level in the atmos model.
pub(crate) struct ZLevel {
    tiles: Box<[Tile; MAP_SIZE * MAP_SIZE]>,
    pub(crate) active_pressure_chunks: HashSet<(u8, u8)>,
    pub(crate) frozen: bool,
}

impl ZLevel {
    pub(crate) fn new() -> Self {
        let mut unbuilt: Vec<Tile> = Vec::with_capacity(MAP_SIZE * MAP_SIZE);
        for _ in 0..MAP_SIZE * MAP_SIZE {
            unbuilt.push(Tile::new());
        }
        ZLevel {
            tiles: unbuilt.into_boxed_slice().try_into().unwrap(),
            active_pressure_chunks: HashSet::new(),
			frozen: false,
        }
    }

    pub(crate) fn maybe_get_index(x: i32, y: i32) -> Option<usize> {
        if x < 0 || x >= MAP_SIZE as i32 || y < 0 || y >= MAP_SIZE as i32 {
            None
        } else {
            Some(x as usize * MAP_SIZE + y as usize)
        }
    }

    pub(crate) fn get_tile(&self, index: usize) -> &Tile {
        &self.tiles[index]
    }

    #[allow(dead_code)]
    pub(crate) fn maybe_get_tile(&self, x: i32, y: i32) -> Option<&Tile> {
        Some(&self.tiles[ZLevel::maybe_get_index(x, y)?])
    }

    pub(crate) fn get_tile_mut(&mut self, index: usize) -> &mut Tile {
        &mut self.tiles[index]
    }

    pub(crate) fn get_pair_mut(&mut self, index1: usize, index2: usize) -> (&mut Tile, &mut Tile) {
        // Split borrow to get two mutable tiles at the same time.
        // Ref: https://doc.rust-lang.org/nomicon/borrow-splitting.html
        let ptr = self.tiles.as_mut_ptr();
        unsafe {
            assert!(index1 != index2);

            (
                ptr.add(index1).as_mut().unwrap(),
                ptr.add(index2).as_mut().unwrap(),
            )
        }
    }

    pub(crate) fn copy_from(&mut self, other: &ZLevel) {
        for i in 0..self.tiles.len() {
            self.tiles[i].copy_from(&other.tiles[i]);
        }
        self.active_pressure_chunks = other.active_pressure_chunks.clone();
		self.frozen = other.frozen;
    }
}

/// A complete atmos model, including all Z levels.
pub(crate) struct Model(pub(crate) Vec<RwLock<ZLevel>>);

impl Model {
    pub(crate) fn new() -> Self {
        Model(Vec::new())
    }
}

/// The main buffers that hold the active and inactive versions of the model.
/// Whichever buffer is active represents the current tick, and is the only thing BYOND can see.
/// Normally, the active buffer is read-write.
///
/// During tick(), things change:
/// * The active buffer is now read-only, as it represents the values from the previous tick.
/// * The inactive buffer is now available read-write, as it represents the values of the next tick,
///   the ones we're currently computing.
/// Note that we do read some values from the inactive buffer here, as they are intermediate results
/// during computation.
pub(crate) struct Buffers {
    buffer_a: RwLock<Model>,
    buffer_b: RwLock<Model>,
    /// The atomic boolean that's used to determine which buffer is active.
    flipper: AtomicBool,
    pub(crate) environments: RwLock<Vec<Tile>>,
}

/// Readability constant for flipper's value.
const A_IS_ACTIVE: bool = false;

impl Buffers {
    pub(crate) fn new() -> Self {
        Buffers {
            buffer_a: RwLock::new(Model::new()),
            buffer_b: RwLock::new(Model::new()),
            flipper: AtomicBool::new(true),
            environments: RwLock::new(Vec::new()),
        }
    }

    /// Ensures that all buffers up to ZLevel `z` exist.
    pub(crate) fn init_to(&self, z: i32) {
        let mut a_levels = self.buffer_a.write().unwrap();
        while z >= a_levels.0.len() as i32 {
            a_levels.0.push(RwLock::new(ZLevel::new()));
        }
        let mut b_levels = self.buffer_b.write().unwrap();
        while z >= b_levels.0.len() as i32 {
            b_levels.0.push(RwLock::new(ZLevel::new()));
        }
    }

    /// Fetches the active buffer map, which could be either buffer_a or buffer_b.
    pub(crate) fn get_active(&self) -> &RwLock<Model> {
        match self.flipper.load(std::sync::atomic::Ordering::Relaxed) {
            A_IS_ACTIVE => &self.buffer_a,
            _ => &self.buffer_b,
        }
    }

    /// Fetches the inactive buffer map, which could be either buffer_a or buffer_b.
    pub(crate) fn get_inactive(&self) -> &RwLock<Model> {
        match self.flipper.load(std::sync::atomic::Ordering::Relaxed) {
            A_IS_ACTIVE => &self.buffer_b,
            _ => &self.buffer_a,
        }
    }

    /// Flips wether buffer_a or buffer_b is active.
    pub(crate) fn flip(&self) {
        self.flipper
            .fetch_xor(true, std::sync::atomic::Ordering::Relaxed);
    }

    /// Create an environment for ExposedTo.
    pub(crate) fn create_environment(&self, mut tile: Tile) -> u8 {
        let mut environments = self.environments.write().unwrap();
        let id = environments.len() as u8;
        tile.mode = AtmosMode::ExposedTo { environment_id: id };
        tile.gases.recalculate();
        environments.push(tile);
        id
    }
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;

    // The model should start empty.
    #[test]
    fn initial_zero() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        let active = buffers.get_active().read().unwrap();
        let z_level = active.0[0].read().unwrap();
        let tile = z_level.get_tile(ZLevel::maybe_get_index(0, 0).unwrap());
        assert_eq!(tile.airtight_directions, AirtightDirections::empty());
        for i in 0..GAS_COUNT {
            assert_eq!(tile.gases.values[i], 0.0, "{}", i);
        }
        assert_eq!(tile.thermal_energy, 0.0);
        assert_eq!(tile.mode, AtmosMode::Space);
        assert_eq!(tile.superconductivity.north, OPEN_HEAT_TRANSFER_COEFFICIENT);
        assert_eq!(tile.superconductivity.east, OPEN_HEAT_TRANSFER_COEFFICIENT);
        assert_eq!(tile.superconductivity.south, OPEN_HEAT_TRANSFER_COEFFICIENT);
        assert_eq!(tile.superconductivity.west, OPEN_HEAT_TRANSFER_COEFFICIENT);
        assert_eq!(tile.innate_heat_capacity, 0.0);
    }

    /// flip_buffers() should alternate us betweeen two buffers, and changes should be preserved
    /// when we switch back to the original one.
    #[test]
    fn flip_works() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        // Write some arbitrary data to the first buffer.
        {
            let active = buffers.get_active().read().unwrap();
            let mut z_level = active.0[0].write().unwrap();
            let tile = z_level.get_tile_mut(ZLevel::maybe_get_index(0, 0).unwrap());
            tile.gases.values[0] = 1.0;
        }

        buffers.flip();

        // Verify that the second buffer is still empty.
        {
            let active = buffers.get_active().read().unwrap();
            let z_level = active.0[0].write().unwrap();
            let tile = z_level.get_tile(ZLevel::maybe_get_index(0, 0).unwrap());
            assert_eq!(tile.gases.values[0], 0.0);
        }

        // Write a different set of arbitrary data to the second buffer.
        {
            let active = buffers.get_active().read().unwrap();
            let mut z_level = active.0[0].write().unwrap();
            let tile = z_level.get_tile_mut(ZLevel::maybe_get_index(0, 0).unwrap());
            tile.gases.values[0] = 2.0;
        }

        buffers.flip();

        // Verify that what we wrote to the first buffer is still there.
        {
            let active = buffers.get_active().read().unwrap();
            let z_level = active.0[0].write().unwrap();
            let tile = z_level.get_tile(ZLevel::maybe_get_index(0, 0).unwrap());
            assert_eq!(tile.gases.values[0], 1.0);
        }

        buffers.flip();

        // Verify that what we wrote to the second buffer is still there.
        {
            let active = buffers.get_active().read().unwrap();
            let z_level = active.0[0].write().unwrap();
            let tile = z_level.get_tile(ZLevel::maybe_get_index(0, 0).unwrap());
            assert_eq!(tile.gases.values[0], 2.0);
        }
    }
}
