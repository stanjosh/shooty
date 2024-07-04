extends Node


signal refresh_interface


func refresh(target):
	refresh_interface.emit(target)
