import camera;
import shape;
import scene;
import material;
import randomValues;
import payload;

struct UnifromBuffer
{
    float4x4 view;
    float4x4 inverseView;
    float4 viewParams; // z - bounce count | w - rays per pixel 
    float4 aditionalParams;
}

struct VertexOutput
{
    float4 sv_position : SV_Position;
    float2 uv;
}

[[vk::binding(0,0)]]
ConstantBuffer<UnifromBuffer> GlobalData;

[[vk::binding(1,0)]]
StructuredBuffer<Sphere> SceneData;

[shader("vertex")]
VertexOutput vertexMain(uint VertexIndex: SV_VertexID)
{
    VertexOutput out;
    out.uv = float2((VertexIndex << 1) & 2, VertexIndex & 2);
    out.sv_position = float4(out.uv * 2.0f - 1.0f, 0.0f, 1.0f);
    return out;
}

[shader("fragment")]
float4 fragmentMain(VertexOutput fsIn) : SV_Target
{
    int bounceCount  = (int)GlobalData.viewParams.z;
    int raysPerPixel = (int)GlobalData.viewParams.w;
    float halfTanFov = GlobalData.viewParams.y;
    float aspect     = GlobalData.viewParams.x;
    

    uint2 numPixels = int2((int)GlobalData.aditionalParams.x, (int)GlobalData.aditionalParams.y);
    uint2 pixelCoord = (fsIn.uv) * numPixels;
    uint pixelIndex = pixelCoord.y * numPixels.x + pixelCoord.x;
    uint u = pixelIndex;

    var camera = PinholeCamera(halfTanFov, aspect, GlobalData.view, GlobalData.inverseView);

    
    var scene = Scene(SceneData);
    
    
    for(int rayPerpixel = 0; rayPerpixel < raysPerPixel; rayPerpixel++){

        RayPayload payLoad = {};
        var ray = camera.GenerateRayToWorld(fsIn.uv * 2.0f - 1.0f);
        int numSamples = 1;

        for(int bounce = 0; bounce < bounceCount; bounce++){
            if(let hit = scene.GetClosestIntersection(ray)){
                
                // we have a hit 
                payLoad.radiance += (hit.material.emmision * hit.material.emissionStrength) * payLoad.throughPut;
    
                var brdf = hit.material.GetBrdf(u);
                var brdfSample = brdf.Sample(-ray.Direction, hit.normal, u);
                
                float3 f = brdf.f(-ray.Direction, hit.normal, brdfSample.wi);
    
                payLoad.throughPut *= f / brdfSample.PDF;
                
                ray.Direction = brdfSample.wi;
                ray.Origin = hit.hitPoint;
                numSamples++;
            }
            // we dont have a hit so accumulate inderect light 
            else{
                float3 skyColour = SampleSkyColour(ray);
                payLoad.radiance += skyColour * payLoad.throughPut;
                break;
            }  
        }
        camera.film += payLoad.radiance;
    }
    camera.film = (1.0/(float)raysPerPixel) * camera.film;


    return float4(camera.film, 1.0); // grayscale
}
