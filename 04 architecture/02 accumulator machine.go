package main

import "fmt"
import "os"

type AccMachine struct {
	A int
	VM
}

func (a *AccMachine) String() string {
	return fmt.Sprintf("%v, A=%v", a.VM, a.A)
}

func (a *AccMachine) Clear() {
	a.A = 0
}

func (a *AccMachine) LoadValue() {
	a.PC++
	a.A = a.read_program().(int)
}

func (a *AccMachine) Add() {
	a.PC++
	a.A += a.read_program().(int)
}

func (a *AccMachine) JumpIfNotZero() {
	a.PC++
	if a.A != 0 {
		a.PC = a.m[a.PC].(int)
	}
}

func main() {
	a := new(AccMachine)
	print_state := func() {
		fmt.Println(a)
	}
	skip := func() { a.PC++ }
	a.Load(
		a.Clear,
		a.LoadValue, 13,
		Label("decrement"),
		a.Add, -1,
		print_state,
		skip,
		print_state,
		a.JumpIfNotZero, Label("decrement"),
		print_state,
		func() { os.Exit(0) },
	).Run()
}