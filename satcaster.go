package main

import (
	"fmt"
	"os"

	"github.com/ungerik/go3d/vec3"

	"athaeryn.com/satcaster/pixelbuffer"
	"athaeryn.com/satcaster/renderer"
	"athaeryn.com/satcaster/scene"
)

func main() {
	// light := vec3.T{10, 10, 5}
	// sphere1 := scene.Sphere{Position: vec3.T{0, 0, -5}, Radius: 2}
	// sphere2 := scene.Sphere{Position: vec3.T{-2.75, -0.5, -6}, Radius: 0.5}
	light := vec3.T{10, 0, 0}
	sphere1 := scene.Sphere{Position: vec3.T{0, 0, -10}, Radius: 2}
	sphere2 := scene.Sphere{Position: vec3.T{3, 0, -7}, Radius: 0.5}
	camera := scene.Camera{Position: vec3.T{}, Direction: vec3.T{0, 0, -1}, Fov: 90}
	scene := scene.T{Camera: camera, Light: light, Spheres: []scene.Sphere{sphere1, sphere2}}

	pixels := pixelbuffer.New(512, 512)

	renderer.RenderToPixelbuffer(scene, &pixels)

	// print_display(&pixels)
	pgm := generatePgm(&pixels)
	_ = os.WriteFile("./render.pgm", []byte(pgm), 0644)
}

/*
func print_display(pixels *pixelbuffer.T) {
	for y := 0; y < (*pixels).Height; y++ {
		var line string
		for x := 0; x < (*pixels).Width; x++ {
			if pixelbuffer.Get(pixels, x, y) > 0 {
				line += "()"
			} else {
				line += "<>"
			}
		}
		fmt.Println(line)
	}
}
*/

func generatePgm(pixels *pixelbuffer.T) string {
	var buffer string
	buffer += "P2\n" + fmt.Sprint(pixels.Width) + " " + fmt.Sprint(pixels.Height) + "\n255\n"
	for y := 0; y < (*pixels).Height; y++ {
		var line string
		for x := 0; x < (*pixels).Width; x++ {
			value := pixelbuffer.Get(pixels, x, y)
			val := fmt.Sprint(value)
			line += val + " "
		}
		buffer += line + "\n"
	}
	return buffer
}
