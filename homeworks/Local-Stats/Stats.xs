#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

static SV * init = (SV*)NULL;

typedef struct object {
  HV * metrics;
  HV * counts;
} stats_obj;

typedef stats_obj * Local__Stats;

MODULE = Local::Stats		PACKAGE = Local::Stats

INCLUDE: const-xs.inc

Local::Stats
new(char * class, code)
  SV * code
  CODE:
    RETVAL = calloc (1, sizeof(stats_obj));
    if (! RETVAL) {
      croak ("No memory for %s", class);
    }
    RETVAL->metrics = newHV();
    RETVAL->counts = newHV();
    if (init == (SV*)NULL)
        init = newSVsv(code);
    else
        SvSetSV(init, code);
  OUTPUT:
    RETVAL

void
add(stats, name, num)
  Local::Stats stats
  char * name
  float num
  CODE:
    if (hv_exists(stats->metrics, name, strlen(name))) {
      int count = SvIV(*(hv_fetch(stats->counts, name, strlen(name), 0))) + 1;
      hv_store(stats->counts, name, strlen(name), newSViv(count), 0);
      HV * save_metr = (HV *)(SvRV(*(hv_fetch(stats->metrics, name, strlen(name), 0))));
      HV * metr = newHV();
      if(hv_exists(save_metr, "cnt", 3)) {
        hv_store(metr, "cnt", 3, newSViv(count), 0);
      }
      if(hv_exists(save_metr, "min", 3)) {
        float min = SvNV(*(hv_fetch(save_metr, "min", 3, 0)));
        if (min > num) {
          hv_store(metr, "min", 3, newSVnv(num), 0);
        } else {
          hv_store(metr, "min", 3, newSVnv(min), 0);
        }
      }
      if(hv_exists(save_metr, "max", 3)) {
        float max = SvNV(*(hv_fetch(save_metr, "max", 3, 0)));
        if (max < num) {
          hv_store(metr, "max", 3, newSVnv(num), 0);
        } else {
          hv_store(metr, "max", 3, newSVnv(max), 0);
        }
      }
      if(hv_exists(save_metr, "sum", 3)) {
        hv_store(metr, "sum", 3, newSVnv(SvNV(*(hv_fetch(save_metr, "sum", 3, 0))) + num), 0);
      }
      if(hv_exists(save_metr, "avg", 3)) {
        hv_store(metr, "avg", 3, newSVnv((SvNV(*(hv_fetch(save_metr, "avg", 3, 0)))*(count-1) + num)/count), 0);
      }
      hv_store(stats->metrics, name, strlen(name), newRV((SV *)metr), 0);
    } else {
      int count;
      ENTER;
      SAVETMPS;
      PUSHMARK(SP);
      EXTEND(SP, 5);
      mPUSHp(name, strlen(name));
      PUTBACK;
      count = call_sv(init, G_ARRAY);
      SPAGAIN;
      if (count > 5)
        croak("Only cnt, max, min, avg or sum in metric!\n");
      HV* metr = (HV *)sv_2mortal((SV *)newHV());
      for (int i = 0; i < count; i++) {
        char * str = POPp;
        int empty = 1;
        if (!strcmp(str,"cnt")) {
          hv_store(metr, "cnt", 3, newSViv(1), 0);
          empty = 0;
        }
        if (!strcmp(str,"min")) {
          hv_store(metr, "min", 3, newSVnv(num), 0);
          empty = 0;
        }
        if (!strcmp(str,"max")) {
          hv_store(metr, "max", 3, newSVnv(num), 0);
          empty = 0;
        }
        if (!strcmp(str,"sum")) {
          hv_store(metr, "sum", 3, newSVnv(num), 0);
          empty = 0;
        }
        if (!strcmp(str,"avg")) {
          hv_store(metr, "avg", 3, newSVnv(num), 0);
          empty = 0;
        }
        if(!empty) {
          hv_store(stats->counts, name, strlen(name), newSViv(1), 0);
          hv_store(stats->metrics, name, strlen(name), newRV((SV *)metr), 0);
        }
      }
      FREETMPS;
      LEAVE;
    }

SV * get(stats)
    Local::Stats stats
    CODE:
      RETVAL = newRV((SV *)stats->metrics);
    OUTPUT:
      RETVAL
