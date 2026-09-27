class_name SpriteFit
extends RefCounted

## Scales a picture uniformly so it stands a given height tall, keeping its
## proportions. Shared by anything that shows an artist's drawing at a fixed
## on-screen size instead of doing its own scale math (panda, barrel,
## bamboo — see issue #16).


## Returns the uniform scale to apply to a texture of `texture_size` so it is
## `target_height` tall. Returns Vector2.ONE if `texture_size.y` is zero,
## since there is no sensible scale to compute.
static func scale_for(texture_size: Vector2, target_height: float) -> Vector2:
	if texture_size.y <= 0.0:
		return Vector2.ONE
	var s := target_height / texture_size.y
	return Vector2(s, s)
