//
//  FilterEventsDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI
import MapKit

struct FilterEventsDrawer: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @Binding var selectedRadius: String
    @Binding var selectedType: EventTypeEnum?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @StateObject private var mapState = MapState()
    
    var body: some View {
        VStack(spacing: 20) {
            //Spacer()
            // Map View
            Map(coordinateRegion: $mapState.region, showsUserLocation: true)
                .frame(height: 300)
                .cornerRadius(12)
                .overlay(
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 300, height: 300)
                )
            
            // Radius Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Radius: \(Int(Double(selectedRadius) ?? 20))km")
                    .font(.headline)
                
                Slider(value: Binding(
                    get: { Double(selectedRadius) ?? 20.0 },
                    set: { newValue in
                        selectedRadius = String(Int(newValue))
                        mapState.updateRegion(radius: newValue)
                    }
                ), in: 1...1000, step: 10)
                .tint(.blue)
            }
            .padding()
            .background(Color.highLightBackground)
            .cornerRadius(12)
            
            HStack {
                // Date Range Filter
                DateRangeFilter(
                    startDate: $startDate,
                    endDate: $endDate
                ) {}
                    .padding()
                    .background(Color.highLightBackground)
                    .cornerRadius(12)
                
                Spacer()
                
                // Event Type Filter
                EventTypeFilter(selectedType: $selectedType) {}
                    .padding()
                    .background(Color.highLightBackground)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .onReceive(locationManager.$location) { location in
            guard let location = location else { return }
            mapState.setInitialLocation(location.coordinate)
        }
        .background(.primaryBackground)
    }
}

class MapState: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    func setInitialLocation(_ coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.region.center = coordinate
            self.updateRegion(radius: 20)
        }
    }
    
    func updateRegion(radius: Double) {
        DispatchQueue.main.async {
            let latDelta = (radius / 111.0) * 2
            let lonDelta = latDelta
            
            self.region.span = MKCoordinateSpan(
                latitudeDelta: latDelta,
                longitudeDelta: lonDelta
            )
        }
    }
}
