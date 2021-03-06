#ifndef __swd_h__
#define __swd_h__

/* Include all types and macros exposed by the Flipper Toolbox. */
#include <flipper/libflipper.h>

/* Declare the virtual interface for this module. */
extern const struct _swd {

	int (* configure)(void);

} swd;

#ifdef __private_include__

/* Declare the _lf_module structure for this module. */
extern struct _lf_module _swd;

/* Declare the FMR overlay for this module. */
enum { _swd_configure };

/* Declare the prototypes for all of the functions within this module. */
int swd_configure(void);

#endif
#endif
