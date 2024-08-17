bg white
space cmyk
set ray_shadow, 0
set opaque_background, 0

load 1bl8.pdb
as cartoon
show spheres, resn K

set sphere_scale, 0.5, resn K
util.cbc 1bl8 and e. C, 7, quiet=1

show sticks, resi 71

### cut below here and paste into script ###
set_view (\
     0.725519359,    0.402470559,   -0.558232248,\
     0.600737035,   -0.766106486,    0.228429049,\
    -0.335732192,   -0.501084864,   -0.797612011,\
    -0.001348486,    0.000199109, -156.212524414,\
    73.138122559,   25.062622070,   18.763792038,\
    44.564746857,  267.892242432,  -20.000000000 )
### cut above here and paste into script ###