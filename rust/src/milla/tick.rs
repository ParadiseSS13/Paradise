use crate::milla::constants::*;
use crate::milla::model::*;
use crate::milla::simulate;
use crate::milla::statics::*;
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
    let active = buffers.get_active().read().unwrap();
    let inactive = buffers.get_inactive().read().unwrap();

    let new_interesting_tiles: Bag<InterestingTile> = Bag::default();
    let mut result: Result<(), eyre::Error> = Ok(());

    // The scope tells Rust that all the threads we create here will end by the time the scope
    // closes. This allows us to pass things into them that are only borrowed for the lifetime of
    // this function.
    thread::scope(|s| {
        // Force most things to be captured by reference, despite the `move`
        // in the thread spawn, which is really just for `z`.
        let active = &active;
        let inactive = &inactive;
        let new_interesting_tiles = &new_interesting_tiles;

        // Handle each Z level in its own thread.
        let mut handles = Vec::<ScopedJoinHandle<()>>::new();
        for z in 0..active.0.len() {
            handles.push(s.spawn(move || {
                assert!(thread_priority::ThreadPriority::Min
                    .set_for_current()
                    .is_ok());
                tick_z_level(
                    buffers,
                    &active.0[z],
                    &inactive.0[z],
                    z as i32,
                    &new_interesting_tiles,
                )
                .unwrap();
            }));
        }
        for handle in handles {
            if let Err(e) = handle.join() {
                result = Err(eyre::eyre!("Worker thread failed: {:#?}", e));
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
    active_atmos_lock: &RwLock<ZLevel>,
    inactive_atmos_lock: &RwLock<ZLevel>,
    z: i32,
    new_interesting_tiles: &Bag<InterestingTile>,
) -> Result<(), eyre::Error> {
    let environments;
    {
        let global_environments = buffers.environments.read().unwrap();
        environments = global_environments.clone().into_boxed_slice();
    }
    let active = active_atmos_lock.read().unwrap();
    let mut inactive = inactive_atmos_lock.write().unwrap();
    // Initialize the new frame as a copy of the old one.
    inactive.copy_from(&active);
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;
        let my_tile = active.get_tile(my_index);
        let my_connected_dirs = simulate::count_connected_dirs(&active, my_index, x, y)?;

        // Handle gas and heat exchange with neighbors.
        for (dx, dy) in AXES {
            let maybe_their_index = ZLevel::maybe_get_index(x + dx, y + dy);
            let their_index;
            match maybe_their_index {
                Some(index) => their_index = index,
                None => continue,
            }

            let their_tile = active.get_tile(their_index);
            if let AtmosMode::Space = my_tile.mode {
                if let AtmosMode::Space = their_tile.mode {
                    // Exchange what, exactly?
                    continue;
                }
            }
            let their_connected_dirs =
                simulate::count_connected_dirs(&active, their_index, x + dx, y + dy)?;

            let (my_inactive_tile, their_inactive_tile) =
                inactive.get_pair_mut(my_index, their_index);

            // Bail if we shouldn't share air this way, but still run superconductivity.
            if dx > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::EAST)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::WEST))
            {
                simulate::superconduct(my_inactive_tile, their_inactive_tile, true);
                continue;
            }
            if dy > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::NORTH)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::SOUTH))
            {
                simulate::superconduct(my_inactive_tile, their_inactive_tile, false);
                continue;
            }

            // Calculate the amount of air and thermal energy transferred.
            let (gas_change, thermal_energy_change) =
                simulate::share_air(my_tile, their_tile, my_connected_dirs, their_connected_dirs);

            // Transfer it.
            for i in 0..GAS_COUNT {
                if gas_change.values[i] != 0.0 {
                    my_inactive_tile.gases.values[i] += gas_change.values[i];
                    my_inactive_tile.gases.set_dirty();
                    their_inactive_tile.gases.values[i] -= gas_change.values[i];
                    their_inactive_tile.gases.set_dirty();
                }
            }
            my_inactive_tile.thermal_energy += thermal_energy_change;
            their_inactive_tile.thermal_energy -= thermal_energy_change;

            // Run superconductivity.
            simulate::superconduct(my_inactive_tile, their_inactive_tile, dx > 0);
        }

        let my_inactive_tile = inactive.get_tile_mut(my_index);
        simulate::apply_tile_mode(my_tile, my_inactive_tile, &environments)?;

        if let AtmosMode::Space = my_tile.mode {
            // Space has no reactions, doesn't need to be sanitized, and is never interesting.
            continue;
        }

        // Track how much "fuel" was burnt across all reactions.
        let fuel_burnt = simulate::react(my_inactive_tile);

        // Sanitize the tile, to avoid negative/NaN/infinity spread.
        simulate::sanitize(my_inactive_tile, my_tile);

        simulate::check_interesting(
            x,
            y,
            z,
            &active,
            &environments,
            my_tile,
            my_inactive_tile,
            fuel_burnt,
            new_interesting_tiles,
        )?;
    }

    Ok(())
}

// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;

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
        let active = buffers.get_active().read().unwrap();
        let mut z_level = active.0[z as usize].write().unwrap();
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
        let active = buffers.get_active().read().unwrap();
        let z_level = active.0[z as usize].read().unwrap();
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

    // Air should split evenly to surrounding vacuum tiles.
    #[test]
    fn tick_splits_air() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "#######", //
                "#     #", //
                "#  0  #", //
                "# 0X0 #", //
                "#  0  #", //
                "#     #", //
                "#######", //
            ],
            set_with_defaults(|_c: char| None),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "#######", //
                "#     #", //
                "#  x  #", //
                "# xxx #", //
                "#  x  #", //
                "#     #", //
                "#######", //
            ],
            expect_with_defaults(|c: char| match c {
                'x' => Some(
                    TileChecker::new() //
                        .oxygen(20.0)
                        .thermal_energy(20.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Air should not flow into walls.
    #[test]
    fn tick_respects_walls() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            set_with_defaults(|_c: char| None),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "#0#", //
                "0X0", //
                "#0#", //
            ],
            expect_with_defaults(|_c: char| None),
            0,
        );
    }

    // Air should flow properly into dead-end tiles.
    #[test]
    fn tick_handles_different_connections() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "#####", //
                "##0##", //
                "#0X0#", //
                "##0##", //
                "#####", //
            ],
            set_with_defaults(|_c: char| None),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "#####", //
                "##x##", //
                "#xxx#", //
                "##x##", //
                "#####", //
            ],
            expect_with_defaults(|c: char| match c {
                'x' => Some(
                    TileChecker::new() //
                        .oxygen(20.0)
                        .thermal_energy(20.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Four equal dead-end tiles around a vacuum should distribute air evenly between all 5 tiles.
    // Temp: Or not, because we're matching MILLA behavior.
    #[test]
    fn tick_merges_properly() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "#####", //
                "##X##", //
                "#X0X#", //
                "##X##", //
                "#####", //
            ],
            set_with_defaults(|_c: char| None),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "#####", //
                "##x##", //
                "#x!x#", //
                "##x##", //
                "#####", //
            ],
            expect_with_defaults(|c: char| match c {
                '!' => Some(
                    TileChecker::new() //
                        .oxygen(200.0)
                        .thermal_energy(200.0),
                ),
                'x' => Some(
                    TileChecker::new() //
                        .oxygen(50.0)
                        .thermal_energy(50.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Energy should be transferred into superconducting walls.
    #[test]
    fn tick_superconducts_into_walls() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "######", //
                "##XS##", //
                "#S##X#", //
                "#X##S#", //
                "##SX##", //
                "######", //
            ],
            set_with_defaults(|c: char| match c {
                'S' => Some(
                    TileBuilder::wall() //
                        .superconducts(OPEN_HEAT_TRANSFER_COEFFICIENT)
                        .innate_heat_capacity(2000.0)
                        .build(),
                ),
                _ => None,
            }),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "######", //
                "##xS##", //
                "#S##x#", //
                "#x##S#", //
                "##Sx##", //
                "######", //
            ],
            expect_with_defaults(|c: char| match c {
                'x' => Some(
                    TileChecker::new() //
                        .oxygen(100.0)
                        // This value is arbitrary, it's just what we get right now.
                        // Update it if the calculations changed intentionally.
                        .thermal_energy(80.0),
                ),
                'S' => Some(
                    TileChecker::new() //
                        // This value is arbitrary, it's just what we get right now.
                        // Update it if the calculations changed intentionally.
                        .thermal_energy(20.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Air should flow into a space tile, and be deleted.
    #[test]
    fn tick_empties_space() {
        let buffers = Buffers::new();
        buffers.init_to(0);

        set_pattern(
            &buffers,
            &[
                "#####", //
                "##X##", //
                "#X X#", //
                "##X##", //
                "#####", //
            ],
            set_with_defaults(|c: char| match c {
                'x' => Some(
                    TileBuilder::sealed() //
                        .oxygen(100.0)
                        .thermal_energy(100.0)
                        .build(),
                ),
                _ => None,
            }),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "#####", //
                "##x##", //
                "#x0x#", //
                "##x##", //
                "#####", //
            ],
            expect_with_defaults(|c: char| match c {
                'x' => Some(
                    TileChecker::new() //
                        .oxygen(50.0)
                        .thermal_energy(50.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Air should tend towards the environment's temperature, if any.
    #[test]
    fn tick_affected_by_environment_temperature() {
        let buffers = Buffers::new();
        buffers.init_to(0);
        let lavaland = buffers.create_environment(
            TileBuilder::sealed() //
                .oxygen(8.0)
                .nitrogen(14.0)
                .temperature(500.0)
                .build(),
        );

        set_pattern(
            &buffers,
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            set_with_defaults(|c: char| match c {
                'X' => Some(
                    TileBuilder::exposed_to(lavaland)
                        .oxygen(8.0)
                        .nitrogen(14.0)
                        .thermal_energy(0.0)
                        .build(),
                ),
                _ => None,
            }),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "###", //
                "#Y#", //
                "###", //
            ],
            expect_with_defaults(|c: char| match c {
                'Y' => Some(
                    TileChecker::new() //
                        .oxygen(8.0)
                        .nitrogen(14.0)
                        // This value is arbitrary, it's just what we get right now.
                        // Update it if the calculations changed intentionally.
                        .thermal_energy(44_000.0),
                ),
                _ => None,
            }),
            0,
        );
    }

    // Air should exchange with the tile's environment, if any.
    #[test]
    fn tick_affected_by_environment() {
        let buffers = Buffers::new();
        buffers.init_to(0);
        let lavaland = buffers.create_environment(
            TileBuilder::sealed() //
                .oxygen(8.0)
                .nitrogen(14.0)
                .temperature(500.0)
                .build(),
        );

        set_pattern(
            &buffers,
            &[
                "###", //
                "#X#", //
                "###", //
            ],
            set_with_defaults(|c: char| match c {
                'X' => Some(TileBuilder::exposed_to(lavaland).build()),
                _ => None,
            }),
            0,
        );

        tick(&buffers).unwrap();

        expect_pattern(
            &buffers,
            &[
                "###", //
                "#Y#", //
                "###", //
            ],
            expect_with_defaults(|c: char| match c {
                'Y' => Some(
                    TileChecker::new() //
                        .oxygen(4.0)
                        .nitrogen(7.0)
                        .temperature(500.0),
                ),
                _ => None,
            }),
            0,
        );
    }
}
