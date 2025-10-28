module camera;

public struct PinholeCamera{
    float4x4 worldToCamera;
    float4x4 cameraToWorld;
    float tan2half = {0.0f};
    float aspect = {0.0f};

    public float3 film = {0.0f};

    __init(float tan2half, float aspect, float4x4 view, float4x4 inverseView){
        this.tan2half = tan2half;
        this.aspect = aspect;
        this.worldToCamera = view;
        this.cameraToWorld = inverseView;
    }

    public RayDesc GenerateRayToWorld(){
        return RayDesc();    
    }

    private RayDesc RayToWorld(RayDesc inray){
        RayDesc ray_ws;
        ray_ws.Direction = mul((float3x3)cameraToWorld, inray.Direction);
        ray_ws.Origin = cameraToWorld._m30_m31_m32;
        ray_ws.TMin  = inray.TMax;
        ray_ws.TMax = inray.TMin;
    }

}