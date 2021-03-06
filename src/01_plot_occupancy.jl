
using Plots
using ColorSchemes
using Base.Unicode: lowercase

include(joinpath(".", "00_clean_data.jl"))

tensor, empty, species, lakes, years = getdata(trainingyears=20)


function occupancy_by_lake(tensor, lakes)
    nlakes = size(tensor)[2]
    nyears = size(tensor)[3]

    response = zeros(nyears, nlakes)

    for l in 1:nlakes, t in 1:nyears
        response[t, l] = sum(tensor[:,l,t]) / sum(ones(size(tensor[:,l,t])))
    end

    plt = plot(size=(700,500), frame=:box, legend=:outerright, legendtitle="Lake")
    

    clrs = palette(:RdBu_10)

    for l in 1:nlakes
        plot!(plt, years, response[:,l], lw=3, la=0.3,lc=clrs[l], label="")
        scatter!(plt, years, response[:,l], ms=5, msw=3, ma=0.5,msc=clrs[l], labels=lakes[l],mc=clrs[l])    
    end


    xaxis!("year")
    yaxis!("proportion species present")
    title!("Proportion of species in each lake")


    return plt
end

function occupancy_by_species(tensor, species)
    nspecies = size(tensor)[1]
    nyears = size(tensor)[3]

    response = zeros(nyears, nspecies)

    for s in 1:nspecies, t in 1:nyears
        response[t, s] = sum(tensor[s,:,t]) / sum(ones(size(tensor[s,:,t])))
    end

    plt = plot(size=(700,500), frame=:box, legend=:outerright, legendtitle="Species")

    clrs = get(palette(:acton), 0:(1.0/nspecies):1)
    for s in 1:nspecies
        plot!(plt, years, response[:,s], lw=3, la=0.3,lc=clrs[s], label="")
        scatter!(plt, years, response[:,s], ms=5, msw=3, ma=0.5,msc=clrs[s], labels=species[s],mc=clrs[s])    
    end

    ylims!(0,1)
    xaxis!("year")
    yaxis!("proportion lakes occupied")

    title!("Proportion of lakes occupied by each species")
    return plt
end

"""

    Two panel fig
"""
default(titlefont = ( "Computer Modern"), legendfont=(12, "Computer Modern"), legendfontsize = 12, guidefont = (14, "Computer Modern", :black), tickfont = (12, "Computer Modern", :black), guide = "x")
a = occupancy_by_lake(tensor, lowercase.(lakes))
b  = occupancy_by_species(tensor, lowercase.(species))
plot(a,b, layout=(2,1), size=(900,700), dpi = 300)
savefig("occupancy_by_lake_and_species.png")



"""
 Everything
"""

function occupancy_by_everything(tensor, lakes, species)
    nspecies = length(species)
    nlakes = length(lakes)
    nyears = size(tensor)[3]

    plotlist = []
    for s in 1:nspecies
        for l in 1:nlakes
            thistimeseries = vec(tensor[s,l,:])
            @show thistimeseries
            thisplt = plot(size=(100,100),frame=:box, legend=:none)
            plot!(thisplt, years, thistimeseries, lw=1)
            scatter!(thisplt, years, thistimeseries, ms=1)    
            push!(plotlist, thisplt)
        end
    end
    @show plotlist
    return plot(plotlist...)
end


default()

c = occupancy_by_everything(tensor, lowercase.(species), lowercase.(lakes))



occplots = []
for s in 1:length(species)
    for l in 1:length(lakes)
        push!(occplots , scatter(1:size(tensor)[3], vec(tensor[s,l,:])) )
    end
end

plot(occplots..., size = (3000, 3000))

savefig("attempt.png")