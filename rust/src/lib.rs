mod logging;
mod mapmanip;
mod milla;
mod redis_pubsub;

#[cfg(all(not(feature = "byond-515"), not(feature = "byond-516")))]
compile_error!("Please specify byond-515 or byond-516 as a feature to specify BYOND version.");

#[cfg(all(feature = "byond-515", feature = "byond-516"))]
compile_error!(
    "Please specify ONLY byond-515 or bypnd-516 as a feature to specify BYOND version, not all features."
);
