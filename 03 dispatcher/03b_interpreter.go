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

type Primitive func(*Interpreter)

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
		i.read_program()(i)
		i.PC++
	}
}

func main() {
	p := &Interpreter{
		m: []Primitive{
			func(i *Interpreter) {
				i.S = i.S.Push(13)
				i.PC++
				i.read_program()(i)
				i.PC++
				i.read_program()(i)
			},
			func(i *Interpreter) { i.S = i.S.Push(28) },
			func(i *Interpreter) {
				i.l, i.S = i.S.Pop()
				i.r, i.S = i.S.Pop()
				i.S = i.S.Push(i.l + i.r)
			},
			func(i *Interpreter) {
				fmt.Printf("%v + %v = %v\n", i.l, i.r, i.S.data)
			},
			func (i *Interpreter) { os.Exit(0) },
		},
	}
	p.Run()
}