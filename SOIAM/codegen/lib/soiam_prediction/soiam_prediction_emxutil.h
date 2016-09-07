/*
 * soiam_prediction_emxutil.h
 *
 * Code generation for function 'soiam_prediction_emxutil'
 *
 * C source code generated on: Mon Mar 24 20:18:06 2014
 *
 */

#ifndef __SOIAM_PREDICTION_EMXUTIL_H__
#define __SOIAM_PREDICTION_EMXUTIL_H__
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
extern void b_emxInit_real_T(emxArray_real_T **pEmxArray, int32_T numDimensions);
extern void c_emxInit_real_T(emxArray_real_T **pEmxArray, int32_T numDimensions);
extern void emxEnsureCapacity(emxArray__common *emxArray, int32_T oldNumel, int32_T elementSize);
extern void emxFree_real_T(emxArray_real_T **pEmxArray);
extern void emxInit_real_T(emxArray_real_T **pEmxArray, int32_T numDimensions);
#endif
/* End of code generation (soiam_prediction_emxutil.h) */
