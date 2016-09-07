/*
 * soiam_prediction_types.h
 *
 * Code generation for function 'soiam_prediction'
 *
 * C source code generated on: Mon Mar 24 20:18:06 2014
 *
 */

#ifndef __SOIAM_PREDICTION_TYPES_H__
#define __SOIAM_PREDICTION_TYPES_H__

/* Type Definitions */
#ifndef struct_emxArray__common
#define struct_emxArray__common
typedef struct emxArray__common
{
    void *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray__common;
#endif
#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
typedef struct emxArray_real_T
{
    real_T *data;
    int32_T *size;
    int32_T allocatedSize;
    int32_T numDimensions;
    boolean_T canFreeData;
} emxArray_real_T;
#endif
typedef struct
{
    real_T dimension;
    real_T deleteNodePeriod;
    real_T maxEdgeAge;
    real_T minNeighborNumber;
    emxArray_real_T *nodes;
    emxArray_real_T *adjacencyMat;
    real_T inputNum;
    emxArray_real_T *winTimes;
} struct_T;

#endif
/* End of code generation (soiam_prediction_types.h) */
