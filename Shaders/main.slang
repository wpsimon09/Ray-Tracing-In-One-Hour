import camera;
import scene;

struct UnifromBuffer
{
    float4x4 model;
    float4x4 view;
    float4x4 proj;
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
    return float4(SceneData[0].colour.xyz,  1.0);
}
