#include <math.h>
#include <string.h>
#include "code_runner_ext.h"


void trinitycrdriver_run_trinity(VALUE class){
	printf("RUNNING TRINITY!!!\n\n");

}

void Init_trinitycrdriver()
{
	
	printf("HERE!!!\n\n");
	ccode_runner =  RGET_CLASS_TOP("CodeRunner");
	/*VALUE ctrinity =  RGET_CLASS_TOP("CodeRunner");*/
	VALUE ctrinity = RGET_CLASS(ccode_runner, "Trinity");
	rb_define_method(ctrinity, "run_trinity", trinitycrdriver_run_trinity, 0);
		/*rb_define_class_under(ccode_runner, "Trinity",*/
		/*RGET_CLASS(*/
		/*RGET_CLASS(ccode_runner, "Run"), */
		/*"FortranNamelist"*/
		/*)*/
		/*);*/

	/*ccode_runner_gs2_gsl_tensor_complexes = rb_define_module_under(ccode_runner_gs2, "GSLComplexTensors");*/
	/*rb_include_module(ccode_runner_gs2, ccode_runner_gs2_gsl_tensor_complexes);*/

	/*ccode_runner_gs2_gsl_tensors = rb_define_module_under(ccode_runner_gs2, "GSLTensors"); */
	/*rb_include_module(ccode_runner_gs2, ccode_runner_gs2_gsl_tensors);*/

	/*cgsl = RGET_CLASS_TOP("GSL");*/
	/*cgsl_vector = RGET_CLASS(cgsl, "Vector");*/
	/*cgsl_vector_complex = RGET_CLASS(cgsl_vector, "Complex");*/

	/*rb_define_method(ccode_runner_gs2_gsl_tensor_complexes, "field_gsl_tensor_complex_2", gs2crmod_tensor_complexes_field_gsl_tensor_complex_2, 1);*/
	/*rb_define_method(ccode_runner_gs2_gsl_tensors, "field_real_space_gsl_tensor", gs2crmod_tensor_field_gsl_tensor, 1);*/
	/*rb_define_method(ccode_runner_gs2_gsl_tensors, "field_correlation_gsl_tensor", gs2crmod_tensor_field_correlation_gsl_tensor, 1);*/

	/*rb_define_method(ccode_runner_ext, "hello_world", code_runner_ext_hello_world, 0);*/
}

