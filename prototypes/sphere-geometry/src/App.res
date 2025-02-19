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

let makePoints = (): array<Vec2.t> => {
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

  pts
}

@react.component
let make = () => {
  let points = React.useMemo0(makePoints)
  let (count, setCount) = React.useState(() => 0)

  <div className="p-6">
    <h1 className="text-3xl font-semibold"> {"What is this about?"->React.string} </h1>
    <p>
      {React.string("This is a simple template for a Vite project using ReScript & Tailwind CSS.")}
    </p>
    <h2 className="text-2xl font-semibold mt-5"> {React.string("Fast Refresh Test")} </h2>
    <Button onClick={_ => setCount(count => count + 1)}>
      {React.string(`count is ${count->Int.toString}`)}
    </Button>
    <p>
      {React.string("Edit ")}
      <code> {React.string("src/App.res")} </code>
      {React.string(" and save to test Fast Refresh.")}
    </p>
    <svg width="400" height="400" viewBox="0 0 200 200" className="border">
      <style> {"text { font: 10px monospace; }"->React.string} </style>
      {points
      ->Array.mapWithIndex(((x, y), i) => {
        <React.Fragment key={i->Int.toString}>
          <rect width="2" height="2" fill="black" x={x->Float.toString} y={y->Float.toString} />
          <text x={(x +. 4.)->Float.toString} y={(y -. 2.)->Float.toString}>
            {i->Int.toString->React.string}
          </text>
        </React.Fragment>
      })
      ->React.array}
    </svg>
  </div>
}
