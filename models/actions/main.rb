
require "models/profiles/main"

class Main < Roby::Actions::Interface
    use_profile Testrich::TestProfile


    describe("step1")
    pddl do
        @precondition = "(at start)"
        @effect= "(and (not (at :init)) (at step1))"
    end
    state_machine "step1" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
    
    describe("step2")
    pddl do
        @precondition = "(at step1)"
        @effect= "(and (not (at step1)) (at goal))"
    end
    state_machine "step2" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
end

