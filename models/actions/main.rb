
require "models/profiles/main"

class Main < Roby::Actions::Interface
    use_profile Testrich::TestProfile


    describe("step1").
    required_arg('sys', 'The System which should to the Step').
    pddl do
        @parameters = ["?sys - system"]
        @precondition = "(and (at start ?sys) (has_ability power ?sys))"
        @effect= "(and (not (at start ?sys)) (at step1 ?sys))"
    end
    state_machine "step1" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
    
    describe("merge-systems").
    required_arg('sys1', 'First System').
    required_arg('sys2', 'Second System which system get merged into second').
    pddl do
        @parameters = ["?sys1 - system", "?sys2 - system"]
        @precondition = "(and(not (has_system ?sys1 ?sys2 )))"
        @effect= "(and (has_system ?sys1 ?sys2) (not (free ?sys2)) (forall (?a - ability)(when (has_ability ?a ?sys2) (has_ability ?a ?sys1) )))"
    end
    state_machine "merge_systems" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
    
    describe("step2").
    required_arg('sys', 'The System which should to the Step').
    pddl do
        @parameters = ["?sys - system"]
        @precondition = "(and (at step1 ?sys) (has_ability power ?sys))"
        @effect= "(and (not (at step1 ?sys)) (at goal ?sys))"
    end
    state_machine "step2" do
        s1 = state true_task_def
        start s1
        forward s1.success_event, success_event
    end
end

