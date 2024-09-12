package renderer

import (
	"fmt"
	"math"
	"sort"

	"github.com/ungerik/go3d/vec3"

	"athaeryn.com/satcaster/pixelbuffer"
	"athaeryn.com/satcaster/scene"
)

type ray struct {
	position  vec3.T
	direction vec3.T
}

type intersection struct {
	position vec3.T
	normal   vec3.T
	z        float32
}

type intersectionByZ []intersection

func (x intersectionByZ) Len() int           { return len(x) }
func (x intersectionByZ) Swap(i, j int)      { x[i], x[j] = x[j], x[i] }
func (x intersectionByZ) Less(i, j int) bool { return x[i].z < x[i].z }

func RenderToPixelbuffer(s scene.T, pixels *pixelbuffer.T) {
	w := (*pixels).Width
	h := (*pixels).Height

	aspect := float32(w) / float32(h)

	fov := float32(math.Tan(float64(s.Camera.Fov / 2.0 * 3.14 / 180.0)))

	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {

			sx := ((2.0 * (float32(x) + 0.5) / float32(w)) - 1.0) * aspect * fov
			sy := (1.0 - (2.0 * (float32(y) + 0.5) / float32(h))) * fov

			ray_dir := vec3.T{sx, sy, -1.0}
			ray_dir = *(ray_dir.Normalize())

			camera_ray := ray{position: s.Camera.Position, direction: ray_dir}

			intersections := []intersection{}

			for _, sphere := range s.Spheres {
				if intersection, ok := getIntersection(camera_ray, sphere); ok {
					intersections = append(intersections, intersection)
				}
			}

			sort.Slice(intersections, func(i, j int) bool {
				return intersections[i].z < intersections[j].z
			})

			if len(intersections) > 0 {
				intersection := intersections[0]

				lightDir := vec3.T{}
				lightDir.Add(&s.Light).Sub(&intersection.position).Normalize()

				lightRay := ray{position: intersection.position, direction: lightDir}

				shadowed := false
				for _, sphere := range s.Spheres {
					if _, intersects := getIntersection(lightRay, sphere); intersects {
						fmt.Println("SHADOW")
						shadowed = true
						break
					}
				}

				if shadowed {
					pixelbuffer.Set(pixels, x, y, 0)
				} else {
					angleToLight := vec3.Dot(&lightDir, &intersection.normal)

					value := 200.0 * angleToLight
					if value > 255 {
						value = 255.0
					}
					if value < 0 {
						value = 0.0
					}
					pixelbuffer.Set(pixels, x, y, int(value))
				}
			}
		}
	}
}

func getIntersection(ray ray, sphere scene.Sphere) (intersection, bool) {
	t0 := getIntersectionDistance(ray, sphere)
	if t0 < 0.0 {
		return intersection{}, false
	}

	mag := ray.direction.Scaled(t0)
	hit := ray.position.Add(&mag)
	normal := hit
	normal.Sub(&sphere.Position).Normalize()

	return intersection{
		position: *hit,
		normal:   *normal,
		z:        t0,
	}, true
}

func getIntersectionDistance(ray ray, sphere scene.Sphere) float32 {
	var noIntersection float32 = -1.0

	// fmt.Println("----")
	// fmt.Println("ray", ray, "sphere", sphere)

	sphereRadSquared := sphere.Radius * sphere.Radius

	l := sphere.Position.Subed(&ray.position)

	// fmt.Println("L", l)

	tca := vec3.Dot(&ray.direction, &l)
	// fmt.Println("tca", tca)
	if tca < 0.0 {
		return noIntersection
	}

	// fmt.Println("LengthSquared", l.LengthSqr()-tca*tca)

	d := float32(math.Sqrt(float64(l.LengthSqr() - tca*tca)))
	d2 := l.LengthSqr() - tca*tca
	// fmt.Println("d", d, "sphere.Radius", sphere.Radius)
	// fmt.Println("d2", d2, "sphereRadSquared", sphereRadSquared)
	if d > sphere.Radius {
		return noIntersection
	}

	thc := float32(math.Sqrt(float64(sphereRadSquared - d2)))
	// fmt.Println("thc", thc)
	t0 := tca - thc
	t1 := tca + thc
	// fmt.Println("t0", t0, "t1", t1)

	if t1 < t0 {
		foo := t0
		t0 = t1
		t1 = foo
	}

	if t0 < 0.0 {
		t0 = t1
		if t0 < 0.0 {
			return noIntersection
		}
	}

	if t0 > 0.0 {
		return t0
	}

	return noIntersection
}
