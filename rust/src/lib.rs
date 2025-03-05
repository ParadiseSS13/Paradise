mod logging;
mod mapmanip;
mod milla;

#[cfg(all(not(feature = "byond-515"), not(feature = "byond-516")))]
compile_error!("Please specify b515 or b515 as a feature to specify BYOND version.");

#[cfg(all(feature = "byond-515", feature = "byond-516"))]
compile_error!(
    "Please specify ONLY b515 or b515 as a feature to specify BYOND version, not all features."
);
