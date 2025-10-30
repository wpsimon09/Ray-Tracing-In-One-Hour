module material;
import randomValues;

public static const float ONE_OVER_PI = 1/float.getPi();

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


internal void constructLocalFrame(float3 N, out float3 T, out float3 B){
    // construct local frame for sampling 
    float3 up = (fabs(N.z) < 0.999f) ? float3(0.0f, 0.0f, 1.0f)
                        : float3(1.0f, 0.0f, 0.0f);

    T = normalize(cross(up, N));
    B = cross(N, T);
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
