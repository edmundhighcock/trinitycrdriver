require 'mkmf'

#Need to link with C GSL libraries to use in C extensions
#gsl_inc = `gsl-config --cflags`

#$CFLAGS = " -Wall -I../include #{gsl_inc}"

#srcs = Dir.glob("*.c")

#p ['srcs', srcs]
                                                                                                         
#$objs = srcs.collect { |f| f.sub(".c", ".o") }                                                           
RbConfig::CONFIG['CC'] = CONFIG['CC'] = ENV['CC'] || "mpicc"
RbConfig::CONFIG['CPP'] = CONFIG['CPP'] = ENV['CPP'] || "mpicc -E"
p 'CONFIG[CC]', CONFIG['CC']
crgemspec=Gem::Specification.find_by_name('coderunner')
crconfig = crgemspec.full_gem_path
$CPPFLAGS = " -I#{File.join(crconfig, 'include')} "+$CPPFLAGS
p ['CPPFLAGS', $CPPFLAGS]
raise "Please set the environment variable TRINITY_DIR" unless ENV['TRINITY_DIR']
$LOCAL_LIBS = " -L#{ENV['TRINITY_DIR']} " + $LOCAL_LIBS
$LOCAL_LIBS = " -L#{ENV['GS2']} " + $LOCAL_LIBS
have_library("gfortran")
have_library("netcdf")
have_library("netcdff")
have_library("fftw3")
have_library("fftw3f")
have_library("fftw3_mpi")
have_library("fftw3f_mpi")
have_library("simpledataio")

#have_library("gs2", "__gs2_main_MOD_gs2spec_from_trin")
have_library("gs2")
have_library("trinity")

dir_config('mpi')
have_header("mpi.h")
have_library("mpi")
have_library("mpi_f90")
have_library("mpi_f77")

create_makefile("trinitycrdriver/trinitycrdriver")  
