extends GutTest

# Issue #19: the five pink panda pose pictures are cut out from raw renders
# with a shared crop box, so the panda's body shows at the same size in
# every pose.

const POSE_PATHS := [
	"res://assets/panda/pink/run_1.png",
	"res://assets/panda/pink/run_2.png",
	"res://assets/panda/pink/jump_takeoff.png",
	"res://assets/panda/pink/jump_air.png",
	"res://assets/panda/pink/hurt.png",
]


func test_every_pose_picture_loads():
	for path in POSE_PATHS:
		assert_not_null(load(path), "%s loads as a texture" % path)


func test_every_pose_picture_has_transparency():
	for path in POSE_PATHS:
		var texture: Texture2D = load(path)
		var image := texture.get_image()
		assert_ne(image.detect_alpha(), Image.ALPHA_NONE, "%s has an alpha channel" % path)


func test_every_pose_picture_has_transparent_corners():
	for path in POSE_PATHS:
		var texture: Texture2D = load(path)
		var image := texture.get_image()
		var w := image.get_width()
		var h := image.get_height()
		for corner in [Vector2i(0, 0), Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]:
			var pixel := image.get_pixel(corner.x, corner.y)
			assert_lt(pixel.a, 0.1, "%s corner %s is transparent" % [path, corner])


func test_every_pose_picture_shares_one_size():
	var first_texture: Texture2D = load(POSE_PATHS[0])
	var first_size := first_texture.get_image().get_size()
	assert_eq(first_size.y, 512, "first pose picture has height 512")
	for path in POSE_PATHS:
		var texture: Texture2D = load(path)
		var size := texture.get_image().get_size()
		assert_eq(size, first_size, "%s shares the same size as the first pose picture" % path)
