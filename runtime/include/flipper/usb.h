#ifndef __usb_h__
#define __usb_h__

/* Include all types and macros exposed by the Flipper Toolbox. */
#include <flipper/libflipper.h>

/* Declare the virtual interface for this module. */
extern const struct _usb {
	int (* configure)(void);
} usb;

#ifdef __private_include__

/* Declare the _lf_module structure for this module. */
extern struct _lf_module _usb;

/* Declare the FMR overlay for this module. */
enum { _usb_configure };

/* Declare the prototypes for all of the functions within this module. */
int usb_configure(void);

#endif
#endif
