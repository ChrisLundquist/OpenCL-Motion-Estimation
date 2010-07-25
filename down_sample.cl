sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;

__kernel void down_sample(write_only image2d_t output, read_only image2d_t input)
{
    const int2 position_down_scaled = (int2)(get_global_id(0), get_global_id(1));
    const int2 position = position_down_scaled * 2;
    const uint a = read_imageui(input, sampler, position).x;
    const uint b = read_imageui(input, sampler, position + (int2)(0,1)).x;
    const uint c = read_imageui(input, sampler, position + (int2)(1,0)).x;
    const uint d = read_imageui(input, sampler, position + (int2)(1,1)).x;
    const uint result = (a + b + c + d) / 4;
    write_imageui(output, position_down_scaled, (uint4)(result, result, result, result));
}
