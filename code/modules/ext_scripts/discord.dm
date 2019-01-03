/hook/startup/proc/discordNotify()
    world << "trigger discordNotify()"
    if (config.use_discord_bot && config.discord_host && config.discord_port)
        world << "http://[config.discord_host]:[config.discord_port]/?command=startup&name=[station_name()]&connect=[world.address]:[world.port]"
        world.Export("http://[config.discord_host]:[config.discord_port]/?command=startup&name=[station_name()]&connect=[world.address]:[world.port]")
    return 1