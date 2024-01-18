extends Node


const BGM_SETTING = "user_settings/audio/bgm_level"
const SFX_SETTING = "user_settings/audio/sfx_level"


# Get player settings for audio bus levels and set volume levels accordingly
func set_audio_busses():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"),\
								ProjectSettings.get_setting(BGM_SETTING))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"),\
								ProjectSettings.get_setting(SFX_SETTING))
