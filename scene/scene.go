package scene

import "github.com/ungerik/go3d/vec3"

type Camera struct {
	Position  vec3.T
	Direction vec3.T
	Fov       float32
}

type Sphere struct {
	Position vec3.T
	Radius   float32
}

type T struct {
	Camera  Camera
	Light   vec3.T
	Spheres []Sphere
}
