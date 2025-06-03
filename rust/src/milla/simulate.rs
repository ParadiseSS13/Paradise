use crate::milla::constants::*;
use crate::milla::model::*;
use byondapi::map::ByondXYZ;
use eyre::eyre;
use scc::Bag;
use std::collections::HashSet;

pub(crate) fn find_walls(next: &mut ZLevel) {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;

        for (axis, (dx, dy)) in AXES.iter().enumerate() {
            let their_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => {
                    // Edge of the map, acts like a wall.
                    let my_tile = next.get_tile_mut(my_index);
                    my_tile.wall[axis] = true;
                    continue;
                }
            };

            let (my_tile, their_tile) = next.get_pair_mut(my_index, their_index);
            if *dx > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::EAST)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::WEST))
            {
                // Something's blocking airflow.
                my_tile.wall[axis] = true;
                continue;
            } else if *dy > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::NORTH)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::SOUTH))
            {
                // Something's blocking airflow.
                my_tile.wall[axis] = true;
                continue;
            }
            my_tile.wall[axis] = false;
        }
    }
}

/// Calculate the new wind at each boundary.
pub(crate) fn update_wind(prev: &ZLevel, next: &mut ZLevel) {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;
        let my_tile = prev.get_tile(my_index);

        for (axis, (dx, dy)) in AXES.iter().enumerate() {
            let neighbor_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => continue,
            };
            let neighbor = prev.get_tile(neighbor_index);
            let my_new_tile = next.get_tile_mut(my_index);

            // No wind across walls.
            if my_new_tile.wall[axis] {
                my_new_tile.wind[axis] = 0.0;
                for i in 0..GAS_COUNT {
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_IN] = 0.0;
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT] = 0.0;
                }
                continue;
            }

            // If there's no air, there's no wind.
            if my_tile.pressure() + neighbor.pressure() <= 0.0 {
                my_new_tile.wind[axis] = 0.0;
                for i in 0..GAS_COUNT {
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_IN] = 0.0;
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT] = 0.0;
                }
                continue;
            }

            // How much pressure do these tiles have together?
            let combined_pressure = my_tile.pressure() + neighbor.pressure();

            // A bias from [-1.0, 1.0] representing how much air is flowing from the negative tile
            // to the positive one, based purely on pressure.
            let pressure_bias = 2.0 * (my_tile.pressure() / combined_pressure) - 1.0;

            // New wind mixes the pressure bias with the old wind, and clamps it to reasonable
            // bounds.
            my_new_tile.wind[axis] = (my_tile.wind[axis]
                + WIND_ACCELERATION * (pressure_bias * WIND_STRENGTH - my_tile.wind[axis]))
                .clamp(-MAX_WIND, MAX_WIND);

            for i in 0..GAS_COUNT {
                my_new_tile.gas_flow[axis][i][GAS_FLOW_IN] = 0.0;
                my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT] = 0.0;

                // Calculate how much gas should flow based on pressure.
                let combined_partial_pressure =
                    my_tile.partial_pressure(i) + neighbor.partial_pressure(i);
                if combined_partial_pressure <= 0.0 {
                    // Gas? What gas?
                    continue;
                }
                let wind_gas_flow = (1.0 + WIND_SPEED).powf(my_new_tile.wind[axis].abs()) - 1.0;
                if my_new_tile.wind[axis] > 0.0 {
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT] += wind_gas_flow;
                } else {
                    my_new_tile.gas_flow[axis][i][GAS_FLOW_IN] += wind_gas_flow;
                }

                // And how much gas should flow based on diffusion.
                let diffusion_gas_flow = DIFFUSION_SPEED;
                my_new_tile.gas_flow[axis][i][GAS_FLOW_IN] += diffusion_gas_flow;
                my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT] += diffusion_gas_flow;
            }
        }
    }
}

pub(crate) struct AirflowOutcome {
    active_tiles: HashSet<usize>,
    max_gas_delta: f32,
    max_thermal_energy_delta: f32,
}

/// Let the air flow until it stabilizes for this tick or we run out of patience.
pub(crate) fn flow_air(prev: &ZLevel, next: &mut ZLevel) -> Result<AirflowOutcome, eyre::Error> {
    let mut outcome = flow_air_once(prev, next, None)?;
    for _iter in 1..MAX_ITERATIONS {
        outcome = flow_air_once(prev, next, Some(outcome))?;

        // Check for significant changes.
        if outcome.max_gas_delta < GAS_CHANGE_SIGNIFICANCE
            && outcome.max_thermal_energy_delta < THERMAL_CHANGE_SIGNIFICANCE
        {
            // We've stabilized.
            return Ok(outcome);
        }
    }

    Ok(outcome)
}

/// Let the air flow at every active tile by one step.
pub(crate) fn flow_air_once(
    prev: &ZLevel,
    next: &mut ZLevel,
    maybe_old_outcome: Option<AirflowOutcome>,
) -> Result<AirflowOutcome, eyre::Error> {
    let mut new_outcome = AirflowOutcome {
        active_tiles: HashSet::new(),
        max_gas_delta: 0.0,
        max_thermal_energy_delta: 0.0,
    };

    if let Some(old_outcome) = maybe_old_outcome {
        for my_index in &old_outcome.active_tiles {
            flow_air_once_at_index(prev, next, *my_index, &mut new_outcome)?;
        }
    } else {
        for my_index in 0..MAP_SIZE * MAP_SIZE {
            flow_air_once_at_index(prev, next, my_index, &mut new_outcome)?;
        }
    }

    Ok(new_outcome)
}

pub(crate) fn flow_air_once_at_index(
    prev: &ZLevel,
    next: &mut ZLevel,
    my_index: usize,
    outcome: &mut AirflowOutcome,
) -> Result<(), eyre::Error> {
    let x = (my_index / MAP_SIZE) as i32;
    let y = (my_index % MAP_SIZE) as i32;
    let my_tile = prev.get_tile(my_index);

    // Skip tiles that can't change.
    match my_tile.mode {
        // Space is always empty.
        AtmosMode::Space => return Ok(()),
        // Tiles exposed to an environment always contain that environment.
        AtmosMode::ExposedTo { .. } => return Ok(()),
        _ => (),
    }

    // Save the values from the prior iteration so we can check how much they changed.
    let prev_iter = next.get_tile(my_index).clone();
    {
        // We're doing a modified Gauss-Seidel method, and while it's counter-intuitive, one of
        // the necessary steps is to reset the current tile to its original values before
        // processing this iteration.
        // See https://en.wikipedia.org/wiki/Gauss%E2%80%93Seidel_method#Element-based_formula
        let my_new_tile = next.get_tile_mut(my_index);
        my_new_tile.gases.copy_from(&my_tile.gases);
        my_new_tile.thermal_energy = my_tile.thermal_energy;
    }
    let mut outgoing_gas_mult: [f32; GAS_COUNT] = [0.0; GAS_COUNT];
    let mut total_weighted_temperature = my_tile.temperature() * my_tile.heat_capacity();
    let mut total_temperature_weights: f32 = my_tile.heat_capacity();
    for (dir, (dx, dy)) in DIRECTIONS.iter().enumerate() {
        let neighbor_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
            Some(value) => value,
            None => continue,
        };
        let (my_new_tile, new_neighbor) = next.get_pair_mut(my_index, neighbor_index);

        let axis = DIRECTION_AXIS[dir];

        // Don't do anything across walls.
        if dx + dy > 0 {
            if my_new_tile.wall[axis] {
                continue;
            }
        } else {
            if new_neighbor.wall[axis] {
                continue;
            }
        }

        // If there's no air, don't do anything.
        let total_pressure = my_tile.pressure() + new_neighbor.pressure();
        if total_pressure <= 0.0 {
            continue;
        }

        for i in 0..GAS_COUNT {
            // Normalise the gas flow direction.
            let gas_flow_in;
            let gas_flow_out;
            if dx + dy > 0 {
                gas_flow_in = my_new_tile.gas_flow[axis][i][GAS_FLOW_IN];
                gas_flow_out = my_new_tile.gas_flow[axis][i][GAS_FLOW_OUT];
            } else {
                gas_flow_in = new_neighbor.gas_flow[axis][i][GAS_FLOW_OUT];
                gas_flow_out = new_neighbor.gas_flow[axis][i][GAS_FLOW_IN];
            }

            // Once again, this may looks a bit odd, but it's the second step of Gauss-Seidel,
            // summing together this tile's value from the last iteration with the incoming values
            // from other tiles this tick.
            my_new_tile.gases.values[i] += gas_flow_in * new_neighbor.gases.values[i];
            let temperature_weight = gas_flow_in * new_neighbor.gases.values[i] * SPECIFIC_HEATS[i];

            // Track the outgoing values as well.
            outgoing_gas_mult[i] += gas_flow_out;

            // Temperature is not Gauss-Seidel, though it looks similar. It's just a weighted
            // average.
            total_weighted_temperature +=
                new_neighbor.temperature() * temperature_weight * TEMPERATURE_FLOW_RATE;
            total_temperature_weights += temperature_weight * TEMPERATURE_FLOW_RATE;
        }

        my_new_tile.gases.set_dirty();
    }

    // And now we finish off Gauss-Seidel by dividing by the total outgoing weights, plus one
    // to represent this tile.
    let mut max_gas_delta: f32 = 0.0;
    let my_new_tile = next.get_tile_mut(my_index);
    for i in 0..GAS_COUNT {
        my_new_tile.gases.values[i] /= 1.0 + outgoing_gas_mult[i];

        if (prev_iter.gases.values[i] - my_new_tile.gases.values[i]).abs()
            >= GAS_CHANGE_SIGNIFICANCE
        {
            let new_gas_delta = (2.0 * prev_iter.gases.values[i]
                / (prev_iter.gases.values[i] + my_new_tile.gases.values[i])
                - 1.0)
                .abs();
            max_gas_delta = max_gas_delta.max(new_gas_delta);
        }
    }
    my_new_tile.gases.set_dirty();

    my_new_tile.thermal_energy =
        my_new_tile.heat_capacity() * total_weighted_temperature / total_temperature_weights;

    let new_thermal_energy_delta;
    if (prev_iter.thermal_energy - my_new_tile.thermal_energy).abs() >= THERMAL_CHANGE_SIGNIFICANCE
    {
        new_thermal_energy_delta = (2.0 * prev_iter.thermal_energy
            / (prev_iter.thermal_energy + my_new_tile.thermal_energy)
            - 1.0)
            .abs();
    } else {
        new_thermal_energy_delta = 0.0
    }

    // outcome is the global version across all tiles.
    outcome.max_gas_delta = outcome.max_gas_delta.max(max_gas_delta);
    outcome.max_thermal_energy_delta = outcome
        .max_thermal_energy_delta
        .max(new_thermal_energy_delta);

    // Check for significant changes.
    if max_gas_delta < GAS_CHANGE_SIGNIFICANCE_FRACTION {
        if new_thermal_energy_delta < THERMAL_CHANGE_SIGNIFICANCE_FRACTION {
            return Ok(());
        }
    }

    // If any change was significant, mark this tile and all neighbors as active.
    outcome.active_tiles.insert(my_index);
    for (dx, dy) in DIRECTIONS {
        if let Some(neighbor_index) = ZLevel::maybe_get_index(x + dx, y + dy) {
            outcome.active_tiles.insert(neighbor_index);
        }
    }

    Ok(())
}

/// Applies effects that happen after the main airflow routine:
/// * Tile modes
/// * Superconductivity
/// * Reactions
/// * Hotspot cleanup
/// * Sanitization
/// * Looking for interesting tiles.
pub(crate) fn post_process(
    prev: &ZLevel,
    next: &mut ZLevel,
    environments: &Box<[Tile]>,
    new_interesting_tiles: &Bag<InterestingTile>,
    z: i32,
) -> Result<(), eyre::Error> {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;
        let my_tile = prev.get_tile(my_index);

        {
            let my_next_tile = next.get_tile_mut(my_index);
            apply_tile_mode(my_next_tile, environments)?;
        }

        if let AtmosMode::Space = my_tile.mode {
            // Space doesn't superconduct, has no reactions, doesn't need to be sanitized, and is never interesting. (Take that, astrophysicists and astronomers!)
            continue;
        }

        for (dx, dy) in AXES {
            let their_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => continue,
            };

            let (my_next_tile, their_next_tile) = next.get_pair_mut(my_index, their_index);

            if their_next_tile.mode != AtmosMode::Space {
                superconduct(my_next_tile, their_next_tile, dx > 0, false);
            }
        }

        {
            let my_next_tile = next.get_tile_mut(my_index);
            // New tick, reset the fuel tracker.
            my_next_tile.fuel_burnt = 0.0;

            react(my_next_tile, false);
            if my_next_tile.hotspot_volume > 0.0 {
                react(my_next_tile, true);
            }

            // Sanitize the tile, to avoid negative/NaN/infinity spread.
            sanitize(my_next_tile, my_tile);
        }

        check_interesting(x, y, z, next, my_tile, my_index, new_interesting_tiles)?;
    }
    Ok(())
}

pub(crate) fn sanitize(my_next_tile: &mut Tile, my_tile: &Tile) -> bool {
    let mut sanitized = false;
    for i in 0..GAS_COUNT {
        if !my_next_tile.gases.values[i].is_finite() {
            // Reset back to the last value, in the hopes that it's safe.
            my_next_tile.gases.values[i] = my_tile.gases.values[i];
            my_next_tile.gases.set_dirty();
            sanitized = true;
        } else if my_next_tile.gases.values[i] < 0.0 {
            // Zero out anything that becomes negative.
            my_next_tile.gases.values[i] = 0.0;
            my_next_tile.gases.set_dirty();
            sanitized = true;
        }
    }
    if !my_next_tile.thermal_energy.is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.thermal_energy = my_tile.thermal_energy;
        sanitized = true;
    } else if my_next_tile.thermal_energy < 0.0 {
        // Zero out anything that becomes negative.
        my_next_tile.thermal_energy = 0.0;
        sanitized = true;
    }
    if !my_next_tile.wind[0].is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.wind[0] = my_tile.wind[0];
        sanitized = true;
    }
    if !my_next_tile.wind[1].is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.wind[1] = my_tile.wind[1];
        sanitized = true;
    }
    if my_next_tile.gases.moles() < MINIMUM_NONZERO_MOLES {
        for i in 0..GAS_COUNT {
            my_next_tile.gases.values[i] = 0.0;
        }
        my_next_tile.thermal_energy = 0.0;
        // We don't count this as sanitized because it's expected.
    }

    sanitized
}

#[allow(clippy::if_same_then_else)]
/// Checks a tile to see if it's "interesting" and should be sent to BYOND.
pub(crate) fn check_interesting(
    x: i32,
    y: i32,
    z: i32,
    next: &mut ZLevel,
    my_tile: &Tile,
    my_index: usize,
    new_interesting_tiles: &Bag<InterestingTile>,
) -> Result<(), eyre::Error> {
    let mut reasons: ReasonFlags = ReasonFlags::empty();
    {
        let my_next_tile = next.get_tile_mut(my_index);
        if (my_next_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES)
            != (my_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES)
        {
            // Fire started or stopped.
            reasons |= ReasonFlags::DISPLAY;
        } else if (my_next_tile.gases.toxins() >= TOXINS_MIN_VISIBILITY_MOLES)
            != (my_tile.gases.toxins() >= TOXINS_MIN_VISIBILITY_MOLES)
        {
            // Crossed the toxins visibility threshold.
            reasons |= ReasonFlags::DISPLAY;
        } else if (my_next_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
            != (my_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
        {
            // Crossed the sleeping agent visibility threshold.
            reasons |= ReasonFlags::DISPLAY;
        }

        if my_next_tile.temperature() > PLASMA_BURN_MIN_TEMP {
            if let AtmosMode::ExposedTo { .. } = my_next_tile.mode {
                // Since environments have fixed gases and temperatures, we only count them as
                // interesting (for heat) if there's an active fire.
                if my_next_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES {
                    reasons |= ReasonFlags::HOT;
                }
            } else {
                // Anywhere else is interesting if it's hot enough to start a fire.
                reasons |= ReasonFlags::HOT;
            }
        }
    }
    let my_next_tile = next.get_tile(my_index);
    let mut wind_x: f32 = 0.0;
    if my_next_tile.wind[AXIS_X] > 0.0 {
        wind_x += my_next_tile.wind[AXIS_X] * WIND_SPEED * BYOND_WIND_MULTIPLIER;
    }
    if let Some(index) = ZLevel::maybe_get_index(x - 1, y) {
        let their_next_tile = next.get_tile(index);
        if their_next_tile.wind[AXIS_X] < 0.0 {
            // This is negative, but that's good, because we want it to fight against the wind
            // towards +X.
            wind_x += their_next_tile.wind[AXIS_X] * BYOND_WIND_MULTIPLIER;
        }
    }
    wind_x *= my_next_tile.pressure();
    let mut wind_y: f32 = 0.0;
    if my_next_tile.wind[AXIS_Y] > 0.0 {
        wind_y += my_next_tile.wind[AXIS_Y] * BYOND_WIND_MULTIPLIER;
    }
    if let Some(index) = ZLevel::maybe_get_index(x, y - 1) {
        let their_next_tile = next.get_tile(index);
        if their_next_tile.wind[AXIS_Y] < 0.0 {
            // This is negative, but that's good, because we want it to fight against the wind
            // towards +Y.
            wind_y += their_next_tile.wind[AXIS_Y] * BYOND_WIND_MULTIPLIER;
        }
    }
    wind_y *= my_next_tile.pressure();
    if wind_x.powi(2) + wind_y.powi(2) > 1.0 {
        // Pressure flowing out of this tile might move stuff.
        reasons |= ReasonFlags::WIND;
    }

    if !reasons.is_empty() {
        // :eyes:
        new_interesting_tiles.push(InterestingTile {
            tile: my_next_tile.clone(),
            // +1 here to convert from our 0-indexing to BYOND's 1-indexing.
            coords: ByondXYZ::with_coords((x as i16 + 1, y as i16 + 1, z as i16 + 1)),
            reasons,
            wind_x,
            wind_y,
        });
    }

    Ok(())
}

/// Perform chemical reactions on the tile.
pub(crate) fn react(my_next_tile: &mut Tile, hotspot_step: bool) {
    let fraction: f32;
    let hotspot_boost: f32;
    let mut cached_heat_capacity: f32;
    let mut cached_temperature: f32;
    let mut thermal_energy: f32;
    if hotspot_step {
        fraction = my_next_tile.hotspot_volume;
        hotspot_boost = PLASMA_BURN_HOTSPOT_RATIO_BOOST;
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        cached_temperature = my_next_tile.hotspot_temperature;
        thermal_energy = cached_temperature * cached_heat_capacity;
    } else {
        fraction = 1.0 - my_next_tile.hotspot_volume;
        hotspot_boost = 1.0;
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        thermal_energy = fraction * my_next_tile.thermal_energy;
        cached_temperature = thermal_energy / cached_heat_capacity;
    }
    let initial_thermal_energy = thermal_energy;

    // Agent B converting CO2 to O2
    if cached_temperature > AGENT_B_CONVERSION_TEMP
        && my_next_tile.gases.agent_b() > 0.0
        && my_next_tile.gases.carbon_dioxide() > 0.0
        && my_next_tile.gases.toxins() > 0.0
    {
        let co2_converted = fraction
            * (my_next_tile.gases.carbon_dioxide() * 0.75)
                .min(my_next_tile.gases.toxins() * 0.25)
                .min(my_next_tile.gases.agent_b() * 0.05);

        my_next_tile
            .gases
            .set_carbon_dioxide(my_next_tile.gases.carbon_dioxide() - co2_converted);
        my_next_tile
            .gases
            .set_oxygen(my_next_tile.gases.oxygen() + co2_converted);
        my_next_tile
            .gases
            .set_agent_b(my_next_tile.gases.agent_b() - co2_converted * 0.05);
        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // Add in the new thermal energy.
        thermal_energy += AGENT_B_CONVERSION_ENERGY * co2_converted;
        // Recalculate temperature for any subsequent reactions.
        cached_temperature = thermal_energy / cached_heat_capacity;
        my_next_tile.fuel_burnt += co2_converted;
    }
    // Nitrous Oxide breaking down into nitrogen and oxygen.
    if cached_temperature > SLEEPING_GAS_BREAKDOWN_TEMP && my_next_tile.gases.sleeping_agent() > 0.0
    {
        let reaction_percent = (0.00002
            * (cached_temperature - (0.00001 * (cached_temperature.powi(2)))))
        .max(0.0)
        .min(1.0);
        let nitrous_decomposed = reaction_percent * fraction * my_next_tile.gases.sleeping_agent();

        my_next_tile
            .gases
            .set_sleeping_agent(my_next_tile.gases.sleeping_agent() - nitrous_decomposed);
        my_next_tile
            .gases
            .set_nitrogen(my_next_tile.gases.nitrogen() + nitrous_decomposed);
        my_next_tile
            .gases
            .set_oxygen(my_next_tile.gases.oxygen() + nitrous_decomposed / 2.0);

        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // Add in the new thermal energy.
        thermal_energy += NITROUS_BREAKDOWN_ENERGY * nitrous_decomposed;
        // Recalculate temperature for any subsequent reactions.
        cached_temperature = thermal_energy / cached_heat_capacity;

        my_next_tile.fuel_burnt += nitrous_decomposed;
    }
    // Plasmafire!
    if cached_temperature > PLASMA_BURN_MIN_TEMP
        && my_next_tile.gases.toxins() > 0.0
        && my_next_tile.gases.oxygen() > 0.0
    {
        // How efficient is the burn?
        // Linear scaling fom 0 to 1 as temperatue goes from minimum to optimal.
        let efficiency = ((cached_temperature - PLASMA_BURN_MIN_TEMP)
            / (PLASMA_BURN_OPTIMAL_TEMP - PLASMA_BURN_MIN_TEMP))
            .max(0.0)
            .min(1.0);

        // How much plasma is available to burn?
        let burnable_plasma = fraction * my_next_tile.gases.toxins();

        // Actual burn amount.
        let mut plasma_burnt = efficiency * PLASMA_BURN_MAX_RATIO * hotspot_boost * burnable_plasma;
        if plasma_burnt < PLASMA_BURN_MIN_MOLES {
            // Boost up to the minimum.
            plasma_burnt = PLASMA_BURN_MIN_MOLES.min(burnable_plasma);
        }
        if plasma_burnt * PLASMA_BURN_OXYGEN_PER_PLASMA > fraction * my_next_tile.gases.oxygen() {
            // Restrict based on available oxygen.
            plasma_burnt = fraction * my_next_tile.gases.oxygen() / PLASMA_BURN_OXYGEN_PER_PLASMA;
        }

        my_next_tile
            .gases
            .set_toxins(my_next_tile.gases.toxins() - plasma_burnt);
        my_next_tile
            .gases
            .set_carbon_dioxide(my_next_tile.gases.carbon_dioxide() + plasma_burnt);
        my_next_tile
            .gases
            .set_oxygen(my_next_tile.gases.oxygen() - plasma_burnt * PLASMA_BURN_OXYGEN_PER_PLASMA);

        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        thermal_energy += PLASMA_BURN_ENERGY * plasma_burnt;
        // Recalculate temperature for any subsequent reactions.
        // (or we would, but this is the last reaction)
        //cached_temperature = thermal_energy / cached_heat_capacity;

        my_next_tile.fuel_burnt += plasma_burnt;
    }

    if hotspot_step {
        adjust_hotspot(my_next_tile, thermal_energy - initial_thermal_energy);
    } else {
        my_next_tile.thermal_energy += thermal_energy - initial_thermal_energy;
    }
}

/// Apply effects caused by the tile's atmos mode.
pub(crate) fn apply_tile_mode(
    my_next_tile: &mut Tile,
    environments: &Box<[Tile]>,
) -> Result<(), eyre::Error> {
    match my_next_tile.mode {
        AtmosMode::Space => {
            // Space tiles lose all gas and thermal energy every tick.
            for gas in 0..GAS_COUNT {
                my_next_tile.gases.values[gas] = 0.0;
            }
            my_next_tile.gases.set_dirty();
            my_next_tile.thermal_energy = 0.0;
        }
        AtmosMode::ExposedTo { environment_id } => {
            // Exposed tiles reset back to the same state every tick.
            if environment_id as usize > environments.len() {
                return Err(eyre!("Invalid environment ID {}", environment_id));
            }

            let environment = &environments[environment_id as usize];
            my_next_tile.gases.copy_from(&environment.gases);
            my_next_tile.thermal_energy = environment.thermal_energy;
        }
        AtmosMode::Sealed => {
            if my_next_tile.temperature() > SPACE_COOLING_THRESHOLD {
                let excess_thermal_energy = my_next_tile.thermal_energy
                    - SPACE_COOLING_THRESHOLD * my_next_tile.heat_capacity();
                let cooling = (SPACE_COOLING_FLAT
                    + SPACE_COOLING_TEMPERATURE_RATIO * my_next_tile.temperature())
                .min(excess_thermal_energy);
                my_next_tile.thermal_energy -= cooling;
            }
        }
        AtmosMode::NoDecay => {} // No special interactions
    }
    Ok(())
}

// Performs superconduction between two superconductivity-connected tiles.
pub(crate) fn superconduct(my_tile: &mut Tile, their_tile: &mut Tile, is_east: bool, force: bool) {
    // Superconduction is scaled to the smaller directional superconductivity setting of the two
    // tiles.
    let mut transfer_coefficient: f32;
    if force {
        transfer_coefficient = OPEN_HEAT_TRANSFER_COEFFICIENT;
    } else if is_east {
        if !my_tile.wall[AXIS_X] {
            // Atmos flows freely here, no need to superconduct.
            return;
        }
        transfer_coefficient = my_tile
            .superconductivity
            .east
            .min(their_tile.superconductivity.west);
    } else {
        if !my_tile.wall[AXIS_Y] {
            // Atmos flows freely here, no need to superconduct.
            return;
        }
        transfer_coefficient = my_tile
            .superconductivity
            .north
            .min(their_tile.superconductivity.south);
    }

    let my_heat_capacity = my_tile.heat_capacity();
    let their_heat_capacity = their_tile.heat_capacity();
    if transfer_coefficient <= 0.0 || my_heat_capacity <= 0.0 || their_heat_capacity <= 0.0 {
        // Nothing to do.
        return;
    }

    // Temporary workaround to match LINDA better for high temperatures.
    if my_tile.temperature() > T20C || their_tile.temperature() > T20C {
        transfer_coefficient = (transfer_coefficient * 100.0).min(OPEN_HEAT_TRANSFER_COEFFICIENT);
    }

    // This is the formula from LINDA. I have no idea if it's a good one, I just copied it.
    // Positive means heat flow from us to them.
    // Negative means heat flow from them to us.
    let conduction = transfer_coefficient
        * (my_tile.temperature() - their_tile.temperature())
        * my_heat_capacity
        * their_heat_capacity
        / (my_heat_capacity + their_heat_capacity);

    // Half of the conduction always goes to the overall heat of the tile
    my_tile.thermal_energy -= conduction / 2.0;
    their_tile.thermal_energy += conduction / 2.0;

    // The other half can spawn or expand hotspots.
    if conduction > 0.0
        && my_tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP
        && their_tile.temperature() < PLASMA_BURN_OPTIMAL_TEMP
    {
        // Positive: Spawn or expand their hotspot.
        adjust_hotspot(their_tile, conduction / 2.0);
        my_tile.thermal_energy -= conduction / 2.0;
    } else if conduction < 0.0
        && my_tile.temperature() < PLASMA_BURN_OPTIMAL_TEMP
        && their_tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP
    {
        // Negative: Spawn or expand my hotspot.
        adjust_hotspot(my_tile, -conduction / 2.0);
        their_tile.thermal_energy += conduction / 2.0;
    } else {
        // No need for hotspot adjustment.
        my_tile.thermal_energy -= conduction / 2.0;
        their_tile.thermal_energy += conduction / 2.0;
    }
}

pub(crate) fn normalise_hotspot(tile: &mut Tile) {
    if tile.hotspot_volume <= 0.0 || tile.hotspot_temperature <= tile.temperature() {
        // Unnecesary hotspot.
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    if tile.hotspot_volume >= 1.0 {
        // Hotspot has expanded to fill the tile.
        tile.thermal_energy = tile.hotspot_temperature * tile.heat_capacity();
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    let optimal_thermal_energy = PLASMA_BURN_OPTIMAL_TEMP * tile.heat_capacity();
    let hotspot_extra_thermal_energy = tile.hotspot_volume
        * (tile.hotspot_temperature - tile.temperature())
        * tile.heat_capacity();
    if tile.thermal_energy + hotspot_extra_thermal_energy >= optimal_thermal_energy {
        // Hotspot has done its job, dump the remaining heat into the tile.
        tile.thermal_energy += hotspot_extra_thermal_energy;
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    let hotspot_thermal_energy =
        tile.hotspot_volume * tile.hotspot_temperature * tile.heat_capacity();
    if tile.hotspot_temperature > PLASMA_BURN_OPTIMAL_TEMP {
        // Use excess heat to expand the hotspot.
        tile.hotspot_volume = hotspot_thermal_energy / optimal_thermal_energy;
        tile.hotspot_temperature = PLASMA_BURN_OPTIMAL_TEMP;
        return;
    }

    if tile.hotspot_temperature < PLASMA_BURN_MIN_TEMP
        || tile.gases.toxins() <= REACTION_SIGNIFICANCE_MOLES
        || tile.gases.oxygen() <= REACTION_SIGNIFICANCE_MOLES
    {
        // Hotspot can't sustain combustion.
        tile.thermal_energy += hotspot_extra_thermal_energy;
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }
}

// Adjusts the hotspot based on the given thermal energy delta.
// For positive values, the energy will first be used to reach PLASMA_BURN_OPTIMAL_TEMP, then
// to expand volume up to 1 (filled), and finally dumped into the tile's thermal energy.
// For negative values, only the hotspot's volume is affected.
pub(crate) fn adjust_hotspot(tile: &mut Tile, thermal_energy_delta: f32) {
    if thermal_energy_delta < 0.0 {
        if tile.hotspot_volume <= 0.0 {
            // No hotspot to sap heat from.
            return;
        }
        // Shrink volume accordingly.
        // How much heat do we need to fill the whole tile?
        let total_heat_needed = tile.heat_capacity() * tile.hotspot_temperature;
        // How much heat do we have now?
        let heat_available = tile.heat_capacity() * tile.hotspot_temperature * tile.hotspot_volume
            + thermal_energy_delta;
        // We fill that portion of the tile.
        tile.hotspot_volume = (heat_available / total_heat_needed).max(0.0);
    } else if tile.hotspot_volume > 0.0 {
        // Heat up the hotspot; it'll expand when normalised.
        tile.hotspot_temperature +=
            thermal_energy_delta / (tile.heat_capacity() * tile.hotspot_volume);
    } else if tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP {
        // No need to make a hotspot, just heat the tile.
        tile.thermal_energy += thermal_energy_delta;
    } else {
        // Create an optimal hotspot with the available energy.
        let optimal_thermal_energy = PLASMA_BURN_OPTIMAL_TEMP * tile.heat_capacity();
        tile.hotspot_temperature = PLASMA_BURN_OPTIMAL_TEMP;
        tile.hotspot_volume = thermal_energy_delta / (optimal_thermal_energy - tile.thermal_energy);
    }

    normalise_hotspot(tile);
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;

    // TODO
}
