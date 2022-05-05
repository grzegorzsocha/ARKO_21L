#include <iostream>
#include <stdio.h>
#include <fstream>
#include "polynomial.h"
#include <SFML/Graphics.hpp>

int main(int argc, char *argv[]) 
{
    if (argc < 6)
    {
        std::cout<< "Arguments missing\n";
        return 0;
    }

    double A = atof(argv[1]), B = atof(argv[2]), C = atof(argv[3]), D = atof(argv[4]), S = atof(argv[5]);

    if (S < 1)
    {
        std::cout<< "Invalid S value\n";
        return 0;
    }

	unsigned char picture_header[54] {0};
    int size = 3145782;
    int width = 512;
    int height = 512;

    picture_header[0] =  (unsigned char)('B');
    picture_header[1] = (unsigned char)('M');
    picture_header[2] = (unsigned char)(size);
    picture_header[3] = (unsigned char)(size >>  8);
    picture_header[4] = (unsigned char)(size >> 16);
    picture_header[5] = (unsigned char)(size >> 24);
    picture_header[10] = (unsigned char)(54);
    picture_header[14] = (unsigned char)(40);
    picture_header[18] = (unsigned char)(width);
    picture_header[19] = (unsigned char)(width >>  8);
    picture_header[20] = (unsigned char)(width >> 16);
    picture_header[21] = (unsigned char)(width >> 24);
    picture_header[22] = (unsigned char)(height);
    picture_header[23] = (unsigned char)(height >>  8);
    picture_header[24] = (unsigned char)(height >> 16);
    picture_header[25] = (unsigned char)(height >> 24);
    picture_header[26] = (unsigned char)(1);
    picture_header[28] = (unsigned char)(24);
    picture_header[34] = (unsigned char)(48);

	unsigned char *picture =new unsigned char[3145728];
    unsigned char *first_pixel = picture;

	polynomial(first_pixel, width, height, A, B, C, D, S);

	std::ofstream pic("polynomial.bmp");

    for(int i = 0; i<54; ++i) 
	{
        pic << picture_header[i];
    }
    for(int i = 0; i < 3145728; ++i)
    {
        pic << picture[i];
    }
    pic.close();
	delete picture;

    sf::RenderWindow window(sf::VideoMode(512, 512), "Polynomial");
    sf::Texture texture;
    texture.loadFromFile("polynomial.bmp");
    sf::Sprite sprite(texture);
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(sprite);
        window.display();
    }

    return 0;
}
