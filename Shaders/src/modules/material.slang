module material;
import randomValues;

/*
Reference for brdfs:
[0] https://github.com/boksajak/referencePT/blob/master/shaders/brdf.h
[1] https://www.pbr-book.org/4ed/Reflection_Models/Specular_Reflection_and_Transmission
*/

public static const float ONE_OVER_PI =     1/float.getPi();
public static const float ONE_OVER_2_PI =   1 / (2* float.getPi());
public static const float TWO_PI =          2 * float.getPi();

public struct Material{
    public float3 albedo = {0.0};
    public float roughnes = {0.0};
    public float metalnes = {0.0};
    public float3 emmision = {0.0};
    public float emissionStrength = {0.0};

    public IBRDF GetBrdf(inout uint u){

        float3 F0 = lerp(float3(0.4), albedo.xyz, metalnes);
        float3 Ks = F0;
        float3 Kd = 1.0 - Ks;

        float p_specular  = max(max(Ks.x, Ks.y), Ks.z);

        bool sampleSpecular = RandomValue(u) < p_specular;
        
        if(sampleSpecular){
            return SpecularBrdf(albedo, roughnes, metalnes);
        }else{
            return DiffuseBrdf(albedo, metalnes);
        }

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
    float3 F0;
    float shnininess = 0.0;

    internal __init(float3 colour, float roughness, float metallnes){
        this.albedo = colour;
        this.roughness = roughness;
        this.metallnes = 1.0 - metallnes;
        this.shnininess = beckmannAlphaToShininess(this.roughness * this.roughness);
        F0 = lerp(0.4, albedo, this.metallnes);
    }



    public float3 f(float3 wo, float3 N, float3 wi){
        float3 R = reflect(-wi, N);
        return F0 * (phongNormalizationTerm(shnininess) * pow(max(0.0f, dot(R, wo)), shnininess) * dot(N, wi));
    }

    // Samples a Phong distribution lobe oriented along +Z axis
    // Source: "Sampling Transformations Zoo" in Ray Tracing Gems by Shirley et al.
    public BrdfSample Sample(float3 wo, float3 N, inout uint u){
        BrdfSample result;

        float2 us = float2(RandomValue(u), RandomValue(u));
        
        float cosTheta = pow(1.0f - us.x, 1.0 / (1.0f + shnininess));
        float sinTheta = sqrt(1.0f - cosTheta * cosTheta);

        float phi = TWO_PI * us.y;

        // specular lobe is scaled by the shininess
        result.PDF =  phongNormalizationTerm(shnininess) * pow(cosTheta, shnininess);
        float3 wi_T = float3(
		    cos(phi) * sinTheta,
		    sin(phi) * sinTheta,
		    cosTheta);
        
        // we use the R as a local frame and not N,
        /*   N *R - this is where we want to sample next ray and not in the normal direction 
             | /
            ----
        */
        float3 R = reflect(-wo, N);

        result.wi = toWorld(wi_T, R);

        return result;
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

internal float3 toWorld(float3 local, float3 N){
    // transfer from local coordinate system to the world coordinate system
    // this is not covered in the workshop please see chapter 3.1 - Coordinate system in PBRT (https://pbr-book.org/4ed/Geometry_and_Transformations/Coordinate_Systems)
    float3 T, B;
    constructLocalFrame(N, T, B);
    return normalize(local.x * T + local.y * B + local.z * N);
}
// Converts Beckmann roughness (alpha) to Phong's exponent (shininess)
// Source: "Microfacet Models for Refraction through Rough Surfaces" by Walter et al.
internal float beckmannAlphaToShininess(float alpha) {
	return 2.0f / min(0.9999f, max(0.0002f, (alpha * alpha))) - 2.0f;
}



// source: https://www.youtube.com/watch?v=Qz0KTGYJtUk&t=2s
public float3 SampleSkyColour(RayDesc ray){
    float3 SkyColorHorizon = float3(1.0, 1.0, 1.0);
    float3 SkyColorZenith = float3(0.4, 0.4, 1.0);
    float3 GroundColor = float3(0.4, 0.4, 0.4);

    float3 ray_d = ray.Direction;

    float skyGradientT = pow(smoothstep(0, 0.4, ray_d.y), 0.35);
    float groundToSkyT = smoothstep(-0.01, 0, ray_d.y);
    float3 skyGradient = lerp(SkyColorHorizon, SkyColorZenith, skyGradientT);
        
    return lerp(GroundColor, skyGradient, groundToSkyT);
}
