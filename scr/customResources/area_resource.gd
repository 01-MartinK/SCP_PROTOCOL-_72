extends Resource
class_name AreaData

## The name of the area for building and scp-s
@export var name : String = "Template"
@export var description: String = ""
## The type of area it is for categorization
@export var area_type_name : String = "Template"
## Furniture objects that are required for the room to function
@export var furniture_requirements : Array[FurnitureData] = []
## Color for the grid
@export var area_color: Color = Color.WHITE
