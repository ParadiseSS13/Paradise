/hook/startup/proc/discordNotify()
    if (config.use_discord_bot && config.discord_host && config.discord_port)
        world.Export("http://[config.discord_host]:[config.discord_port]/?command=startup&name=[station_name()]&connect=[config.server?"[config.server]":"[world.address]:[world.port]"]")
    return 1

/hook/roundend/proc/discordNotify()
    if (config.use_discord_bot && config.discord_host && config.discord_port)
        world.Export("http://[config.discord_host]:[config.discord_port]/?command=roundend")
    return 1