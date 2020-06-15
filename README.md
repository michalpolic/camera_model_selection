<p align="center"><iframe width="560" height="315" src="https://www.youtube.com/embed/grPFAf0Ul3g" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</p>
<p>

This is a project page dedicated to our CVPR 2020 paper.<br><br>

For more information see <a href="http://openaccess.thecvf.com/content_CVPR_2020/html/Polic_Uncertainty_Based_Camera_Model_Selection_CVPR_2020_paper.html">the paper</a> and <a href="http://147.32.71.15">our demo website</a><br><br>
</p>

# Motivation
SfM pipelines use many parameters that are hard to set in practice. A crucial parameter to set is the camera model to be used. In fact, every geometrical solver is derived for one particular camera model and the nonextistence of automatic metod for model selection force the user to choose it manualy.
  
* Using a too simple camera model may lead to under-fitting and inaccurate reconstruction.
* Using too complex model may lead to over-fitting the data and result in degeneracies.  
* The ultimate goal of a camera model selection method is to select a ”good” model where (i) all images are registered, (ii) the reprojection error is minimal, and (iii) the number of parameters is small. This goal is very hard to reach in practice.


# Contribution
We present extensive comparison of standard, robust, and geometrical information criteria on the importatnt task of radial distortion model selection.

We present a new way to
* Significantly increase in the reconstruction quality as well as speedup of the reconstruction process by automatic camera selection
* Evaluate the quality of the scene by Accuracy-based Criterion (AC)
* Propose model Selection method (ACS) and fine tuned learned LACS method for radial distortion selection


## The idea
Select the camera model leading to the most accurate reconstruction, e.g., the most accurate camera poses and positions of points in 3D.


If a device ( e.g. a smartphone) with two RS cameras moves, the images contain distortions. In current devices the cameras both use identical readout directions, which causes the distortions to look identical.

<p align="center">
<img src="imgs/arrow_text_down.png"  height="150"/>
<img src="imgs/phone_identical_no_arrows.jpg" height="150"/>
<img src="imgs/arrow_text_down.png"  height="150"/>
</p>

Our idea is to **roll the shutters in the opposite directions**.  

<p align="center">
<img src="imgs/arrow_text_down.png"  height="150"/>
<img src="imgs/phone_opposite_no_arrows.jpg"  height="150"/>
<img src="imgs/arrow_text_up.png"  height="150"/>
</p>

Having such differences in the distortion allows us to compute the motion of the device from a few sparse correspondences.  
  
The motion parameters can then be used to e.g. undistort the image:  

<p align="center">
<img src="imgs/re_rot4.jpg" height="300" alt="down"/>
</p>

## Examples

Here is another example of identical RS readout directions:

<p float="left" align="center">
<img src="imgs/anim_down.gif"  height="150"/>
<img src="imgs/arrow_text_down.png"  height="150"/>
<img src="imgs/anim_down.gif"  height="150"/>
<img src="imgs/arrow_text_down.png"  height="150"/>
</p>

and opposite directions:

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
