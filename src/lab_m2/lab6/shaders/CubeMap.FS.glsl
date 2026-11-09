#version 330

// Input
in vec3 world_position;
in vec3 world_normal;

// Uniform properties
uniform samplerCube texture_cubemap;
uniform int type;

uniform vec3 camera_position;

// Output
layout(location = 0) out vec4 out_color;


// Returns the reflection DIRECTION; it must be used to sample the cubemap
vec3 myReflect()
{
    // TODO(student): Compute the reflection color value
    vec3 incident = normalize(world_position - camera_position);
    return reflect(incident, normalize(world_normal));
}


// Returns the refraction DIRECTION; it must be used to sample the cubemap
vec3 myRefract(float refractive_index)
{
    // TODO(student): Compute the refraction color value
    vec3 incident = normalize(world_position - camera_position);
    return refract(incident, normalize(world_normal), refractive_index);
}


void main()
{

    if (type == 0)
    {
        out_color = vec4(texture(texture_cubemap, myReflect()).rgb, 1);
    }
    else
    {
        out_color = vec4(texture(texture_cubemap, myRefract(1.0/1.33)).rgb, 1);
    }
}
