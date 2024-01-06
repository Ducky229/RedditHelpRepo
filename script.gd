extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var anim = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals
@onready var interaction_hitbox = $InteractionHitbox
@onready var label = $Control/Label
@onready var great_sword = $visuals/mixamo_base/Armature/Skeleton3D/Shoulder/GreatSword

var SPEED = 3
const JUMP_VELOCITY = 4.5

var walking_speed = 3.0
var running_speed = 5.0

var lerp_speed = 10.0

var running = false

var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var label_visible = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-89), deg_to_rad(45))
func _physics_process(delta):
	
	
	
	if !anim.is_playing():
		is_locked = false
	
	
	if Input.is_action_just_pressed("interaction"):
		for body in interaction_hitbox.get_overlapping_bodies():
			if body.has_method("interact"):
				body.interact()
			
				
	
	if Input.is_action_just_pressed("kick") and is_on_floor():
		if anim.current_animation != "kick":
			anim.play("kick")
			is_locked = true
	# Handle running
	
	if  Input.is_action_pressed("running") and is_on_floor():
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if anim.current_animation != "running":
					anim.play("running")
			else:
				if anim.current_animation != "walking":
					anim.play("walking")
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if anim.current_animation != "idle":
				anim.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if !is_locked:
		move_and_slide()

func _on_greatsword_item_greatsword_pickup():
	label.set("visible", true)
	great_sword.set("visible", true)
	label.text = "Greatsword pickuped"
	$Control/Timer.start()

func _on_timer_timeout():
	label.set("visible", false)S