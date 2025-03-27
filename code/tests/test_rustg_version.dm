/datum/game_test/rustg_version/Run()
	var/library_version = rustg_get_version()
	TEST_ASSERT_EQUAL(library_version, RUST_G_VERSION, "invalid RUSTG Version")
