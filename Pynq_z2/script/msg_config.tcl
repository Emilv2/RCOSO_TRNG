proc set_msg {} {
  # Error on latches
  set_msg_config -id "Synth 8-327" -new_severity ERROR
  # Error on multi driven nets
  set_msg_config -id "Synth 8-6859" -new_severity ERROR
}
