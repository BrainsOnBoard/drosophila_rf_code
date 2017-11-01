This folder contants the data for the kernels (RFs).

vf_kernels.mat          => thresholded kernels
vf_kernels_nothresh.mat => unthresholded (but normalised kernels)

You should use the unthresholded kernels.

The variables of interest in these files are:
- vf_kernels_r2 and vf_kernels_r4     => original RFs for individual flies
- vf_avkernels_r2 and vf_avkernels_r4 => our averaged kernels across flies
- neuroncolormap                      => used for rendering the RFs in figures

The vf_* variables are struct arrays with the following fields:
- k       => actual kernel/RF as a matrix
- glomnum => glomerulus number
- flynum  => fly number (from Seelig & Jayaraman's original paper)
- cent    => centroid of RF (see Methods in paper)
- isleft  => whether kernel is LHS/RHS version

