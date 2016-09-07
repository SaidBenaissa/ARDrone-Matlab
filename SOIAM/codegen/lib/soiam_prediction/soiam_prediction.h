/*
 * soiam_prediction.h
 *
 * Code generation for function 'soiam_prediction'
 *
 * C source code generated on: Mon Mar 24 20:18:06 2014
 *
 */

#ifndef __SOIAM_PREDICTION_H__
#define __SOIAM_PREDICTION_H__
/* Include files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"

#include "rtwtypes.h"
#include "soiam_prediction_types.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern void soiam_prediction(const struct_T soinn, const emxArray_real_T *signal, real_T key_step_length, real_T interval_length, emxArray_real_T *value, real_T *min_dist, real_T *winner_time);
#endif
/* End of code generation (soiam_prediction.h) */
