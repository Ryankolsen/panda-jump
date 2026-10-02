extends GutTest

# Bamboo was hard to spot against the bamboo-forest background, so its
# picture bobs gently to read as a pickup. The bob moves only the picture,
# never the hitbox, and stays within BOB_HEIGHT of rest.


func test_bob_offset_starts_at_rest():
	assert_almost_eq(Bamboo.bob_offset(0.0), 0.0, 0.0001)


func test_bob_offset_stays_within_bob_height():
	for i in 200:
		var offset := Bamboo.bob_offset(i * 0.037)
		assert_lte(absf(offset), Bamboo.BOB_HEIGHT + 0.0001, "bob at t=%f" % (i * 0.037))


func test_bob_offset_reaches_bob_height():
	assert_almost_eq(Bamboo.bob_offset(Bamboo.BOB_PERIOD / 4.0), -Bamboo.BOB_HEIGHT, 0.0001)


func test_bob_moves_picture_not_hitbox():
	var bamboo: Bamboo = autofree(preload("res://scenes/pickups/bamboo.tscn").instantiate())
	add_child(bamboo)
	var hitbox_y: float = bamboo.get_node("CollisionShape2D").position.y
	bamboo.get_node("Visual").position.y = 0.0
	bamboo._process(Bamboo.BOB_PERIOD / 4.0)
	assert_almost_eq(bamboo.get_node("Visual").position.y, -Bamboo.BOB_HEIGHT, 0.0001)
	assert_eq(bamboo.get_node("CollisionShape2D").position.y, hitbox_y)
