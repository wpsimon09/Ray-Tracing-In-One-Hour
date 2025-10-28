#include <iostream>

#include "RenderingEngine.hpp"

int main()
{

    RenderingEngine app;

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