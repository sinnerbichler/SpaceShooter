extends KinematicBody

var speed = 30
var velocity = Vector3()

func start(pos, rot, inertia):
	rotation = rot
	translation = pos
	velocity = transform.basis.z * speed + inertia# * transform.basis.z
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	handle_collisions(delta)
	
	if (translation - get_parent().translation).length() > 1000:
		print("out of bounds")
		queue_free()

func handle_collisions(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.get_parent().is_a_parent_of(self.get_parent()):
			return
		print("exploding")
		queue_free()
		if collision.collider.has_method("hit"):
			collision.collider.hit()
