#define __private_include__
#include <flipper/flipper.h>
#include <flipper/carbon/timer.h>

int timer_configure(void) {
	return lf_invoke(&_timer, _timer_configure, NULL);
}