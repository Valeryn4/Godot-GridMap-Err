extends Reference
class_name GridConsts

const BUILD_MODE_REMOVE = 0
const BUILD_MODE_ROOM_DEFAULT = 1
const BUILD_MODE_SETUP_OBJECT = 4000
const BUILD_MODE_SET_PATH = 5000




enum ROOM_TYPES {
	EMPTY = 0,
	CORRIDOR = 1,
	LABS = 2,
	DINNING = 3,
	ROOM = 4,
	MEDICINE = 5,
	FLOOR = 6
}

const ROOM_ID_TO_NAME = {
	ROOM_TYPES.EMPTY : "Empty",
	ROOM_TYPES.CORRIDOR : "Base",
	ROOM_TYPES.LABS : "Labs",
	ROOM_TYPES.DINNING : "Dinning",
	ROOM_TYPES.ROOM : "Room",
	ROOM_TYPES.MEDICINE : "Medicine",
	ROOM_TYPES.FLOOR : "Floor"
}


const ROOM_NAME_TO_ID = {
	"Empty" : ROOM_TYPES.EMPTY,
	"Base" : ROOM_TYPES.CORRIDOR,
	"Labs" : ROOM_TYPES.LABS,
	"Dinning" : ROOM_TYPES.DINNING,
	"Room" : ROOM_TYPES.ROOM,
	"Medicine" : ROOM_TYPES.MEDICINE,
	"Floor" : ROOM_TYPES.FLOOR
}

enum ENEMY_TYPES {
	EMPTY,
	HUMAN,
	SCP,
	MECH,
}

enum PERSONAL_TYPES {
	D,
	SCINES,
	CLERC,
	MANAGER,
	MILLITARY,
	ARGENT,
}

enum OBJECTS_BASE {
	BED,
	TABLE,
	BOX,
	DOOR,
	SPAWN,
	ALARM,
}
