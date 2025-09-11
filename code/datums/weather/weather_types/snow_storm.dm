/datum/weather/snow_storm
	name = "снежная буря"
	desc = "Суровые снежные бури бушуют на поверхности этой арктической планеты, погребая под собой всё, что окажется на их пути."
//	probability = 90

	telegraph_message = "<span class='warning'>Дрейфующие снежинки начинают выпадать на окружающую местность...</span>"
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>В воздухе поднимается сильный ветер, а с неба начинает падать густой снег! Ищите укрытие!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600

	end_duration = 100
	end_message = "<span class='boldannounceic'>Снежная буря прекратилась, теперь снова можно безопасно выходить наружу.</span>"

//	area_type = /area/awaymission/snowdin/outside
	target_trait = AWAY_LEVEL

	immunity_type = "snow"

	barometer_predictable = TRUE


/datum/weather/snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(5, 15))

