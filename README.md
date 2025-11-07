# Workshop (Ray tracing in one hour)

In this workshop you will implement non-physically based path tracer that runs on your graphics card in real time.

The results of the workshop should look similar to this picture.

![](readme-images/end.png)

While the path tracer wont be physically based, its implementation will include propper monte carlo estimator to help us evaluate light transport equation. Starting code is implemented in such ways that you can further expand on the material presented in the workshop. This would include:

- ading other shapes
- adding physically correct specular reflections using differnet BRDFs etc.

## Building and running the program.

3 requirements must be met:

1. your GPU (either discrete or embedded) supports `Vulkan 1.3` (read more [here](https://docs.vulkan.org/guide/latest/checking_for_support.html))
2. you must have `python` installed.
3. you must download the `Slang` compiler
