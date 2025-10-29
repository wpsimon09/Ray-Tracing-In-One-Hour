import shape;    

public struct Scene{
    
    StructuredBuffer<Sphere> spheres;

    public __init(StructuredBuffer<Sphere> spheres){
        this.spheres = spheres;
    }

    public Optional<IntersectionInfo>GetClosestIntersection(RayDesc ray){
        Optional<IntersectionInfo> closestIntersection;
        float closestT = float.maxValue;

        for( int i = 0; i < spheres.getCount(); i++){
            if(let intersection = spheres[i].Intersects(ray)){
                IntersectionInfo intersect = intersection;
                if(intersect.t < closestT){
                    closestIntersection = intersect;
                    closestT = intersect.t;
                }
            }
        }  
        
        return closestIntersection;
    }
};