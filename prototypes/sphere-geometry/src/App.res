module Vec2: {
  type t = (float, float)

  let add: (t, t) => t
  let multiply: (t, t) => t
  let divide: (t, t) => t

  let scalarMultiply: (t, float) => t
  let scalarDivide: (t, float) => t

  let length: t => float
  let lengthSq: t => float

  let normalize: t => t
} = {
  type t = (float, float)

  let add = ((aX, aY), (bX, bY)) => {
    (aX +. bX, aY +. bY)
  }

  let multiply = ((aX, aY), (bX, bY)) => {
    (aX *. bX, aY *. bY)
  }

  let divide = ((aX, aY), (bX, bY)) => {
    (aX /. bX, aY /. bY)
  }

  let scalarMultiply = ((x, y), s) => {
    (x *. s, y *. s)
  }

  let scalarDivide = ((x, y), s) => {
    (x /. s, y /. s)
  }

  let length = ((x, y)) => {
    Math.sqrt(x *. x +. y *. y)
  }

  let lengthSq = ((x, y)) => {
    x *. x +. y *. y
  }

  let normalize = vec => {
    let mag = length(vec)
    let (x, y) = vec
    (x /. mag, y /. mag)
  }
}

let centroid = (a: Vec2.t, b: Vec2.t, c: Vec2.t): Vec2.t => {
  let (aX, aY) = a
  let (bX, bY) = b
  let (cX, cY) = c
  ((aX +. bX +. cX) /. 3., (aY +. bY +. cY) /. 3.)
}

let midpoint = (a: Vec2.t, b: Vec2.t): Vec2.t => {
  let (aX, aY) = a
  let (bX, bY) = b
  ((aX +. bX) /. 2., (aY +. bY) /. 2.)
}

let makePoints = (): (array<Vec2.t>, array<(int, int, int)>) => {
  let radius = 80.
  let center = (100., 100.)

  let pts = [center]

  let offset = -90. *. Math.Constants.pi /. 180.
  let angle = 72. *. Math.Constants.pi /. 180.

  for i in 0 to 4 {
    let x = Math.cos(angle *. float(i) +. offset)
    let y = Math.sin(angle *. float(i) +. offset)
    let p: Vec2.t = (x, y)->Vec2.normalize->Vec2.scalarMultiply(radius)->Vec2.add(center)
    pts->Array.push(p)
  }

  let triangles = [(0, 1, 2), (0, 2, 3), (0, 3, 4), (0, 4, 5), (0, 5, 1)]

  {
    let p0 = pts->Array.getUnsafe(0)
    let p1 = pts->Array.getUnsafe(1)
    let p2 = pts->Array.getUnsafe(2)
    let p3 = pts->Array.getUnsafe(3)
    let p4 = pts->Array.getUnsafe(4)
    let p5 = pts->Array.getUnsafe(5)
    pts->Array.push(midpoint(p0, p1))
    pts->Array.push(midpoint(p0, p2))
    pts->Array.push(midpoint(p0, p3))
    pts->Array.push(midpoint(p0, p4))
    pts->Array.push(midpoint(p0, p5))
    pts->Array.push(midpoint(p1, p2))
    pts->Array.push(midpoint(p2, p3))
    pts->Array.push(midpoint(p3, p4))
    pts->Array.push(midpoint(p4, p5))
    pts->Array.push(midpoint(p5, p1))
  }

  let foo = ((a, b, c)) => {
    triangles->Array.push((a, b, c))

    let pA = pts->Array.getUnsafe(a)
    let pB = pts->Array.getUnsafe(b)
    let pC = pts->Array.getUnsafe(c)
    pts->Array.push(midpoint(pA, pB))
    pts->Array.push(midpoint(pB, pC))
    pts->Array.push(midpoint(pC, pA))
  }

  let subdivideFace = ((a, b, c)) => {
    let e = pts->Array.length
    let f = e + 1
    let g = f + 1
    let h = g + 1
    let i = h + 1
    let j = i + 1
    foo((a, b, c))
    foo((e, f, g))
    triangles->Array.push((h, i, j))
  }

  subdivideFace((6, 11, 7))
  subdivideFace((7, 12, 8))
  subdivideFace((8, 13, 9))
  subdivideFace((9, 14, 10))
  subdivideFace((10, 15, 6))
  subdivideFace((0, 6, 7))
  subdivideFace((0, 7, 8))
  subdivideFace((0, 8, 9))
  subdivideFace((0, 9, 10))
  subdivideFace((0, 10, 6))
  subdivideFace((2, 7, 12))
  subdivideFace((12, 3, 8))
  subdivideFace((8, 3, 13))
  subdivideFace((13, 4, 9))
  subdivideFace((9, 4, 14))
  subdivideFace((10, 14, 5))
  subdivideFace((10, 5, 15))
  subdivideFace((6, 15, 1))
  subdivideFace((6, 1, 11))
  subdivideFace((7, 11, 2))

  (pts, triangles)
}

let getColor: int => string = {
  let colors = ["darkorchid", "deeppink", "firebrick"]
  let colorCount = colors->Array.length
  x => {
    colors->Array.get(mod(x + 2, colorCount))->Option.getOr("white")
  }
}

@react.component
let make = () => {
  let (points, triangles) = React.useMemo0(makePoints)

  <svg width="600" height="600" viewBox="0 0 200 200" className="border rounded shadow-xl m-12">
    <style> {"text { font: 4px monospace; }"->React.string} </style>
    {triangles
    ->Array.mapWithIndex((triangle, i) => {
      let (a, b, c) = triangle
      let verts = [a, b, c]
      let pts =
        verts
        ->Array.map(v => {
          let (x, y) = points->Array.getUnsafe(v)
          `${x->Float.toString},${y->Float.toString}`
        })
        ->Array.join(" ")
      <polygon
        key={i->Int.toString}
        points=pts
        fill="none"
        stroke={getColor(i)}
        strokeWidth="0.5"
        strokeDasharray="2 1 3"
        strokeOpacity="0.75"
      />
    })
    ->React.array}
    /*
    {points
    ->Array.mapWithIndex(((x, y), i) => {
      <React.Fragment key={i->Int.toString}>
        <rect
          width="2"
          height="2"
          fill="red"
          x={(x -. 1.)->Float.toString}
          y={(y -. 1.)->Float.toString}
        />
        <text x={(x +. 1.)->Float.toString} y={(y -. 1.)->Float.toString}>
          {i->Int.toString->React.string}
        </text>
      </React.Fragment>
    })
    ->React.array}
 */
  </svg>
}
