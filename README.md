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

Toy data can be found in the 'processed_data' directory.  The 'full_network_toy_data.mat' contains a sparse connectivity 
matrix for the full case 
study network where the nodes are randomly numbered and identified with its row/ column in this matrix.  The 'gen_nums' is an array containing 
the the associated node numbers where generators are located. The per unit nominal KV and per unit megawatts of generation are included in the
remaining structs in this .mat file.  The fields in these structs are given in the form 'b\*' or 'g\*' where \* is the node number.

The 'd1_d2_tree_edge_data.mat' contains the connectivity matrices and the hash tables for the reductions of each of the degree one and degree
two reductions of the full network.  The connectivity matrices in this case are represented simply by a list of all nodes, descending order in
 the rows, with the column entry corresponding to a connected node.  This format can be mapped into the matlab sparse matrix format, but was
 used for convenient sorting in the algorithms.  The hash tables are structured as described in the appendix of the manuscript.  However,
the degree two hash table only contains the mappings from the degree two reduction.

The 'd1_d2_unstructured_reduction_data_structs.mat' includes hash tables with unstructured lists of all nodes contained in trees and edges in 
the degree one and degree two reductions.  In constrast to the structured data above, the hash table of unstructured degree two reductions also
includes the degree one reductions in this list.

The 'tr_red_no_kv_thresh_degthresh_8.mat' contains the connectivity matrix of the smallest triangle reduced network without a voltage threshold
 and with a degree threshold of 8.  Additionally, this contains the reduction hash table (described in the manuscript) as well as the
unstructured reduction hash table, containing the location of all nodes under mappings in the degree one, degree two and triangle reductions.
Likewise, we include the hash table of all generator locations.  For every field in the generator hash table is listed by the terminal node, or
the pair of nodes defining an edge, of the reduction.  Associated to the field is the list of generator numbers as given in the list in 
'full_network_toy_data.mat'.  We prepend each super node as with the other reductions, indicating if it is a tree or triangle, and seperately
 with 'g\*' if this is only the generator itself. 


## Functions

All subroutines are listed in this directory and are commented in the code.  Drivers in the main directory call these to perform the actual 
reductions.

## License

This project is licensed under the MIT License - see the [License.md](https://github.com/cgrudz/electric_grid_model_reduction/blob/master/LICENSE) file for details

