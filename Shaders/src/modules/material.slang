module material;
import randomValues;

/*
Reference for brdfs:
[0] https://github.com/boksajak/referencePT/blob/master/shaders/brdf.h
[1] https://www.pbr-book.org/4ed/Reflection_Models/Specular_Reflection_and_Transmission
*/

public static const float ONE_OVER_PI = 1/float.getPi();
public static const float ONE_OVER_2_PI = 1 / (2* float.getPi());
public static const float TWO_PI = 2 * float.getPi();

public struct Material{
    public float3 albedo = {0.0};
    public float roughnes = {0.0};
    public float metalnes = {0.0};
    public float3 emmision = {0.0};
    public float emissionStrength = {0.0};

    public IBRDF GetBrdf(){
        return DiffuseBrdf(albedo, metalnes);
    }
}

public struct BrdfSample{
    public float3 wi;
    public float PDF;
}

public interface IBRDF{
 
    public float3 f(float3 wo, float3 N, float3 wi);
    public BrdfSample Sample(float3 wo, float3 N, inout uint u);
}

public struct DiffuseBrdf : IBRDF{
    internal __init(float3 colour, float metalness){
        albedo = colour;
        this.metalness = metalness;
    }

    float3 albedo;
    float metalness;

    public float3 f(float3 wo, float3 N, float3 wi){ 
        float3 diffuseReflectance = albedo * (1.0 - metalness);

        if(dot(N, wo) <= 0.0f){
            return float3(0.0f);
        }
        float cosTheta = max(dot(N, wo), 0.001);
        return diffuseReflectance * (ONE_OVER_PI * cosTheta);
    }

    public BrdfSample Sample(float3 wo, float3 N, inout uint u){
        BrdfSample sample;
        
        // sample cosine weighted hemisphere 
        float2 us;
        us.x = RandomValue(u);
        us.y = RandomValue(u);
    

        float a = sqrt(us.x);
        float b = 2 * float.getPi() * us.y;

        float3 result = float3(
            a * cos(b),
            a * sin(b),
            sqrt(1.0f - us.x)
        );

        // go from tangent space to the world space for cosine calculation
        float3 dir_Ws = toWorld(result, N,);

        sample.PDF =  result.z * (1.0 / float.getPi());
        
        sample.wi = dir_Ws;
        return sample;
    }
}

public struct  SpecularBrdf : IBRDF{
    float3 albedo;
    float roughness;
    float metallnes;

    internal __init(float3 colour, float roughness, float metallnes){
        albedo = colour;
        roughness = roughness;
        metallnes = metallnes;
    }



    public float3 f(float3 wo, float3 N, float3 wi){
        float alpha = roughness * roughness; // see Diney`s paper for alpha 
        float shnininess = beckmannAlphaToShininess(alpha);

        float cosTheta = dot(N, wo);
        float3 F = fresnellShlick(cosTheta, albedo, metallnes);
        float3 R = reflect(-wi, N);

        return F * phongNormalizationTerm(shnininess) * pow(max(0.0, dot(R, wo)), shnininess) * cosTheta;
    }

    public BrdfSample Sample(float3 wo, float3 N, inout uint u){

    }
}

// For derivation see "Phong Normalization Factor derivation" by Giesen
float phongNormalizationTerm(float shininess) {

	return (1.0f + shininess) * ONE_OVER_2_PI;
}

internal void constructLocalFrame(float3 N, out float3 T, out float3 B){
    // construct local frame for sampling 
    float3 up = (fabs(N.z) < 0.999f) ? float3(0.0f, 0.0f, 1.0f)
                        : float3(1.0f, 0.0f, 0.0f);

    T = normalize(cross(up, N));
    B = cross(N, T);
}

internal float3 toLocal(float3 world, float3 N){
    float3 T, B;
    constructLocalFrame(N, T, B);
    return float3(dot(world, T), dot(world, B), dot(world, N));
}

// Converts Beckmann roughness (alpha) to Phong's exponent (shininess)
// Source: "Microfacet Models for Refraction through Rough Surfaces" by Walter et al.
internal float beckmannAlphaToShininess(float alpha) {
	return 2.0f / min(0.9999f, max(0.0002f, (alpha * alpha))) - 2.0f;
}

// Approximation for Fresnel term of the specular reflection evaluation
// fresnell term is dependand on the direction and gives how much light is reflected and refracted from the surface 
// Srouce: https://en.wikipedia.org/wiki/Schlick%27s_approximation
internal float3 fresnellShlick(float cosTheta, float3 albedo, float metallnes )
{

    float3 F0 = float3(0.4);
    F0 = lerp(F0, albedo.xyz, metallnes);
            return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

internal float3 toWorld(float3 local, float3 N){
    // transfer from local coordinate system to the world coordinate system
    // this is not covered in the workshop please see chapter 3.1 - Coordinate system in PBRT (https://pbr-book.org/4ed/Geometry_and_Transformations/Coordinate_Systems)
    float3 T, B;
    constructLocalFrame(N, T, B);
    return normalize(local.x * T + local.y * B + local.z * N);
}

public float3 SampleSkyColour(RayDesc ray){
    float3 skyTop    = float3(0.2, 0.4, 0.9); // blue sky
    float3 skyBottom = float3(0.6, 0.6, 0.6); // gray horizon
        
    // Clamp direction.y to [0,1] for gradient interpolation
    float t = saturate(ray.Direction.y * 0.5f + 0.5f);
        
    // Optionally make gradient more curved
    t = pow(t, 1.5f);
        
    return lerp(skyBottom, skyTop, t);
}
