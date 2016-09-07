/*
 * soiam_prediction.cpp
 *
 * Code generation for function 'soiam_prediction'
 *
 * C source code generated on: Mon Mar 24 20:18:06 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "soiam_prediction.h"
#include "soiam_prediction_emxutil.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
static int32_T mul_s32_s32_s32_sat(int32_T a, int32_T b);
static void mul_wide_s32(int32_T in0, int32_T in1, uint32_T *ptrOutBitsHi,
  uint32_T *ptrOutBitsLo);
static real_T rt_powd_snf(real_T u0, real_T u1);
static real_T rt_roundd_snf(real_T u);

/* Function Definitions */
static int32_T mul_s32_s32_s32_sat(int32_T a, int32_T b)
{
  int32_T result;
  uint32_T u32_clo;
  uint32_T u32_chi;
  mul_wide_s32(a, b, &u32_chi, &u32_clo);
  if (((int32_T)u32_chi > 0) || ((u32_chi == 0U) && (u32_clo >= 2147483648U))) {
    result = MAX_int32_T;
  } else if (((int32_T)u32_chi < -1) || (((int32_T)u32_chi == -1) && (u32_clo <
               2147483648U))) {
    result = MIN_int32_T;
  } else {
    result = (int32_T)u32_clo;
  }

  return result;
}

static void mul_wide_s32(int32_T in0, int32_T in1, uint32_T *ptrOutBitsHi,
  uint32_T *ptrOutBitsLo)
{
  uint32_T absIn0;
  uint32_T absIn1;
  int32_T negativeProduct;
  int32_T in0Hi;
  int32_T in0Lo;
  int32_T in1Hi;
  int32_T in1Lo;
  uint32_T productLoHi;
  uint32_T productLoLo;
  uint32_T outBitsLo;
  absIn0 = (uint32_T)(in0 < 0 ? -in0 : in0);
  absIn1 = (uint32_T)(in1 < 0 ? -in1 : in1);
  negativeProduct = (int32_T)!((in0 == 0) || ((in1 == 0) || ((int32_T)(in0 > 0) ==
                                 (int32_T)(in1 > 0))));
  in0Hi = (int32_T)(absIn0 >> 16U);
  in0Lo = (int32_T)(absIn0 & 65535U);
  in1Hi = (int32_T)(absIn1 >> 16U);
  in1Lo = (int32_T)(absIn1 & 65535U);
  absIn0 = (uint32_T)in0Hi * (uint32_T)in1Hi;
  absIn1 = (uint32_T)in0Hi * (uint32_T)in1Lo;
  productLoHi = (uint32_T)in0Lo * (uint32_T)in1Hi;
  productLoLo = (uint32_T)in0Lo * (uint32_T)in1Lo;
  in0Hi = 0;
  outBitsLo = productLoLo + (productLoHi << 16U);
  if (outBitsLo < productLoLo) {
    in0Hi = 1;
  }

  productLoLo = outBitsLo;
  outBitsLo += absIn1 << 16U;
  if (outBitsLo < productLoLo) {
    in0Hi = (int32_T)((uint32_T)in0Hi + 1U);
  }

  absIn0 = (((uint32_T)in0Hi + absIn0) + (productLoHi >> 16U)) + (absIn1 >> 16U);
  if (negativeProduct) {
    absIn0 = ~absIn0;
    outBitsLo = ~outBitsLo;
    outBitsLo++;
    if (outBitsLo == 0U) {
      absIn0++;
    }
  }

  *ptrOutBitsHi = absIn0;
  *ptrOutBitsLo = outBitsLo;
}

static real_T rt_powd_snf(real_T u0, real_T u1)
{
  real_T y;
  real_T d1;
  real_T d2;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else {
    d1 = fabs(u0);
    d2 = fabs(u1);
    if (rtIsInf(u1)) {
      if (d1 == 1.0) {
        y = rtNaN;
      } else if (d1 > 1.0) {
        if (u1 > 0.0) {
          y = rtInf;
        } else {
          y = 0.0;
        }
      } else if (u1 > 0.0) {
        y = 0.0;
      } else {
        y = rtInf;
      }
    } else if (d2 == 0.0) {
      y = 1.0;
    } else if (d2 == 1.0) {
      if (u1 > 0.0) {
        y = u0;
      } else {
        y = 1.0 / u0;
      }
    } else if (u1 == 2.0) {
      y = u0 * u0;
    } else if ((u1 == 0.5) && (u0 >= 0.0)) {
      y = sqrt(u0);
    } else if ((u0 < 0.0) && (u1 > floor(u1))) {
      y = rtNaN;
    } else {
      y = pow(u0, u1);
    }
  }

  return y;
}

static real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

void soiam_prediction(const struct_T soinn, const emxArray_real_T *signal,
                      real_T key_step_length, real_T interval_length,
                      emxArray_real_T *value, real_T *min_dist, real_T
                      *winner_time)
{
  emxArray_real_T *nodes;
  real_T one_block_length;
  int32_T i0;
  int32_T ia;
  int32_T ix;
  emxArray_real_T *b_nodes;
  real_T b_index;
  int32_T k;
  int32_T ib;
  real_T d0;
  int32_T j;
  int32_T ixstart;
  int32_T iacol;
  int32_T mv[2];
  int32_T outsize[2];
  emxArray_real_T *y;
  uint32_T sz[2];
  emxArray_real_T *b_y;
  emxArray_real_T *D;
  int32_T min_index;
  boolean_T exitg1;
  emxInit_real_T(&nodes, 2);
  one_block_length = (key_step_length + interval_length) + 1.0;
  *min_dist = rtInf;
  i0 = nodes->size[0] * nodes->size[1];
  nodes->size[0] = soinn.nodes->size[0];
  nodes->size[1] = soinn.nodes->size[1];
  emxEnsureCapacity((emxArray__common *)nodes, i0, (int32_T)sizeof(real_T));
  ia = soinn.nodes->size[0] * soinn.nodes->size[1] - 1;
  for (i0 = 0; i0 <= ia; i0++) {
    nodes->data[i0] = soinn.nodes->data[i0];
  }

  i0 = value->size[0] * value->size[1];
  value->size[0] = 1;
  value->size[1] = (int32_T)soinn.dimension;
  emxEnsureCapacity((emxArray__common *)value, i0, (int32_T)sizeof(real_T));
  ia = (int32_T)soinn.dimension - 1;
  for (i0 = 0; i0 <= ia; i0++) {
    value->data[i0] = 0.0;
  }

  *winner_time = -1.0;
  if (!((soinn.nodes->size[0] == 0) || (soinn.nodes->size[1] == 0))) {
    ix = 0;
    emxInit_real_T(&b_nodes, 2);
    while (ix <= (int32_T)-(1.0 + (-1.0 - soinn.dimension)) - 1) {
      b_index = soinn.dimension + -(real_T)ix;
      for (k = 0; k <= (int32_T)-(1.0 + (-1.0 - (interval_length + 1.0))) - 1; k
           ++) {
        ib = nodes->size[1] - 1;
        d0 = rt_roundd_snf(((b_index - 1.0) * one_block_length + key_step_length)
                           + ((interval_length + 1.0) + -(real_T)k));
        if (d0 < 2.147483648E+9) {
          if (d0 >= -2.147483648E+9) {
            j = (int32_T)d0;
          } else {
            j = MIN_int32_T;
          }
        } else if (d0 >= 2.147483648E+9) {
          j = MAX_int32_T;
        } else {
          j = 0;
        }

        while (j <= ib) {
          i0 = nodes->size[0];
          for (ia = 0; ia + 1 <= i0; ia++) {
            nodes->data[ia + nodes->size[0] * (j - 1)] = nodes->data[ia +
              nodes->size[0] * j];
          }

          j++;
        }

        if (1 > ib) {
          ib = 0;
        }

        ixstart = nodes->size[0];
        i0 = b_nodes->size[0] * b_nodes->size[1];
        b_nodes->size[0] = ixstart;
        b_nodes->size[1] = ib;
        emxEnsureCapacity((emxArray__common *)b_nodes, i0, (int32_T)sizeof
                          (real_T));
        ia = ib - 1;
        for (i0 = 0; i0 <= ia; i0++) {
          ib = ixstart - 1;
          for (iacol = 0; iacol <= ib; iacol++) {
            b_nodes->data[iacol + b_nodes->size[0] * i0] = nodes->data[iacol +
              nodes->size[0] * i0];
          }
        }

        i0 = nodes->size[0] * nodes->size[1];
        nodes->size[0] = b_nodes->size[0];
        nodes->size[1] = b_nodes->size[1];
        emxEnsureCapacity((emxArray__common *)nodes, i0, (int32_T)sizeof(real_T));
        ia = b_nodes->size[1] - 1;
        for (i0 = 0; i0 <= ia; i0++) {
          ib = b_nodes->size[0] - 1;
          for (iacol = 0; iacol <= ib; iacol++) {
            nodes->data[iacol + nodes->size[0] * i0] = b_nodes->data[iacol +
              b_nodes->size[0] * i0];
          }
        }
      }

      ix++;
    }

    emxFree_real_T(&b_nodes);
    mv[0] = nodes->size[0];
    mv[1] = 1;
    for (i0 = 0; i0 < 2; i0++) {
      outsize[i0] = mul_s32_s32_s32_sat(signal->size[i0], mv[i0]);
    }

    emxInit_real_T(&y, 2);
    i0 = y->size[0] * y->size[1];
    y->size[0] = outsize[0];
    y->size[1] = outsize[1];
    emxEnsureCapacity((emxArray__common *)y, i0, (int32_T)sizeof(real_T));
    if ((y->size[0] == 0) || (y->size[1] == 0)) {
    } else {
      ia = 1;
      ib = 0;
      iacol = 1;
      for (ixstart = 1; ixstart <= signal->size[1]; ixstart++) {
        for (ix = 1; ix <= mv[0]; ix++) {
          ia = iacol;
          for (k = 1; k <= signal->size[0]; k++) {
            y->data[ib] = signal->data[ia - 1];
            ia++;
            ib++;
          }
        }

        iacol = ia;
      }
    }

    i0 = nodes->size[0] * nodes->size[1];
    nodes->size[0] = nodes->size[0];
    nodes->size[1] = nodes->size[1];
    emxEnsureCapacity((emxArray__common *)nodes, i0, (int32_T)sizeof(real_T));
    ixstart = nodes->size[0];
    ia = nodes->size[1];
    ia = ixstart * ia - 1;
    for (i0 = 0; i0 <= ia; i0++) {
      nodes->data[i0] -= y->data[i0];
    }

    for (i0 = 0; i0 < 2; i0++) {
      sz[i0] = (uint32_T)nodes->size[i0];
    }

    i0 = y->size[0] * y->size[1];
    y->size[0] = (int32_T)sz[0];
    y->size[1] = (int32_T)sz[1];
    emxEnsureCapacity((emxArray__common *)y, i0, (int32_T)sizeof(real_T));
    i0 = y->size[0] * y->size[1];
    for (k = 0; k <= i0 - 1; k++) {
      y->data[k] = rt_powd_snf(nodes->data[k], 2.0);
    }

    for (i0 = 0; i0 < 2; i0++) {
      sz[i0] = (uint32_T)y->size[i0];
    }

    b_emxInit_real_T(&b_y, 1);
    sz[1] = 1U;
    i0 = b_y->size[0];
    b_y->size[0] = (int32_T)sz[0];
    emxEnsureCapacity((emxArray__common *)b_y, i0, (int32_T)sizeof(real_T));
    if ((y->size[0] == 0) || (y->size[1] == 0)) {
      ia = b_y->size[0];
      i0 = b_y->size[0];
      b_y->size[0] = ia;
      emxEnsureCapacity((emxArray__common *)b_y, i0, (int32_T)sizeof(real_T));
      ia--;
      for (i0 = 0; i0 <= ia; i0++) {
        b_y->data[i0] = 0.0;
      }
    } else {
      ia = y->size[1];
      ib = y->size[0];
      iacol = -1;
      ixstart = -1;
      for (j = 1; j <= ib; j++) {
        ixstart++;
        ix = ixstart;
        one_block_length = y->data[ixstart];
        for (k = 2; k <= ia; k++) {
          ix += ib;
          one_block_length += y->data[ix];
        }

        iacol++;
        b_y->data[iacol] = one_block_length;
      }
    }

    emxFree_real_T(&y);
    b_emxInit_real_T(&D, 1);
    i0 = D->size[0];
    D->size[0] = b_y->size[0];
    emxEnsureCapacity((emxArray__common *)D, i0, (int32_T)sizeof(real_T));
    ia = b_y->size[0] - 1;
    for (i0 = 0; i0 <= ia; i0++) {
      D->data[i0] = b_y->data[i0];
    }

    for (k = 0; k <= b_y->size[0] - 1; k++) {
      D->data[k] = sqrt(D->data[k]);
    }

    emxFree_real_T(&b_y);
    *winner_time = 0.0;
    *min_dist = 0.0;
    while ((*winner_time < 1.0) && (*min_dist != rtInf)) {
      ixstart = 1;
      ia = D->size[0];
      one_block_length = D->data[0];
      min_index = 0;
      if (ia > 1) {
        if (rtIsNaN(D->data[0])) {
          ix = 2;
          exitg1 = FALSE;
          while ((exitg1 == 0U) && (ix <= ia)) {
            ixstart = ix;
            if (!rtIsNaN(D->data[ix - 1])) {
              one_block_length = D->data[ix - 1];
              exitg1 = TRUE;
            } else {
              ix++;
            }
          }
        }

        if (ixstart < ia) {
          while (ixstart + 1 <= ia) {
            if (D->data[ixstart] < one_block_length) {
              one_block_length = D->data[ixstart];
              min_index = ixstart;
            }

            ixstart++;
          }
        }
      }

      *min_dist = one_block_length;
      *winner_time = soinn.winTimes->data[min_index];
      D->data[min_index] = rtInf;
    }

    emxFree_real_T(&D);

    /*  winner_time=soinn.winTimes(min_index); */
    for (ix = 0; ix <= (int32_T)((soinn.dimension - 1.0) + 1.0) - 1; ix++) {
      value->data[(int32_T)((real_T)ix + 1.0) - 1] = soinn.nodes->data[min_index
        + soinn.nodes->size[0] * ((int32_T)(((real_T)ix * ((key_step_length +
        interval_length) + 1.0) + key_step_length) + 1.0) - 1)];
    }
  }

  emxFree_real_T(&nodes);
}

/* End of code generation (soiam_prediction.cpp) */
