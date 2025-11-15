//
//  MapViewRepresentable.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-21.
//
import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: IdentifiableCoordinate?
    
    let nearbyListings: [Listing]    // 👈 NEW
    let radiusKm: Double             // 👈 NEW
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        // Handle tap gesture to drop or move pin
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let locationInView = gesture.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            parent.updateAnnotation(on: mapView, coordinate: tappedCoordinate)
        }
        
        // Enable draggable annotation
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            // main draggable pin (our selected location)
            if annotation.title ?? "" == "Drag to adjust" {
                let identifier = "DraggablePin"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
                
                if view == nil {
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.isDraggable = true
                    view?.canShowCallout = true
                    view?.pinTintColor = .systemBlue
                } else {
                    view?.annotation = annotation
                }
                
                return view
            } else {
                // listing pins = non-draggable
                let identifier = "ListingPin"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    view?.markerTintColor = .systemGreen
                } else {
                    view?.annotation = annotation
                }
                return view
            }
        }
        
        // Update coordinate when dragged
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard let annotation = view.annotation else { return }
            if newState == .ending {
                parent.selectedCoordinate = IdentifiableCoordinate(coordinate: annotation.coordinate)
                parent.region.center = annotation.coordinate
            }
        }
        
        // Radius circle renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.15)
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.7)
                renderer.lineWidth = 1.5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // remove everything first
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // main selected pin
        if let selected = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selected.coordinate
            annotation.title = "Drag to adjust"
            mapView.addAnnotation(annotation)
            
            // add radius circle
            let circle = MKCircle(center: selected.coordinate,
                                  radius: radiusKm * 1000) // km -> meters
            mapView.addOverlay(circle)
        }
        
        // nearby listing pins
        for listing in nearbyListings {
            guard let lat = listing.latitude,
                  let lon = listing.longitude else { continue }
            
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = listing.title
            annotation.subtitle = "$\(listing.price)/month"
            mapView.addAnnotation(annotation)
        }
    }
    
    func updateAnnotation(on mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Drag to adjust"
        mapView.addAnnotation(annotation)
        
        DispatchQueue.main.async {
            self.selectedCoordinate = IdentifiableCoordinate(coordinate: coordinate)
            self.region.center = coordinate
        }
    }
}
