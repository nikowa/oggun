#+feature using-stmt
package willow
// import "base:runtime"
// import "core:fmt"
// import "core:strings"
// import "vendor:miniaudio"
// import sdl "vendor:sdl2"
// import mix "vendor:sdl2/mixer"


// Audio :: struct {
// 	sounds:                  [dynamic]Sound,
// 	sounds_map:              map[string]^Sound,
// 	ma_rm:                   miniaudio.resource_manager,
// 	ma_res:                  miniaudio.result,
// 	ma_rm_conf:              miniaudio.resource_manager_config,
// 	ma_ctx:                  miniaudio.context_type,
// 	ma_dev_infos:            [^]miniaudio.device_info,
// 	ma_dev_count:            u32,
// 	ma_devs:                 [16]miniaudio.device,
// 	ma_dev_confs:            [^]miniaudio.device_config,
// 	ma_engs:                 [16]miniaudio.engine,
// 	ma_audio_engine:         ^miniaudio.engine,
// 	ma_eng_confs:            [^]miniaudio.engine_config,
// 	ma_default_device_index: int }


// Sound :: struct {
// 	filepath:   string,
// 	cfilepath:  cstring,
// 	loop:       bool,
// 	start_time: f32,
// 	duration:   f32,
// 	name:       string,
// 	source:     cstring,
// 	sound:      miniaudio.sound }


// audio_init :: proc(audio: ^Audio) {
// 	audio.sounds = make_dynamic_array_len_cap([dynamic]Sound, len=0, cap=32)
// 	audio.sounds_map = make(map[string]^Sound)
// 	audio.ma_rm_conf = miniaudio.resource_manager_config_init()
// 	audio.ma_rm_conf.decodedFormat = miniaudio.format.f32
// 	audio.ma_rm_conf.decodedChannels = 0
// 	audio.ma_rm_conf.decodedSampleRate = 48000
// 	audio.ma_res = miniaudio.resource_manager_init(&audio.ma_rm_conf, &audio.ma_rm)
// 	if audio.ma_res != miniaudio.result.SUCCESS { return }
// 	audio.ma_res = miniaudio.context_init(nil, 0, nil, &audio.ma_ctx)
// 	if audio.ma_res != miniaudio.result.SUCCESS { return }
// 	audio.ma_res = miniaudio.context_get_devices(&audio.ma_ctx, &audio.ma_dev_infos, &audio.ma_dev_count, nil, nil)
// 	if audio.ma_res != miniaudio.result.SUCCESS { miniaudio.context_uninit(&audio.ma_ctx); return }
// 	audio.ma_dev_confs = make([^]miniaudio.device_config, audio.ma_dev_count)
// 	audio.ma_eng_confs = make([^]miniaudio.engine_config, audio.ma_dev_count)
// 	audio.ma_default_device_index = -1
// 	for i in 0 ..< audio.ma_dev_count {
// 		audio.ma_dev_confs[i] = miniaudio.device_config_init(miniaudio.device_type.playback)
// 		audio.ma_dev_confs[i].playback.pDeviceID = &audio.ma_dev_infos[i].id
// 		audio.ma_dev_confs[i].playback.format = audio.ma_rm.config.decodedFormat
// 		audio.ma_dev_confs[i].playback.channels = 0
// 		audio.ma_dev_confs[i].sampleRate = audio.ma_rm.config.decodedSampleRate
// 		audio.ma_dev_confs[i].dataCallback = miniaudio.device_data_proc(audio_data_callback)
// 		audio.ma_dev_confs[i].pUserData = &audio.ma_engs[i]
// 		audio.ma_res = miniaudio.device_init(nil, &audio.ma_dev_confs[i], &audio.ma_devs[i])
// 		if audio.ma_res != miniaudio.result.SUCCESS { return }
// 		dev_info: miniaudio.device_info
// 		miniaudio.device_get_info(&audio.ma_devs[i], miniaudio.device_type.playback, &dev_info)
// 		if dev_info.isDefault { audio.ma_default_device_index = int(i) }
// 		audio.ma_eng_confs[i] = miniaudio.engine_config_init()
// 		audio.ma_eng_confs[i].pDevice = &audio.ma_devs[i]
// 		audio.ma_eng_confs[i].pResourceManager = &audio.ma_rm
// 		audio.ma_eng_confs[i].noAutoStart = true
// 		audio.ma_res = miniaudio.engine_begin_init(&audio.ma_eng_confs[i], &audio.ma_engs[i])
// 		if audio.ma_res != miniaudio.result.SUCCESS { miniaudio.device_uninit(&audio.ma_devs[i]); return } }
// 	for i in 0 ..< audio.ma_dev_count {
// 		audio.ma_res = miniaudio.engine_start(&audio.ma_engs[i])
// 		if audio.ma_res != miniaudio.result.SUCCESS { return } }
// 	if audio.ma_default_device_index != -1 {
// 		audio.ma_audio_engine = &audio.ma_engs[audio.ma_default_device_index]
// 		miniaudio.device_set_master_volume(&audio.ma_devs[audio.ma_default_device_index], 1.0) }
// 	else {
// 		audio.ma_audio_engine = &audio.ma_engs[0] }
// 	load_sound(audio, "./sounds/music.wav", 10)
// }
// 	// play_sound("music",loop=true) }


// load_sound :: proc(audio: ^Audio, filepath: string, duration: f32 = -1) -> (ptr: ^Sound) {
// 	sound:Sound
// 	sound.name = name_from_path(filepath)
// 	sound.filepath = strings.clone(filepath)
// 	sound.cfilepath = strings.clone_to_cstring(filepath)
// 	sound.duration = duration
// 	// miniaudio.sound_init_from_file(pEngine=audio.ma_audio_engine,pFilePath=strings.clone_to_cstring(filepath),flags={},pGroup=nil,pDoneFence=nil,pSound=&sound.sound)
// 	append(&audio.sounds, sound)
// 	ptr = &audio.sounds[len(audio.sounds) - 1]
// 	audio.sounds_map[sound.name] = ptr
// 	return ptr }


// audio_data_callback :: proc(dev: ^miniaudio.device, output, input: rawptr, frame_count: u32) {
// 	miniaudio.engine_read_pcm_frames((^miniaudio.engine)(dev.pUserData), output, u64(frame_count), nil) }


// play_sound :: proc(audio: ^Audio, net_time: f32, name: string, loop: bool = false) {
// 	sound, ok := audio.sounds_map[name]
// 	assert(ok)
// 	sound.start_time = net_time
// 	sound.loop = loop
// 	miniaudio.engine_play_sound(audio.ma_audio_engine, sound.cfilepath, nil) }


// set_audio_volume :: proc(audio: ^Audio, volume: f16) {
// 	miniaudio.device_set_master_volume(&audio.ma_devs[audio.ma_default_device_index], f32(volume)) }


// watch_sound :: proc(audio: ^Audio, net_time:f32, name : string) {
// 	sound := audio.sounds_map[name]
// 	if sound.loop do if (net_time - sound.start_time) >= sound.duration do play_sound(audio, net_time, name, sound.loop) }


// Audio_Tick_Data :: struct {
// 	audio: ^Locked_Struct(Audio),
// 	clock: ^Locked_Struct(Clock) }
// audio_tick_filters: Thread_Filters : { }
// @(tag="job") audio_tick :: proc(data_ptr: rawptr) {
// 	fmt.println("Audio Tick")
// 	data := cast(^Audio_Tick_Data)data_ptr
// 	defer free(data)
// 	using data
// 	lock_guard(&audio.lock)
// 	lock_guard(&clock.lock)
// 	watch_sound(audio, clock.net_time, "music") }