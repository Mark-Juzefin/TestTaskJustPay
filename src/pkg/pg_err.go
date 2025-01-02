package pkg

import (
	"errors"
	"github.com/jackc/pgx/v5/pgconn"
)

func IsPgErrorUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code == "23505"
	}
	return false
}
