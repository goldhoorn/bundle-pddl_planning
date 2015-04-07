
module Test
    #class True < Roby::Task  #Don't know this does not work here when using the define
    class True < Syskit::Composition 
        on :start do |e|
            emit :success
            e
        end
    end
end
