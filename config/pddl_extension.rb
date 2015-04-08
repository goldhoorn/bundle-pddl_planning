#require 'roby'

require 'erubis'

class Binding
    def render(file, res)
        input = File.read(File.join(File.dirname(__FILE__),file))
        eruby = Erubis::Eruby.new(input)
        erg = eruby.result(self) 
        File.write(res,erg)
    end
end

module Roby
    module Actions
        module Models
            class PDDL
                attr_reader :precondition
                attr_reader :effect
                attr_reader :parameters
                attr_accessor :name

                def to_s
                    "PDDL:{Name: #{name}; Precondition: #{@precondition}; Effect: #{@effect}; Arguments: #{@parameters}}"
                end

#                def name 
#                    model.name
#                end
                
                #def initialize(model) ##see comment below
                def initialize(name)
                    @precondition = "" 
                    @effect = ""
                    #@model = model
                    @name= name 
                end
               
                def parameters 
                    #Figure out howto define argument, or get them from syskit-model
                    []
                end
            end
            
            module Interface
                def pddl(&block)
                    if !@current_description
                        raise ArgumentError, "you must describe the action with #describe before calling #pddl"
                    end
                    @current_description.pddl(&block)
                end
            end

            class Action
                def pddl(&block)
                    if @pddl.nil?
                        @pddl = Models::PDDL.new name #self  #Results in serialization errors for druby
                    end
                    if block_given?
                        @pddl.instance_eval(&block)
                    end
                    @pddl
                end
            end
        end

        class Action
            def pddl
                model.pddl
            end
        end
    end
end

module PDDL
    class MyKnowledge

        attr_accessor :types
        attr_accessor :predicates
        attr_accessor :objects
        attr_accessor :init

        def actions
            arr = []
            #Todo figure out howto access all actions in general not only in the user-defined Main class
            Main.actions.each do |name,act|
                #The names from above are buggy so we overide the name here
                act.pddl.name = name

                #Skipping actions that have not pre conditiond and no effect (assumung they are unused)
                if act.pddl.precondition != "" and act.pddl.effect != ""
                    arr << act.pddl
                end
            end
            arr
        end

        def initialize
            #Currently create only dummy knowledge, this needs to be fed from another place
            @types = ['location']
            @predicates = ['at ?x - location']
            @objects = ['start - location']
            @objects << 'goal - location'
            @objects << 'step1 - location'
            @objects << 'step2 - location'
            @init= ['at start']
        end

        def plan(goals)
            if goals.instance_of? String
                goals = [goals]
            elsif goals.instance_of? Array
                #Allright
            elsif
                raise ArgumentError, "goals needs to be a instance of string or array"
            end
            binding.render("problem.pddl.template","/tmp/problem.pddl")
            binding.render("domain.pddl.template","/tmp/domain.pddl")
            syscall = 'pddl_planner_bin -p FDAUTOTUNE2 -t 20 /tmp/domain.pddl /tmp/problem.pddl'
#            STDOUT.puts "Calling: #{syscall}"
            erg = `#{syscall}`.split('\n')
            STDOUT.puts erg
            erg.last
        end
    end
   
    Knowledge = MyKnowledge.new
    
    class ShellInterface < Roby::Interface::CommandLibrary
        def tester
            STDOUT.puts "hallo test funktion"
        end
        command :tester, "This tests this module"

        def plan(goal = "at goal")
            PDDL::Knowledge.plan(goal) 
        end
        command :plan, "Generate plan to goal",
            :goal => "Goal Description"
    end

end
