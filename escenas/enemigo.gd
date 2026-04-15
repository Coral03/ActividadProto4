extends CharacterBody2D  

# Se definen los posibles estados del enemigo
enum State {
	PATROL,  # Se mueve entre puntos
	CHASE,   # Persigue al jugador
	ATTACK   # Ataca al jugador
}

# Estado actual del enemigo (arranca patrullando)
var current_state = State.PATROL

# Referencia al player
# Variable donde guardamos al player
var player = null

# variables de mov
@export var speed := 100.0           # Velocidad general del enemigo
@export var detection_range := 200.0 # Distancia para empezar a perseguir
@export var attack_range := 100.0     # Distancia para atacar

# Variables de patrulla
@export var patrol_distance := 200.0 # Distancia máxima de patrulla
var start_position                   # Posición inicial del enemigo
var patrol_direction := -1            # Dirección (1 derecha, -1 izquierda)

func _ready():
	# Guarda la posición inicial para usarla como referencia en la patrulla
	start_position = global_position
	
	# Busca automáticamente al jugador usando el grupo "player"
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Actualiza el estado según la distancia al jugador
	update_state()
	
	# Ejecutamos lógica según el estado actual
	match current_state:
		State.PATROL:
			patrol(delta)  # Se mueve de un lado a otro
		
		State.CHASE:
			chase(delta)   # Persigue al jugador
		
		State.ATTACK:
			attack()       # Ataca
	
	# Aplica el movimiento y colisiones
	move_and_slide()

func update_state():
	# Si no encontramos al jugador, no hacemos nada
	if player == null:
		return
	
	# Calcula la distancia entre enemigo y jugador
	var distance = global_position.distance_to(player.global_position)
	
	# Cambia el estado según la distancia
	if distance < attack_range:
		current_state = State.ATTACK   # Muy cerca → atacar
	
	elif distance < detection_range:
		current_state = State.CHASE    # Cerca → perseguir
	
	else:
		current_state = State.PATROL   # Lejos → patrullar

# Estado: Patrulla
func patrol(delta):
	# Se mueve en una dirección constante
	velocity.x = patrol_direction * speed
	
	# Si se aleja demasiado de la posición inicial
	if abs(global_position.x - start_position.x) > patrol_distance:
		# Cambia de dirección
		patrol_direction *= -1

# Estado: persecución
func chase(delta):
	# Calcula hacia dónde está el jugador
	var direction = sign(player.global_position.x - global_position.x)
	
	# Nos movemos hacia él
	velocity.x = direction * speed

# Estado: Ataque
func attack():
	# Frena el movimiento
	velocity.x = 0
	
	# Si el jugador existe
	if player != null:
		# Llamamos a su función de daño
		player.take_damage()
