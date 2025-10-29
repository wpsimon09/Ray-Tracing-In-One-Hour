module shape;
import material;
//https://github.com/wpsimon09/Vulkan-RTX/blob/74341633b02a51f051da6a0be289335228977895/Shaders/Fragment/RayTracer.frag.slang


public struct IntersectionInfo{
    public float t = {float.maxValue};
    public float3 hitPoint = {0.0};
    public float3 normal = {0.0};
    public Material material = {};
    public float3 alebdo = {0.0};
} 

public interface IShape{
    public Optional<IntersectionInfo> Intersects(RayDesc ray);
    public bool IntersectsRayP(RayDesc ray);
}

public struct Sphere : IShape{
    internal float4 position; // xyz: positon | w: radius
    internal float4 colour;  // xyz: rgb | w: empty
    internal float4 matrialProperties; // x: roughness | y: metalness | z: emission | w: unused

    public Optional<IntersectionInfo> Intersects(RayDesc ray){
        float radius = position.w;
        float3 offsetRayOrigin = ray.Origin - position.xyz;

        float a = dot(ray.Direction, ray.Direction);
        float b = 2 * dot(offsetRayOrigin, ray.Direction);
        float c = dot(offsetRayOrigin, offsetRayOrigin) - radius * radius;

        float discriminatn = b * b  - 4 * a * c;
        if(discriminatn >= 0){

            // calculate the x1 of the quadratic equation to have the front point and not the one in the back 
            float t = (-b -sqrt(discriminatn)) / (2 * a);

                // ray hits sphere more than once 
                if(t >= 0){
                    IntersectionInfo intersectionInfo;
                    intersectionInfo.t = t;
                    // get the hit poinnt
                    intersectionInfo.hitPoint = ray.Origin + ray.Direction * t;
                    intersectionInfo.alebdo = colour.xyz;
                    intersectionInfo.normal = normalize(intersectionInfo.hitPoint - position.xyz);
                    return intersectionInfo;
                }
        }
        return {};
    }

    public bool IntersectsRayP(RayDesc ray){
        float radius = position.w;
        float3 offsetRayOrigin = ray.Origin - position.xyz;

        float a = dot(ray.Direction, ray.Direction);
        float b = 2 * dot(offsetRayOrigin, ray.Direction);
        float c = dot(offsetRayOrigin, offsetRayOrigin) - radius * radius;

        float discriminatn = b * b  - 4 * a * c;
        if(discriminatn >= 0){
            return true;
        }
        return false;
    }

}

