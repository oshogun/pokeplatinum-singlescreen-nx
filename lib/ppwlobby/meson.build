# Public includes
ppwlobby_public_includes = include_directories('include')

ppwlobby_c_args = [
    '-fpermissive',
    # NX: libnx headers (pulled in via nitro/types.h) need C++11
    (build_target == 'nx' ? '-std=gnu++11' : '-std=c++03')
]

# Libraries
ppwlobby_libs = []
subdir('libraries')
