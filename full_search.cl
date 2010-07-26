#include "util.hl"

inline int2 find_best_motion_vector(
        read_only image2d_t imageA,
        read_only image2d_t imageB,
        int2 block
        ){
    // start at block.x - window_size , block.y - window_size
    block *= BLOCK_SIZE; //we were handed the (xth,yth) block. We want the top left pixel of it.
    int2 test_block = (int2)(block.x - SEARCH_WINDOW_SIZE, block.y - SEARCH_WINDOW_SIZE);
    int2 best_block = test_block;
    uint best_value = UINT_MAX;
    uint test_value = UINT_MAX;
    uint move_cost = UINT_MAX;

    // scan the row until block.y + window_size
    // scan the column until block.x + window_size
    for(; test_block.y < block.y + SEARCH_WINDOW_SIZE; test_block.y++)
        for( test_block.x = block.x - SEARCH_WINDOW_SIZE; test_block.x < block.x + SEARCH_WINDOW_SIZE; test_block.x++)
        {
            int2 motion_vector = block - test_block;

            // find the difference of this choice
            test_value = simple_sad( imageA, imageB, block, motion_vector);

            move_cost = delta_cost2(motion_vector);
            // update our best score if its better
            if(move_cost + test_value < best_value)
            {
                best_value = test_value + move_cost;
                best_block = test_block;
            }
        }

    //return our match 
    return block - best_block;
}
__kernel void motion_estimation(
        read_only image2d_t imageA,
        read_only image2d_t imageB,
        write_only image2d_t result
        )
{
    int2 block = (int2)(get_global_id(0), get_global_id(1));
    // For each block in imageA ...
    int2 motion_vector = find_best_motion_vector(imageA,imageB, block);
    write_answer(motion_vector, result);
}
