package main

import "fmt"
import "os"

type RegMachine struct {
	R []int
	VM
}

func (r *RegMachine) String() string {
	return fmt.Sprintf("%v, R=%v", r.VM, r.R)
}

func (r *RegMachine) Clear() {
	r.R = make([]int, 2, 2)
}

func (r *RegMachine) read_value() int {
	r.PC++
	return r.read_program().(int)
}

func (r *RegMachine) LoadValue() {
	r.R[r.read_value()] = r.read_value()
}

func (r *RegMachine) Add() {
	i := r.read_value()
	j := r.read_value()
	r.R[i] += r.R[j]
}

func (r *RegMachine) JumpIfNotZero() {
	if r.R[r.read_value()] != 0 {
		r.PC = r.read_value()
	} else {
		r.PC++
	}
}

func main() {
	r := new(RegMachine)
	print_state := func() {
		fmt.Println(r)
	}
	skip := func() { r.PC++ }
	r.Load(
		r.Clear,
		r.LoadValue, 0, 13,
		r.LoadValue, 1, -1,
		Label("decrement"),
		r.Add, 0, 1,
		print_state,
		skip,
		print_state,
		r.JumpIfNotZero, 0, Label("decrement"),
		print_state,
		func() { os.Exit(0) },
	).Run()
}