<p align="center"><iframe width="1024" height="576" src="https://www.youtube.com/embed/grPFAf0Ul3g" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</p>
<p>

This is a project page dedicated to our CVPR 2020 paper.<br><br>

For more information see <a href="http://openaccess.thecvf.com/content_CVPR_2020/html/Polic_Uncertainty_Based_Camera_Model_Selection_CVPR_2020_paper.html">the paper</a> and <a href="http://147.32.71.15">our demo website</a><br><br>
</p>

# Motivation
SfM pipelines use many configuration parameters that are hard to set in practice. A crucial parameter to set is the camera model to be used. In fact, every geometrical solver is derived for one particular camera model and the nonextistence of automatic metod for model selection force the user to choose it manualy.
  
* Using a too simple camera model may lead to under-fitting and inaccurate reconstruction.
* Using too complex model may lead to over-fitting the data and result in degeneracies.  
* The ultimate goal of a camera model selection method is to select a ”good” model where (i) all images are registered, (ii) the reprojection error is minimal, and (iii) the number of parameters is small. This goal is very hard to reach in practice.

<p align="center">
<img src="web/images/model_comparison.png" height="200"/>
</p>

# Contribution
We present extensive comparison of standard, robust, and geometrical information criteria on the importatnt task of radial distortion model selection. Motivated by bad results we present a new way to
* Significantly increase in the reconstruction quality as well as speedup of the reconstruction process by automatic camera model selection
* Evaluate the quality of the scene by Accuracy-based Criterion (AC)
* Propose model Selection method (ACS) and fine tuned learned LACS method for radial distortion model selection


## The idea
The idea is to create unique quality measurement for the reconstructions form images. We propose to use the accuracy of calculated parameters (AC), i.e., the accuracy of camera poses and the positions of points in 3D, as such scene quality measurement. The quality measurement will provide an order of suitability of camera models and select the best one, i.e., the camera model leading to the most accurate reconstruction.

We can propagate the accuracy of 2D observations in images into the 3D scene, see <a href="https://michalpolic.github.io/usfm.github.io">USfM framework</a> for details. 
<p align="center">
<img src="web/images/uncertainty.png" height="200"/>
</p>

To compare the suitability of several camera models, we need to calculate a small sub-reconstructions from a subset of images and propagate the accuracy of observations into 3D scenes. 

The comparable covariance matrices are achieved by (i) aligning coordinate systems of sub-reconstructions before uncertaitny propagation and (ii) fixing the gauge of covariance matrix using suitable S-transoformation. 

Please see our <a href="http://openaccess.thecvf.com/content_CVPR_2020/html/Polic_Uncertainty_Based_Camera_Model_Selection_CVPR_2020_paper.html">paper</a> for more details.


## Examples

The camera model for real data is unknow and therefore we evaluated correctnes of this methos on large amount of various synthetic scenes. The folowing sucess rate of correctly estimated camera model was evaluated from 72000 synthetic datasets simulating real cameras and 3D scenes, for different camera models, outlier and noise contamination.

<p align="center">
<img src="web/images/synthetic_01.png" height="200"/>
<img src="web/images/synthetic_02.png" height="200"/>
</p>



-----------------------------------------------------------------
TODO:

<p float="left" align="center">
<img src="imgs/anim_down.gif"  height="150"/>
<img src="imgs/arrow_text_down.png" height="150"/>
<img src="imgs/anim_up.gif" height="150"/>
<img src="imgs/arrow_text_up.png" height="150"/>
</p>

We can warp both input images and then combine them to obtain a more complete undistorted image:

<p align="center">
<img src="imgs/rot11_combined_res.jpg" height="300"/>
</p>

For smartphones it is typical that one camera has a different FOV due to e.g. a telephoto lens. We show that even such combination can be efficiently used:

<table style="margin: 0px auto;">
	<tr>
		<td>Wide</td>
		<td>Zoom</td>
		<td>Undistorted</td>
	</tr>
	<tr>
		<td><img src="imgs/wide_features.jpg" height="150"/></td>
		<td><img src="imgs/narrow_features.jpg" height="150"/></td>
		<td><img src="imgs/wide_narrow_undist.jpg" height="150"/></td>
	</tr>
</table>

If the motion contains also translation:

<p float="left" align="center">
<img src="imgs/re_tr17_1.jpg" height="150"/>
<img src="imgs/re_tr17_2.jpg" height="150"/>
</p>

We can obtain dense correspondences using e.g. optical flow and using the motion parameters we can compute the depth for each pixel:

<p float="left" align="center">
<img src="imgs/tr17_depth_fused.png" height="150"/>
</p>

And backproject to create and undistorted image: 

<p float="left" align="center">
<img src="imgs/tr17_res.jpg" height="150"/>
</p>

Note that the quality of the result will depend on the quality of the correspondences. The few artefacts are caused by having imperfect optical flow. We did not use any post-processing methods to remove those artefacts.  
  
We can also correct the sparse correspondences and use them in a traditional SfM pipeline to obtain a better 3D reconstruction than with the RS images.

<table style="margin: 0px auto;">
	<tr>
		<td>Sparse features image 1</td>
		<td>Sparse features image 2</td>
		<td>Undistorted sparse features</td>
	</tr>
	<tr>
		<td><img src="imgs/sparse_cam1.jpg" height="150"/></td>
		<td><img src="imgs/sparse_cam2.jpg" height="150"/></td>
		<td><img src="imgs/sparse_undist.png" height="150"/></td>
	</tr>
</table>

And here is the result of the 3D reconstruction for the original RS images, our undistorted ones and images captured by a GS camera:

<p float="left" align="center">
<img src="imgs/sfm.jpg"/>
</p>

## The method
Here is a diagram briefly describing the workflows depending on the motion we want to model.
<p align="center">
<img src="imgs/method_poster_section_6dof.png"/>
&nbsp;&nbsp;&nbsp;&nbsp;
<img src="imgs/method_poster_section_rot.png"/>
</p>

## License
Patent pending. For more information please contact: cenek.albl@gmail.com .
