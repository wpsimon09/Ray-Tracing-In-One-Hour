//
// Created by wpsimon09 on 26/07/24.
//

#ifndef UTILS_HPP
#define UTILS_HPP
#include <GLFW/glfw3.h>
#include <iostream>
#include <optional>
#include <set>
#include <vulkan/vulkan.hpp>
#include <limits>
#include <algorithm>
#include <fstream>
#include <vector>
#include <glm/glm.hpp>

#include "Structs.hpp"
#include "imgui.h"

const std::vector<const char*> deviceExtentions = {VK_KHR_SWAPCHAIN_EXTENSION_NAME};


/*
const std::vector<Vertex> vertices = {
    {{-0.5f, -0.5f}, {1.0f, 0.0f, 0.0f}},
    {{0.5f, -0.5f}, {0.0f, 1.0f, 0.0f}},
    {{0.5f, 0.5f}, {0.0f, 0.0f, 1.0f}},
    {{-0.5f, 0.5f}, {1.0f, 1.0f, 1.0f}}
};

const std::vector<uint16_t> indices = {
    0, 1, 2, 2, 3, 0
};
*/


inline VkResult CreateDebugUtilsMessengerEXT(VkInstance                                instance,
                                             const VkDebugUtilsMessengerCreateInfoEXT* pCreateInfor,
                                             const VkAllocationCallbacks*              pAllocator,
                                             VkDebugUtilsMessengerEXT*                 pDebugMessenger)
{
    auto func = (PFN_vkCreateDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
    if(func != nullptr)
        return func(instance, pCreateInfor, pAllocator, pDebugMessenger);
    else
        return VK_ERROR_EXTENSION_NOT_PRESENT;
}

inline void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks* pAllocator)
{
    auto func = (PFN_vkDestroyDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT");

    if(func != nullptr)
    {
        func(instance, debugMessenger, pAllocator);
    }
}


inline QueueFamilyIndices FindQueueFamilies(VkPhysicalDevice device, VkSurfaceKHR surface)
{
    QueueFamilyIndices indices;
    uint32_t           queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, nullptr);
    std::vector<VkQueueFamilyProperties> queueFamilyProperties(queueFamilyCount);
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, queueFamilyProperties.data());

    int i = 0;
    for(auto& queueFamily : queueFamilyProperties)
    {
        if(queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT)
        {
            indices.graphicsFamily = i;
        }
        if(queueFamily.queueFlags & VK_QUEUE_TRANSFER_BIT)
        {
            indices.transferFamily = i;
        }
        VkBool32 presentSupport = false;
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface, &presentSupport);
        if(presentSupport)
        {
            indices.presentFamily = i;
        }
        if(indices.isComplete())
            break;

        i++;
    }

    return indices;
}

inline bool CheckDeviceExtentionSupport(VkPhysicalDevice device)
{
    uint32_t extensionCount;
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, nullptr);
    std::vector<VkExtensionProperties> availablExtensions(extensionCount);
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, availablExtensions.data());

    std::set<std::string> requiredExtensions(deviceExtentions.begin(), deviceExtentions.end());

    for(auto& availabl_extension : availablExtensions)
    {
        requiredExtensions.erase(availabl_extension.extensionName);
    }

    return requiredExtensions.empty();
}


inline SwapChainSupportDetails querySwapChainSupport(VkPhysicalDevice physicalDevice, VkSurfaceKHR surface)
{
    SwapChainSupportDetails details;

    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, &details.capabilities);

    uint32_t formatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, nullptr);
    if(formatCount != 0)
    {
        details.formats.resize(formatCount);
        vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, details.formats.data());
    }

    uint32_t presentModeCount;
    vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &presentModeCount, nullptr);
    if(presentModeCount != 0)
    {
        details.presentModes.resize(presentModeCount);
        vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &presentModeCount, details.presentModes.data());
    }

    return details;
}

inline bool isDeviceSuitable(VkPhysicalDevice device, VkSurfaceKHR surface)
{
    VkPhysicalDeviceProperties deviceProperties;
    VkPhysicalDeviceFeatures   deviceFeatures;
    vkGetPhysicalDeviceProperties(device, &deviceProperties);
    vkGetPhysicalDeviceFeatures(device, &deviceFeatures);
    std::cout << '\t' << deviceProperties.deviceName << std::endl;

    QueueFamilyIndices indices = FindQueueFamilies(device, surface);

    bool extensionsSupported = CheckDeviceExtentionSupport(device);

    bool swapChainAdequtate = false;
    if(extensionsSupported)
    {
        SwapChainSupportDetails swapChainSupport = querySwapChainSupport(device, surface);

        swapChainAdequtate = !swapChainSupport.formats.empty() && !swapChainSupport.presentModes.empty();
    }

    return deviceProperties.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU && indices.isComplete() && swapChainAdequtate;
}

inline VkSurfaceFormatKHR chooseSwapSurfaceFormat(const std::vector<VkSurfaceFormatKHR>& availableFormats)
{
    for(const auto& availableFormat : availableFormats)
    {
        if(availableFormat.format == VK_FORMAT_B8G8R8A8_SRGB && availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
        {
            return availableFormat;
        }
    }
    return availableFormats[0];
}

inline VkPresentModeKHR chooseSwapPresentMode(const std::vector<VkPresentModeKHR>& availablePresentModes)
{
    for(const auto& availblePresentMode : availablePresentModes)
    {
        if(availblePresentMode == VK_PRESENT_MODE_MAILBOX_KHR)
        {
            return availblePresentMode;
        }
    }
    return VK_PRESENT_MODE_FIFO_KHR;
}

inline VkExtent2D chooseSwapExtent(const VkSurfaceCapabilitiesKHR& capabilities, GLFWwindow* window)
{
    if(capabilities.currentExtent.width != std::numeric_limits<uint32_t>::max())
    {
        //we are going with the window size to be set as current extend
        return capabilities.currentExtent;
    }
    //teh current extend is max of uint32_t and we adjust max width and height for the swap chain images instead
    int width, height;
    glfwGetFramebufferSize(window, &width, &height);

    VkExtent2D acctualExtend = {static_cast<uint32_t>(width), static_cast<uint32_t>(height)};

    acctualExtend.width = std::clamp(acctualExtend.width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width);
    acctualExtend.height =
        std::clamp(acctualExtend.height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height);

    return acctualExtend;
}

static inline std::vector<char> readFile(const std::string& fileName)
{
    std::ifstream file(fileName, std::ios::ate | std::ios::binary);

    if(!file.is_open())
    {
        const auto err = "Failed to open file at path: " + fileName;
        throw std::runtime_error(err);
    }

    //create buffer to hold the binary
    size_t            fileSize = (size_t)file.tellg();
    std::vector<char> buffer(fileSize);

    //go back to the begining and read the file again to get the content
    file.seekg(0);
    file.read(buffer.data(), fileSize);

    file.close();

    return buffer;
}


static inline VkShaderModule createShaderModuel(VkDevice device, std::vector<char>& shaderSPIRV)
{
    VkShaderModuleCreateInfo createInfo;
    createInfo.sType    = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    createInfo.codeSize = shaderSPIRV.size();
    createInfo.flags    = 0;
    createInfo.pNext    = nullptr;
    //cast from char to uint32_t
    createInfo.pCode = reinterpret_cast<const uint32_t*>(shaderSPIRV.data());

    VkShaderModule shaderModule;
    if(vkCreateShaderModule(device, &createInfo, nullptr, &shaderModule) != VK_SUCCESS)
    {
        throw std::runtime_error("Could not create shader module");
    }

    shaderSPIRV.clear();

    return shaderModule;
}

static inline uint32_t FindMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags properties, VkPhysicalDevice physicalDevice)
{
    //get the available types of memories on the GPU
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memProperties);

    for(uint32_t i = 0; i < memProperties.memoryTypeCount; i++)
    {
        if(typeFilter & (1 << i) && (memProperties.memoryTypes[i].propertyFlags & properties) == properties)
        {
            return i;
        }
    }

    throw std::runtime_error("Fialed to find suitable memmory type");
}

static inline void CreateBuffer(BufferCreateInfo bufferCreateInfo, VkBuffer& buffer, VkDeviceMemory& bufferMemory)
{
    QueueFamilyIndices indices = FindQueueFamilies(bufferCreateInfo.physicalDevice, bufferCreateInfo.surface);
    VkBufferCreateInfo bufferInfo{};
    bufferInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    bufferInfo.size  = bufferCreateInfo.size;
    // might be more using | operator
    bufferInfo.usage = bufferCreateInfo.usage;
    // specifies if it can be shared between queue families
    // we will use it only for the graphics family
    std::vector<uint32_t> sharedQueueFamilies = {indices.graphicsFamily.value(), indices.transferFamily.value()};

    bufferInfo.sharingMode           = VK_SHARING_MODE_EXCLUSIVE;
    bufferInfo.queueFamilyIndexCount = static_cast<uint32_t>(sharedQueueFamilies.size());
    bufferInfo.pQueueFamilyIndices   = sharedQueueFamilies.data();

    //sparse buffer memmory
    bufferInfo.flags = 0;

    if(vkCreateBuffer(bufferCreateInfo.logicalDevice, &bufferInfo, nullptr, &buffer) != VK_SUCCESS)
    {
        throw std::runtime_error("Failed to create Vertex Buffer");
    }

    VkMemoryRequirements memRequirements;
    vkGetBufferMemoryRequirements(bufferCreateInfo.logicalDevice, buffer, &memRequirements);

    VkMemoryAllocateInfo allocInfo{};
    allocInfo.sType          = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocInfo.allocationSize = memRequirements.size;
    allocInfo.memoryTypeIndex =
        FindMemoryType(memRequirements.memoryTypeBits, bufferCreateInfo.properties, bufferCreateInfo.physicalDevice);

    if(vkAllocateMemory(bufferCreateInfo.logicalDevice, &allocInfo, nullptr, &bufferMemory) != VK_SUCCESS)
    {
        throw std::runtime_error("Failed to allocate memory");
    }

    vkBindBufferMemory(bufferCreateInfo.logicalDevice, buffer, bufferMemory, 0);
}

static inline void CopyBuffer(VkDevice      logicalDevice,
                              VkQueue       transferQueue,
                              VkCommandPool transferCommandPool,
                              VkBuffer      srcBuffer,
                              VkBuffer      dstBuffer,
                              VkDeviceSize  size)
{
    VkCommandBufferAllocateInfo allocInfo{};
    allocInfo.sType              = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.level              = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandPool        = transferCommandPool;
    allocInfo.commandBufferCount = 1;

    VkCommandBuffer commandBuffer;
    vkAllocateCommandBuffers(logicalDevice, &allocInfo, &commandBuffer);

    VkCommandBufferBeginInfo beginInfo{.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
    beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(commandBuffer, &beginInfo);

    VkBufferCopy copyRegion{};
    copyRegion.srcOffset = 0;
    copyRegion.dstOffset = 0;
    copyRegion.size      = size;
    vkCmdCopyBuffer(commandBuffer, srcBuffer, dstBuffer, 1, &copyRegion);

    vkEndCommandBuffer(commandBuffer);

    VkSubmitInfo submitInfo{.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO};
    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers    = &commandBuffer;

    vkQueueSubmit(transferQueue, 1, &submitInfo, VK_NULL_HANDLE);
    vkQueueWaitIdle(transferQueue);

    vkFreeCommandBuffers(logicalDevice, transferCommandPool, 1, &commandBuffer);
}

static inline std::vector<Sphere> GenerateScene()
{
    std::vector<Sphere> spheres;

    spheres.push_back({glm::vec4(0.0f, -1.0f, 0.0f, 1.0f), glm::vec4(0.7f, 0.7f, 0.7f, 1.0f), glm::vec4(0.9f, 0.0f, 0.0f, 0.0f)});

    float radius             = 0.2f;
    float angleStep          = glm::radians(72.0f);
    float distanceFromCenter = 1.0f;

    for(int i = 0; i < 5; i++)
    {
        float angle = i * angleStep;
        float x     = distanceFromCenter * sin(angle);
        float z     = distanceFromCenter * cos(angle);
        float y     = sqrt(distanceFromCenter * distanceFromCenter - x * x - z * z);

        spheres.push_back({glm::vec4(x, y, z, radius), glm::vec4(sin(angle) * 0.5f + 0.5f, cos(angle) * 0.5f + 0.5f, 0.5f, 1.0f),
                           glm::vec4(0.1f, 0.9f, 0.0f, 0.0f)});
    }

    spheres.push_back({glm::vec4(0.0f, 2.0f, 0.0f, 0.3f), glm::vec4(1.0f, 0.2f, 0.2f, 1.0f), glm::vec4(0.5f, 0.5f, 2.0f, 0.0f)});

    return spheres;
}

inline void SetImguiTheme()
{
    ImGuiStyle& style  = ImGui::GetStyle();
    ImVec4*     colors = style.Colors;

    // Corners
    style.WindowRounding    = 8.0f;
    style.ChildRounding     = 8.0f;
    style.FrameRounding     = 6.0f;
    style.PopupRounding     = 6.0f;
    style.ScrollbarRounding = 6.0f;
    style.GrabRounding      = 6.0f;
    style.TabRounding       = 6.0f;

    // Colors
    colors[ImGuiCol_Text]                  = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);
    colors[ImGuiCol_TextDisabled]          = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
    colors[ImGuiCol_WindowBg]              = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    colors[ImGuiCol_ChildBg]               = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    colors[ImGuiCol_PopupBg]               = ImVec4(0.08f, 0.08f, 0.08f, 0.94f);
    colors[ImGuiCol_Border]                = ImVec4(0.25f, 0.25f, 0.25f, 0.70f);
    colors[ImGuiCol_BorderShadow]          = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_FrameBg]               = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
    colors[ImGuiCol_FrameBgActive]         = ImVec4(0.30f, 0.30f, 0.30f, 1.00f);
    colors[ImGuiCol_TitleBg]               = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
    colors[ImGuiCol_TitleBgActive]         = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
    colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
    colors[ImGuiCol_MenuBarBg]             = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    colors[ImGuiCol_ScrollbarBg]           = ImVec4(0.02f, 0.02f, 0.02f, 0.53f);
    colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.30f, 0.30f, 0.30f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.35f, 0.35f, 0.35f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.40f, 0.40f, 0.40f, 1.00f);
    colors[ImGuiCol_CheckMark]             = ImVec4(0.80f, 0.80f, 0.80f, 1.00f);
    colors[ImGuiCol_SliderGrab]            = ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
    colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.85f, 0.85f, 0.85f, 1.00f);
    colors[ImGuiCol_Button]                = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
    colors[ImGuiCol_ButtonHovered]         = ImVec4(0.30f, 0.30f, 0.30f, 1.00f);
    colors[ImGuiCol_ButtonActive]          = ImVec4(0.35f, 0.35f, 0.35f, 1.00f);
    colors[ImGuiCol_Header]                = ImVec4(0.25f, 0.25f, 0.25f, 0.55f);
    colors[ImGuiCol_HeaderHovered]         = ImVec4(0.35f, 0.35f, 0.35f, 0.80f);
    colors[ImGuiCol_HeaderActive]          = ImVec4(0.40f, 0.40f, 0.40f, 1.00f);
    colors[ImGuiCol_Separator]             = ImVec4(0.30f, 0.30f, 0.30f, 0.50f);
    colors[ImGuiCol_SeparatorHovered]      = ImVec4(0.45f, 0.45f, 0.45f, 0.78f);
    colors[ImGuiCol_SeparatorActive]       = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
    colors[ImGuiCol_ResizeGrip]            = ImVec4(0.30f, 0.30f, 0.30f, 0.25f);
    colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.45f, 0.45f, 0.45f, 0.67f);
    colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.50f, 0.50f, 0.50f, 0.95f);
    colors[ImGuiCol_Tab]                   = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    colors[ImGuiCol_TabHovered]            = ImVec4(0.30f, 0.30f, 0.30f, 0.80f);
    colors[ImGuiCol_TabActive]             = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
    colors[ImGuiCol_TabUnfocused]          = ImVec4(0.10f, 0.10f, 0.10f, 0.97f);
    colors[ImGuiCol_TabUnfocusedActive]    = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
    colors[ImGuiCol_PlotLines]             = ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
    colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.90f, 0.50f, 0.50f, 1.00f);
    colors[ImGuiCol_PlotHistogram]         = ImVec4(0.80f, 0.65f, 0.00f, 1.00f);
    colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(0.90f, 0.50f, 0.00f, 1.00f);
    colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.30f, 0.30f, 0.30f, 0.35f);
    colors[ImGuiCol_DragDropTarget]        = ImVec4(1.00f, 0.00f, 0.00f, 0.90f);
    colors[ImGuiCol_NavHighlight]          = ImVec4(0.70f, 0.70f, 0.70f, 1.00f);
    colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
    colors[ImGuiCol_NavWindowingDimBg]     = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
    colors[ImGuiCol_ModalWindowDimBg]      = ImVec4(0.80f, 0.80f, 0.80f, 0.35f);
}

#endif  //UTILS_HPP
