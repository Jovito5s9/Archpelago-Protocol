extends CharacterBody3D

const MAX_SPEED = 6.5
const ACCELERATE = 0.3
const JUMP_VELOCITY = 6.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.4
		if velocity.y<0:
			velocity.y-= 0.35

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	if direction.x:
		velocity.x += direction.x * ACCELERATE
	elif abs(velocity.x)<MAX_SPEED/5:
		velocity.x = 0
	else:
		velocity.x -= direction.x * 0.15
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = MAX_SPEED * direction.x
	
	if direction.z:
		velocity.z += direction.z * ACCELERATE
	elif abs(velocity.z)<MAX_SPEED/5:
		velocity.z = 0
	else:
		velocity.z -= direction.z * 0.15
	if abs(velocity.z) > MAX_SPEED:
		velocity.z = MAX_SPEED * direction.z
		
	if not direction:
		velocity.x = move_toward(velocity.x, 0, ACCELERATE)
		velocity.z = move_toward(velocity.z, 0, ACCELERATE)
		
	
	if direction!=Vector3.ZERO:#rotacao do body
		var target = global_position + direction
		target.y = global_position.y
		$MeshInstance3D.look_at(target)

	move_and_slide()
