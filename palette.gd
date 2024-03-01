extends Node

var Red500 = Color.html('#F44336')

var Blue500 = Color.html('#2196F3')

var LightBlue100 = Color.html('#E1F5FE')
var LightBlue200 = Color.html('#B3E5FC')

var Green500 = Color.html('#4CAF50')

var BlueGrey900 = Color.html('#263238')

func pick_random() -> Color:
	var colors:Array[Color] = []
	var prop_list = get_property_list()
	for prop in prop_list:
		if prop.get('name') in self and typeof(self[prop.get('name')]) == TYPE_COLOR:
			colors.append(self[prop.get('name')])
	return colors.pick_random()

func lerp_colors(colors:Array[Color], weight:float) -> Color:
	var idx = wrapi(floor(weight * colors.size()), 0, colors.size() - 1) + 1
	return lerp(colors[idx-1], colors[idx], weight)
