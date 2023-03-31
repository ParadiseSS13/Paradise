/datum/unit_test/rustg_version/Run()
	var/library_version = rustg_get_version()
	if(library_version != RUST_G_VERSION)
		Fail("Invalid RUSTG Version. Library is [library_version], but in-code API is [RUST_G_VERSION]")
