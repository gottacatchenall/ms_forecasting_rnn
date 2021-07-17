import Flux
using Flux: logitcrossentropy, Dropout,relu, GRU, LSTM, RNN, Chain, Dense, ADAM, params, σ, onehot, reset!, tanh, train!, softmax
using StatsFuns: softmax, logit, logistic
using Plots
using StatsBase
using ProgressMeter

include(joinpath(".", "02_convert_to_features_and_labels.jl"))

function getmodel(inputsize)
    return Chain(
        LSTM(inputsize, inputsize),
        Dense(inputsize, 1, σ))
end


function trainModel(features, labels;
    nbatches = 5000,
    matat = 100,
    batchsize = 0.5,    
)
    themodel= getmodel(length(features[1][1]))
    ps = params(themodel)
    opt= ADAM()    
    reset!(themodel)
    
    function loss(xs, ys)
        l = sum(logitcrossentropy.(themodel.(xs), ys))
        return l
    end
      
    batchitems = Int32(floor(batchsize*length(labels)))
    @showprogress for i in 1:nbatches    
        ord = sample(1:length(labels), batchitems; replace=false)   
        Xs = features[ord]
        Ys = labels[ord]
        data_batch = zip(Xs,Ys)
        train!(loss, ps, data_batch, opt)
    end 

    return themodel
end

features, labels = getfeatures(trainingyears=14)
model, trainingloss, testloss = trainModel(features, labels)


predict = [model.(features[i])[1][1] for i in 1:length(features)]

scatter(predict, labels, ma=0.01, ms=5, legend=:none)

