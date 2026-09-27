extends GutTest

# Issue #5: PandaSkin picks a picture per pose and falls back to a simpler
# pose when the specific one is missing, so a skin with only `standing` set
# (the only drawing so far) still resolves every pose to something drawable.

func _make_texture() -> Texture2D:
	return ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))


func test_texture_for_returns_the_set_pose():
	var skin := PandaSkin.new()
	skin.standing = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.STANDING), skin.standing, "STANDING returns its own texture")


func test_texture_for_falls_back_to_standing_when_only_standing_is_set():
	var skin := PandaSkin.new()
	skin.standing = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_1), skin.standing, "RUN_1 falls back to standing")
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.standing, "RUN_2 falls back to standing")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_TAKEOFF), skin.standing, "JUMP_TAKEOFF falls back to standing")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.standing, "JUMP_AIR falls back to standing")
	assert_eq(skin.texture_for(PandaSkin.Pose.HURT), skin.standing, "HURT falls back to standing")


func test_run_2_falls_back_to_run_1_when_set():
	var skin := PandaSkin.new()
	skin.standing = _make_texture()
	skin.run_1 = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_1, "RUN_2 falls back to run_1 before standing")


func test_jump_air_falls_back_to_jump_takeoff_when_set():
	var skin := PandaSkin.new()
	skin.standing = _make_texture()
	skin.jump_takeoff = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.jump_takeoff, "JUMP_AIR falls back to jump_takeoff before standing")


func test_every_pose_returns_its_own_texture_when_all_are_set():
	var skin := PandaSkin.new()
	skin.standing = _make_texture()
	skin.run_1 = _make_texture()
	skin.run_2 = _make_texture()
	skin.jump_takeoff = _make_texture()
	skin.jump_air = _make_texture()
	skin.hurt = _make_texture()
	assert_eq(skin.texture_for(PandaSkin.Pose.STANDING), skin.standing, "STANDING returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_1), skin.run_1, "RUN_1 returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.RUN_2), skin.run_2, "RUN_2 returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_TAKEOFF), skin.jump_takeoff, "JUMP_TAKEOFF returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.JUMP_AIR), skin.jump_air, "JUMP_AIR returns its own texture")
	assert_eq(skin.texture_for(PandaSkin.Pose.HURT), skin.hurt, "HURT returns its own texture")


func test_pink_skin_resource_has_a_standing_texture():
	var skin: PandaSkin = load("res://resources/panda/pink_skin.tres")
	assert_not_null(skin.texture_for(PandaSkin.Pose.STANDING), "pink_skin.tres resolves a standing texture")
