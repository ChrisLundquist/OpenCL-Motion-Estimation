#include "util.hl"

inline int4 find_best_motion_vector(
        read_only image2d_t imageA,
        read_only image2d_t imageB,
        const int2 block,
        const uint block_size
        ){
    // This will look for a match in imageB
    int2 test_block = (int2)(0,0);
    int2 best_block = (int2)(0,0);
    uint best_value = UINT_MAX;
    uint test_value = UINT_MAX;
    uint move_cost = UINT_MAX;
    int2 image_size = get_image_dim(imageA);

    
    for( ; test_block.y < image_size.y; ++test_block.y)// For Each Row
        for( test_block.x = 0; test_block.x < image_size.x; ++test_block.x)// Compare Each Element
        {
            // Compare NOTE: simple_sad includes mv_cost
            test_value = simple_sad(imageA,imageB,test_block,block,block_size);
            move_cost = delta_cost2(block - test_block);
            // Check if we have a better one
            if(test_value + move_cost < best_value)
            {
                best_value = test_value + move_cost;
                best_block = test_block;
            }
        }
    return (int4)(best_block.x, best_block.y, best_value, 0);
}

__kernel void motion_estimation(
        read_only image2d_t imageA,
        read_only image2d_t imageB,
        write_only image2d_t result,
        uint block_size
        )
{
    int2 block = (int2)(get_global_id(0), get_global_id(1));
    // For each block in imageA ...
    int4 motion_vector = find_best_motion_vector(imageA,imageB, block * (int2)block_size , block_size);
    write_imagei(result,(int2)(block),(int4)(motion_vector));
}
