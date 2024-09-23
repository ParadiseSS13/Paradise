use crate::constants::*;
use crate::model::*;
use byondapi::map::ByondXYZ;
use eyre::eyre;
use scc::Bag;

/// Calculates the pressure flow out from this tile to the two neighboring tiles on this axis.
/// For a tile losing air equally in all directions, flow will be zero.
/// For a tile losing air towards positive only, flow will be the air pressure moved.
pub(crate) fn calculate_flow(
    maybe_negative_tile: Option<&Tile>,
    tile: &Tile,
    maybe_positive_tile: Option<&Tile>,
    is_x: bool,
) -> f32 {
    let mut flow = 0.0;
    let my_pressure = tile.pressure();
    if let Some(negative_tile) = maybe_negative_tile {
        // Make sure air can pass this way.
        let mut permeable = true;
        if is_x {
            permeable = permeable
                && !negative_tile
                    .airtight_directions
                    .contains(AirtightDirections::EAST);
            permeable = permeable && !tile.airtight_directions.contains(AirtightDirections::WEST);
        } else {
            permeable = permeable
                && !negative_tile
                    .airtight_directions
                    .contains(AirtightDirections::NORTH);
            permeable = permeable && !tile.airtight_directions.contains(AirtightDirections::SOUTH);
        }
        if permeable {
            let negative_pressure = negative_tile.pressure();
            if negative_pressure < my_pressure {
                // Causes flow in the negative direction.
                flow += negative_pressure - my_pressure;
            }
        }
    }
    if let Some(positive_tile) = maybe_positive_tile {
        // Make sure air can pass this way.
        let mut permeable = true;
        if is_x {
            permeable = permeable
                && !positive_tile
                    .airtight_directions
                    .contains(AirtightDirections::WEST);
            permeable = permeable && !tile.airtight_directions.contains(AirtightDirections::EAST);
        } else {
            permeable = permeable
                && !positive_tile
                    .airtight_directions
                    .contains(AirtightDirections::SOUTH);
            permeable = permeable && !tile.airtight_directions.contains(AirtightDirections::NORTH);
        }
        if permeable {
            let positive_pressure = positive_tile.pressure();
            if positive_pressure < my_pressure {
                // Causes flow in the positive direction.
                flow += my_pressure - positive_pressure;
            }
        }
    }
    flow
}

/// Counts the number of adjacent tiles that can share atmos with this tile, i.e. have no blockers
/// on either tile.
#[allow(clippy::if_same_then_else)]
pub(crate) fn count_connected_dirs(
    z_level: &ZLevel,
    index: usize,
    x: i32,
    y: i32,
) -> Result<i32, eyre::Error> {
    let mut connected_dirs = 0;

    let tile = z_level.get_tile(index);
    if let AtmosMode::Space = tile.mode {
        // Space can always accept as much air as you throw at it.
        return Ok(1);
    }
    for (dx, dy) in DIRECTIONS {
        let maybe_other_index = ZLevel::maybe_get_index(x + dx, y + dy);
        let other_index;
        match maybe_other_index {
            Some(index) => other_index = index,
            None => continue,
        }
        let other_tile = z_level.get_tile(other_index);

        if dx > 0
            && !tile.airtight_directions.contains(AirtightDirections::EAST)
            && !other_tile
                .airtight_directions
                .contains(AirtightDirections::WEST)
        {
            connected_dirs += 1;
        } else if dy > 0
            && !tile.airtight_directions.contains(AirtightDirections::NORTH)
            && !other_tile
                .airtight_directions
                .contains(AirtightDirections::SOUTH)
        {
            connected_dirs += 1;
        } else if dx < 0
            && !tile.airtight_directions.contains(AirtightDirections::WEST)
            && !other_tile
                .airtight_directions
                .contains(AirtightDirections::EAST)
        {
            connected_dirs += 1;
        } else if dy < 0
            && !tile.airtight_directions.contains(AirtightDirections::SOUTH)
            && !other_tile
                .airtight_directions
                .contains(AirtightDirections::NORTH)
        {
            connected_dirs += 1;
        }
    }

    Ok(connected_dirs)
}

/// Sanitizes a tile to make sure it's not problematic.
pub(crate) fn sanitize(my_inactive_tile: &mut Tile, my_tile: &Tile) -> bool {
    let mut sanitized = false;
    for i in 0..GAS_COUNT {
        if !my_inactive_tile.gases.values[i].is_finite() {
            // Reset back to the last value, in the hopes that it's safe.
            my_inactive_tile.gases.values[i] = my_tile.gases.values[i];
            my_inactive_tile.gases.set_dirty();
            sanitized = true;
        } else if my_inactive_tile.gases.values[i] < 0.0 {
            // Zero out anything that becomes negative.
            my_inactive_tile.gases.values[i] = 0.0;
            my_inactive_tile.gases.set_dirty();
            sanitized = true;
        }
    }
    if !my_inactive_tile.thermal_energy.is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_inactive_tile.thermal_energy = my_tile.thermal_energy;
        sanitized = true;
    } else if my_inactive_tile.thermal_energy < 0.0 {
        // Zero out anything that becomes negative.
        my_inactive_tile.thermal_energy = 0.0;
        sanitized = true;
    }
    if my_inactive_tile.gases.moles() < MINIMUM_NONZERO_MOLES {
        for i in 0..GAS_COUNT {
            my_inactive_tile.gases.values[i] = 0.0;
        }
        my_inactive_tile.thermal_energy = 0.0;
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
    active: &std::sync::RwLockReadGuard<ZLevel>,
    environments: &Box<[Tile]>,
    my_tile: &Tile,
    my_inactive_tile: &Tile,
    fuel_burnt: f32,
    new_interesting_tiles: &Bag<InterestingTile>,
) -> Result<(), eyre::Error> {
    let mut reasons: ReasonFlags = ReasonFlags::empty();
    if (my_inactive_tile.gases.toxins() >= TOXINS_VISIBILITY_MOLES)
        != (my_tile.gases.toxins() >= TOXINS_VISIBILITY_MOLES)
    {
        // Crossed the toxins visibility threshold.
        reasons |= ReasonFlags::DISPLAY;
    } else if (my_inactive_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
        != (my_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
    {
        // Crossed the sleeping agent visibility threshold.
        reasons |= ReasonFlags::DISPLAY;
    }
    let temperature = my_inactive_tile.temperature();
    if temperature > PLASMA_BURN_MIN_TEMP {
        match my_inactive_tile.mode {
            // In environments we expect to be hot, we don't normally flag that as interesting.
            AtmosMode::ExposedTo { environment_id } => {
                if fuel_burnt > 0.0 {
                    // Active fires are interesting, even if it's hot here normally.
                    reasons |= ReasonFlags::HOT;
                } else {
                    if environment_id as usize > environments.len() {
                        return Err(eyre!("Invalid environment ID {}", environment_id));
                    }

                    let environment_temp = environments[environment_id as usize].temperature();
                    if environment_temp + 1.0 >= temperature {
                        // No active fire, not hotter than normal. Not interesting.
                    } else {
                        // Oh, hey, we're hotter than normal, and can start fires.
                        // That's interesting.
                        reasons |= ReasonFlags::HOT;
                    }
                }
            }
            // Anywhere else is interesting if it can start fires.
            _ => reasons |= ReasonFlags::HOT,
        }
    }
    let flow_x = calculate_flow(
        active.maybe_get_tile(x - 1, y),
        my_tile,
        active.maybe_get_tile(x + 1, y),
        true,
    );
    if flow_x.abs() > 1.0 {
        // Pressure flowing out of this tile along the X axis.
        reasons |= ReasonFlags::WIND;
    }
    let flow_y = calculate_flow(
        active.maybe_get_tile(x, y - 1),
        my_tile,
        active.maybe_get_tile(x, y + 1),
        false,
    );
    if flow_x.powi(2) + flow_y.powi(2) > 1.0 {
        // Pressure flowing out of this tile along the Y axis.
        reasons |= ReasonFlags::WIND;
    }

    if !reasons.is_empty() {
        // Boooooring.

        // :eyes:
        new_interesting_tiles.push(InterestingTile {
            tile: my_inactive_tile.clone(),
            // +1 here to convert from our 0-indexing to BYOND's 1-indexing.
            coords: ByondXYZ::with_coords((x as i16 + 1, y as i16 + 1, z as i16 + 1)),
            reasons,
            flow_x,
            flow_y,
        });
    }

    Ok(())
}

/// Is the amount of gas present significant?
pub(crate) fn is_significant(tile: &Tile, gas: usize) -> bool {
    if tile.gases.values[gas] < REACTION_SIGNIFICANCE_MOLES {
        return false;
    }
    if gas != GAS_AGENT_B
        && tile.gases.values[gas] / tile.gases.moles() < REACTION_SIGNIFICANCE_RATIO
    {
        return false;
    }
    return true;
}

/// Perform chemical reactions on the tile.
pub(crate) fn react(my_inactive_tile: &mut Tile) -> f32 {
    let mut fuel_burnt: f32 = 0.0;
    // Handle reactions
    let mut my_inactive_temperature = my_inactive_tile.temperature();
    // Agent B converting CO2 to O2
    if my_inactive_temperature > AGENT_B_CONVERSION_TEMP
        && is_significant(my_inactive_tile, GAS_AGENT_B)
        && is_significant(my_inactive_tile, GAS_CARBON_DIOXIDE)
        && is_significant(my_inactive_tile, GAS_TOXINS)
    {
        let co2_converted = (my_inactive_tile.gases.carbon_dioxide() * 0.75)
            .min(my_inactive_tile.gases.toxins() * 0.25)
            .min(my_inactive_tile.gases.agent_b() * 0.05);

        my_inactive_tile
            .gases
            .set_carbon_dioxide(my_inactive_tile.gases.carbon_dioxide() - co2_converted);
        my_inactive_tile
            .gases
            .set_oxygen(my_inactive_tile.gases.oxygen() + co2_converted);
        my_inactive_tile
            .gases
            .set_agent_b(my_inactive_tile.gases.agent_b() - co2_converted * 0.05);
        // Recalculate existing thermal energy to account for the decrease in heat capacity
        // caused by turning very high capacity toxins into much lower capacity carbon
        // dioxide.
        my_inactive_tile.thermal_energy =
            my_inactive_temperature * my_inactive_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        my_inactive_tile.thermal_energy += co2_converted * AGENT_B_CONVERSION_ENERGY;
        // Recalculate temperature for any subsequent reactions.
        my_inactive_temperature = my_inactive_tile.temperature();
        fuel_burnt += co2_converted;
    }
    // Nitrous Oxide breaking down into nitrogen and oxygen.
    if my_inactive_temperature > SLEEPING_GAS_BREAKDOWN_TEMP
        && is_significant(my_inactive_tile, GAS_SLEEPING_AGENT)
    {
        let reaction_percent = (0.00002
            * (my_inactive_temperature - (0.00001 * (my_inactive_temperature.powi(2)))))
        .max(0.0)
        .min(1.0);
        let nitrous_decomposed = reaction_percent * my_inactive_tile.gases.sleeping_agent();

        my_inactive_tile
            .gases
            .set_sleeping_agent(my_inactive_tile.gases.sleeping_agent() - nitrous_decomposed);
        my_inactive_tile
            .gases
            .set_nitrogen(my_inactive_tile.gases.nitrogen() + nitrous_decomposed);
        my_inactive_tile
            .gases
            .set_oxygen(my_inactive_tile.gases.oxygen() + nitrous_decomposed / 2.0);
        // Recalculate existing thermal energy to account for the decrease in heat capacity
        // caused by turning very high capacity toxins into much lower capacity carbon
        // dioxide.
        my_inactive_tile.thermal_energy =
            my_inactive_temperature * my_inactive_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        my_inactive_tile.thermal_energy += NITROUS_BREAKDOWN_ENERGY * nitrous_decomposed;
        // Recalculate temperature for any subsequent reactions.
        my_inactive_temperature = my_inactive_tile.temperature();
        fuel_burnt += nitrous_decomposed;
    }
    // Plasmafire!
    if my_inactive_temperature > PLASMA_BURN_MIN_TEMP
        && is_significant(my_inactive_tile, GAS_TOXINS)
        && is_significant(my_inactive_tile, GAS_OXYGEN)
    {
        // How efficient is the burn?
        // Linear scaling fom 0 to 1 as temperatue goes from minimum to optimal.
        let efficiency = ((my_inactive_temperature - PLASMA_BURN_MIN_TEMP)
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
        // consumed. This means that if there is enough oxygen to burn all the plasma, the
        // oxygen-to-plasm ratio will increase while burning.
        let burnable_plasma = my_inactive_tile
            .gases
            .toxins()
            .min(my_inactive_tile.gases.oxygen() / PLASMA_BURN_REQUIRED_OXYGEN_AVAILABILITY);

        // Actual burn amount.
        let plasma_burnt = efficiency * PLASMA_BURN_MAX_RATIO * burnable_plasma;

        my_inactive_tile
            .gases
            .set_toxins(my_inactive_tile.gases.toxins() - plasma_burnt);
        my_inactive_tile
            .gases
            .set_carbon_dioxide(my_inactive_tile.gases.carbon_dioxide() + plasma_burnt);
        my_inactive_tile
            .gases
            .set_oxygen(my_inactive_tile.gases.oxygen() - plasma_burnt * oxygen_per_plasma);
        // Recalculate existing thermal energy to account for the decrease in heat capacity
        // caused by turning very high capacity toxins into much lower capacity carbon
        // dioxide.
        my_inactive_tile.thermal_energy =
            my_inactive_temperature * my_inactive_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        my_inactive_tile.thermal_energy += PLASMA_BURN_ENERGY * plasma_burnt;
        fuel_burnt += plasma_burnt;
    }

    fuel_burnt
}

/// Apply effects caused by the tile's atmos mode.
pub(crate) fn apply_tile_mode(
    my_tile: &Tile,
    my_inactive_tile: &mut Tile,
    environments: &Box<[Tile]>,
) -> Result<(), eyre::Error> {
    match my_tile.mode {
        AtmosMode::Space => {
            // Space tiles lose all gas and thermal energy every tick.
            for gas in 0..GAS_COUNT {
                my_inactive_tile.gases.values[gas] = 0.0;
            }
            my_inactive_tile.gases.set_dirty();
            my_inactive_tile.thermal_energy = 0.0;
        }
        AtmosMode::ExposedTo { environment_id } => {
            if environment_id as usize > environments.len() {
                return Err(eyre!("Invalid environment ID {}", environment_id));
            }

            let mut environment = environments[environment_id as usize].clone();

            // Calculate the amount of air and thermal energy transferred.
            let (gas_change, thermal_energy_change) = share_air(
                // Planetary atmos is aggressive and does a 1-connected-direction share
                // with the otherwise-final air.
                my_inactive_tile,
                &environment,
                1,
                1,
            );

            // Transfer it.
            for i in 0..GAS_COUNT {
                if gas_change.values[i] != 0.0 {
                    my_inactive_tile.gases.values[i] += gas_change.values[i];
                    my_inactive_tile.gases.set_dirty();
                }
            }
            my_inactive_tile.thermal_energy += thermal_energy_change;

            // Temporarily override the tile's superconductivity, since there's no UP.
            let real_superconductivity = my_inactive_tile.superconductivity;
            my_inactive_tile.superconductivity = Superconductivity::new();

            // Superconduct with planetary atmos.
            superconduct(my_inactive_tile, &mut environment, true);

            // Restore original superconductivity
            my_inactive_tile.superconductivity = real_superconductivity;
        }
        AtmosMode::Sealed => {
            if my_inactive_tile.temperature() > T20C {
                my_inactive_tile.thermal_energy *= 1.0 - SPACE_COOLING_FACTOR;
            }
        }
		AtmosMode::NoDecay => {} // No special interactions
    }
    Ok(())
}

/// Shares air between two connected tiles.
#[allow(clippy::needless_range_loop)]
pub(crate) fn share_air(
    mine: &Tile,
    theirs: &Tile,
    my_connected_dirs: i32,
    their_connected_dirs: i32,
) -> (GasSet, f32) {
    let mut delta_gases = GasSet::new();
    let mut delta_thermal_energy: f32 = 0.0;

    // Since we're moving bits of gas independantly, we need to know the temperature of the gas
    // mix.
    let my_old_temperature = mine.temperature();
    let their_old_temperature = theirs.temperature();

    // Each gas is handled separately. This is dumb, but it's how LINDA did it, so it's used in V1.
    for gas in 0..GAS_COUNT {
        delta_gases.values[gas] = theirs.gases.values[gas] - mine.gases.values[gas];
        if delta_gases.values[gas] > 0.0 {
            // Gas flowing in from the other tile, limit by its connected_dirs.
            delta_gases.values[gas] /= (their_connected_dirs + 1) as f32;
            // Heat flowing in.
            delta_thermal_energy +=
                SPECIFIC_HEATS[gas] * delta_gases.values[gas] * their_old_temperature;
        } else {
            // Gas flowing out from this tile, limit by our connected_dirs.
            delta_gases.values[gas] /= (my_connected_dirs + 1) as f32;
            // Heat flowing out.
            delta_thermal_energy +=
                SPECIFIC_HEATS[gas] * delta_gases.values[gas] * my_old_temperature;
        }
    }

    (delta_gases, delta_thermal_energy)
}

/// Performs superconduction between two superconductivity-connected tiles.
pub(crate) fn superconduct(my_tile: &mut Tile, their_tile: &mut Tile, is_east: bool) {
    // Superconduction is scaled to the smaller directional superconductivity setting of the two
    // tiles.
    let mut transfer_coefficient: f32;
    if is_east {
        transfer_coefficient = my_tile
            .superconductivity
            .east
            .min(their_tile.superconductivity.west);
    } else {
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
    let conduction = transfer_coefficient
        * (my_tile.temperature() - their_tile.temperature())
        * my_heat_capacity
        * their_heat_capacity
        / (my_heat_capacity + their_heat_capacity);
    my_tile.thermal_energy -= conduction;
    their_tile.thermal_energy += conduction;
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;
    // share_air() should do nothing to two space tiles.
    #[test]
    fn share_nothing() {
        let tile_a = Tile::new();
        let tile_b = Tile::new();

        let (gas_change, thermal_energy_change) = share_air(&tile_a, &tile_b, 1, 1);
        for i in 0..GAS_COUNT {
            assert_eq!(gas_change.values[i], 0.0, "{}", i);
        }
        assert_eq!(thermal_energy_change, 0.0);
    }

    // share_air() should do nothing to two matching tiles.
    #[test]
    fn share_equilibrium() {
        let mut tile_a = Tile::new();
        tile_a.gases.set_oxygen(80.0);
        tile_a.gases.set_nitrogen(20.0);
        tile_a.thermal_energy = 100.0;
        let mut tile_b = Tile::new();
        tile_b.gases.set_oxygen(80.0);
        tile_b.gases.set_nitrogen(20.0);
        tile_b.thermal_energy = 100.0;

        let (gas_change, thermal_energy_change) = share_air(&tile_a, &tile_b, 1, 1);
        for i in 0..GAS_COUNT {
            assert_eq!(gas_change.values[i], 0.0, "{}", i);
        }
        assert_eq!(thermal_energy_change, 0.0);
    }

    // share_air() should split air into 2 equal parts with connected_dirs of 1.
    #[test]
    fn share_splits_air_cd1() {
        let mut tile_a = Tile::new();
        tile_a.gases.set_oxygen(100.0);
        tile_a.thermal_energy = 100.0;
        let tile_b = Tile::new();

        let (gas_change, thermal_energy_change) = share_air(&tile_a, &tile_b, 1, 1);
        for i in 0..GAS_COUNT {
            if i == GAS_OXYGEN {
                assert_eq!(gas_change.values[i], -50.0);
            } else {
                assert_eq!(gas_change.values[i], 0.0, "{}", i);
            }
        }
        assert_eq!(thermal_energy_change, -50.0);
    }

    // share_air() should split air into 5 equal parts with connected_dirs of 4.
    #[test]
    fn share_splits_air_cd4() {
        let mut tile_a = Tile::new();
        tile_a.gases.set_oxygen(100.0);
        tile_a.thermal_energy = 100.0;
        let tile_b = Tile::new();

        let (gas_change, thermal_energy_change) = share_air(&tile_a, &tile_b, 4, 4);
        for i in 0..GAS_COUNT {
            if i == GAS_OXYGEN {
                assert_eq!(gas_change.values[i], -20.0);
            } else {
                assert_eq!(gas_change.values[i], 0.0, "{}", i);
            }
        }
        assert_eq!(thermal_energy_change, -20.0);
    }

    // superconduct() should transfer part of the thermal energy between two tiles that differ
    // only in thermal energy.
    #[test]
    fn superconduct_temperature() {
        let mut tile_a = Tile::new();
        tile_a.gases.set_oxygen(80.0);
        tile_a.gases.set_nitrogen(20.0);
        tile_a.thermal_energy = 100.0;
        let mut tile_b = Tile::new();
        tile_b.gases.set_oxygen(80.0);
        tile_b.gases.set_nitrogen(20.0);
        tile_b.thermal_energy = 200.0;

        superconduct(&mut tile_a, &mut tile_b, true);

        // These values are arbitrary, they're just what we get right now.
        // Update them if the calculations changed intentionally.
        assert_eq!(tile_a.thermal_energy, 120.0);
        assert_eq!(tile_b.thermal_energy, 180.0);
    }
}
