extends GutTest

# Issue #20: PandaSkin picks a picture per pose and falls back to run_1, the
# base everything falls back to, when the specific pose's picture is missing.

func _make_texture() -> Texture2D:
	return ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))


func test_every_pose_falls_back_to_run_1_when_only_run_1_is_set():
	var skin := PandaSkin.new()
	skin.run_1 = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_1), skin.run_1, "RUN_1 returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_1, "RUN_2 falls back to run_1")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_TAKEOFF), skin.run_1, "JUMP_TAKEOFF falls back to run_1")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.run_1, "JUMP_AIR falls back to run_1")
	assert_eq(skin.texture_for(PandaSkin.Pose.HURT), skin.run_1, "HURT falls back to run_1")


func test_every_pose_returns_its_own_texture_when_all_are_set():
	var skin := PandaSkin.new()
	skin.run_1 = _make_texture()
	skin.run_2 = _make_texture()
	skin.jump_takeoff = _make_texture()
	skin.jump_air = _make_texture()
	skin.hurt = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_1), skin.run_1, "RUN_1 returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_2, "RUN_2 returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_TAKEOFF), skin.jump_takeoff, "JUMP_TAKEOFF returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.jump_air, "JUMP_AIR returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.HURT), skin.hurt, "HURT returns its own texture")


func test_run_2_falls_back_to_run_1():
	var skin := PandaSkin.new()
	skin.run_1 = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_1, "RUN_2 falls back to run_1")
	skin.run_2 = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_2, "RUN_2 returns its own texture once set")


func test_jump_air_falls_back_to_jump_takeoff_before_run_1():
	var skin := PandaSkin.new()
	skin.run_1 = _make_texture()
	skin.jump_takeoff = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.jump_takeoff, "JUMP_AIR falls back to jump_takeoff before run_1")


func test_pink_skin_resource_has_every_pose():
	var skin: PandaSkin = load("res://resources/panda/pink_skin.tres")
	assert_not_null(skin.run_1, "pink_skin.tres sets run_1")
	assert_not_null(skin.run_2, "pink_skin.tres sets run_2")
	assert_not_null(skin.jump_takeoff, "pink_skin.tres sets jump_takeoff")
	assert_not_null(skin.jump_air, "pink_skin.tres sets jump_air")
	assert_not_null(skin.hurt, "pink_skin.tres sets hurt")
	assert_ne(skin.run_1, skin.run_2, "run_1 and run_2 are distinct")
	assert_ne(skin.run_1, skin.jump_takeoff, "run_1 and jump_takeoff are distinct")
	assert_ne(skin.run_1, skin.jump_air, "run_1 and jump_air are distinct")
	assert_ne(skin.run_1, skin.hurt, "run_1 and hurt are distinct")
	assert_ne(skin.run_2, skin.jump_takeoff, "run_2 and jump_takeoff are distinct")
	assert_ne(skin.run_2, skin.jump_air, "run_2 and jump_air are distinct")
	assert_ne(skin.run_2, skin.hurt, "run_2 and hurt are distinct")
	assert_ne(skin.jump_takeoff, skin.jump_air, "jump_takeoff and jump_air are distinct")
	assert_ne(skin.jump_takeoff, skin.hurt, "jump_takeoff and hurt are distinct")
	assert_ne(skin.jump_air, skin.hurt, "jump_air and hurt are distinct")


func test_texture_for_returns_null_when_nothing_is_set():
	var skin := PandaSkin.new()
	assert_null(skin.texture_for(PandaSkin.Pose.RUN_1), "RUN_1 is null when unset")
	assert_null(skin.texture_for(PandaSkin.Pose.RUN_2), "RUN_2 is null when unset")
	assert_null(skin.texture_for(PandaSkin.Pose.JUMP_TAKEOFF), "JUMP_TAKEOFF is null when unset")
	assert_null(skin.texture_for(PandaSkin.Pose.JUMP_AIR), "JUMP_AIR is null when unset")
	assert_null(skin.texture_for(PandaSkin.Pose.HURT), "HURT is null when unset")
