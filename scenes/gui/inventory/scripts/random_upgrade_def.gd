extends UpgradeDef
class_name RandomUpgradeDef


enum UpgradeTypes {
	SWORD_RANGE,
	SWORD_AREA,
	SWORD_COOLDOWN,
	SWORD_DAMAGE,
	PLAYER_SPEED,
	PLAYER_MAX_HEALTH,
	PLAYER_DASH_SPEED,
	GUN_MAGAZINE,
	GUN_FIRE_RATE,
	GUN_ACCURACY,
	GUN_PELLETS,
	GUN_COOLDOWN
}

var upgrade_ranges :={
	UpgradeTypes.PLAYER_SPEED : [1, 5],
	UpgradeTypes.PLAYER_MAX_HEALTH : [5, 10],
	UpgradeTypes.PLAYER_DASH_SPEED : [25, 50],
	UpgradeTypes.GUN_MAGAZINE : [1, 3],
	UpgradeTypes.GUN_FIRE_RATE : [1, 2],
	UpgradeTypes.GUN_ACCURACY : []
}	
