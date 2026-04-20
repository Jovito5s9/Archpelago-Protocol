extends CharacterBody3D


const SPEED = 2.5
const JUMP_VELOCITY = 4.5
@onready var player = get_parent().get_node("player")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	if player:
		var direction := Vector3(int(player.global_position.x>global_position.x), int(player.global_position.y>global_position.y), int(player.global_position.z>global_position.z))
		if abs(player.global_position.x-global_position.x)<0.05:
			direction.x=0
		elif not direction.x:
			direction.x = -1
			
		if abs(player.global_position.z-global_position.z)<0.05:
			direction. z=0
		elif not direction.z:
			direction.z = -1
			
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
