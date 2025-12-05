package utils

type Null[t any] struct {
	Value t
	Set   bool
	Valid bool
}

func NewNull[t any]() Null[t] {
	return Null[t]{}
}
