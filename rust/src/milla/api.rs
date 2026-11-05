use crate::logging;
use crate::milla::constants::*;
use crate::milla::conversion;
use crate::milla::model::*;
use crate::milla::simulate;
use crate::milla::statics::*;
use crate::milla::tick;
use byondapi::byond_string::str_id_of;
use byondapi::global_call::call_global;
use byondapi::global_call::call_global_id;
use byondapi::map::byond_block;
use byondapi::map::byond_locatexyz;
use byondapi::map::byond_xyz;
use byondapi::map::ByondXYZ;
use byondapi::prelude::*;
use eyre::eyre;
use eyre::Result;
use std::env;
use std::thread;
use std::time::Instant;

/// BYOND API for ensuring the buffers are usable.
#[byondapi::bind]
fn milla_initialize(byond_z: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    env::set_var("RUST_BACKTRACE", "1");
    let z = f32::try_from(byond_z)? as i32 - 1;
    internal_initialize(z)?;
    Ok(ByondValue::null())
}

/// Ensure that buffers are available.
pub(crate) fn internal_initialize(z: i32) -> eyre::Result<ByondValue> {
    if z >= MAX_Z_LEVELS {
        return Err(eyre!(
            "Suspiciously high Z level {} initialized, update MAX_Z_LEVELS if this is intentional.",
            z
        ));
    }
    let buffers = BUFFERS.get_or_init(Buffers::new);
    buffers.init_to(z);
    Ok(ByondValue::null())
}

/// BYOND API for defining an environment that a tile can be exposed to.
#[byondapi::bind]
fn milla_create_environment(
    oxygen: ByondValue,
    carbon_dioxide: ByondValue,
    nitrogen: ByondValue,
    toxins: ByondValue,
    sleeping_agent: ByondValue,
    agent_b: ByondValue,
    hydrogen: ByondValue,
    water_vapor: ByondValue,
    temperature: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    Ok(ByondValue::from(internal_create_environment(
        conversion::byond_to_option_f32(oxygen)?,
        conversion::byond_to_option_f32(carbon_dioxide)?,
        conversion::byond_to_option_f32(nitrogen)?,
        conversion::byond_to_option_f32(toxins)?,
        conversion::byond_to_option_f32(sleeping_agent)?,
        conversion::byond_to_option_f32(agent_b)?,
        conversion::byond_to_option_f32(hydrogen)?,
        conversion::byond_to_option_f32(water_vapor)?,
        conversion::byond_to_option_f32(temperature)?,
    ) as f32))
}

/// Define an environment that a tile can be exposed to.
pub(crate) fn internal_create_environment(
    oxygen: Option<f32>,
    carbon_dioxide: Option<f32>,
    nitrogen: Option<f32>,
    toxins: Option<f32>,
    sleeping_agent: Option<f32>,
    agent_b: Option<f32>,
    hydrogen: Option<f32>,
    water_vapor: Option<f32>,
    temperature: Option<f32>,
) -> u8 {
    let mut tile = Tile::new();
    if let Some(value) = oxygen {
        tile.gases.set_oxygen(value);
    }
    if let Some(value) = carbon_dioxide {
        tile.gases.set_carbon_dioxide(value);
    }
    if let Some(value) = nitrogen {
        tile.gases.set_nitrogen(value);
    }
    if let Some(value) = toxins {
        tile.gases.set_toxins(value);
    }
    if let Some(value) = sleeping_agent {
        tile.gases.set_sleeping_agent(value);
    }
    if let Some(value) = agent_b {
        tile.gases.set_agent_b(value);
    }
    if let Some(value) = hydrogen {
        tile.gases.set_hydrogen(value);
    }
    if let Some(value) = water_vapor {
        tile.gases.set_water_vapor(value);
    }
    if let Some(value) = temperature {
        tile.thermal_energy = value * tile.heat_capacity();
    }

    let buffers = BUFFERS.get_or_init(Buffers::new);
    buffers.create_environment(tile)
}

/// BYOND API for loading a block of turfs into MILLA with their default air.
#[byondapi::bind]
fn milla_load_turfs(
    data_property: ByondValue,
    low_corner: ByondValue,
    high_corner: ByondValue,
) -> eyre::Result<ByondValue> {
    let property_ref = data_property.get_strid()?;
    for turf in byond_block(byond_xyz(&low_corner)?, byond_xyz(&high_corner)?)? {
        let (x, y, z) = byond_xyz(&turf)?.coordinates();
        let mut property = turf.read_var_id(property_ref)?;
        let data = property.get_list_values()?;
        property.decrement_tempref();

        if data.len() != 19 {
            return Err(eyre!(
                "data property has the wrong length: {} vs {}",
                data.len(),
                18
            ));
        }

        internal_set_tile(
            x as i32 - 1,
            y as i32 - 1,
            z as i32 - 1,
            conversion::byond_to_option_f32(data[0])?,
            conversion::byond_to_option_f32(data[1])?,
            conversion::byond_to_option_f32(data[2])?,
            conversion::byond_to_option_f32(data[3])?,
            conversion::byond_to_option_f32(data[4])?,
            conversion::byond_to_option_f32(data[5])?,
            conversion::bounded_byond_to_option_f32(data[6], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[7], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[8], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[9], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[10], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[11], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[12], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[13], 0.0, f32::INFINITY)?,
            conversion::bounded_byond_to_option_f32(data[14], 0.0, f32::INFINITY)?,
            None,
            Some(0.0),
            Some(0.0),
            Some(0.0),
        )?;

        internal_reset_superconductivity(x as i32 - 1, y as i32 - 1, z as i32 - 1)?;
        internal_reduce_superconductivity(
            x as i32 - 1,
            y as i32 - 1,
            z as i32 - 1,
            conversion::bounded_byond_to_option_f32(data[15], 0.0, 1.0)?,
            conversion::bounded_byond_to_option_f32(data[16], 0.0, 1.0)?,
            conversion::bounded_byond_to_option_f32(data[17], 0.0, 1.0)?,
            conversion::bounded_byond_to_option_f32(data[18], 0.0, 1.0)?,
        )?;
    }
    Ok(ByondValue::null())
}

/// BYOND API for setting the atmos details of a tile.
#[byondapi::bind]
fn milla_set_tile(
    turf: ByondValue,
    airtight_north: ByondValue,
    airtight_east: ByondValue,
    airtight_south: ByondValue,
    airtight_west: ByondValue,
    atmos_mode: ByondValue,
    environment: ByondValue,
    oxygen: ByondValue,
    carbon_dioxide: ByondValue,
    nitrogen: ByondValue,
    toxins: ByondValue,
    sleeping_agent: ByondValue,
    agent_b: ByondValue,
    hydrogen: ByondValue,
    water_vapor: ByondValue,
    temperature: ByondValue,
    _innate_heat_capacity: ByondValue,
    hotspot_temperature: ByondValue,
    hotspot_volume: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    internal_set_tile(
        x as i32 - 1,
        y as i32 - 1,
        z as i32 - 1,
        conversion::byond_to_option_f32(airtight_north)?,
        conversion::byond_to_option_f32(airtight_east)?,
        conversion::byond_to_option_f32(airtight_south)?,
        conversion::byond_to_option_f32(airtight_west)?,
        conversion::byond_to_option_f32(atmos_mode)?,
        conversion::byond_to_option_f32(environment)?,
        conversion::bounded_byond_to_option_f32(oxygen, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(carbon_dioxide, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(nitrogen, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(toxins, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(sleeping_agent, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(agent_b, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(hydrogen, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(water_vapor, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(temperature, 0.0, f32::INFINITY)?,
        None,
        // Temporarily disabled to better match the existing system.
        //bounded_byond_to_option_f32(innate_heat_capacity, 0.0, f32::INFINITY)?,
        Some(0.0),
        conversion::bounded_byond_to_option_f32(hotspot_temperature, 0.0, f32::INFINITY)?,
        conversion::bounded_byond_to_option_f32(hotspot_volume, 0.0, 1.0)?,
    )?;
    Ok(ByondValue::null())
}

/// BYOND API for setting the directions a tile is airtight in.
/// Like set_tile, just with a smaller set of fields.
#[byondapi::bind]
fn milla_set_tile_airtight(
    turf: ByondValue,
    airtight_north: ByondValue,
    airtight_east: ByondValue,
    airtight_south: ByondValue,
    airtight_west: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    internal_set_tile(
        x as i32 - 1,
        y as i32 - 1,
        z as i32 - 1,
        conversion::byond_to_option_f32(airtight_north)?,
        conversion::byond_to_option_f32(airtight_east)?,
        conversion::byond_to_option_f32(airtight_south)?,
        conversion::byond_to_option_f32(airtight_west)?,
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
        None,
        None,
        None,
        None,
    )?;
    Ok(ByondValue::null())
}

/// Rust version of setting the atmos details of a tile.
#[allow(clippy::too_many_arguments)]
pub(crate) fn internal_set_tile(
    x: i32,
    y: i32,
    z: i32,
    airtight_north: Option<f32>,
    airtight_east: Option<f32>,
    airtight_south: Option<f32>,
    airtight_west: Option<f32>,
    atmos_mode: Option<f32>,
    environment: Option<f32>,
    oxygen: Option<f32>,
    carbon_dioxide: Option<f32>,
    nitrogen: Option<f32>,
    toxins: Option<f32>,
    sleeping_agent: Option<f32>,
    agent_b: Option<f32>,
    hydrogen: Option<f32>,
    water_vapor: Option<f32>,
    temperature: Option<f32>,
    thermal_energy: Option<f32>,
    innate_heat_capacity: Option<f32>,
    hotspot_temperature: Option<f32>,
    hotspot_volume: Option<f32>,
) -> Result<()> {
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    let tile = z_level.get_tile_mut_for_write(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?);
    if let Some(value) = airtight_north {
        tile.airtight_directions
            .set(AirtightDirections::NORTH, value > 0.0);
    }
    if let Some(value) = airtight_east {
        tile.airtight_directions
            .set(AirtightDirections::EAST, value > 0.0);
    }
    if let Some(value) = airtight_south {
        tile.airtight_directions
            .set(AirtightDirections::SOUTH, value > 0.0);
    }
    if let Some(value) = airtight_west {
        tile.airtight_directions
            .set(AirtightDirections::WEST, value > 0.0);
    }
    if let Some(value) = atmos_mode {
        match value as i32 {
            0 => tile.mode = AtmosMode::Space,
            1 => tile.mode = AtmosMode::Sealed,
            2 => {
                if let Some(env) = environment {
                    tile.mode = AtmosMode::ExposedTo {
                        environment_id: env as u8,
                    };
                }
            }
            3 => tile.mode = AtmosMode::NoDecay,
            _ => return Err(eyre!("Invalid atmos_mode: {}", value)),
        }
    }
    if let Some(value) = oxygen {
        tile.gases.set_oxygen(value);
    }
    if let Some(value) = carbon_dioxide {
        tile.gases.set_carbon_dioxide(value);
    }
    if let Some(value) = nitrogen {
        tile.gases.set_nitrogen(value);
    }
    if let Some(value) = toxins {
        tile.gases.set_toxins(value);
    }
    if let Some(value) = sleeping_agent {
        tile.gases.set_sleeping_agent(value);
    }
    if let Some(value) = agent_b {
        tile.gases.set_agent_b(value);
    }
    if let Some(value) = hydrogen {
        tile.gases.set_hydrogen(value);
    }
    if let Some(value) = water_vapor {
        tile.gases.set_water_vapor(value);
    }
    // Done sooner because we need innate heat capacity to calculate thermal energy from
    // temperature.
    if let Some(value) = innate_heat_capacity {
        tile.innate_heat_capacity = value;
    }
    if let Some(value) = temperature {
        tile.thermal_energy = value * tile.heat_capacity();
    }
    if let Some(value) = thermal_energy {
        tile.thermal_energy = value;
    }
    if let Some(value) = hotspot_temperature {
        tile.hotspot_temperature = value;
    }
    if let Some(value) = hotspot_volume {
        tile.hotspot_volume = value;
    }

    Ok(())
}

/// BYOND API for fetching the atmos details of a tile.
#[byondapi::bind]
fn milla_get_tile(turf: ByondValue, list: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let vec: Vec<ByondValue>;
    let mut watched = false;
    if let Ok((tile, settled)) =
        internal_get_tile_and_state(x as i32 - 1, y as i32 - 1, z as i32 - 1)
    {
        vec = (&tile).into();
        // A tile that changed last tick is likely to change again, and telling BYOND every time
        // would cost more than BYOND reading it again when it wants it.
        if settled {
            remember_tile(x as i32 - 1, y as i32 - 1, z as i32 - 1);
            watched = true;
        }
    } else {
        // MILLA has died and is unrecoverable.
        // Uh... uh... report everything as breathable air, I guess?
        let mut air = Tile::new();
        air.gases.set_oxygen(20.0);
        air.gases.set_nitrogen(80.0);
        air.thermal_energy = air.heat_capacity() * T20C;
        vec = (&air).into();
    }
    list.write_list(vec.as_slice())?;
    // Tells BYOND whether it'll hear about it when this tile changes.
    Ok(ByondValue::from(if watched { 1.0 } else { 0.0 }))
}

/// Fetches a tile, and whether it came through the last tick and since without BYOND being able
/// to tell it changed.
pub(crate) fn internal_get_tile_and_state(x: i32, y: i32, z: i32) -> Result<(Tile, bool)> {
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let maybe_active = buffers.get_active().read();
    if maybe_active.is_err() {
        return Err(eyre!("MILLA buffers have been poisoned."));
    }
    let active = maybe_active.unwrap();
    let z_level = active.0[z as usize].read().unwrap();
    let index = ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?;
    let settled = !z_level.changed_for_byond.contains(index) && !z_level.written.contains(index);
    Ok((z_level.get_tile(index).clone(), settled))
}

/// Rust version of fetching the atmos details of a tile.
#[cfg(test)]
pub(crate) fn internal_get_tile(x: i32, y: i32, z: i32) -> Result<Tile> {
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let maybe_active = buffers.get_active().read();
    if maybe_active.is_err() {
        return Err(eyre!("MILLA buffers have been poisoned."));
    }
    let active = maybe_active.unwrap();
    let z_level = active.0[z as usize].read().unwrap();
    Ok(z_level
        .get_tile(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
            "Bad coordinates ({}, {}, {})",
            x + 1,
            y + 1,
            z + 1
        ))?)
        .clone())
}

/// BYOND API for putting a scrubber on a turf, or changing what one does. Pass 0 for a new one,
/// or the id of the one to change. `starts_for` and `takes` have a bit for each gas, in MILLA's
/// order: the scrubber only does anything while there's more than a trace of a gas in
/// `starts_for`, and then takes `share` of each gas in `takes` every tick.
/// Returns the scrubber's id.
#[byondapi::bind]
fn milla_set_scrubber(
    id: ByondValue,
    turf: ByondValue,
    starts_for: ByondValue,
    takes: ByondValue,
    share: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let id = internal_set_scrubber(
        f32::try_from(id)? as u32,
        x as i32 - 1,
        y as i32 - 1,
        z as i32 - 1,
        f32::try_from(starts_for)? as u8,
        f32::try_from(takes)? as u8,
        f32::try_from(share)?,
    )?;
    Ok(ByondValue::from(id as f32))
}

/// Rust version of setting up a scrubber. Coordinates count from zero.
pub(crate) fn internal_set_scrubber(
    id: u32,
    x: i32,
    y: i32,
    z: i32,
    starts_for: u8,
    takes: u8,
    share: f32,
) -> Result<u32> {
    check_writable()?;
    let tile = ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?;
    if z < 0 || z >= MAX_Z_LEVELS {
        return Err(eyre!("Bad Z level {}", z + 1));
    }
    // One that's being changed keeps whatever it's taken.
    let mut taken = [0.0; GAS_COUNT];
    let mut taken_thermal_energy = 0.0;
    let mut id = id;
    if id == 0 {
        id = LAST_SCRUBBER_ID.fetch_add(1, std::sync::atomic::Ordering::Relaxed) as u32 + 1;
    } else if let Some(old) = take_scrubber(id) {
        taken = old.taken;
        taken_thermal_energy = old.taken_thermal_energy;
    }
    {
        let mut scrubbers = SCRUBBERS[z as usize].lock().unwrap();
        let position = scrubbers.partition_point(|other| other.tile <= tile);
        scrubbers.insert(
            position,
            Scrubber {
                id,
                tile,
                starts_for,
                takes,
                share,
                taken,
                taken_thermal_energy,
            },
        );
    }
    // There might be something on the tile for it already, so the next tick has to look.
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    if let Some(level) = active.0.get(z as usize) {
        if let Ok(mut z_level) = level.try_write() {
            z_level.get_tile_mut_for_write(tile);
        }
    }
    Ok(id)
}

/// Takes a scrubber out of whichever level's list it's in, if no tick has hold of that list.
fn take_scrubber(id: u32) -> Option<Scrubber> {
    for level in SCRUBBERS.iter() {
        if let Ok(mut scrubbers) = level.try_lock() {
            if let Some(position) = scrubbers.iter().position(|scrubber| scrubber.id == id) {
                return Some(scrubbers.remove(position));
            }
        }
    }
    None
}

/// BYOND API for taking a scrubber away. Whatever it took and BYOND hasn't collected is lost
/// with it. This can be called at any time: if a tick is running, the scrubber goes when BYOND
/// next collects.
#[byondapi::bind]
fn milla_remove_scrubber(id: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let id = f32::try_from(id)? as u32;
    if TICK_UNFINISHED.load(std::sync::atomic::Ordering::Relaxed) || take_scrubber(id).is_none() {
        SCRUBBERS_TO_REMOVE.lock().unwrap().push(id);
    }
    Ok(ByondValue::null())
}

/// BYOND API for collecting what the scrubbers have taken off their tiles. Returns one list with
/// ten values for each scrubber that took anything: its id, the moles of each gas in MILLA's
/// order, and the thermal energy that gas had. Collecting empties them.
#[byondapi::bind]
fn milla_collect_scrubbed() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let mut values: Vec<ByondValue> = Vec::new();
    if TICK_UNFINISHED.load(std::sync::atomic::Ordering::Relaxed) {
        // The tick's still using them. Next time.
        return Ok(values.as_slice().try_into()?);
    }
    {
        let mut to_remove = SCRUBBERS_TO_REMOVE.lock().unwrap();
        to_remove.retain(|id| take_scrubber(*id).is_none() && scrubber_exists(*id));
    }
    for level in SCRUBBERS.iter() {
        let mut scrubbers = match level.try_lock() {
            Ok(scrubbers) => scrubbers,
            Err(_) => continue,
        };
        for scrubber in scrubbers.iter_mut() {
            if scrubber.taken.iter().all(|amount| *amount == 0.0) {
                continue;
            }
            values.push(ByondValue::from(scrubber.id as f32));
            for gas in 0..GAS_COUNT {
                values.push(ByondValue::from(scrubber.taken[gas]));
            }
            values.push(ByondValue::from(scrubber.taken_thermal_energy));
            scrubber.taken = [0.0; GAS_COUNT];
            scrubber.taken_thermal_energy = 0.0;
        }
    }
    Ok(values.as_slice().try_into()?)
}

/// Is there still a scrubber with this id? One that couldn't be looked at counts as there.
fn scrubber_exists(id: u32) -> bool {
    for level in SCRUBBERS.iter() {
        match level.try_lock() {
            Ok(scrubbers) => {
                if scrubbers.iter().any(|scrubber| scrubber.id == id) {
                    return true;
                }
            }
            Err(_) => return true,
        }
    }
    false
}

/// A tick that's been started has to become the current frame before anything gets written, or
/// the write would land on the frame that's about to be replaced.
fn check_writable() -> Result<()> {
    if TICK_UNFINISHED.load(std::sync::atomic::Ordering::Relaxed) {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    Ok(())
}

/// Notes that BYOND now holds a copy of this tile, so it wants to hear when the tile changes.
pub(crate) fn remember_tile(x: i32, y: i32, z: i32) {
    if let Some(index) = ZLevel::maybe_get_index(x, y) {
        let mut remembered = REMEMBERED_TILES.lock().unwrap();
        while remembered.len() <= z as usize {
            remembered.push(TileSet::new());
        }
        remembered[z as usize].insert(index);
    }
}

/// BYOND API for getting the turfs whose air has changed since it last asked, out of the ones
/// it's holding a copy of. Once a turf has been handed over here, BYOND isn't told about it
/// again until it reads the tile again.
#[byondapi::bind]
fn milla_get_changed_tiles() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    // If BYOND's the one finishing ticks, this is where it happens: the new frame becomes current
    // and BYOND hears what changed in the same breath.
    if let Some(buffers) = BUFFERS.get() {
        tick::finish_tick(buffers);
    }
    let mut turfs: Vec<ByondValue> = Vec::new();
    for (x, y, z) in internal_get_changed_tiles() {
        turfs.push(byond_locatexyz(ByondXYZ::with_coords((
            x as i16 + 1,
            y as i16 + 1,
            z as i16 + 1,
        )))?);
    }
    Ok(turfs.as_slice().try_into()?)
}

/// Rust version of getting the tiles that changed. Coordinates count from zero.
pub(crate) fn internal_get_changed_tiles() -> Vec<(i32, i32, i32)> {
    let mut changed_tiles = CHANGED_TILES.lock().unwrap();
    let mut remembered = REMEMBERED_TILES.lock().unwrap();
    let mut tiles = Vec::new();
    for z in 0..changed_tiles.len() {
        if z < remembered.len() {
            let mut cursor = 0;
            while let Some(index) = changed_tiles[z].next_from(cursor) {
                cursor = index + 1;
                if remembered[z].remove(index) {
                    tiles.push((
                        (index / MAP_SIZE) as i32,
                        (index % MAP_SIZE) as i32,
                        z as i32,
                    ));
                }
            }
        }
        changed_tiles[z].clear();
    }
    tiles
}

/// BYOND API for hearing when a tile's pressure goes under pressure_below. A second tripwire on a
/// tile joins the first. BYOND hears about it from milla_get_tripped_tiles() when the frame that
/// set it off comes in. Returns 0 if it can't be set.
#[byondapi::bind]
fn milla_set_tile_tripwire(
    turf: ByondValue,
    pressure_below: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    // BYOND only hears in time if it's the one finishing ticks.
    if !BYOND_FINISHES_TICKS.load(std::sync::atomic::Ordering::Relaxed) {
        return Ok(ByondValue::from(0.0));
    }
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let Some(index) = ZLevel::maybe_get_index(x as i32 - 1, y as i32 - 1) else {
        return Ok(ByondValue::from(0.0));
    };
    let wire = Tripwire {
        pressure_below: f32::try_from(pressure_below)?,
    };
    let z = z as usize - 1;
    let mut tripwires = TRIPWIRES.lock().unwrap();
    while tripwires.len() <= z {
        tripwires.push(std::collections::HashMap::new());
    }
    tripwires[z]
        .entry(index)
        .and_modify(|old| old.join(&wire))
        .or_insert(wire);
    Ok(ByondValue::from(1.0))
}

/// BYOND API for the turfs whose tripwires went off in the frame that just came in.
#[byondapi::bind]
fn milla_get_tripped_tiles() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let mut turfs: Vec<ByondValue> = Vec::new();
    for (x, y, z) in TRIPPED_TILES.lock().unwrap().drain(..) {
        turfs.push(byond_locatexyz(ByondXYZ::with_coords((
            x as i16 + 1,
            y as i16 + 1,
            z as i16 + 1,
        )))?);
    }
    Ok(turfs.as_slice().try_into()?)
}

/// BYOND API for saying whether BYOND makes a finished tick the current frame itself, by calling
/// milla_get_changed_tiles() when it's told the tick is done. That way nothing can read the new
/// frame before BYOND knows what changed in it.
#[byondapi::bind]
fn milla_set_byond_finishes_ticks(enabled: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    BYOND_FINISHES_TICKS.store(
        f32::try_from(enabled)? > 0.0,
        std::sync::atomic::Ordering::Relaxed,
    );
    Ok(ByondValue::null())
}

/// BYOND API for getting a list of interesting tiles this tick.
/// There are three kinds:
/// * Turfs that are hot eough to cause fires.
/// * Turfs that just passed the threshold for showing plasma or sleeping gas.
/// * Turfs with strong airflow out.
#[byondapi::bind]
fn milla_get_interesting_tiles() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let interesting_tiles = INTERESTING_TILES.lock().unwrap();
    let byond_interesting_tiles = interesting_tiles
        .iter()
        .flat_map(|v| Vec::from(v))
        .collect::<Vec<ByondValue>>();
    Ok(byond_interesting_tiles.as_slice().try_into()?)
}

/// BYOND API for getting a single random interesting tile.
#[byondapi::bind]
fn milla_get_random_interesting_tile() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let interesting_tiles = INTERESTING_TILES.lock().unwrap();
    let length = interesting_tiles.len() as f32;
    if length <= 0.0 {
        return Err(eyre!("No interesting tiles."));
    }
    let random: f32 = rand::random();
    let chosen = (random * length) as usize;
    Ok(Vec::from(&interesting_tiles[chosen])
        .as_slice()
        .try_into()?)
}

/// BYOND API for capping the superconductivity of a tile.
#[byondapi::bind]
fn milla_reduce_superconductivity(
    turf: ByondValue,
    north: ByondValue,
    east: ByondValue,
    south: ByondValue,
    west: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let rust_north = conversion::bounded_byond_to_option_f32(north, 0.0, 1.0)?;
    let rust_east = conversion::bounded_byond_to_option_f32(east, 0.0, 1.0)?;
    let rust_south = conversion::bounded_byond_to_option_f32(south, 0.0, 1.0)?;
    let rust_west = conversion::bounded_byond_to_option_f32(west, 0.0, 1.0)?;
    internal_reduce_superconductivity(
        x as i32 - 1,
        y as i32 - 1,
        z as i32 - 1,
        rust_north,
        rust_east,
        rust_south,
        rust_west,
    )?;
    Ok(ByondValue::null())
}

/// Rust version of capping the superconductivity of a tile.
/// We never increase superconductivity, only reduce it, because it represents how much heat flow has
/// been restricted by the tiles and objects on them.
pub(crate) fn internal_reduce_superconductivity(
    x: i32,
    y: i32,
    z: i32,
    north: Option<f32>,
    east: Option<f32>,
    south: Option<f32>,
    west: Option<f32>,
) -> eyre::Result<()> {
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    let tile = z_level.get_tile_mut_for_write(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?);
    if let Some(value) = north {
        tile.superconductivity.north = tile.superconductivity.north.min(value);
    }
    if let Some(value) = east {
        tile.superconductivity.east = tile.superconductivity.east.min(value);
    }
    if let Some(value) = south {
        tile.superconductivity.south = tile.superconductivity.south.min(value);
    }
    if let Some(value) = west {
        tile.superconductivity.west = tile.superconductivity.west.min(value);
    }
    Ok(())
}

/// BYOND API for resetting the superconductivity of a tile.
#[byondapi::bind]
fn milla_reset_superconductivity(turf: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    internal_reset_superconductivity(x as i32 - 1, y as i32 - 1, z as i32 - 1)?;
    Ok(ByondValue::null())
}

/// Rust version of resetting the superconductivity of a tile.
pub(crate) fn internal_reset_superconductivity(x: i32, y: i32, z: i32) -> Result<()> {
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    let tile = z_level.get_tile_mut_for_write(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?);
    tile.superconductivity.north = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile.superconductivity.east = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile.superconductivity.south = OPEN_HEAT_TRANSFER_COEFFICIENT;
    tile.superconductivity.west = OPEN_HEAT_TRANSFER_COEFFICIENT;
    Ok(())
}

/// BYOND API for a heat source creating a hotspot on a tile.
#[byondapi::bind]
fn milla_create_hotspot(
    turf: ByondValue,
    temperature: ByondValue,
    volume: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let rust_temperature =
        conversion::bounded_byond_to_option_f32(temperature, 0.0, f32::INFINITY)?
            .ok_or(eyre!("Hotspot temperature is required.."))?;
    let rust_volume = conversion::bounded_byond_to_option_f32(volume, 0.0, TILE_VOLUME)?
        .ok_or(eyre!("Hotspot volume is required.."))?;

    internal_create_hotspot(
        x as i32 - 1,
        y as i32 - 1,
        z as i32 - 1,
        rust_temperature,
        rust_volume / TILE_VOLUME,
    )?;
    Ok(ByondValue::null())
}

/// Rust version of a heat source creating a hotspot.
pub(crate) fn internal_create_hotspot(
    x: i32,
    y: i32,
    z: i32,
    temperature: f32,
    volume: f32,
) -> Result<()> {
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    let tile = z_level.get_tile_mut_for_write(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?);

    if temperature <= tile.temperature() || volume == 0.0 {
        return Ok(());
    }

    if tile.hotspot_volume == 0.0 {
        tile.hotspot_temperature = temperature;
        tile.hotspot_volume = volume;
        return Ok(());
    }

    let excess_thermal_energy = (temperature - tile.temperature()) * tile.heat_capacity() * volume;
    if excess_thermal_energy > 0.0 {
        simulate::adjust_hotspot(tile, excess_thermal_energy);
    }

    Ok(())
}

/// BYOND API for a heat source creating a hotspot on a tile.
#[byondapi::bind]
fn milla_extinguish_hotspot(turf: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();

    internal_extinguish_hotspot(x as i32 - 1, y as i32 - 1, z as i32 - 1)?;
    Ok(ByondValue::null())
}

/// Rust version of a heat source creating a hotspot.
pub(crate) fn internal_extinguish_hotspot(x: i32, y: i32, z: i32) -> Result<()> {
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to write during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    let tile = z_level.get_tile_mut_for_write(ZLevel::maybe_get_index(x, y).ok_or(eyre!(
        "Bad coordinates ({}, {}, {})",
        x + 1,
        y + 1,
        z + 1
    ))?);

    tile.hotspot_temperature = 0.0;
    tile.hotspot_volume = 0.0;
    Ok(())
}

/// BYOND API for tracking the pressure of all nearby tiles next tick.
#[byondapi::bind]
fn milla_track_pressure_tiles(
    turf: ByondValue,
    byond_radius: ByondValue,
) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let (x, y, z) = byond_xyz(&turf)?.coordinates();
    let radius = conversion::bounded_byond_to_option_f32(byond_radius, 0.0, MAP_SIZE as f32)?
        .ok_or(eyre!("Invalid radius: {:#?}", byond_radius))? as i32;

    internal_track_pressure_tiles(x as i32 - 1, y as i32 - 1, z as i32 - 1, radius)?;
    Ok(ByondValue::null())
}

/// Rust version of tracking the pressure of all nearby tiles next tick.
fn internal_track_pressure_tiles(x: i32, y: i32, z: i32, radius: i32) -> eyre::Result<()> {
    let mut tracked_pressure_tiles = TRACKED_PRESSURE_TILES.lock().unwrap();
    for dx in -radius..=radius {
        if x + dx < 0 {
            continue;
        }
        if x + dx >= MAP_SIZE as i32 {
            break;
        }
        for dy in -radius..=radius {
            if y + dy < 0 {
                continue;
            }
            if y + dy >= MAP_SIZE as i32 {
                break;
            }
            tracked_pressure_tiles.push((x + dx, y + dy, z as usize));
        }
    }

    Ok(())
}

/// BYOND API for getting the tracked pressure tiles.
#[byondapi::bind]
fn milla_get_tracked_pressure_tiles() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    let tracked_pressures = internal_get_tracked_pressure_tiles()?
        .iter()
        .map(|v: &f32| ByondValue::from(*v))
        .collect::<Vec<ByondValue>>();
    Ok(tracked_pressures.as_slice().try_into()?)
}

/// Rust version of getting the tracked pressure tiles.
fn internal_get_tracked_pressure_tiles() -> eyre::Result<Vec<f32>> {
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let inactive = buffers.get_inactive().read().unwrap();
    let mut tracked_pressure_tiles = TRACKED_PRESSURE_TILES.lock().unwrap();

    let mut tiles_by_zlevel: Vec<Vec<(i32, i32)>> = Vec::new();
    for _z in 0..inactive.0.len() {
        tiles_by_zlevel.push(Vec::new());
    }

    for (x, y, z) in tracked_pressure_tiles.drain(..) {
        if z < tiles_by_zlevel.len() {
            tiles_by_zlevel[z].push((x, y));
        }
    }

    // This is a bit gross, but the easiest way to return the coordinates and data is to cast the
    // coordinates to f32. It feels bad in Rust, but everything is an f32 in BYOND, so it's more or
    // less a no-op.
    let mut tracked_pressures: Vec<f32> = Vec::new();
    for z in 0..tiles_by_zlevel.len() {
        let z_level = inactive.0[z as usize].read().unwrap();
        for (x, y) in &tiles_by_zlevel[z] {
            if let Some(index) = ZLevel::maybe_get_index(*x, *y) {
                tracked_pressures.push(*x as f32 + 1.0);
                tracked_pressures.push(*y as f32 + 1.0);
                tracked_pressures.push(z as f32 + 1.0);
                tracked_pressures.push(z_level.get_tile(index).pressure());
            }
        }
    }

    Ok(tracked_pressures)
}

/// BYOND API for starting an atmos tick.
#[byondapi::bind]
fn milla_spawn_tick_thread() -> eyre::Result<ByondValue> {
    // Looked up here, on BYOND's own thread, where it costs nothing. Looked up from the tick thread
    // it's one more wait for BYOND's thread on top of the call itself.
    let tick_finished = str_id_of("milla_tick_finished")?;
    // A tick BYOND never got around to finishing gets finished now, before the next one builds on it.
    tick::finish_tick(BUFFERS.get_or_init(Buffers::new));
    TICK_UNFINISHED.store(true, std::sync::atomic::Ordering::Relaxed);
    thread::spawn(move || -> Result<(), eyre::Error> {
        let now = Instant::now();
        let buffers = BUFFERS.get_or_init(Buffers::new);
        let result = tick::tick(buffers);
        TICK_TIME.store(
            now.elapsed().as_millis() as usize,
            std::sync::atomic::Ordering::Relaxed,
        );
        if result.is_ok() {
            call_global_id(tick_finished, &[])?;
        } else {
            TICK_UNFINISHED.store(false, std::sync::atomic::Ordering::Relaxed);
            let err = format!("MILLA tick error:\n----\n{:#?}\n----", result);
            call_global("milla_tick_error", &[ByondValue::new_str(err)?])?;
        }

        Ok(())
    });
    Ok(ByondValue::null())
}

/// BYOND API for asking how long the prior tick took.
#[byondapi::bind]
fn milla_get_tick_time() -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    Ok(ByondValue::from(
        TICK_TIME.load(std::sync::atomic::Ordering::Relaxed) as f32,
    ))
}

/// BYOND API for freezing a specific z-level.
#[byondapi::bind]
fn milla_set_zlevel_frozen(
    byond_z: ByondValue,
    byond_frozen: ByondValue,
) -> eyre::Result<ByondValue> {
    let z = f32::try_from(byond_z)? as i32 - 1;
    let frozen = bool::try_from(byond_frozen)?;
    check_writable()?;
    let buffers = BUFFERS.get().ok_or(eyre!("BUFFERS not initialized."))?;
    let active = buffers.get_active().read().unwrap();
    let maybe_z_level = active.0[z as usize].try_write();
    if maybe_z_level.is_err() {
        return Err(eyre!(
            "Tried to freeze or unfreeze during asynchronous, read-only atmos. Use a /datum/milla_safe/..."
        ));
    }
    let mut z_level = maybe_z_level.unwrap();
    z_level.frozen = frozen;
    Ok(ByondValue::null())
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;

    // The data set by internal_set_tile() should be retrieved by internal_get_tile().
    #[test]
    fn set_get_loop() {
        let test_z = 0;
        internal_initialize(test_z).unwrap();

        // Set some arbitrary data.
        internal_set_tile(
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
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
        )
        .unwrap();

        // Check that we got the same data back.
        {
            let tile = internal_get_tile(1, 2, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(tile.gases.values[gas], 0.0, "{}", gas);
                } else {
                    assert_eq!(tile.gases.values[gas], 1.0, "{}", gas);
                }
            }
            assert_eq!(tile.thermal_energy, 0.0);
            assert_eq!(tile.innate_heat_capacity, 1.0);
            assert_eq!(tile.hotspot_temperature, 0.0);
            assert_eq!(tile.hotspot_volume, 1.0);
        }

        // Set a different set of arbitrary data.
        internal_set_tile(
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
            None,
            None,
            Some(1.0),
            None,
            Some(1.0),
            None,
        )
        .unwrap();

        // Check that we got the same data back.
        {
            let tile = internal_get_tile(1, 1, test_z).unwrap();
            for gas in 0..GAS_COUNT {
                if gas % 2 == 0 {
                    assert_eq!(tile.gases.values[gas], 1.0, "{}", gas);
                } else {
                    assert_eq!(tile.gases.values[gas], 0.0, "{}", gas);
                }
            }
            assert_eq!(tile.thermal_energy, 1.0);
            assert_eq!(tile.innate_heat_capacity, 0.0);
            assert_eq!(tile.hotspot_temperature, 1.0);
            assert_eq!(tile.hotspot_volume, 0.0);
        }
    }
}
