__kernel void image_filli(write_only image2d_t image, int4 value)
{
    write_imagei(image, (int2)(get_global_id(0), get_global_id(1)), value);
}
