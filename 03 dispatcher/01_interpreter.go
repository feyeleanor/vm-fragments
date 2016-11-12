package main

import "fmt"

func main() {
	var program = []interface{}{
		PUSH, 13,
		PUSH, 28,
		ADD,
		PRINT,
		EXIT,
	}
	interpret(program)
}

type stack struct {
	data int
	tail *stack
}

func (s *stack) Push(v int) (r *stack) {
	r = &stack{data: v, tail: s}
	return
}

func (s *stack) Pop() (v int, r *stack) {
	return s.data, s.tail
}

type OPCODE int

const (
	PUSH = OPCODE(iota)
	ADD
	PRINT
	EXIT
)

func interpret(p []interface{}) {
	var l, r int
	S := new(stack)

	for PC := 0; ; PC++ {
		if op, ok := p[PC].(OPCODE); ok {
			switch op {
			case PUSH:
				PC++
				S = S.Push(p[PC].(int))
			case ADD:
				l, S = S.Pop()
				r, S = S.Pop()
				S = S.Push(l + r)
			case PRINT:
				fmt.Printf("%v + %v = %v\n", l, r, S.data)
			case EXIT:
				return
			}
		} else {
			return
		}
	}
}
