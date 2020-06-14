This archive contains an example implementation of epipolar geometry solver 
solver F10e (10pt solver for F_l1l2 problem based on the Groebner basis method 
and eigendecomposition) presented in

Zuzana Kukelova, Jan Heller, Martin Bujnak, Andrew Fitzgibbon, Tomas Pajdla: 
Efficient Solution to the Relative Pose Problem for Radially Distorted Cameras,
The IEEE International Conference on Computer Vision (ICCV) 2015.

Please cite this work when using this code for academic purposes:

@InProceedings{Kukelova_2015_ICCV,
    author = {Kukelova, Zuzana and Heller, Jan and Bujnak, Martin and Fitzgibbon, Andrew and Pajdla, Tomas},
    title = {Efficient Solution to the Epipolar Geometry for Radially Distorted Cameras},
    booktitle = {The IEEE International Conference on Computer Vision (ICCV)},
    month = {December},
    year = {2015}
} 

The solver resides in subdirectory 'src', they are implemented in C++ and depend on
Eigen linear algebra library (eigen.tuxfamily.org). The subdirectory 'matlab' 
contains a sample MATLAB application 'demo.m' demonstrating the solver
capabilities and usage. The solvers as well as the demo application are
distributed under New BSD Licence.

The demo uses parts of LVFeat library (vlfeat.org) which is distributed under
BSD Licence. 
