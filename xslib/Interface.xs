#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

void overlay_arrays_simple(AV* lower_layer, AV* top_layer, SV* offset_y, SV* offset_x);
//void greeting2(AV* lower_layer, AV* top_layer, SV* offset_y, SV* offset_x);

MODULE = XS::Interface       PACKAGE = XS::Interface

void overlay_arrays_simple(AV* lower_layer, AV* top_layer, SV* offset_y, SV* offset_x)
    CODE:
        size_t y;
        for (y = 0; y <= av_len(top_layer); y++) {
            SV** elem = av_fetch(top_layer, y, 1);
            if (SvROK(*elem) && SvTYPE(SvRV(*elem)) == SVt_PVAV) {
                AV* inter = (AV*) SvRV(*elem);
                size_t x;
                for (x = 0; x <= av_len(inter); x++) {
                    SV** elem_inter = av_fetch(inter, x, 1);
                    //printf("hello world3!   %d\n", (int) SvIV(*elem_inter));
                    int offset_y_int = (int) SvIV(offset_y);
                    SV** ll_y_ref = av_fetch(lower_layer, y + offset_y_int, 1);
                    AV* ll_y = (AV*) SvRV(*ll_y_ref);
                    int offset_x_int = (int) SvIV(offset_x);
                    SV** ll_x_ref = av_fetch(ll_y, x + offset_x_int, 1);
                    //printf("hello world3!   %d\n", (int) SvIV(*ll_x_ref));
                    **ll_x_ref = **elem_inter;
                }
            }
        }
