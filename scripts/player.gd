extends CharacterBody3D

const MAX_SPEED = 6.5
const ACCELERATE = 0.3
const JUMP_VELOCITY = 6.5

var last_direction = Vector3()

@onready var ataque = get_node("ataque")
@onready var col = ataque.get_node("collision")

var pode_atacar = true
var atacando = false
var ataque_cooldown = 2.0

func _on_ataque_acertado(body: Node3D) -> void:
	if body == self:
		return
	
	print("Acertou:", body)
	print(body.is_in_group("enemy"))
	
	if body.is_in_group("enemy"):
		body.queue_free()

func atacar():
	if not pode_atacar or atacando:
		print("espere o cooldown")
		return
	
	# garante direção válida
	if last_direction == Vector3.ZERO:
		last_direction = -transform.basis.z
	
	atacando = true
	pode_atacar = false
	
	print("atacando")
	
	# posiciona ataque na frente do player
	var offset = last_direction.normalized()
	ataque.global_position = global_position + offset
	ataque.look_at(ataque.global_position + last_direction, Vector3.UP)
	
	# ativa hitbox
	col.disabled = false
	
	# tempo ativo do ataque
	await get_tree().create_timer(0.1).timeout
	
	col.disabled = true
	ataque.global_position = global_position
	atacando = false
	
	print("fim do ataque")
	
	# cooldown
	await get_tree().create_timer(ataque_cooldown).timeout
	pode_atacar = true
	
	print("liberado ataque")

func _physics_process(delta: float) -> void:
	# input ataque
	if Input.is_action_just_pressed("punch"):
		atacar()
	
	# gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.4
		if velocity.y < 0:
			velocity.y -= 0.35
	
	# pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# input movimento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		last_direction = direction
	
	# movimento X
	if direction.x != 0:
		velocity.x += direction.x * ACCELERATE
	elif abs(velocity.x) < MAX_SPEED / 5:
		velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATE)
	
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = MAX_SPEED * sign(velocity.x)
	
	# movimento Z
	if direction.z != 0:
		velocity.z += direction.z * ACCELERATE
	elif abs(velocity.z) < MAX_SPEED / 5:
		velocity.z = 0
	else:
		velocity.z = move_toward(velocity.z, 0, ACCELERATE)
	
	if abs(velocity.z) > MAX_SPEED:
		velocity.z = MAX_SPEED * sign(velocity.z)
	
	# desaceleração geral
	if direction == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, ACCELERATE)
		velocity.z = move_toward(velocity.z, 0, ACCELERATE)
	
	# rotação do personagem
	if direction != Vector3.ZERO:
		var target = global_position + direction
		target.y = global_position.y
		$MeshInstance3D.look_at(target)
	
	move_and_slide()
