extends Node

## Returns a random index based on given weights
## weighted_choice([20,30,50]) -> 20% chance of returning 0, 30% for 1, 50% for 2
func weighted_choice(weights:Array[int]):
	var sum:int = weights.reduce(func(prev, next): return prev + next, 0)
	var r = randi() % sum
	for w in range(weights.size()):
		if r <= weights[w]:
			return w
	return weights.size() - 1

func closest_node(to:Node2D, nodes:Array[Node2D]) -> Node2D:
	nodes.sort_custom(func(a:Node2D,b:Node2D): 
		return a.node.global_position.distance_to(to.global_position) <  b.node.global_position.distance_to(to.global_position)
	)
	return nodes.front()

func closest_vector2i(to:Vector2i, nodes:Array[Vector2i]) -> Vector2i:
	nodes.sort_custom(func(a:Vector2i,b:Vector2i): 
		return Vector2(a).distance_to(to) <  Vector2(b).distance_to(to)
	)
	return nodes.front()
