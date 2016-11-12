package main

import "fmt"
import "os"

func main() {
	p := new(Interpreter)
	p.m = []interface{}{
		p.Push, 13,
		p.Push, 28,
		p.Add,
		p.Print,
		p.Exit,
	}
	p.Run()
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

type Interpreter struct {
	S        *stack
	l, r, PC int
	m        []interface{}
}

func (i *Interpreter) opcode() func() {
	return i.m[i.PC].(func())
}

func (i *Interpreter) operand() int {
	return i.m[i.PC].(int)
}

func (i *Interpreter) Run() {
	for {
		i.opcode()()
		i.PC++
	}
}

func (i *Interpreter) Push() {
	i.PC++
	i.S = i.S.Push(i.operand())
}

func (i *Interpreter) Add() {
	i.l, i.S = i.S.Pop()
	i.r, i.S = i.S.Pop()
	i.S = i.S.Push(i.l + i.r)
}

func (i *Interpreter) Print() {
	fmt.Printf("%v + %v = %v\n", i.l, i.r, i.S.data)
}

func (i *Interpreter) Exit() {
	os.Exit(0)
}
