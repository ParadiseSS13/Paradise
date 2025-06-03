use crate::milla::model::*;
use crate::milla::simulate;
use crate::milla::statics::*;
use eyre;
use scc::Bag;
use std::sync::RwLock;
use std::thread;
use std::thread::ScopedJoinHandle;
use thread_priority;

/// Runs a single tick of the atmospherics model, multi-threaded by Z level.
pub(crate) fn tick(buffers: &Buffers) -> Result<(), eyre::Error> {
    assert!(thread_priority::ThreadPriority::Min
        .set_for_current()
        .is_ok());
    let prev = buffers.get_active().read().unwrap();
    let next = buffers.get_inactive().read().unwrap();

    let new_interesting_tiles: Bag<InterestingTile> = Bag::default();
    let mut result: eyre::Result<()> = Ok(());
    let handle_results: RwLock<Vec<eyre::Result<()>>> = RwLock::new(Vec::new());

    // The scope tells Rust that all the threads we create here will end by the time the scope
    // closes. This allows us to pass things into them that are only borrowed for the lifetime of
    // this function.
    thread::scope(|s| {
        // Force most things to be captured by reference, despite the `move`
        // in the thread spawn, which is really just for `z`.
        let prev = &prev;
        let next = &next;
        let new_interesting_tiles = &new_interesting_tiles;

        // Handle each Z level in its own thread.
        let mut handles = Vec::<ScopedJoinHandle<()>>::new();
        let handle_results = &handle_results;
        for z in 0..prev.0.len() {
            handles.push(s.spawn(move || {
                assert!(thread_priority::ThreadPriority::Min
                    .set_for_current()
                    .is_ok());
                let result = tick_z_level(
                    buffers,
                    &prev.0[z],
                    &next.0[z],
                    z as i32,
                    &new_interesting_tiles,
                );
                let mut results = handle_results.write().unwrap();
                results.push(result);
            }));
        }
        for handle in handles {
            let _ = handle.join();
        }
        let readable_results = handle_results.read().unwrap();
        for index in 0..readable_results.len() {
            if readable_results[index].is_err() {
                result = Err(eyre::eyre!(
                    "MILLA worker thread failed: {:#?}",
                    readable_results[index].as_ref().err()
                ));
            }
        }
    });

    result?;

    buffers.flip();

    let mut interesting_tiles = INTERESTING_TILES.lock().unwrap();
    // drake_no: Last tick's interesting tiles.
    interesting_tiles.clear();
    // drake_yes: This tick's interesting tiles.
    interesting_tiles.extend(new_interesting_tiles);

    Ok(())
}

/// Runs a single tick of one Z level's atmospherics model.
pub(crate) fn tick_z_level(
    buffers: &Buffers,
    prev_atmos_lock: &RwLock<ZLevel>,
    next_atmos_lock: &RwLock<ZLevel>,
    z: i32,
    new_interesting_tiles: &Bag<InterestingTile>,
) -> eyre::Result<()> {
    let environments;
    {
        let global_environments = buffers.environments.read().unwrap();
        environments = global_environments.clone().into_boxed_slice();
    }
    let prev = prev_atmos_lock.read().unwrap();
    let mut next = next_atmos_lock.write().unwrap();

    // Initialize the new frame as a copy of the old one.
    next.copy_from(&prev);

    if !prev.frozen {
        simulate::find_walls(&mut next);
        simulate::update_wind(&prev, &mut next);
        simulate::flow_air(&prev, &mut next)?;
        simulate::post_process(&prev, &mut next, &environments, new_interesting_tiles, z)?;

        next.active_pressure_chunks.clear();
    }

    Ok(())
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;
    use crate::milla::constants::*;

    fn set_with_defaults<F>(legend: F) -> impl Fn(char) -> Tile
    where
        F: Fn(char) -> Option<Tile>,
    {
        move |c: char| {
            match legend(c) {
                Some(tile) => tile,
                None => {
                    match c {
                        // Sealed tile with simple air.
                        'X' => TileBuilder::sealed() //
                            .oxygen(100.0)
                            .thermal_energy(100.0)
                            .build(),
                        // Sealed vacuum.
                        '0' => TileBuilder::sealed().build(),
                        // Solid wall, non-superconducting.
                        '#' => TileBuilder::wall().build(),
                        // Space.
                        ' ' => TileBuilder::space().build(),
                        // ???
                        _ => {
                            assert!(false);
                            Tile::new()
                        }
                    }
                }
            }
        }
    }

    // Testing function for setting the initial state of the air in a region.
    fn set_pattern<F>(buffers: &Buffers, pattern: &[&str], legend: F, z: i32)
    where
        F: Fn(char) -> Tile,
    {
        let current = buffers.get_active().read().unwrap();
        let mut z_level = current.0[z as usize].write().unwrap();
        for inv_y in 0..pattern.len() {
            // Reverse the Y direction, so +Y is up, like in the game.
            let y = pattern.len() - inv_y - 1;
            for x in 0..pattern[inv_y].len() {
                z_level
                    .get_tile_mut(ZLevel::maybe_get_index(x as i32, y as i32).unwrap())
                    .copy_from(&legend(pattern[inv_y].chars().nth(x).unwrap()));
            }
        }
    }

    fn expect_with_defaults<F>(legend: F) -> impl Fn(char) -> TileChecker
    where
        F: Fn(char) -> Option<TileChecker>,
    {
        move |c: char| match legend(c) {
            Some(checker) => checker,
            None => match c {
                'X' => TileChecker::new() //
                    .oxygen(100.0)
                    .carbon_dioxide(0.0)
                    .nitrogen(0.0)
                    .toxins(0.0)
                    .sleeping_agent(0.0)
                    .agent_b(0.0)
                    .thermal_energy(100.0),
                '0' => TileChecker::new() //
                    .oxygen(0.0)
                    .carbon_dioxide(0.0)
                    .nitrogen(0.0)
                    .toxins(0.0)
                    .sleeping_agent(0.0)
                    .agent_b(0.0)
                    .thermal_energy(0.0),
                '#' => TileChecker::new(),
                ' ' => TileChecker::new(),
                _ => {
                    assert!(false);
                    TileChecker::new()
                }
            },
        }
    }

    // Testing function for cheking that the resulting air is what we expect.
    fn expect_pattern<F>(buffers: &Buffers, pattern: &[&str], legend: F, z: i32)
    where
        F: Fn(char) -> TileChecker,
    {
        let current = buffers.get_active().read().unwrap();
        let z_level = current.0[z as usize].read().unwrap();
        for inv_y in 0..pattern.len() {
            // Reverse the Y direction, so +Y is up, like in the game.
            let y = pattern.len() - inv_y - 1;
            for x in 0..pattern[inv_y].len() {
                let actual = z_level.get_tile(ZLevel::maybe_get_index(x as i32, y as i32).unwrap());
                let checker = legend(pattern[inv_y].chars().nth(x).unwrap());
                checker.check(actual, x as i32, y as i32);
            }
        }
    }

    struct TileBuilder(Tile);

    #[allow(dead_code)]
    impl TileBuilder {
        fn new(mode: AtmosMode) -> Self {
            let mut tile = Tile::new();
            tile.mode = mode;
            Self(tile)
        }
        fn space() -> Self {
            Self::new(AtmosMode::Space)
        }
        fn sealed() -> Self {
            Self::new(AtmosMode::Sealed)
        }
        fn exposed_to(environment_id: u8) -> Self {
            Self::new(AtmosMode::ExposedTo { environment_id })
        }
        fn wall() -> Self {
            let mut builder = Self::sealed();
            builder
                .0
                .airtight_directions
                .set(AirtightDirections::NORTH, true);
            builder
                .0
                .airtight_directions
                .set(AirtightDirections::EAST, true);
            builder
                .0
                .airtight_directions
                .set(AirtightDirections::SOUTH, true);
            builder
                .0
                .airtight_directions
                .set(AirtightDirections::WEST, true);
            builder
        }
        fn superconducts(mut self, value: f32) -> Self {
            self.0.superconductivity.north = value;
            self.0.superconductivity.east = value;
            self.0.superconductivity.south = value;
            self.0.superconductivity.west = value;
            self
        }
        fn oxygen(mut self, value: f32) -> Self {
            self.0.gases.set_oxygen(value);
            self
        }
        fn carbon_dioxide(mut self, value: f32) -> Self {
            self.0.gases.set_carbon_dioxide(value);
            self
        }
        fn nitrogen(mut self, value: f32) -> Self {
            self.0.gases.set_nitrogen(value);
            self
        }
        fn toxins(mut self, value: f32) -> Self {
            self.0.gases.set_toxins(value);
            self
        }
        fn sleeping_agent(mut self, value: f32) -> Self {
            self.0.gases.set_sleeping_agent(value);
            self
        }
        fn agent_b(mut self, value: f32) -> Self {
            self.0.gases.set_agent_b(value);
            self
        }
        fn thermal_energy(mut self, value: f32) -> Self {
            self.0.thermal_energy = value;
            self
        }
        fn innate_heat_capacity(mut self, value: f32) -> Self {
            self.0.innate_heat_capacity = value;
            self
        }
        fn temperature(mut self, value: f32) -> Self {
            self.0.thermal_energy = value * self.0.heat_capacity();
            self
        }
        fn build(self) -> Tile {
            self.0
        }
    }

    struct TileChecker {
        oxygen_: Option<f32>,
        carbon_dioxide_: Option<f32>,
        nitrogen_: Option<f32>,
        toxins_: Option<f32>,
        sleeping_agent_: Option<f32>,
        agent_b_: Option<f32>,
        thermal_energy_: Option<f32>,
        temperature_: Option<f32>,
    }

    impl TileChecker {
        fn new() -> Self {
            TileChecker {
                oxygen_: None,
                carbon_dioxide_: None,
                nitrogen_: None,
                toxins_: None,
                sleeping_agent_: None,
                agent_b_: None,
                thermal_energy_: None,
                temperature_: None,
            }
        }
        fn check(self, tile: &Tile, x: i32, y: i32) {
            if let Some(value) = self.oxygen_ {
                assert!(
                    (tile.gases.oxygen() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.oxygen(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.carbon_dioxide_ {
                assert!(
                    (tile.gases.carbon_dioxide() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.carbon_dioxide(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.nitrogen_ {
                assert!(
                    (tile.gases.nitrogen() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.nitrogen(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.toxins_ {
                assert!(
                    (tile.gases.toxins() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.toxins(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.sleeping_agent_ {
                assert!(
                    (tile.gases.sleeping_agent() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.sleeping_agent(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.agent_b_ {
                assert!(
                    (tile.gases.agent_b() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.gases.agent_b(),
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.thermal_energy_ {
                assert!(
                    (tile.thermal_energy - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.thermal_energy,
                    value,
                    x,
                    y
                );
            }
            if let Some(value) = self.temperature_ {
                assert!(
                    (tile.temperature() - value).abs() < TEST_TOLERANCE,
                    "{} != {} @ ({}, {})",
                    tile.temperature(),
                    value,
                    x,
                    y
                );
            }
        }
        fn oxygen(mut self, value: f32) -> Self {
            self.oxygen_ = Some(value);
            self
        }
        fn carbon_dioxide(mut self, value: f32) -> Self {
            self.carbon_dioxide_ = Some(value);
            self
        }
        fn nitrogen(mut self, value: f32) -> Self {
            self.nitrogen_ = Some(value);
            self
        }
        fn toxins(mut self, value: f32) -> Self {
            self.toxins_ = Some(value);
            self
        }
        fn sleeping_agent(mut self, value: f32) -> Self {
            self.sleeping_agent_ = Some(value);
            self
        }
        fn agent_b(mut self, value: f32) -> Self {
            self.agent_b_ = Some(value);
            self
        }
        fn thermal_energy(mut self, value: f32) -> Self {
            self.thermal_energy_ = Some(value);
            self
        }
        fn temperature(mut self, value: f32) -> Self {
            self.temperature_ = Some(value);
            self
        }
    }

    // The empty comments from here on out are to force rustfmt to preserve
    // line breaks, rather than compressing things into a single line.
    // This is especially important for the pattern, which should visually
    // look like a grid.
    //
    // rustfmt provides a #[rustfmt::skip] directive that we could use,
    // unfortunately, the compiler won't let it be applied in the middle of
    // the code right now. It formats right, it just won't compile.

    // TODO
}
