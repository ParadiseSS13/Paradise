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
    pub(crate) fn hydrogen(&self) -> f32 {
        self.values[GAS_HYDROGEN]
    }
    pub(crate) fn set_hydrogen(&mut self, value: f32) {
        self.values[GAS_HYDROGEN] = value;
        self.dirty.store(true, Relaxed);
    }
    pub(crate) fn water_vapor(&self) -> f32 {
        self.values[GAS_WATER_VAPOR]
    }
    pub(crate) fn set_water_vapor(&mut self, value: f32) {
        self.values[GAS_WATER_VAPOR] = value;
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
    /// How much flows in and out across the +X and +Y sides each tick, as a share of what's
    /// there. Every gas that flows across a side flows by the same amount.
    pub(crate) flow: [[f32; 2]; AXES.len()],
    /// Which gases flow across each of those sides, a bit for each gas.
    pub(crate) flow_gases: [u8; AXES.len()],
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
            flow: [[0.0; 2]; AXES.len()],
            flow_gases: [0; AXES.len()],
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
    /// The tile's pressure, and the temperature its partial pressures get worked out with, in one
    /// go. The same two numbers `pressure()` and `temperature()` give, the second held to the
    /// minimum.
    pub(crate) fn pressure_and_pressure_temperature(&self) -> (f32, f32) {
        let heat_capacity = self.heat_capacity();
        if heat_capacity <= 0.0 {
            return (0.0, (0.0f32).max(MINIMUM_TEMPERATURE_FOR_PRESSURE));
        }
        let pressure_temperature =
            (self.thermal_energy / heat_capacity).max(MINIMUM_TEMPERATURE_FOR_PRESSURE);
        if let AtmosMode::Space = self.mode {
            return (0.0, pressure_temperature);
        }
        (
            self.gases.moles() * pressure_temperature * R_IDEAL_GAS_EQUATION / TILE_VOLUME,
            pressure_temperature,
        )
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
            self.flow[axis] = other.flow[axis];
            self.flow_gases[axis] = other.flow_gases[axis];
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
            ByondValue::from(value.gases.hydrogen()),
            ByondValue::from(value.gases.water_vapor()),
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
        /// Water condensed on it this tick.
        const WET = 1 << 3;
        /// Water condensed on it this tick and froze.
        const ICY = 1 << 4;
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

/// What BYOND is waiting for on a tile: its pressure going under a line.
#[derive(Debug, Clone, Copy)]
pub(crate) struct Tripwire {
    /// Goes off when the pressure is under this.
    pub(crate) pressure_below: f32,
}

impl Tripwire {
    /// Goes off when either this or the other one would.
    pub(crate) fn join(&mut self, other: &Tripwire) {
        self.pressure_below = self.pressure_below.max(other.pressure_below);
    }

    /// Has this tile's air set it off? Pressure is worked out the way BYOND does it.
    pub(crate) fn tripped_by(&self, tile: &Tile) -> bool {
        let mut moles = 0.0;
        for gas in 0..GAS_COUNT {
            moles += tile.gases.values[gas];
        }
        let pressure = moles * R_IDEAL_GAS_EQUATION * tile.temperature() / TILE_VOLUME;
        pressure
            < self.pressure_below
                + self.pressure_below.abs() * TRIPWIRE_ROOM_FRACTION
                + TRIPWIRE_ROOM
    }
}

/// A scrubber working on one tile. What it takes off the tile each tick piles up here until BYOND
/// comes for it.
#[derive(Clone)]
pub(crate) struct Scrubber {
    /// What BYOND knows it by.
    pub(crate) id: u32,
    /// Which tile it's on.
    pub(crate) tile: usize,
    /// It only does anything while there's more than a trace of one of these gases, a bit each.
    pub(crate) starts_for: u8,
    /// The gases it takes, a bit each.
    pub(crate) takes: u8,
    /// How much of what's there it takes each tick.
    pub(crate) share: f32,
    /// The gas it's taken since BYOND last collected.
    pub(crate) taken: [f32; GAS_COUNT],
    /// The heat that gas carried.
    pub(crate) taken_thermal_energy: f32,
}

impl Scrubber {
    /// Takes this tick's gas off the tile. The tile keeps its temperature.
    pub(crate) fn scrub(&mut self, tile: &mut Tile) {
        let mut wanted = false;
        for gas in 0..GAS_COUNT {
            if self.starts_for & (1 << gas) != 0 && tile.gases.values[gas] > SCRUBBER_TRACE_MOLES {
                wanted = true;
            }
        }
        if !wanted {
            return;
        }
        let temperature = tile.temperature();
        let mut taken_heat_capacity = 0.0;
        let mut took_any = false;
        for gas in 0..GAS_COUNT {
            if self.takes & (1 << gas) == 0 {
                continue;
            }
            // BYOND's gas mixtures move gas around in ten-thousandths of a mole, so this does too.
            let amount = ((tile.gases.values[gas] * self.share) / SCRUBBER_STEP_MOLES + 0.5)
                .floor()
                * SCRUBBER_STEP_MOLES;
            if !(amount > 0.0) {
                continue;
            }
            let amount = amount.min(tile.gases.values[gas]);
            tile.gases.values[gas] -= amount;
            self.taken[gas] += amount;
            taken_heat_capacity += amount * SPECIFIC_HEATS[gas];
            took_any = true;
        }
        if took_any {
            tile.gases.set_dirty();
            tile.thermal_energy = temperature * tile.heat_capacity();
            self.taken_thermal_energy += temperature * taken_heat_capacity;
        }
    }
}

/// A set of tiles on one Z level, one bit per tile, so walking it always goes in index order.
#[derive(Clone)]
pub(crate) struct TileSet {
    words: Box<[usize]>,
}

const TILE_SET_WORD_BITS: usize = usize::BITS as usize;

impl TileSet {
    pub(crate) fn new() -> Self {
        TileSet {
            words: vec![0; (MAP_SIZE * MAP_SIZE).div_ceil(TILE_SET_WORD_BITS)].into_boxed_slice(),
        }
    }

    /// Adds a tile. Returns true if it wasn't in the set already.
    pub(crate) fn insert(&mut self, index: usize) -> bool {
        let word = &mut self.words[index / TILE_SET_WORD_BITS];
        let bit = 1 << (index % TILE_SET_WORD_BITS);
        let is_new = *word & bit == 0;
        *word |= bit;
        is_new
    }

    pub(crate) fn contains(&self, index: usize) -> bool {
        self.words[index / TILE_SET_WORD_BITS] & (1 << (index % TILE_SET_WORD_BITS)) != 0
    }

    /// Takes a tile out. Returns true if it was in the set.
    pub(crate) fn remove(&mut self, index: usize) -> bool {
        let word = &mut self.words[index / TILE_SET_WORD_BITS];
        let bit = 1 << (index % TILE_SET_WORD_BITS);
        let was_there = *word & bit != 0;
        *word &= !bit;
        was_there
    }

    /// Adds every tile from another set.
    pub(crate) fn add_all(&mut self, other: &TileSet) {
        for (word, other_word) in self.words.iter_mut().zip(other.words.iter()) {
            *word |= *other_word;
        }
    }

    pub(crate) fn clear(&mut self) {
        self.words.fill(0);
    }

    /// Puts every tile in the set.
    pub(crate) fn fill(&mut self) {
        self.words.fill(!0);
        let spare_bits = self.words.len() * TILE_SET_WORD_BITS - MAP_SIZE * MAP_SIZE;
        if spare_bits > 0 {
            let last = self.words.len() - 1;
            self.words[last] = !0 >> spare_bits;
        }
    }

    /// The first tile in the set at or after `from`. Walking with this picks up tiles that get
    /// added ahead of where the walk has got to.
    pub(crate) fn next_from(&self, from: usize) -> Option<usize> {
        if from >= MAP_SIZE * MAP_SIZE {
            return None;
        }
        let mut word_index = from / TILE_SET_WORD_BITS;
        let mut word = self.words[word_index] & (!0 << (from % TILE_SET_WORD_BITS));
        loop {
            if word != 0 {
                return Some(word_index * TILE_SET_WORD_BITS + word.trailing_zeros() as usize);
            }
            word_index += 1;
            if word_index >= self.words.len() {
                return None;
            }
            word = self.words[word_index];
        }
    }
}

/// Each tile's pressure as of the start of the tick, worked out the first time it's asked for.
#[derive(Default)]
pub(crate) struct PressureCache {
    pressures: Vec<f32>,
    pressure_temperatures: Vec<f32>,
    stamps: Vec<u32>,
    stamp: u32,
}

impl PressureCache {
    /// Forgets everything, ready for a new tick.
    pub(crate) fn start_tick(&mut self) {
        if self.stamps.is_empty() {
            self.pressures = vec![0.0; MAP_SIZE * MAP_SIZE];
            self.pressure_temperatures = vec![0.0; MAP_SIZE * MAP_SIZE];
            self.stamps = vec![0; MAP_SIZE * MAP_SIZE];
        }
        self.stamp = self.stamp.wrapping_add(1);
        if self.stamp == 0 {
            self.stamps.fill(0);
            self.stamp = 1;
        }
    }

    /// A tile's pressure, and the temperature its partial pressures use.
    pub(crate) fn get(&mut self, level: &ZLevel, index: usize) -> (f32, f32) {
        if self.stamps[index] != self.stamp {
            let (pressure, pressure_temperature) =
                level.get_tile(index).pressure_and_pressure_temperature();
            self.pressures[index] = pressure;
            self.pressure_temperatures[index] = pressure_temperature;
            self.stamps[index] = self.stamp;
        }
        (self.pressures[index], self.pressure_temperatures[index])
    }
}

/// A single Z level in the atmos model.
pub(crate) struct ZLevel {
    tiles: Box<[Tile; MAP_SIZE * MAP_SIZE]>,
    pub(crate) active_pressure_chunks: HashSet<(u8, u8)>,
    pub(crate) frozen: bool,
    /// The tiles being worked on this tick. Everything else hasn't changed lately and is the
    /// same in both buffers, so it gets left alone.
    pub(crate) awake: TileSet,
    /// The tiles that changed at some point this tick. They and the tiles next to them are the
    /// ones to work on next tick.
    pub(crate) active: TileSet,
    /// The tiles BYOND has written to since the last tick.
    pub(crate) written: TileSet,
    /// The tiles whose air BYOND can tell is different after this tick.
    pub(crate) changed_for_byond: TileSet,
    /// The tiles whose blocked sides need working out again this tick, because BYOND wrote to
    /// them or to the tile on one of those sides.
    pub(crate) walls_to_find: TileSet,
    pub(crate) pressure_cache: PressureCache,
}

impl ZLevel {
    pub(crate) fn new() -> Self {
        let mut unbuilt: Vec<Tile> = Vec::with_capacity(MAP_SIZE * MAP_SIZE);
        for _ in 0..MAP_SIZE * MAP_SIZE {
            unbuilt.push(Tile::new());
        }
        // A new level starts with every tile counted as changed and as written to, so the first
        // tick looks at all of them.
        let mut active = TileSet::new();
        active.fill();
        let mut written = TileSet::new();
        written.fill();
        ZLevel {
            tiles: unbuilt.into_boxed_slice().try_into().unwrap(),
            active_pressure_chunks: HashSet::new(),
            frozen: false,
            awake: TileSet::new(),
            active,
            written,
            changed_for_byond: TileSet::new(),
            walls_to_find: TileSet::new(),
            pressure_cache: PressureCache::default(),
        }
    }

    /// Gets the tile for BYOND to write to, and remembers that it did.
    pub(crate) fn get_tile_mut_for_write(&mut self, index: usize) -> &mut Tile {
        self.written.insert(index);
        &mut self.tiles[index]
    }

    /// Starts working on a tile this tick. It hasn't changed lately, so this buffer's copy of it
    /// already matches, but it's copied again anyway so nothing rides on that.
    pub(crate) fn wake(&mut self, prev: &ZLevel, index: usize) {
        if self.awake.insert(index) {
            self.tiles[index].copy_from(&prev.tiles[index]);
        }
    }

    /// Notes that a tile changed this tick, which means the tiles next to it need working on too.
    pub(crate) fn mark_changed(&mut self, prev: &ZLevel, index: usize) {
        if !self.active.insert(index) {
            return;
        }
        let x = (index / MAP_SIZE) as i32;
        let y = (index % MAP_SIZE) as i32;
        for (dx, dy) in DIRECTIONS {
            if let Some(neighbor_index) = ZLevel::maybe_get_index(x + dx, y + dy) {
                self.wake(prev, neighbor_index);
            }
        }
    }

    /// Gets this buffer ready to hold the next tick: picks the tiles to work on and copies them
    /// over from the current buffer.
    pub(crate) fn begin_tick(&mut self, prev: &ZLevel) {
        self.active_pressure_chunks = prev.active_pressure_chunks.clone();
        self.frozen = prev.frozen;
        self.written.clear();
        self.changed_for_byond.clear();
        self.awake.clear();
        // This buffer last held the tick before last, so its list of what changed is from then.
        // Those tiles have only been copied into the other buffer since, so do them once more
        // to leave both buffers with a fresh copy.
        self.awake.add_all(&self.active);
        if self.frozen {
            // Nothing gets worked on while frozen. These only need copying across.
            self.awake.add_all(&prev.active);
            self.awake.add_all(&prev.written);
        } else {
            // Whatever changed last tick or got written to by BYOND since, and the tiles next to
            // those. Nothing else can come out any different than it did last time.
            for source in [&prev.active, &prev.written] {
                let mut cursor = 0;
                while let Some(index) = source.next_from(cursor) {
                    cursor = index + 1;
                    self.awake.insert(index);
                    let x = (index / MAP_SIZE) as i32;
                    let y = (index % MAP_SIZE) as i32;
                    for (dx, dy) in DIRECTIONS {
                        if let Some(neighbor_index) = ZLevel::maybe_get_index(x + dx, y + dy) {
                            self.awake.insert(neighbor_index);
                        }
                    }
                }
            }
        }
        self.active.clear();
        let mut cursor = 0;
        while let Some(index) = self.awake.next_from(cursor) {
            cursor = index + 1;
            self.tiles[index].copy_from(&prev.tiles[index]);
        }
        // BYOND already knows what it wrote, but it gets told anyway, in case the tick leaves the
        // tile exactly as written and BYOND's copy isn't quite that.
        self.changed_for_byond.add_all(&prev.written);
        self.walls_to_find.clear();
        if self.frozen {
            // Keep everything that was waiting to be worked on waiting, for when the level thaws.
            self.active.add_all(&prev.active);
            self.written.add_all(&prev.written);
        } else {
            // A tile keeps whether its +X and +Y sides are blocked, and that goes by what BYOND
            // says about it and about the tiles on those sides. So a write to a tile matters to
            // it and to the tiles on its -X and -Y sides.
            let mut cursor = 0;
            while let Some(index) = prev.written.next_from(cursor) {
                cursor = index + 1;
                self.walls_to_find.insert(index);
                let x = (index / MAP_SIZE) as i32;
                let y = (index % MAP_SIZE) as i32;
                for (dx, dy) in AXES {
                    if let Some(neighbor_index) = ZLevel::maybe_get_index(x - dx, y - dy) {
                        self.walls_to_find.insert(neighbor_index);
                    }
                }
            }
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

    /// A tripwire should go off once the pressure gets to its line, and not before. One joined
    /// with another goes off when either would.
    #[test]
    fn tripwires() {
        let mut tile = Tile::new();
        tile.mode = AtmosMode::Sealed;
        tile.gases.set_oxygen(20.0);
        tile.gases.set_nitrogen(80.0);
        tile.thermal_energy = tile.heat_capacity() * T20C;
        let pressure = 100.0 * R_IDEAL_GAS_EQUATION * tile.temperature() / TILE_VOLUME;

        let mut wire = Tripwire {
            pressure_below: pressure - 0.5,
        };
        assert!(!wire.tripped_by(&tile));
        wire.pressure_below = pressure;
        assert!(wire.tripped_by(&tile));
        // Goes off a little early.
        wire.pressure_below = pressure - TRIPWIRE_ROOM / 2.0;
        assert!(wire.tripped_by(&tile));

        let mut wire = Tripwire {
            pressure_below: pressure - 0.5,
        };
        wire.join(&Tripwire {
            pressure_below: pressure,
        });
        assert!(wire.tripped_by(&tile));
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
