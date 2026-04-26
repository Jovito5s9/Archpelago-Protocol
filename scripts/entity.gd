extends CharacterBody3D

@export var vida_maxima: int = 10
@export var dano_base: int = 2

@export var knockback_forca: float = 6.0
@export var knockback_vertical: float = 2.5
@export var iframe_tempo: float = 0.4

var vida: int
var invencivel = false

@onready var ataque = get_node_or_null("ataque")
@onready var col = ataque.get_node_or_null("collision") if ataque else null

var pode_atacar = true
var atacando = false
var ataque_cooldown = 1.0

var last_direction = Vector3.FORWARD

func _ready():
	vida = vida_maxima

func tomar_dano(dano: int, origem: Vector3 = Vector3.ZERO):
	if invencivel:
		return
	
	vida -= dano
	print(self, " tomou dano:", dano, "vida:", vida)
	
	invencivel = true
	
	aplicar_knockback(origem)
	
	if vida <= 0:
		morrer()
		return
	
	await get_tree().create_timer(iframe_tempo).timeout
	invencivel = false

func aplicar_knockback(origem: Vector3):
	var direcao = (global_position - origem).normalized()
	
	if direcao == Vector3.ZERO:
		direcao = -transform.basis.z
	
	velocity.x = direcao.x * knockback_forca
	velocity.z = direcao.z * knockback_forca
	velocity.y = knockback_vertical

func morrer():
	print(self, " morreu")
	queue_free()

func atacar():
	if not ataque:
		return
	
	if not pode_atacar or atacando:
		return
	
	if last_direction == Vector3.ZERO:
		last_direction = -transform.basis.z
	
	atacando = true
	pode_atacar = false
	
	var offset = last_direction.normalized()
	ataque.global_position = global_position + offset
	ataque.look_at(ataque.global_position + last_direction, Vector3.UP)
	
	if col:
		col.disabled = false
	
	await get_tree().create_timer(0.1).timeout
	
	if col:
		col.disabled = true
	
	ataque.global_position = global_position
	atacando = false
	
	await get_tree().create_timer(ataque_cooldown).timeout
	pode_atacar = true

func _on_ataque_acertado(body: Node3D) -> void:
	if body == self:
		return
	
	if body.has_method("tomar_dano"):
		body.tomar_dano(dano_base, global_position)
