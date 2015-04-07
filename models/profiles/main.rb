require "models/tasks/core"


module Testrich
    profile "TestProfile" do
        define 'true_task', Test::True
    end
end
