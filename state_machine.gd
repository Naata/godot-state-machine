extends Node

const EXPECTED_METHODS = ["state_enter",
                        "state_exit",
                        "state_handle_input",
                        "state_update",
                        "state_name"]
const EXPECTED_SIGNALS = ["state_change"]
const REGISTERED_STATES = {}
const STATES_STACK = []

export(String) var state_previous = "#previous"
var current_state = null

func _ready():
    assert(get_child_count() > 0)

    for sig in EXPECTED_SIGNALS:
        var name = "_on_" + sig
        assert(has_method(name))

    REGISTERED_STATES[state_previous] = Node.new()

    for child in get_children():
        _interface_valid(child)
        var state_name = child.state_name()
        assert(!REGISTERED_STATES.has(state_name))
        REGISTERED_STATES[state_name] = child
        for sig in EXPECTED_SIGNALS:
            child.connect(sig, self, "_on_" + sig)

    var child = get_child(0)
    current_state = child
    _on_state_change(child.state_name())

func _input(event):
    current_state.state_handle_input(event)

func _physics_process(delta):
    current_state.state_update(delta)

func _on_state_change(state, only_state = true):
    assert(REGISTERED_STATES.has(state))

    var incoming_state = REGISTERED_STATES[state]

    current_state.state_exit()

    if state == state_previous:
        STATES_STACK.pop_front()
    elif only_state:
        STATES_STACK.clear()
        STATES_STACK.push_front(incoming_state)
    else:
        STATES_STACK.push_front(incoming_state)

    current_state = STATES_STACK[0]
    current_state.state_enter()

func _interface_valid(state):
    for method in EXPECTED_METHODS:
        assert(state.has_method(method))

    for sig in EXPECTED_SIGNALS:
        assert(state.has_user_signal(sig) or state.get_script().has_script_signal(sig))