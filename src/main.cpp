#include <iostream>

#include "HelloTriangle.hpp"

int main()
{

    HelloTriangle app;

    try
    {
        app.run();
    }
    catch(const std::exception& e)
    {
        std::cout << e.what();
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}