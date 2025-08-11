extends CharacterBody3D

@onready var camera_mount = $"camera mount"
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals

@export var sense_horizontal = 0.5
@export var sense_vertical = 0.5

const JUMP_VELOCITY = 4.5

var speed = 3.0
var walk_speed = 3.0
var run_speed = 7.0
var running = false
var is_locked = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sense_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sense_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sense_vertical))

func _physics_process(delta):
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
	
	if Input.is_action_pressed("run"):
		speed = run_speed
		running = true
	else:
		speed = walk_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
				
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
		
			visuals.look_at(position + direction)
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
