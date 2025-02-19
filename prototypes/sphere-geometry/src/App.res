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

let makePoints = (): (array<Vec2.t>, array<(int, int, int)>) => {
  let radius = 50.
  let center = (100., 100.)

  let pts = [center]

  let angle = 72. *. Math.Constants.pi /. 180.

  for i in 0 to 4 {
    let x = Math.cos(angle *. float(i))
    let y = Math.sin(angle *. float(i))
    let p: Vec2.t = (x, y)->Vec2.normalize->Vec2.scalarMultiply(radius)->Vec2.add(center)
    pts->Array.push(p)
  }

  let triangles = [(0, 1, 2), (0, 2, 3), (0, 3, 4), (0, 4, 5), (0, 5, 1)]

  (pts, triangles)
}

@react.component
let make = () => {
  let (points, triangles) = React.useMemo0(makePoints)

  <svg width="400" height="400" viewBox="0 0 200 200" className="border">
    <style> {"text { font: 10px monospace; }"->React.string} </style>
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
      <polygon key={i->Int.toString} points=pts fill="none" stroke="black" />
    })
    ->React.array}
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
        <text x={(x +. 4.)->Float.toString} y={(y -. 2.)->Float.toString}>
          {i->Int.toString->React.string}
        </text>
      </React.Fragment>
    })
    ->React.array}
  </svg>
}
