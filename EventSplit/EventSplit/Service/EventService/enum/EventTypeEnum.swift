enum EventTypeEnum: String, CaseIterable {
    case musical = "musical"
    case sports = "sports"
    case food = "food"
    case art = "art"
    case theater = "theater"
    case movie = "movie"
    case conference = "conference"
    case other = "other"
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}