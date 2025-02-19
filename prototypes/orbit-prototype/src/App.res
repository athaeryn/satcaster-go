module Simulation = {
  let gravitationalConstant = 6.67e-11

  type body = {
    diameter: int, // meters
    mass: bigint, // kilograms
    x: int, // kilometers
    y: int, // kilometers
    velocityX: int, // km/s
    velocityY: int, // km/s
  }

  type bodyEntity = Static(body) | Dynamic(body)

  type state = {bodies: array<bodyEntity>}

  type action = Step

  let saturn = {
    // 120,500km
    diameter: 120500000,
    mass: 568300000000000000000000000n,
    // Everything is relative to the planet
    x: 0,
    y: 0,
    velocityX: 0,
    velocityY: 0,
  }

  let titan = {
    diameter: 5149000,
    mass: 135000000000000000000000n,
    x: 1221870,
    y: 0,
    velocityX: 0,
    velocityY: 0,
  }

  let satcaster = {
    diameter: 2,
    mass: 800n,
    x: 125529,
    y: 0,
    velocityX: 0,
    velocityY: 17,
  }

  let use = (): (state, action => unit) => {
    let (state, dispatch) = React.useReducer(
      (state, action) => {
        switch action {
        | Step => {
            let bodies' = state.bodies->Array.map(entity => {
              switch entity {
              | Static(body) => Static(body)
              | Dynamic(body) =>
                Dynamic({
                  ...body,
                  x: body.x + body.velocityX * 1000,
                  y: body.y + body.velocityY * 1000,
                })
              }
            })
            {bodies: bodies'}
          }
        }
      },
      {
        bodies: [Static(saturn), Dynamic(titan), Dynamic(satcaster)],
      },
    )
    (state, dispatch)
  }
}

Console.log3(Simulation.saturn, Simulation.titan, Simulation.satcaster)

// let scaleFactor = 1716333
let scaleFactor = 2900000

let center = (500, 500)
let (centerX, centerY) = center

@react.component
let make = () => {
  let (state, dispatch) = Simulation.use()
  <div className="p-6">
    <button
      type_="button"
      onClick={_e => {
        dispatch(Step)
      }}>
      {"Step"->React.string}
    </button>
    <svg height="1000" width="1200" viewBox="0 0 1000 1000" className="border">
      {state.bodies
      ->Array.map(entity =>
        switch entity {
        | Static(body) => body
        | Dynamic(body) => body
        }
      )
      ->Array.map((body: Simulation.body) => {
        let xOffset = body.x * 1000 / scaleFactor
        let yOffset = body.y * 1000 / scaleFactor
        let cx = centerX + xOffset
        let cy = centerY + yOffset
        let r = max(1, body.diameter / scaleFactor)->Int.toString
        <ellipse cx={cx->Int.toString} cy={cy->Int.toString} rx=r ry=r fill="black" />
      })
      ->React.array}
    </svg>
  </div>
}
