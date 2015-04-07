#require 'roby'

module Roby
    module Actions
        module Models


            class PDDL
                attr_reader :precondition
                attr_reader :postcondition
                attr_reader :name

                def to_s
                    "PDDL:{Name: #{name}; Precondition: #{@precondition}; Postcondition: #{@postcondition}}"
                end

#                def name 
#                    model.name
#                end
                
                #def initialize(model) ##see comment below
                def initialize(name)
                    @precondition = "" 
                    @postcondition = ""
                    #@model = model
                    @name= name 
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
