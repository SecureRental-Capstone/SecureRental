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
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
        mapView.removeAnnotations(mapView.annotations)
        if let selected = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selected.coordinate
            annotation.title = "Drag to adjust"
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

