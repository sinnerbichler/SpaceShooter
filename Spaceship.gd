extends KinematicBody


#momentum
export var velocity = Vector3(0, 0, 0.01)
var rot_in = Vector3()
export var speedmod = 0.5
var mouse_boundary = 200
var mouse_position = Vector2()
onready var last_shot = OS.get_ticks_msec()

var Projectile = preload("res://Projectile.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().warp_mouse(get_viewport().size / 2)
	mouse_boundary = get_viewport().size.y / 2

func _physics_process(delta):
	warp_mouse_into_boundary()
	
	if Input.is_action_pressed("shoot") && OS.get_ticks_msec() - last_shot > 300:
		shoot()
		last_shot = OS.get_ticks_msec()
	
	var braking_coef = 0.98
	var accel = Vector3(0, 0, 0)
	
	#brake
	if !Input.is_action_pressed("glide"):
		velocity = velocity * braking_coef
	#strafe
	if Input.is_action_pressed("right"):
		accel += transform.basis.x * -1

	if Input.is_action_pressed("left"):
		accel += transform.basis.x * 1

	#accelerate
	if Input.is_action_pressed("forward"):
		accel += transform.basis.z * 1

	if Input.is_action_pressed("backward"):
		accel += transform.basis.z * -1

	#hover
	if Input.is_action_pressed("up"):
		accel += transform.basis.y * 1

	if Input.is_action_pressed("down"):
		accel += transform.basis.y * -1


	if velocity.length() < 0.3:
		velocity = Vector3(0, 0, 0)
	
	
	velocity += accel * speedmod
	if velocity.length() < 0.3:
		velocity = Vector3(0, 0, 0)
	#velocity = move_and_slide(velocity, Vector3.UP)
	var _collider = move_and_collide(velocity * delta)
	
	#handle rolling
	var rot_accel = Vector3()
	if Input.is_action_pressed("rollright"):
		rot_accel.z += 1
	elif rot_in.z > 0:
		rot_in.z = rot_in.z * 0.9
	if Input.is_action_pressed("rollleft"):
		rot_accel.z += -1
	elif rot_in.z < 0:
		rot_in.z = rot_in.z * 0.9
		
	
	
	#handle looking
	var rel_mouse_pos = (get_viewport().get_mouse_position() - get_viewport().size / 2)
	warp_mouse_into_boundary()
	if rel_mouse_pos.length() > 10: #50 pixels would be the deadzone now
		#print("mouse pos: ", rel_mouse_pos)
		rel_mouse_pos = rel_mouse_pos / mouse_boundary
#		#Y axis
#		rot_accel.y += intensity_curve(-1 * rel_mouse_pos.x)
#		#X axis
#		rot_accel.x += intensity_curve(rel_mouse_pos.y)
		rel_mouse_pos = rel_mouse_pos.rotated(rotation.z) # when flying head over heel, this gives intuitive results
		rotation.y -= (rel_mouse_pos.x / 15)# * intensity_curve(rel_mouse_pos.x)
		rotation.x += (rel_mouse_pos.y / 15)# * intensity_curve(rel_mouse_pos.y)
		#print("mouse pos: ", rel_mouse_pos)
		

	rot_in.z = clamp(rot_in.z, -0.05, 0.05)
	rot_in += rot_accel * 0.0008
	rotation += rot_in



func _process(_delta):
	warp_mouse_into_boundary()
	mouse_position = get_viewport().get_mouse_position()
	pass


func warp_mouse_into_boundary():
	var vp = get_viewport().size
	var rel_mouse_pos = (get_viewport().get_mouse_position() - vp / 2)
	if rel_mouse_pos.length() == 0:
		return
	mouse_position = mouse_boundary / rel_mouse_pos.length() * rel_mouse_pos + (vp / 2)
	if rel_mouse_pos.length() > mouse_boundary:
		get_viewport().warp_mouse(mouse_position)
		
	

#exponential intensity curve
func intensity_curve(a):
	if a < 0:
		a = -a
	#return pow(2, a) -1 #exponential
	return (pow(a, 4) / 2) + (a / 2)

func shoot():
	var p = Projectile.instance()
	p.start($FirePoint.global_transform.origin, rotation, velocity)
	get_parent().add_child(p)
	#p.start($FirePoint.transform.origin, rotation, velocity)
	#add_child(p)
