// Point and other primitive structures in Cartesian coordinate system
//

/// Represents a point in Cartesian coordinate system.
struct CartesianPoint: Hashable {
    let x: Double
    let y: Double

    init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}

func ==(lhs: CartesianPoint, rhs: CartesianPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

/// Represents a rectangle size in Cartesian coordinate system.
struct CartesianSize {
    let width: Double
    let height: Double

    init(width: Int, height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    var hashValue: Int {
        return width.hashValue ^ height.hashValue
    }
}

func ==(lhs: CartesianSize, rhs: CartesianSize) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}

/// Represents a rectangle in Cartesian coordinate system.
struct CartesianRect: Hashable {
    let origin: CartesianPoint
    let size: CartesianSize

    init(x: Int, y: Int, width: Int, height: Int) {
        self.origin = CartesianPoint(x:x,y:y)
        self.size = CartesianSize(width:width, height:height)
    }
    init(x: Double, y: Double, width: Double, height: Double) {
        self.origin = CartesianPoint(x:x,y:y)
        self.size = CartesianSize(width:width, height:height)
    }
    init(origin: CartesianPoint, size: CartesianSize) {
        self.origin = origin
        self.size = size
    }

    var width: Double { return size.width }
    var height: Double { return size.height }

    var minX: Double { return origin.x }
    var minY: Double { return origin.y }
    var maxX: Double { return origin.x + size.width }
    var maxY: Double { return origin.y + size.height }

    var standardized: CartesianRect {
        let x,y,w,h: Double
        
        if size.width < 0 {
            x = origin.x - size.width
            w = -size.width
        }
        else {
            x = origin.x
            w = size.width
        }
        if size.height < 0 {
            y = origin.y - size.height
            h = -size.height
        }
        else {
            y = origin.y
            h = size.height
        }
        return CartesianRect(x: x, y: y, width: w, height: h)
    }

    var integral: CartesianRect {
        return CartesianRect(
            x: origin.x.rounded(.down),
            y: origin.y.rounded(.down),
            width: size.width.rounded(.up),
            height: size.height.rounded(.up)
        )
    }

    func insetBy(dx: Double, dy: Double) -> CartesianRect {
        let std = standardized
        return CartesianRect(
            x: std.origin.x + dx,
            y: std.origin.y + dy,
            width: std.width + 2*dx,
            height: std.height + 2*dy
        )
    }

    func offsetBy(dx: Double, dy: Double) -> CartesianRect {
        return CartesianRect(
            x: origin.x+dx,
            y: origin.y+dy,
            width: size.width,
            height: size.height
        )
    }

    /// Cartesian rectangle where origin and size are zero.
    static var zero: CartesianRect {
        return CartesianRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    }


    var hashValue: Int {
        return origin.hashValue ^ size.hashValue
    }

}

func ==(lhs: CartesianRect, rhs: CartesianRect) -> Bool {
    return lhs.origin == rhs.origin && lhs.size == rhs.size
}
