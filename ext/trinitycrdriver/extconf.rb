require 'mkmf'

#Need to link with C GSL libraries to use in C extensions
#gsl_inc = `gsl-config --cflags`

#$CFLAGS = " -Wall -I../include #{gsl_inc}"

#srcs = Dir.glob("*.c")

#p ['srcs', srcs]
                                                                                                         
#$objs = srcs.collect { |f| f.sub(".c", ".o") }                                                           
                                                                                                         
crgemspec=Gem::Specification.find_by_name('coderunner')
crconfig = crgemspec.full_gem_path
$CPPFLAGS = " -I#{File.join(crconfig, 'include')} "+$CPPFLAGS
p ['CPPFLAGS', $CPPFLAGS]

create_makefile("trinitycrdriver/trinitycrdriver")  
