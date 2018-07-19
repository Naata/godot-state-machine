tool
extends EditorPlugin

const STATE_MACHINE = "State Machine"

func _enter_tree():
    add_custom_type(STATE_MACHINE, "Node", preload("state_machine.gd"), preload("icon.png"))

func _exit_tree():
    remove_custom_type(STATE_MACHINE)