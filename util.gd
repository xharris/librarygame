extends Node

## Returns a random index based on given weights
## weighted_choice([20,30,50]) -> 20% chance of returning 0, 30% for 1, 50% for 2
func weighted_choice(weights:Array[int]):
	var sum:int = weights.reduce(func(prev, next): return prev + next, 0)
	var r = randi() % sum
	for w in range(weights.size()):
		if r <= weights[w]:
			return w
	return -1
