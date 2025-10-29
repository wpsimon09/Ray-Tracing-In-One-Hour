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
                IntersectionInfo i = intersection;
                if(i.t < closestT){
                    closestIntersection = i;
                    closestT = i.t;
                }
            }
        }  
        
        if(closestIntersection.hasValue){
            return closestIntersection;
        }else{
            return {};
        }
    }
};