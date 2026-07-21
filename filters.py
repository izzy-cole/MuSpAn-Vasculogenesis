def cycle_intensity(cycles):
    #cycle strength is cycle death time
    cycles = [i[1] for i in cycles]
    return cycles

def edge_strength(components,b1=5,b2=100,plot=False):
    #edge strength is component birth time
    edges = [i[0] for i in components]
    return edges

def component_intensity(components,d1=150,plot=False):
    #component intensity is component death time
    components = [i[1] for i in components]
    return components

def hole_strength(cycles):
    #hole strength is cycle birth time
    cycles = [i[0] for i in cycles]
    return cycles


def basic_filtering(components,cycles, min_lifespan=30,upper=200,plot=False):

    print(f"Number of components before: {len(components)}")
    comp_filter = [i[1]-i[0]>=min_lifespan for i in components] #filter min lifespan
    comp_filter2 = [i[0]<=upper for i in components] #filter below birth limit
    components = components[np.logical_and(comp_filter,comp_filter2)]

    print(f"Number of components after filtering: {len(components)}")


    print(f"Number of cycles before: {len(cycles)}")
    cycle_filter = [i[1]-i[0]>=min_lifespan for i in cycles] #filter min lifespan
    cycle_filter2 = [i[0]<=upper for i in cycles] #filter below birth limit
    cycles = cycles[np.logical_and(cycle_filter,cycle_filter2)]
    print(f"Number of cycles after filtering: {len(cycles)}")

    if plot:
        if len(components)>0:
            plot_diagrams([components,cycles], show=True)
    return([components,cycles])