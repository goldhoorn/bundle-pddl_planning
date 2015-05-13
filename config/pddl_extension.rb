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
                    @parameters = []
                end
               
#                def parameters 
                    #Figure out howto define argument, or get them from syskit-model
#                    []
#                end
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
    class System
        attr_reader :name
#        attr_reader :abilities
        attr_reader :system
        attr_reader :location
        attr_accessor :free

        def add_system(sys)
            @system[sys.name] = system
        end

        def initialize(name)
            @name = name
            @system = Hash.new
            @abilities = Array.new
            @free = true
        end

        def add_ability(name)
            @abilities << name
        end

        def abilities
            erg = @abilities
            system.each do |_,s|
                erg << s.abilities
            end
            erg
        end

        def set_location(name) #Should be called or call the real runtime layer
            @location=name  
        end
    end

    class Environment 
        attr_reader :locations
        attr_reader :system

        def abilities
            arr = Array.new
            system.each do |_,s|
                s.abilities.each do |a|
                    arr << a
                end
            end
            arr.uniq
        end

        def initialize()
            @locations = Array.new
            @system = Hash.new
        end

        def add_system(name)
            @system[name] = ::PDDL::System.new name
        end

        def add_location(name)
            @locations << name
        end
    end

    class MyKnowledge

        attr_accessor :types
        attr_accessor :predicates
        #attr_accessor :objects

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

        def initialize()
            #Currently create only dummy knowledge, this needs to be fed from another place
            @types = ['location', 'system', 'ability']
            @predicates = ['at ?x - location ?s - system', 'has_ability ?x - system ?y - ability', 'has_system ?x - system ?y - system', 'free ?x']
        end


        def objects
            objects = Array.new
            World.locations.each do |l|
                objects << "#{l} - location"
            end
            World.abilities.each do |a|
                objects << "#{a} - ability"
            end
            World.system.each do |_,s|
                objects << "#{s.name} - system"
            end
            objects
        end

        def init
            erg = Array.new
            World.system.each do |_,s|
                s.abilities.each do |a|
                    erg << "has_ability #{s.name} #{a}"
                end
                erg << "at #{s.location} #{s.name}"
                if s.free
                    erg << "free #{s.name}"
                else
                    erg << "not (free #{s.name})"
                end
            end
            erg
        end

        def plan(goals, planner = 'FDAUTOTUNE2')
            if goals.instance_of? String
                goals = [goals]
            elsif goals.instance_of? Array
                #Allright
            elsif
                raise ArgumentError, "goals needs to be a instance of string or array"
            end
            binding.render("problem.pddl.template","/tmp/problem.pddl")
            binding.render("domain.pddl.template","/tmp/domain.pddl")
            syscall = "pddl_planner_bin -p #{planner} -t 20 /tmp/domain.pddl /tmp/problem.pddl"
            STDOUT.puts "Calling: #{syscall}"
            erg = `#{syscall}`.split('\n')
            STDOUT.puts erg
            erg.last
        end
    end
   
    Knowledge = MyKnowledge.new
    World = Environment.new

    class ShellInterface < Roby::Interface::CommandLibrary
        def tester
            STDOUT.puts "hallo test funktion"
        end
        command :tester, "This tests this module"

        def plan(goal = "at goal rover")
            PDDL::Knowledge.plan(goal) 
        end
        command :plan, "Generate plan to goal",
            :goal => "Goal Description"
    end

end
