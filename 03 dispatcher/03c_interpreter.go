package main

import "fmt"
import "os"

type stack struct {
	data int
	tail *stack
}

func (s *stack) Push(v int) (r *stack) {
	return &stack{data: v, tail: s}
}

func (s *stack) Pop() (v int, r *stack) {
	return s.data, s.tail
}

type Primitive func()

type Interpreter struct {
	S        *stack
	l, r, PC int
	m        []Primitive
}

func (i *Interpreter) read_program() Primitive {
	return i.m[i.PC]
}

func (i *Interpreter) Run() {
	for {
		i.read_program()()
		i.PC++
	}
}

func main() {
	i := new(Interpreter)
	npush := func(vals ...int) Primitive {
		return func() {
			for _, v := range vals {
				i.S = i.S.Push(v)
			}
		}
	}
	i.m = []Primitive{
		npush(13, 28),
		func() {
			i.l, i.S = i.S.Pop()
			i.r, i.S = i.S.Pop()
			i.S = i.S.Push(i.l + i.r)
		},
		func() {
			fmt.Printf("%v + %v = %v\n", i.l, i.r, i.S.data)
		},
		func() { os.Exit(0) },
	}
	i.Run()
}