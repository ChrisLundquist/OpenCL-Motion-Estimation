#include "util.hl"

#define INITIAL_WINDOW_SIZE 4
#define INITIAL_MATCH_THRESHOLD 8

inline int2 find_best_motion_vector(
        read_only image2d_t imageA,
        read_only image2d_t imageB,
        const int2 block
        ){
uchar window_size = INITIAL_WINDOW_SIZE;
int2 test_block;
uint test_value = UINT_MAX;
int2 best_block = block;
uint best_value = UINT_MAX;
uint move_cost;

// Check (0,0) and see if we are less than the initial match threshold


// While our window size > 1
while(window_size > 1)
{
int2 start_pos = best_block;
    // 1) Check the key spots and select the minimum
    // X . . X . . X
    // . . . . . . .
    // . . . . . . .
    // X . . X . . X
    // . . . . . . .
    // . . . . . . .
    // X . . X . . X
    for(char y = -1; y < 2; y++)
        for(char x = -1; x < 2; x++)
    {
        test_block = (int2)(start_pos.x + ( x * window_size * BLOCK_SIZE), block.y + ( y * window_size * BLOCK_SIZE));
        int2 motion_vector = block - test_block;
        test_value = simple_sad( imageA, imageB, block, motion_vector );
        move_cost = delta_cost2(motion_vector);
        // 2) Set our minimum to the one we found
        if( move_cost + test_value < best_value)
        {
            best_value = test_value + move_cost;
            best_block = test_block;
        }
    }
    // 3) Reduce the window size by a factor of 2 if we didn't move
    if(start_pos.x == best_block.x && start_pos.y == best_block.y)
        window_size /= 2;

    // 4) Recenter our search at our new minimum
    start_pos = best_block;
}

return block - best_block;
// Return our match
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
    int2 motion_vector = find_best_motion_vector(imageA, imageB, block);
    write_answer(motion_vector, result);
}
