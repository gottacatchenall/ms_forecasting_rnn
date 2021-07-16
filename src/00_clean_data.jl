using DataFrames, CSV
using NamedArrays

function getdata(; 
    filename = joinpath("assets", "rawdata.csv"),
    trainingyears = 10
)
    justfish = CSV.read(joinpath(".", filename), DataFrame)

    species = unique(justfish[!, :species])
    lakes = unique(justfish[!, :lakename])
    years = sort(unique(justfish[!, :year4]))

    tensor = NamedArray(Bool, length(species), length(lakes), length(years))
    setdimnames!(tensor, ("species", "lake", "year"))

    # not good code 
    for (li, lake) in enumerate(lakes)
        for (si, sp) in enumerate(species)
            for (yi, year) in enumerate(years)
                hereandnow = filter(
                        [:species, :year4, :lakename] => 
                        (s,y, l) -> s == sp && y == year && l == lake, justfish
                    )
                if nrow(hereandnow) > 0 
                    tensor[si, li, yi] = 1
                end
            end
        end
    end

    @info "Using the first $trainingyears years of the total $(length(years)) as training data"

    training = tensor[:,:,begin:trainingyears]
    test = tensor[:,:,trainingyears+1:end]

    return training, test, species, lakes, years
end 

