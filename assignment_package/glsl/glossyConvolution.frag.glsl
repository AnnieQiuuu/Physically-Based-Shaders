#version 330 core

// Compute the irradiance within the glossy
// BRDF lobe aligned with a hard-coded wi
// that will equal our surface normal direction.
// Our surface normal direction is normalize(fs_Pos).

in vec3 fs_Pos;
out vec4 out_Col;
uniform samplerCube u_EnvironmentMap;
uniform float u_Roughness;

const float PI = 3.14159265359;


vec3 ImportanceSampleGGX(vec2 Xi, vec3 N, float roughness)
{
    float a = roughness*roughness;

    float phi = 2.0 * PI * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);

    // from spherical coordinates to cartesian coordinates
    vec3 wh;
    wh.x = cos(phi) * sinTheta;
    wh.y = sin(phi) * sinTheta;
    wh.z = cosTheta;

    // from tangent-space vector to world-space sample vector
    vec3 up        = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
    vec3 tangent   = normalize(cross(up, N));
    vec3 bitangent = cross(N, tangent);

    vec3 whW = tangent * wh.x + bitangent * wh.y + N * wh.z;
    return normalize(whW);
}

float RadicalInverse_VdC(uint bits)
{
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

//Generate well-distributed set of points within a [0,1] square
vec2 Hammersley(uint i, uint N)
{
    return vec2(float(i)/float(N), RadicalInverse_VdC(i));
}

float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;

    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return a2 / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float a = roughness;
    float k = (a * a) / 2.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

void main() {
    // TODO

    // Prefiltered convolution
    vec3 N = normalize(fs_Pos); // Use normalized fragment position as the normal for this example.
    vec3 wo = N; // Assuming view direction is the same as the normal.
    vec3 R = wo; // Reflection vector same as view, for simplification.

    const uint SAMPLE_COUNT = 1024u; // Number of samples for pre-computation.
    vec3 prefilteredLi = vec3(0.0);
    float totalWeight = 0.0;

    for(uint i = 0u; i < SAMPLE_COUNT; ++i) {
        vec2 Xi = Hammersley(i, SAMPLE_COUNT);
        vec3 wh = ImportanceSampleGGX(Xi, N, u_Roughness);
        vec3 wi = normalize(2.0 * dot(wo, wh) * wh - wo);

        float NdotL = max(dot(N, wi), 0.0);
        if(NdotL > 0.0) {

            // Calculate mip level based on roughness and PDF
            float D = DistributionGGX(N, wh, u_Roughness);
            float nDotwh = max(dot(N,wh),0.0);
            float woDotwh = max(dot(wh,wo),0.0);
            float pdf = D * nDotwh / (4.0 * woDotwh) + 0.0001;
            //resolution = 1024
            //midMaps
            float saTexel = 4.0 * PI / (6.0 * 1024.0 * 1024.0);
            float saSample = 1.0 / (float(SAMPLE_COUNT) * pdf + 0.0001);
            float mipLevel = u_Roughness == 0.0 ? 0.0 : 0.5 * log2(saSample / saTexel);

            // Use the calculated mip level for sampling
            vec3 sampleColor = textureLod(u_EnvironmentMap, wi, mipLevel).rgb;
            prefilteredLi += sampleColor * NdotL;
            totalWeight += NdotL;
        }
    }

    prefilteredLi = prefilteredLi / totalWeight;

    out_Col = vec4(prefilteredLi, 1.0);
//    out_Col = vec4(1.0);
}
