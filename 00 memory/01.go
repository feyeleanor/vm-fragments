package main
import "fmt"

func main() {
	m := make(Memory, 2)
	b := m.Bytes()
	s := m.Serialise()
	fmt.Println("m (cells) =", len(m), "of", cap(m), ":", m)
	fmt.Println("b (bytes) =", len(b), "of", cap(b), ":", b)
	fmt.Println("s (bytes) =", len(s), "of", cap(s), ":", s)

	m.Overwrite(Memory{3, 5})
	fmt.Println("m (cells) =", len(m), "of", cap(m), ":", m)
	fmt.Println("b (bytes) =", len(b), "of", cap(b), ":", b)
	fmt.Println("s (bytes) =", len(s), "of", cap(s), ":", s)

	s = m.Serialise()
	m.Overwrite([]byte{8, 7, 6, 5, 4, 3, 2, 1})
	fmt.Println("m (cells) =", len(m), "of", cap(m), ":", m)
	fmt.Println("b (bytes) =", len(b), "of", cap(b), ":", b)
	fmt.Println("s (bytes) =", len(s), "of", cap(s), ":", s)
}