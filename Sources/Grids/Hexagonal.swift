// Hexagonal Grid
//
// Resource:
// Hexagonal Grids from Red Blob Games, https://www.redblobgames.com/grids/hexagons
// https://www.redblobgames.com/grids/hexagons/implementation.html

/// Orientation of a hexagon when drawn in Cartesian coordinate system
struct HexOrientation {
    let f0, f1, f2, f3: Double
    let b0, b1, b2, b3: Double
    let startAngle: Double // in multiplies of 60°

    init(f0: Double, f1: Double, f2: Double, f3: Double,
         b0: Double, b1: Double, b2: Double, b3: Double,
         startAngle: Double) {
        self.f0 = f0
        self.f1 = f1
        self.f2 = f2
        self.f3 = f3
        self.b0 = b0
        self.b1 = b1
        self.b2 = b2
        self.b3 = b3
        self.startAngle = startAngle
    }

    static var pointyTop: HexOrientation {
        return HexOrientation(
            f0: 3.0.squareRoot(),
            f1: 3.0.squareRoot() / 2.0,
            f2: 0.0,
            f3: 3.0 / 2.0,
            b0: 3.0.squareRoot() / 3.0,
            b1: -1.0 / 3.0,
            b2: 0.0,
            b3: 2.0 / 3.0,
            startAngle: 0.5
        )
    }

    static var flatTop: HexOrientation {
        return HexOrientation(
            f0: 3.0 / 2.0,
            f1: 0.0,
            f2: 3.0.squareRoot() / 2.0,
            f3: 3.0.squareRoot(),
            b0: 2.0 / 3.0,
            b1: 0.0,
            b2: -1.0 / 3.0,
            b3: 3.0.squareRoot() / 3.0,
            startAngle: 0.0
        )
    }
}

/// Layout of a hex grid in cartesian system
///
struct HexCartesianLayout {
    let orientation: HexOrientation
    let origin: CartesianPoint
    let size: CartesianSize

    init(orientation: HexOrientation, origin: CartesianPoint, size:
        CartesianSize) {
        self.orientation = orientation
        self.origin = origin
        self.size = size
    }
}


struct HexAxialPoint {
    let q: Int
    let r: Int

    init(q: Int, r: Int) {
        self.q = q
        self.r = r
    }
    
    /// convert the axial location to cartesian point
    func cartesian(layout: HexCartesianLayout) -> CartesianPoint {
        let M = layout.orientation

        return CartesianPoint (
            x: layout.origin.x + (M.f0*Double(q) + M.f1*Double(r)) * layout.size.width,
            y: layout.origin.y + (M.f2*Double(q) + M.f3*Double(r)) * layout.size.height
        )
    }
}


enum HexCubeDirection {
    case d30
    case d90
    case d150
    case d210
    case d270
    case d330

    var unit: HexCubePoint {
        switch self{
        case .d30:  return HexCubePoint(q: +1, r: -1, s:  0) // 0
        case .d90:  return HexCubePoint(q:  0, r: -1, s: +1) // 5
        case .d150: return HexCubePoint(q: -1, r:  0, s: +1) // 4
        case .d210: return HexCubePoint(q: -1, r: +1, s:  0) // 3
        case .d270: return HexCubePoint(q:  0, r: +1, s: -1) // 2
        case .d330: return HexCubePoint(q: +1, r:  0, s: -1) // 1
        }
    }

    static var allDirections: [HexCubeDirection] {
        return [.d30, .d90, .d150, .d210, .d270, .d330]
    }
}

struct HexCubePoint: Hashable {
    let q: Int
    let r: Int
    let s: Int

    /// Create a hex cube point.
    ///
    /// Precondition: x + y + z = 0
    init(q: Int, r: Int, s: Int) {

        precondition(q + r + s == 0)

        self.q = q
        self.r = r
        self.s = s
    }

    /// Create a hex cube point by rounding floating hex cube coordinates.
    ///
    /// precondition: x + y + z = 0
    init(q: Double, r: Double, s: Double){
        var rq = q.rounded()
        var rr = r.rounded()
        var rs = s.rounded()

        let q_diff = abs(rq - q)
        let r_diff = abs(rr - r)
        let s_diff = abs(rs - s)

        if q_diff > r_diff && q_diff > s_diff {
            rq = -rr-rs
        }
        else if q_diff > s_diff {
            rr = -rq-rs
        }
        else {
            rs = -rq-rr
        }

        self.init(q: Int(rq), r: Int(rr), s: Int(rs))
    }

    init(axial: HexAxialPoint) {
        q = axial.q
        r = -axial.q - axial.r
        s = axial.r
    }

    /// Creates an axial point from cartesian coordinates where the hex size is
    /// `size`.
    init(cartesian point: CartesianPoint, layout: HexCartesianLayout) {
        let M = layout.orientation
        let q, r: Double

        // Normalized coordinates
        let x = (point.x - layout.origin.x) / layout.size.width
        let y = (point.y - layout.origin.y) / layout.size.height

        q = M.b0 * x + M.b1 * y
        r = M.b2 * x + M.b3 * y
        self.init(q: q, r: r, s: -q - r)
    }

    func neighbor(_ direction: HexCubeDirection) -> HexCubePoint {
        return self + direction.unit
    }

    func distance(to other: HexCubePoint) -> Int {
        return max(abs(q-other.q), abs(r-other.r), abs(s-other.s))
    }

    func ring(radius: Int) -> [HexCubePoint] {
        var point = self + HexCubeDirection.d150.unit * radius
        var previous = point 

        guard radius > 0 else {
            return [self]
        }

        // Ring is a hexagon where each side is of length radius + 1 and is
        // oriented in one of the hexagon directions.
        let ringDirections = HexCubeDirection.allDirections.flatMap {
            repeatElement($0, count: radius + 1)
        }

        return ringDirections.map {
            previous = point
            point = point.neighbor($0)
            return previous
        }
    }
    func spiral(radius: Int) -> [HexCubePoint] {
        return (0...radius).flatMap {
            self.ring(radius: $0)
        } 
    }

    // Hashable
    var hashValue: Int { return q.hashValue ^ r.hashValue ^ s.hashValue }
}


func ==(lhs: HexCubePoint, rhs: HexCubePoint) -> Bool {
    return lhs.q == rhs.q && lhs.r == rhs.r && lhs.s == rhs.s
}

func +(lhs: HexCubePoint, rhs: HexCubePoint) -> HexCubePoint {
    return HexCubePoint(q:lhs.q+rhs.q, r:lhs.r+rhs.r, s:lhs.s+rhs.s)
}

func -(lhs: HexCubePoint, rhs: HexCubePoint) -> HexCubePoint {
    return HexCubePoint(q:lhs.q-rhs.q, r:lhs.r-rhs.r, s:lhs.s-rhs.s)
}


func *(lhs: HexCubePoint, scale: Int) -> HexCubePoint {
    return HexCubePoint(q:lhs.q*scale, r:lhs.r*scale, s:lhs.s*scale)
}

enum HexGridShape {
    // Width, Height
    case parallelogram(Int, Int)
    case rectangular(Int, Int)
    // Radius
    case hexagonal(Int)
    // Side size
    case triangular(Int)
}

class HexGrid<T> {
    typealias Cell = T
    typealias Location = HexCubePoint
    let shape: HexGridShape
    let cells: [Location:Cell]

    init(shape: HexGridShape) {
        self.shape = shape
        self.cells = [:]
    }
}
