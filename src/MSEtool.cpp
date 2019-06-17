#define TMB_LIB_INIT R_init_MSEtool
#include <TMB.hpp>
#include "../inst/include/functions.h"

template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_STRING(model);

  if(model == "DD") {
    #include "../inst/include/DD.h"
  } else if(model == "DD_SS") {
	  #include "../inst/include/DD_SS.h"
  } else if(model =="SP") {
    #include "../inst/include/SP.h"
  } else if(model == "SP_SS") {
    #include "../inst/include/SP_SS.h"
  } else if(model == "grav") {
    #include "../inst/include/grav.h"
  } else if(model == "grav_Pbyarea") {
    #include "../inst/include/grav_Pbyarea.h"
  } else if(model == "SCA") {
    #include "../inst/include/SCA.h"
  } else if(model == "SCA2") {
    #include "../inst/include/SCA2.h"
  } else if(model == "SCA_Pope") {
    #include "../inst/include/SCA_Pope.h"
  } else if(model == "VPA") {
    #include "../inst/include/VPA.h"
  } else if(model == "cDD") {
    #include "../inst/include/cDD.h"
  } else if(model == "cDD_SS") {
	  #include "../inst/include/cDD_SS.h"
  } else if(model == "SRA_scope") {
	  #include "../inst/include/SRA_scope.h"
  } else {
    error("No model found.");
  }

  return 0;
}
