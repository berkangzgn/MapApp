//
//  ViewController.swift
//  MapApp
//
//  Created by Berkan Gezgin on 8.11.2021.
//

import UIKit
import MapKit
    // Konum bilgilerimizi alması için
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
        // Bir ekleme yapmadan önce "Cann't MKMapView in scope" diye hata veriyor. Onu   düzeltmek için "import MapKit" ekledik.
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Delegate : Herhangi bir olay olduğunda bir nesnenin başka bir nesneye haber göndermesini sağlayan Design Pattern'dir.
            // Bu satırda da mapView Delegate tanımı yaptık.
        mapView.delegate = self
        locationManager.delegate = self
        
        // KONUM ALMA
            // Konum bilgilerini saptama için en iyi konum seçeneğini seçtik. kCL sonrasını değiştirip araştırmalı / denemelisin.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // Kullanıcıya konum isteğini sorduk.
        locationManager.requestWhenInUseAuthorization()
            // Location güncellemeye başladık.
        locationManager.startUpdatingLocation()
        
            // Kullanıcının işaretleme yapabilmesi için
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
            // Minimum basma süresini ayarladık.
        gestureRecognizer.minimumPressDuration = 2
            // Noktayı haritaya ekledik.
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    
        //  Yukarıdaki gestureRecognizer içerisine ulaşmak için alttaki fonk.a parametreler verdik.
    @objc func selectLocation (gestureRecognizer : UILongPressGestureRecognizer) {
            // State : Durum, Began : başlamak (begin)
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            
            // NOKTAYI KOORDİNATA ÇEVİRME
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom : mapView)
            
                // İşaretleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Kullanıcı Seçimi"
            annotation.subtitle = "Örnek altyazı"
            mapView.addAnnotation(annotation)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // altitude - yükseklik
        // coordinate.latitude - enlem
        // coordinate.longitude - boylam
        
        //print(locations[0].coordinate.latitude) : x noktasını yazdırma
        //print(locations[0].coordinate.longitude) : y noktasını yazdırma
        
        let locaiton = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        // Konumu değiştirmek için
            // Belirtilen bölgenin yükseklik ve genişliği. Zoom durumunda seçtiğimiz yerin büyüklüğünün değişmesi durumu. Eğer çok fazla zoom göstermesin istiyorsak 0.9, 0.9a çekebiliriz.
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            // Haritadaki bölge
        let region = MKCoordinateRegion(center: locaiton, span: span)
        mapView.setRegion(region, animated: true)
    }
}
