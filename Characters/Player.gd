class_name Player extends CharacterBody3D

@export var accelaration: float = 100
@export var max_velocity: float = 7
@export var gravity: float = 100
@export var jump_force: float = 100
@export var mouse_sensitivity: float = .003

@onready var skeleton: Skeleton3D = %GeneralSkeleton
@onready var head: BoneAttachment3D = %Head
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

var _direction: Vector3 = Vector3.ZERO
var _angular_velocity = 30

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#skeleton.top_level = true
	pass

func _input(event):
	if (event is InputEventMouseMotion):
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, -75, 75)
	pass
		
func _process(delta):
	#if _direction != Vector3.ZERO:
	#	skeleton.rotation.y = lerp_angle(skeleton.rotation.y, atan2(_direction.x, _direction.z), _angular_velocity * delta)
	pass

func _physics_process(delta):
	_direction = Vector3.ZERO
	var input_direction = Vector3(
		Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"),
		0,
		Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	)
	var h_rot = global_transform.basis.get_euler().y
	_direction = input_direction.rotated(Vector3.UP, h_rot).normalized()
	
	velocity = velocity.move_toward(max_velocity * _direction, accelaration * delta)
	move_and_slide()
	_update_animation_states()
	_update_animation_blend(input_direction)
	pass

func _update_animation_states():
	animation_tree["parameters/conditions/isOnFloor"] = is_on_floor()
	animation_tree["parameters/conditions/isWalking"] = _direction != Vector3.ZERO
	animation_tree["parameters/conditions/isNotWalking"] = _direction == Vector3.ZERO
	animation_tree["parameters/conditions/isJumping"] = false
	pass
	
func _update_animation_blend(direction):
	animation_tree["parameters/Walk/Walk/blend_position"] = Vector2(direction.x, direction.z)
	pass
