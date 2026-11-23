#version 330

// Input
in vec2 texture_coord;

// Uniform properties
uniform sampler2D textureImage;
uniform ivec2 screenSize;
uniform int flipVertical;
uniform int outputMode = 2; // 0: original, 1: grayscale, 2: blur

// Output
layout(location = 0) out vec4 out_color;

// Local variables
vec2 textureCoord = vec2(texture_coord.x, (flipVertical != 0) ? 1 - texture_coord.y : texture_coord.y); // Flip texture


vec4 grayscale()
{
    vec4 color = texture(textureImage, textureCoord);
    float gray = 0.21 * color.r + 0.71 * color.g + 0.07 * color.b; 
    return vec4(gray, gray, gray,  0);
}

const int MAX_KERNEL_SIZE = 3;
vec4 median(const int kernelSize)
{
    vec4 values[MAX_KERNEL_SIZE * MAX_KERNEL_SIZE];
    vec2 texelSize = 1.0 / screenSize;
    int idx = 0;

    // extract values
    for(int k = -kernelSize/2; k <= kernelSize/2; k++)
    {
        for(int l = -kernelSize/2; l <= kernelSize/2; l++)
        {
            values[idx] = texture(textureImage, textureCoord + vec2(k,l) * texelSize);
            idx++;
        }
    }

    // sort values
    for(int k = 0; k < kernelSize * kernelSize; k++)
    {
        for(int l = k; l < kernelSize * kernelSize; l++)
        {
            float s1 = values[k].x + values[k].y + values[k].z; 
            float s2 = values[l].x + values[l].y + values[l].z; 
                    
            if (s1 > s2){
                vec4 tmp = values[k];
                values[k] = values[l];
                values[l] = tmp;
            }
        }
    }

    // update values
    vec4 med = values[kernelSize * kernelSize / 2];
    return med;
}

vec4 blur(int blurRadius)
{
    vec2 texelSize = 1.0f / screenSize;
    vec4 sum = vec4(0);
    for(int i = -blurRadius; i <= blurRadius; i++)
    {
        for(int j = -blurRadius; j <= blurRadius; j++)
        {
            sum += texture(textureImage, textureCoord + vec2(i, j) * texelSize);
        }
    }
        
    float samples = pow((2 * blurRadius + 1), 2);
    return sum / samples;
}


void main()
{
    switch (outputMode)
    {
        case 1:
        {
            out_color = grayscale();
            break;
        }

        case 2:
        {
            out_color = blur(3);
            break;
        }

        case 3:
        {
            out_color = median(3);
            break;
        }

        default:
            out_color = texture(textureImage, textureCoord);
            break;
    }
}
