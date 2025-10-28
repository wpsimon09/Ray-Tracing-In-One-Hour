module camera;

public struct PinholeCamera{
    float4x4 worldToCamera;
    float4x4 cameraToWorld;
    float tan2fov = {0.0f};
    float aspect = {0.0f};

    public float3 film = {0.0f};

    public __init(float tan2fov, float aspect, float4x4 view, float4x4 inverseView){
        this.tan2fov = tan2fov;
        this.aspect = aspect;
        this.worldToCamera = view;
        this.cameraToWorld = inverseView;
    }

    public RayDesc GenerateRayToWorld(float2 pixelPos){
        float2 pixel = float2(pixelPos.x, -pixelPos.y);

        float tanHalfFovX  = tan2fov * aspect;
        float tanHalfFovY  = tan2fov;

        float3 direction = normalize(float3(
            pixel.x * tanHalfFovX,
            pixel.y * tanHalfFovY,
            -1.0f));  


        return RayToWorld(RayDesc(float3(0.0f), 0.0f, direction, 10000.0f));        
    }

    private RayDesc RayToWorld(RayDesc inRay){
        RayDesc result;
        result.TMax = inRay.TMax;
        result.TMin = inRay.TMin;
        result.Direction = mul(float3x3(cameraToWorld), inRay.Direction);
        // third row in inverse view is camera position 
        result.Origin = float3(cameraToWorld._m03, cameraToWorld._m13, cameraToWorld._m23);
        return result;
    }

}