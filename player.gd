extends CharacterBody2D

@export_group("Movimiento Horizontal")
@export var walk_speed := 260.0       # Velocidad al caminar
@export var run_speed := 400.0        # Velocidad al apretar Shift
@export var acceleration := 500.0     # Inercia al arrancar
@export var friction := 500.0         # Fricción al soltar la tecla
@export var turn_around_friction := 6000.0 # El "derrape" al cambiar de dirección

@export_group("Mecánicas de Salto")
@export var jump_velocity := -380.0
@export var gravity := 1100.0
@export var max_fall_speed := 600.0
@export var max_jumps := 1            # salto unico
@export var jump_cut_multiplier := 0.3 # Salto variable (mantener vs presionar)

var jump_count := 0

func _ready():
	# Ubica al personaje y resetea velocidad al inicio
	global_position = Vector2(100, 250)
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_horizontal_movement(delta)
	move_and_slide()
	
	# ver la velocidad en consola
	# print(velocity.x)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		# Caída más fuerte (clave)
		if velocity.y > 0:
			velocity.y += gravity * delta * 1.5
		else:
			velocity.y += gravity * delta
	else:
		velocity.y = 0

func handle_jump() -> void:
	# Salto inicial Quieto → salto normal (vertical) Corriendo → salto más largo
	if Input.is_action_just_pressed("jump") and is_on_floor(): 
		velocity.y = jump_velocity
		jump_count += 1

	# Salto variable: si soltás el botón, la velocidad de subida se corta
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	var target_speed = walk_speed
	if Input.is_action_pressed("run"):
		target_speed = run_speed

	# declarar la variable afuera si o si
	var current_accel = acceleration

	if direction != 0:
		
		# Menos control en el aire
		if not is_on_floor():
			current_accel *= 0.6
		
		# Derrape (skid)
		if sign(direction) != sign(velocity.x) and abs(velocity.x) > 50:
			velocity.x = move_toward(velocity.x, 0, turn_around_friction * delta)
			return
		
		velocity.x = move_toward(velocity.x, direction * target_speed, current_accel * delta)
	else:
		# Desaceleración
		velocity.x = move_toward(velocity.x, 0, friction * delta)
