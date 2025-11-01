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

//============================================================
// This piece of code is running on every pixel in the window

[shader("fragment")]
float4 fragmentMain(VertexOutput fsIn) : SV_Target
{
    // required data for ray tracing 
    int bounceCount  = (int)GlobalData.viewParams.z;
    int raysPerPixel = (int)GlobalData.viewParams.w;
    float halfTanFov = GlobalData.viewParams.y;
    float aspect     = GlobalData.viewParams.x;
    uint2 numPixels = int2((int)GlobalData.aditionalParams.x, (int)GlobalData.aditionalParams.y);
    uint2 pixelCoord = (fsIn.uv) * numPixels;
    uint pixelIndex = pixelCoord.y * numPixels.x + pixelCoord.x;
    uint u = pixelIndex;

    //=================================
    // We start here 



    return float4(fsIn.uv, 1.0); // colour that this pixel will have (float4 = r, g, b, a)
}