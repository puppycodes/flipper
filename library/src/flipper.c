#include <flipper.h>

/* Expose the virtual interface for this driver. */
const struct _flipper flipper = {
	flipper_attach,
	flipper_select,
	flipper_detach,
	flipper_exit,
};

/* Shim to attach all possible flipper devices that could be attached to the system. */
struct _lf_device *flipper_attach(void) {
	int _e = carbon_attach();
	lf_assert(_e == lf_success, failure, E_NO_DEVICE, "Failed to find any Flipper devices attached to this computer. Please check your connection and try again.");
	return lf_get_current_device();
failure:
	return NULL;
}

int flipper_select(struct _lf_device *device) {
	lf_assert(device, failure, E_NULL, "NULL device pointer provided for selection.");
	lf_set_current_device(device);
	return lf_success;
failure:
	return lf_error;
}

/* Shim around lf_detach. */
int flipper_detach(struct _lf_device *device) {
	return lf_detach(device);
}

/* Shim around lf_exit. */
int flipper_exit(void) {
	return lf_exit();
}
