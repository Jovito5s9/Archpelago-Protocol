extends "res://scripts/entity.gd"

const MAX_SPEED = 6.5
const ACCELERATE = 0.3
const JUMP_VELOCITY = 6.5


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("punch"):
		atacar()
	
	# gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.4
	
	# pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		last_direction = direction
	
	# movimento
	if direction != Vector3.ZERO:
		velocity.x = direction.x * MAX_SPEED
		velocity.z = direction.z * MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATE)
		velocity.z = move_toward(velocity.z, 0, ACCELERATE)
	
	# rotação
	if direction != Vector3.ZERO:
		var target = global_position + direction
		target.y = global_position.y
		$MeshInstance3D.look_at(target)
	
	move_and_slide()
