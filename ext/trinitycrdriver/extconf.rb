require 'mkmf'

#Need to link with C GSL libraries to use in C extensions
#gsl_inc = `gsl-config --cflags`

#$CFLAGS = " -Wall -I../include #{gsl_inc}"

#srcs = Dir.glob("*.c")

#p ['srcs', srcs]
                                                                                                         
#$objs = srcs.collect { |f| f.sub(".c", ".o") }                                                           
CONFIG['CC'] = ENV['CC'] || "mpicc"
crgemspec=Gem::Specification.find_by_name('coderunner')
crconfig = crgemspec.full_gem_path
$CPPFLAGS = " -I#{File.join(crconfig, 'include')} "+$CPPFLAGS
p ['CPPFLAGS', $CPPFLAGS]
raise "Please set the environment variable TRINITY_DIR" unless ENV['TRINITY_DIR']
$LOCAL_LIBS = " -L#{ENV['TRINITY_DIR']} " + $LOCAL_LIBS
have_library("trinity")
have_library("gfortran")

dir_config('mpi')
have_header("mpi.h")
have_library("mpi")
have_library("mpi_f90")
have_library("mpi_f77")

create_makefile("trinitycrdriver/trinitycrdriver")  
