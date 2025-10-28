import camera;
import shape;

struct UnifromBuffer
{
    float4x4 view;
    float4x4 inverseView;
    float4 viewParams;
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
    float halfTanFov = GlobalData.viewParams.y;
    float aspect = GlobalData.viewParams.x;
    
    var camera = PinholeCamera(halfTanFov, aspect, GlobalData.view, GlobalData.inverseView);

    var ray = camera.GenerateRayToWorld(fsIn.uv * 2.0f - 1.0f);

    return float4(ray.Direction,  1.0);
}
