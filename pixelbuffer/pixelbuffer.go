package pixelbuffer

type T struct {
	Data   []int
	Width  int
	Height int
}

func New(width int, height int) T {
	return T{
		Data:   make([]int, width*height),
		Width:  width,
		Height: height,
	}
}

func Get(t *T, x int, y int) int {
	return (*t).Data[x+y*(*t).Width]
}

func Set(t *T, x int, y int, value int) {
	(*t).Data[x+y*(*t).Width] = value
}

func Add(t *T, x int, y int, value int) {
	(*t).Data[x+y*(*t).Width] += value
}
