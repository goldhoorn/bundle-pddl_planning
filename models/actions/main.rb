
require "models/profiles/main"

class Main < Roby::Actions::Interface
    use_profile Testrich::TestProfile
    
    
    describe("foo")
    pddl do
        @precondition = "Hallo"
        @postcondition = "Hallo Postcondition"
    end
    state_machine "foo" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
end

