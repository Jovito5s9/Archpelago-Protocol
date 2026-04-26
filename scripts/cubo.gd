extends "res://scripts/entity.gd"

const SPEED = 2.5
@onready var player = get_parent().get_node("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player:
		var dir = (player.global_position - global_position).normalized()
		
		last_direction = dir
		
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		
		if global_position.distance_to(player.global_position) < 2.0:
			atacar()
	
	move_and_slide()
