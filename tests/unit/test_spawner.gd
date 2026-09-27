extends GutTest

# Issue #7: Spawner rolls in barrels with gaps a normal jump can always
# clear. Seeded by the caller so tests (and replays) are reproducible.
#
# Issue #11: Spawner also mixes bamboo into those gaps (ground or floating)
# without ever making a ground bamboo force the panda into a barrel.

func _spawner(seed: int) -> Spawner:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return Spawner.new(Tuning.new(), rng)


## Runs `next()` `count` times at `speed`, returning each result as
## { "kind": Spawner.Kind, "position": float }, position being the running
## sum of offsets from the start (i.e. an absolute spawn position).
func _run(seed: int, speed: float, count: int) -> Array:
	var spawner := _spawner(seed)
	var position := 0.0
	var results := []
	for i in range(count):
		var result: Dictionary = spawner.next(speed)
		position += result.offset
		results.append({ "kind": result.kind, "position": position })
	return results


## Position of the nearest BARREL in `results` from `from_index`, searching
## in `direction` (-1 or 1). Returns null if there isn't one (e.g. the very
## first spawn has no barrel before it).
func _find_barrel(results: Array, from_index: int, direction: int):
	var i: int = from_index + direction
	while i >= 0 and i < results.size():
		if results[i].kind == Spawner.Kind.BARREL:
			return results[i].position
		i += direction
	return null


func _assert_ground_bamboo_keeps_clearance(results: Array, speed: float) -> void:
	var clearance: float = speed * Tuning.new().bamboo_clearance_time
	for i in range(results.size()):
		if results[i].kind == Spawner.Kind.BAMBOO_GROUND:
			var prev = _find_barrel(results, i, -1)
			var next = _find_barrel(results, i, 1)
			if prev != null:
				assert_gte(results[i].position - prev, clearance - 0.01, "ground bamboo %d clears the barrel before it" % i)
			if next != null:
				assert_gte(next - results[i].position, clearance - 0.01, "ground bamboo %d clears the barrel after it" % i)


func test_next_returns_a_barrel_kind():
	# Adapted for #11: bamboo can now be inserted before the first barrel,
	# so the very first next() call is no longer guaranteed to be a barrel.
	# What's still guaranteed is that a barrel shows up within the first
	# gap (at most one bamboo, then the barrel).
	var spawner := _spawner(1)
	var found_barrel := false
	for i in range(2):
		var result: Dictionary = spawner.next(140.0)
		if result.kind == Spawner.Kind.BARREL:
			found_barrel = true
	assert_true(found_barrel, "a barrel appears within the first gap")


func test_min_barrel_gap_matches_air_time_plus_landing_time():
	var spawner := _spawner(1)
	var expected := 140.0 * (2.0 * 520.0 / 1400.0 + 0.45)
	assert_almost_eq(spawner.min_barrel_gap(140.0), expected, 0.1, "min gap comes from air time + landing time")


func test_barrel_to_barrel_distance_stays_within_the_fair_gap_window():
	# Adapted for #11: individual next() offsets can now be shorter than
	# min_barrel_gap (a bamboo offset partway through a gap), so the fair
	# window is checked on barrel-to-barrel distance, ignoring any bamboo
	# spawned in between, rather than on every single offset.
	var speed := 140.0
	var results := _run(1, speed, 1000)
	var min_gap: float = _spawner(1).min_barrel_gap(speed)
	var max_gap := min_gap + 220.0
	var last_barrel_position := 0.0
	var have_last := false
	for r in results:
		if r.kind == Spawner.Kind.BARREL:
			if have_last:
				var dist: float = r.position - last_barrel_position
				assert_gte(dist, min_gap - 0.01, "barrel-to-barrel distance is at least the fair minimum")
				assert_lte(dist, max_gap + 0.01, "barrel-to-barrel distance is at most min + barrel_gap_extra")
			last_barrel_position = r.position
			have_last = true


func test_same_seed_produces_the_same_sequence():
	var a := _spawner(42)
	var b := _spawner(42)
	for i in range(50):
		assert_eq(a.next(140.0), b.next(140.0), "seed 42 reproduces the same result at step %d" % i)


func test_different_seed_produces_a_different_sequence():
	var a := _spawner(42)
	var b := _spawner(43)
	var differs := false
	for i in range(50):
		var result_a: Dictionary = a.next(140.0)
		var result_b: Dictionary = b.next(140.0)
		if result_a.offset != result_b.offset:
			differs = true
	assert_true(differs, "seed 43 diverges from seed 42 somewhere in 50 results")


func test_barrel_to_barrel_distance_stays_fair_at_a_higher_speed():
	# Adapted for #11: see test_barrel_to_barrel_distance_stays_within_the_fair_gap_window.
	var speed := 300.0
	var results := _run(1, speed, 1000)
	var min_gap: float = _spawner(1).min_barrel_gap(speed)
	var last_barrel_position := 0.0
	var have_last := false
	for r in results:
		if r.kind == Spawner.Kind.BARREL:
			if have_last:
				assert_gte(r.position - last_barrel_position, min_gap - 0.01, "barrel-to-barrel distance is at least the fair minimum at 300 px/s")
			last_barrel_position = r.position
			have_last = true


func test_both_bamboo_kinds_appear_over_many_spawns():
	var results := _run(1, 140.0, 1000)
	var has_ground := false
	var has_float := false
	for r in results:
		if r.kind == Spawner.Kind.BAMBOO_GROUND:
			has_ground = true
		elif r.kind == Spawner.Kind.BAMBOO_FLOAT:
			has_float = true
	assert_true(has_ground, "ground bamboo appears somewhere in 1000 spawns")
	assert_true(has_float, "floating bamboo appears somewhere in 1000 spawns")


func test_ground_bamboo_keeps_clearance_from_both_barrels():
	var results := _run(1, 140.0, 1000)
	_assert_ground_bamboo_keeps_clearance(results, 140.0)


func test_never_more_than_one_bamboo_between_two_barrels():
	var results := _run(1, 140.0, 1000)
	var bamboo_since_last_barrel := 0
	for r in results:
		if r.kind == Spawner.Kind.BARREL:
			bamboo_since_last_barrel = 0
		else:
			bamboo_since_last_barrel += 1
			assert_lte(bamboo_since_last_barrel, 1, "no more than one bamboo appears before the next barrel")


func test_bamboo_gap_share_is_about_40_percent():
	var results := _run(7, 140.0, 2000)
	var gap_count := 0
	var bamboo_gap_count := 0
	var bamboo_in_current_gap := false
	for r in results:
		if r.kind == Spawner.Kind.BARREL:
			gap_count += 1
			if bamboo_in_current_gap:
				bamboo_gap_count += 1
			bamboo_in_current_gap = false
		else:
			bamboo_in_current_gap = true
	var share := float(bamboo_gap_count) / float(gap_count)
	assert_true(share >= 0.3 and share <= 0.5, "share of gaps with bamboo (%f) is between 0.3 and 0.5" % share)


func test_same_seed_produces_the_same_mixed_sequence():
	var a := _run(42, 140.0, 1000)
	var b := _run(42, 140.0, 1000)
	assert_eq(a, b, "seed 42 reproduces the same mixed sequence")


func test_ground_bamboo_keeps_clearance_at_a_higher_speed():
	var results := _run(1, 300.0, 1000)
	_assert_ground_bamboo_keeps_clearance(results, 300.0)


# Issue #13: gaps widen with speed so a barrel stays jumpable as pace ramps up.

func test_min_barrel_gap_widens_with_speed():
	var spawner := _spawner(1)
	assert_gt(spawner.min_barrel_gap(300.0), spawner.min_barrel_gap(140.0), "min gap grows with speed")
