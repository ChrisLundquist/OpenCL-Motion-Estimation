sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
inline int median(int a, int b, int c)
{
    int t = a;
    a = max( a, b );
    b = min( t, b );
    a = min( c, a );
    a = max( b, a );
    return a;
}

// leave in float? need the precision of log2?
// mv must be in qpel
inline uint delta_cost2(int2 mv)
{
    //h->cost_mv[lambda][i]  = lambda * (log2f(i+1)*2 + 0.718f + !!i) + .5f;
    float2 mvc_lg2 = native_log2( convert_float2( abs( mv ) + (uint2)( 1 ) ) );
    float2 rounding = (float2)(!!mv.x, !!mv.y);
    float2 mvc = lambda * (mvc_lg2 * 2.0f + 0.718f + rounding) + .5f;
    return convert_uint(QPEX * (mvc.x + mvc.y));
}

inline uint simple_sad( const read_only image2d_t pix1, const read_only image2d_t pix2, const int2 block, const int2 motion_vector )
{
    uint sum = 0;
    int2 pos;

    for (pos.y = block.y; pos.y < block.y + BLOCK_SIZE; pos.y++)
    {
        for (pos.x = block.x; pos.x < block.x + BLOCK_SIZE; pos.x++) {
            // TODO: read 4 byte at a time and 
            uint a = read_imageui(pix1, sampler, (pos)).s0;
            uint b = read_imageui(pix2, sampler, (pos + motion_vector)).s0;
            sum += abs_diff(a, b);
        }
    }
    return sum; 
}

// This function does the incremental sad. E.G. if we want to move our macroblock one pixel in the positive x direction (right), we subtract the values to the left from the previous value
// and we add the new values. This saves calculations in all cases > 2x2 block size
inline uint incremental_x_sad( const read_only image2d_t pix1, 
    const read_only image2d_t pix2, 
    const int2 block, // The block we are comparing against
    const int2 motion_vector, 
    const uchar height, 
    const uint previous_value )
{
    
}

inline void write_answer( int2 motion_vector, write_only image2d_t result)
{
    write_imagei(result,(int2)(get_global_id(0), get_global_id(1)),(int4)(motion_vector,0,0));
}
