# electric_grid_model_reduction
This is a public repository for the scripts and toy data for the "Structure- &amp; physics- preserving reductions of power grid models" project

This repository contains example matlab code and .mat data files containing toy data for study of model reduction of multiscale, distribution
and transmission, electric grid networks.  The scripts here are to be used as templates for the implementation of the reduction algorithms and
associated data architecture in the manuscript.  Toy data from the real test-case network is included in the .mat files, without identifying
information.  The full network structure is available, along with generator locations, but the nominal KV of nodes and megawatts of generators is given in anonymous, per-unit levels.

## Getting Started

All .m files in the main directory of the type 'driver' will run different steps of the reduction proceedure.  This can be done sequentially by

1. running the 'd1_d2_reduction_driver' on a given sparse connectivity matrix for the network. This will produce the degree one and degree two reduced networks with their associated hash tables describing super-nodes and meta-edges.  Note that as written, the hash table for the degree two reduction doesn't include any of the degree one reduction maps.

2. running the 'd1_d2_unstructured_data_driver'.  This will produce unstructured data associated to the reductions, simply describing node locations in the reduced networks.  As opposed to the structured data produced in the first step above, the unstructured data for the degree two reduction contains the node locations for all nodes in the reduced network, including those produced by the initial degree one reduction.

3. running the 'd1_d2_generator_location_driver'.  This will used the unstructured data sets to provide a new hash table of all generator locations in each the degree one and degree two reduced netwok.

4. running the 'tr_reduction_driver'.  This will produce an ensemble of greedy triangular reductions given a specified voltage and degree threshold.  The smallest reduction produced over the ensemble is kept, while the distributions of nodal degree and network size are kept for all experiments.

5. 'tr_reduced_visualization_driver' is an example of how plotting information was generated for the visualizations in vis.js, we write the graph information as variable definitions to be read by the visualization scripts.

6. 'overlay_node_positions_d2_tr_visualization_driver' is used to overlay the degree two reduced network on the node positions for the triangle reduced network.


## Toy Data 

Information on the data sets.

```
Give an example
```

## Functions

Information on the subroutines

## License

This project is licensed under the MIT License - see the [License.md](https://github.com/cgrudz/electric_grid_model_reduction/blob/master/LICENSE) file for details

