import Flux
using Flux: GRU, LSTM, RNN, Chain, Dense, ADAM, params, σ, onehot, reset!, tanh, train!, softmax
using StatsFuns: softmax, logit, logistic

include(joinpath(".", "02_convert_to_features_and_labels.jl"))

function getmodel()
    return Chain(
        GRU(timepts, 32), 
        LSTM(32, 32), 
        Dense(32, 16), 
        Dense(16,1));
end

loss(x, y) = sum((Flux.stack(m.(x),1) .- y) .^ 2)

function train(features, labels)
    data = zip(features,labels)
    m = getmodel()
    ps = params(m)
    opt= ADAM(1e-3)    
    reset!(m)
    train!(loss, ps, data, opt)

    return m
end

timepts = 10
features, labels = getfeatures(trainingyears=timepts)
model = train(features, labels)


predict = [model.(features[i])[1][1] for i in 1:length(features)]

scatter(predict, labels, legend=:none)
