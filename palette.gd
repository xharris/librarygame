extends Node

var Red500 = Color.html('#F44336')

var Blue500 = Color.html('#2196F3')

var Green500 = Color.html('#4CAF50')

func pick_random() -> Color:
	var colors:Array[Color] = []
	var prop_list = get_property_list()
	for prop in prop_list:
		if prop.get('name') in self and typeof(self[prop.get('name')]) == TYPE_COLOR:
			colors.append(self[prop.get('name')])
	return colors.pick_random()
