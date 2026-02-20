extends Node3D

var entity = null
var damaage = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('initialised')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		

func _on_body_entered(body: Node3D) -> void:
	entity = body
	damaage = true
	deal_damage()
	print('Collision detected')
	

func _continous_damage(entity):
	pass


func _on_body_exited(body: Node3D) -> void:
	entity = null
	
func deal_damage():
	while entity:
		entity.receive_damage()
		await get_tree().create_timer(1.0).timeout
		
func variable_damage():
	pass
		
