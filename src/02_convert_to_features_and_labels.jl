
include(joinpath(".", "00_clean_data.jl"))


function getfeatures(; trainingyears = 10) 
    training, test, species, lakes = getdata(trainingyears=trainingyears)

    features = []
    labels = []
    for s in 1:length(species)
        for l in 1:length(lakes)
            timeseries = [Float32.([vec(training[s,l,:])...])]
            push!(features, timeseries)
            push!(labels, [Float32.(training[s,l,begin])])
        end
    end

    return features, labels
end 
  

