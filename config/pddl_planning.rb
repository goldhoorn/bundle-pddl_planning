#Northing so far

require 'config/pddl_extension'


Roby::Interface::Interface.subcommand 'pddl', PDDL::ShellInterface, 'Commands specific to PDDL Planning'
