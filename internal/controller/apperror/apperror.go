package apperror

import "errors"

var ErrUnappropriatedStatus = errors.New("inappropriate status transition")
var ErrOrderNotFound = errors.New("order not found")
var ErrEventAlreadyStored = errors.New("event already stored")

var ErrInvalidOrdersQuery = errors.New("invalid orders query")
var ErrOrderOnHold = errors.New("order is on hold")
var ErrOrderInFinalStatus = errors.New("order is in final status")
