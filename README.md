Name: Annie Qiu
Pennkey: annieqiu
======================
Physically-Based Shaders Part II: Environment Maps
======================

My results
------------
0% metallic, 0% rough, RBG = 1 1 1

![](./results/pic1.png)

100% metallic, 0% rough, RGB = 1 1 1

![](./results/pic2.png)

100% metallic, 25% rough, RGB = 1 1 1

![](./results/pic3.png)

cerberus.json

![](./results/pic4.png)

Overview
------------
You will take what you learned in part I of this physically-based shader assignment and
combine it with the pre-computation of irradiance applied to the plastic-metallic BRDF.
Recall that the overall formula for this BSDF is <img src="https://render.githubusercontent.com/render/math?math=\color{grey}f(\omega_o, \omega_i) = k_D f_{Lambert}( \omega_o, \omega_i)"> + <img src="https://render.githubusercontent.com/render/math?math=\color{grey}k_S f_{Cook-Torrance}(\omega_o, \omega_i)">

Here are some example screenshots of what your implementation should look like with varying amounts of roughness and metallicness:

![](defaultAttribs.png)

![](fullMetal0Rough.png) ![](fullMetal25Rough.png)

![](fullMetal50Rough.png) ![](fullMetal75Rough.png)

![](fullMetalFullRough.png)

The Light Transport Equation
--------------
#### L<sub>o</sub>(p, &#969;<sub>o</sub>) = L<sub>e</sub>(p, &#969;<sub>o</sub>) + &#8747;<sub><sub>S</sub></sub> f(p, &#969;<sub>o</sub>, &#969;<sub>i</sub>) L<sub>i</sub>(p, &#969;<sub>i</sub>) V(p', p) |dot(&#969;<sub>i</sub>, N)| _d_&#969;<sub>i</sub>

* __L<sub>o</sub>__ is the light that exits point _p_ along ray &#969;<sub>o</sub>.
* __L<sub>e</sub>__ is the light inherently emitted by the surface at point _p_
along ray &#969;<sub>o</sub>.
* __&#8747;<sub><sub>S</sub></sub>__ is the integral over the sphere of ray
directions from which light can reach point _p_. &#969;<sub>o</sub> and
&#969;<sub>i</sub> are within this domain.
* __f__ is the Bidirectional Scattering Distribution Function of the material at
point _p_, which evaluates the proportion of energy received from
&#969;<sub>i</sub> at point _p_ that is reflected along &#969;<sub>o</sub>.
* __L<sub>i</sub>__ is the light energy that reaches point _p_ from the ray
&#969;<sub>i</sub>. This is the recursive term of the LTE.
* __V__ is a simple visibility test that determines if the surface point _p_' from
which &#969;<sub>i</sub> originates is visible to _p_. It returns 1 if there is
no obstruction, and 0 is there is something between _p_ and _p_'. This is really
only included in the LTE when one generates &#969;<sub>i</sub> by randomly
choosing a point of origin in the scene rather than generating a ray and finding
its intersection with the scene.
* The __absolute-value dot product__ term accounts for Lambert's Law of Cosines.