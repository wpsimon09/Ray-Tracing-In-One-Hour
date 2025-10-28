#include <glm/fwd.hpp>
#include <glm/glm.hpp>
#include <iostream>
#include <optional>
#include <vector>
#include <vulkan/vulkan_core.h>

struct BufferCreateInfo
{
    VkPhysicalDevice      physicalDevice;
    VkSurfaceKHR          surface;
    VkDevice              logicalDevice;
    VkDeviceSize          size;
    VkBufferUsageFlags    usage;
    VkMemoryPropertyFlags properties;
};


enum APPLICATION_STATUS
{
    IDLE    = 0,
    RUNNING = 1,
    OFF     = -1
};

struct ApplicationStatusNotifier
{
    APPLICATION_STATUS appStatus = RUNNING;
    bool               isDirty   = true;

    void NotifyChange()
    {
        if(isDirty)
        {
            std::cout << "Application is: ";
            switch(appStatus)
            {
                case IDLE: {
                    std::cout << "Idle";
                    break;
                }
                case RUNNING: {
                    std::cout << "Running";
                    break;
                }
                case OFF: {
                    std::cout << "Off";
                    break;
                }
            }
            std::cout << std::endl;
            isDirty = false;
        }
    }
};

struct QueueFamilyIndices
{
    std::optional<uint32_t> graphicsFamily;
    std::optional<uint32_t> presentFamily;
    std::optional<uint32_t> transferFamily;

    bool isComplete() const
    {
        return graphicsFamily.has_value() && presentFamily.has_value() && presentFamily.has_value();
    }
};

struct SwapChainSupportDetails
{
    VkSurfaceCapabilitiesKHR        capabilities;
    std::vector<VkSurfaceFormatKHR> formats;
    std::vector<VkPresentModeKHR>   presentModes;
};

struct UniformBufferObject
{
    glm::mat4 view;
    glm::mat4 inverseView;
    glm::vec4 viewData;  // x - aspect, y - fov2tan, z - sphere count
};


struct Sphere
{
    glm::vec4 position;            // xyz: positon | w: radius
    glm::vec4 colour;              // xyz: rgb | w: empty
    glm::vec4 materialProperties;  // x: roughness | y: metalness | z: emission | w: unused
};