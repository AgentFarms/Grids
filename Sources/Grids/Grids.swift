protocol GridShape {
    associatedtype Location: Hashable

    /// Returns a collection of all locations in the shape
    var locations: AnyCollection<Location> { get }
    /// Returns: origin location of the shape
    var origin: Location { get }
    /// Returns: `true` if the shape contains `location`
    func contains(location: Location) -> Bool
}

class Grid<T, S: GridShape> {
    typealias Cell = T
    typealias Shape = S
    typealias Location = Shape.Location

    let shape: Shape
    let cells: [Location:Cell]

    init(shape: Shape) {
        self.shape = shape
        self.cells = [:]
    }
}
