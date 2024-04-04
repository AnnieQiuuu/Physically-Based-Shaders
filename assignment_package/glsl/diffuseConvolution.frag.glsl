#version 330 core

// Compute the irradiance across the entire
// hemisphere aligned with a surface normal
// pointing in the direction of fs_Pos.
// Thus, our surface normal direction
// is normalize(fs_Pos).

in vec3 fs_Pos;
out vec4 out_Col;
uniform samplerCube u_EnvironmentMap;

const float PI = 3.14159265359;

void main()
{
    // TODO
    vec3 normal = normalize(fs_Pos);
    vec3 irradiance = vec3(0.);
    vec3 up    = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(up, normal));
    up = normalize(cross(normal, right));

    //Iteracte across phi and theta to sample hemisphere
    float sampleDelta = 0.025;
    float nrSamples = 0.0;
    for(float phi = 0.0; phi < 2.0 * PI; phi += sampleDelta)
    {
        for(float theta = 0.0; theta < 0.5 * PI; theta += sampleDelta)
        {

            //sampled direction to world space
            vec3 wi = vec3(sin(theta) * cos(phi),  sin(theta) * sin(phi), cos(theta));

            vec3 wiW = wi.x * right + wi.y * up + wi.z * normal;

            irradiance += texture(u_EnvironmentMap, wiW).rgb * cos(theta) * sin(theta);

            nrSamples++;
        }
    }
    irradiance = PI * irradiance  / float(nrSamples);

    out_Col = vec4(irradiance,1.0);
}
