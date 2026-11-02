#version 430

// Input
layout(location = 0) in vec2 texture_coord;
layout(location = 1) in float geom_lifetime;
layout(location = 2) in float geom_iLifetime;

// Uniform properties
uniform sampler2D texture_1;

// Output
layout(location = 0) out vec4 out_color;


void main()
{
    float lifetime_ratio = clamp(geom_lifetime / geom_iLifetime, 0.0, 1.0);
    int fire_stage = clamp(3 - int(lifetime_ratio / 0.25f), 0, 3);

    // TODO(student): Compute texture coordinates so that,
    // depending on the fire stage (0, 1, 2, 3), a different
    // image of a fire particle is shown.
    // Hint: each stage corresponds to a quarter of the image

    vec2 tex_coord = vec2(texture_coord.x * 0.25f + float(fire_stage) * 0.25f, texture_coord.y);
    
    vec3 color = texture(texture_1, tex_coord).xyz;
    out_color = vec4(color, 1);
}
