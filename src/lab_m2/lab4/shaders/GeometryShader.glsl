#version 330

// Input and output topologies
// TODO(student): First, generate a curve (via line strip),
// then a rotation/translation surface (via triangle strip)
layout(lines) in;
layout(triangle_strip, max_vertices = 256) out;

// Uniform properties
uniform mat4 View;
uniform mat4 Projection;
uniform vec3 control_p0, control_p1, control_p2, control_p3;
uniform int no_of_instances;

// [DONE] TODO(student): Declare any other uniforms here
uniform int no_of_generated_points;
uniform float max_translate;
uniform float max_rotate;
uniform int surface_type;

// Input
in int instance[2];


vec3 rotateY(vec3 point, float u)
{
    float x = point.x * cos(u) - point.z *sin(u);
    float z = point.x * sin(u) + point.z *cos(u);
    return vec3(x, point.y, z);
}


vec3 translateX(vec3 point, float t)
{
    return vec3(point.x + t, point.y, point.z);
}


// This function computes B(t) with 4 control points. For a visual example,
// see [1]. For an interactive Javascript example with the exact points in
// this code, see [2].
//
// [1] https://www.desmos.com/calculator/cahqdxeshd
// [2] https://jsfiddle.net/6yuv9htf/
vec3 bezier(float t)
{
    return  control_p0 * pow((1 - t), 3) +
            control_p1 * 3 * t * pow((1 - t), 2) +
            control_p2 * 3 * pow(t, 2) * (1 - t) +
            control_p3 * pow(t, 3);
}


// TODO(student): If you want to take things a step further, try drawing a
// Hermite spline. Hint: you can repurpose two of the control points. For a
// visual example, see [1]. For an interactive Javascript example with the
// exact points in this code, see [2].
// 
// Unlike the Javascript function, you MUST NOT call the Bezier function.
// There is another way to draw a Hermite spline, all you need is to find
// the formula.
//
// [1] https://www.desmos.com/calculator/5knm5tkr8m
// [2] https://jsfiddle.net/6yuv9htf/

void main()
{
    const int SURFACE_TYPE_ROTATION     = 0;
    const int SURFACE_TYPE_TRANSLATION  = 1;

    // Each instance draws one band between two adjacent curves. The bands
    // together cover max_rotate (rotation) or max_translate (translation).
    float band_angle = max_rotate / no_of_instances;
    float band_width = max_translate / no_of_instances;
    float angle_a = instance[0] * band_angle;
    float angle_b = (instance[0] + 1) * band_angle;
    float offset_a = instance[0] * band_width;
    float offset_b = (instance[0] + 1) * band_width;

    // Sample both ends of the curve, so t goes from 0 to 1 inclusive
    float step = 1.0 / (no_of_generated_points - 1);
    for (int i = 0; i < no_of_generated_points; i++) {
        vec3 p = bezier(i * step);
        vec3 pa, pb;

        if (surface_type == SURFACE_TYPE_ROTATION) {
            pa = rotateY(p, angle_a);
            pb = rotateY(p, angle_b);
        } else {
            pa = translateX(p, offset_a);
            pb = translateX(p, offset_b);
        }

        gl_Position = Projection * View * vec4(pa, 1);   EmitVertex();
        gl_Position = Projection * View * vec4(pb, 1);   EmitVertex();
    }
    EndPrimitive();

}
