#define __private_include__
#include <flipper/adc.h>

#ifdef __use_adc__

LF_MODULE(_adc, "adc", "Interfaces with the device's internal analog to digital converter.", NULL, NULL);

/* Define the virtual interface for this module. */
const struct _adc adc = {
	adc_configure
};

LF_WEAK int adc_configure(void) {
	return lf_invoke(&_adc, _adc_configure, lf_int_t, NULL);
}

#endif
