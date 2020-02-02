extends KinematicBody2D
export (int) var run_speed = 100
export (int) var Health = 100
export (int) var damage = 50
export (int) var jump_speed = -400
export (int) var gravity = 1200

var velocity = Vector2()
var jumping = false
var state_machine

signal player


func get_input():
	velocity.x = 0;
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_up')
	var duck = Input.is_action_pressed('ui_down')
	var attack = Input.is_action_just_pressed("ui_accept")
	if jump and is_on_floor():
		velocity.y=jump_speed
		state_machine.travel("Jump 2")
		return
	elif right:
		velocity.x += run_speed
		$Sprite.flip_h = false
		state_machine.travel('Walk')
		return
	elif left:
		velocity.x -= run_speed
		$Sprite.flip_h = true
		
		state_machine.travel('Walk')
		return
	elif duck:
		state_machine.travel('crouch')
		return
	
	
	elif attack:
		if($Sprite.flip_h == false):
			
			state_machine.travel("Attack")
		else:
			state_machine.travel("Attack2")
		return
	
	
	elif velocity.y > 0 and not is_on_floor():
		state_machine.travel("Fall 3")
		return
	else: 
		state_machine.travel('Idle')

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("player")
	state_machine =$AnimationTree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false

	velocity = move_and_slide(velocity,Vector2(0,-1))

	if Health <= 0:
		die()

func die():
	state_machine.travel("Death")
	set_physics_process(false)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		
func take_damage(pain):
	Health -= pain
