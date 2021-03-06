#ifndef __wdt_h__
#define __wdt_h__

/* Include all types and macros exposed by the Flipper Toolbox. */
#include <flipper/libflipper.h>

/* Declare the virtual interface for this module. */
extern const struct _wdt {
	int (* configure)(void);
	void (* fire)(void);
} wdt;

#ifdef __private_include__

/* Declare the _lf_module structure for this module. */
extern struct _lf_module _wdt;

/* Declare the FMR overlay for this module. */
enum { _wdt_configure, _wdt_fire };

/* Declare the prototypes for all of the functions within this module. */
int wdt_configure(void);
void wdt_fire(void);

#endif
#endif
