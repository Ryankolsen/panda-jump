class_name PauseState
extends RefCounted

## Whether the player has paused the run, and whether pausing is still
## allowed. Pure logic — PauseMenu applies `paused` to the scene tree.
## Locked once the run ends, because Game Over owns the tree's pause from
## then on and a player toggle would unfreeze it.
##
## No reset method: restarting a run reloads the scene (#10), which builds
## a new PauseState.

var paused: bool = false

var _locked: bool = false


## Flips between paused and running. Does nothing once locked.
func toggle() -> void:
	if _locked:
		return
	paused = not paused


## Stops any further pausing and drops a pause already in place.
func lock() -> void:
	_locked = true
	paused = false


func is_locked() -> bool:
	return _locked
