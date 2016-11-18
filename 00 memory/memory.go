package main
import r "reflect"
import "unsafe"

type Memory []uintptr

var _BYTE_SLICE = r.TypeOf([]byte(nil))
var _MEMORY = r.TypeOf(Memory{})
var _MEMORY_BYTES = int(_MEMORY.Elem().Size())

func (m Memory) newHeader() (h r.SliceHeader) {
	h = *(*r.SliceHeader)(unsafe.Pointer(&m))
	h.Len = len(m) * _MEMORY_BYTES
	h.Cap = cap(m) * _MEMORY_BYTES
	return
}

func (m *Memory) Bytes() (b []byte) {
	h := m.newHeader()
	return *(*[]byte)(unsafe.Pointer(&h))
}

func (m *Memory) Serialise() (b []byte) {
	h := m.newHeader()
	b = make([]byte, h.Len)
	copy(b, *(*[]byte)(unsafe.Pointer(&h)))
	return
}

func (m *Memory) Overwrite(i interface{}) {
	switch i := i.(type) {
	case Memory:
		copy(*m, i)
	case []byte:
		h := m.newHeader()
		b := *(*[]byte)(unsafe.Pointer(&h))
		copy(b, i)
	}
}