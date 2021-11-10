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
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
        // Bir ekleme yapmadan önce "Cann't MKMapView in scope" diye hata veriyor. Onu   düzeltmek için "import MapKit" ekledik.
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeText: UITextField!
    @IBOutlet weak var noteText: UITextField!
    
    var locationManager = CLLocationManager()
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    var selectedName = ""
    var selectedId : UUID?
    
        // ListVC'den gelen verileri bu sayfada kullanabilmek için bu değişkenleri tanımlayıp buna atıyoruz
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
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
        
        if selectedName != "" {
            if let uuidString = selectedId?.uuidString {
                    // Verileri filtreleme için DB erişim
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Place")
                    // ***** Anasayfada birden fazla nesneyi filtreleme satırı *****
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                
                // ANNOTATION ATAMA
                do {
                    let conclusions = try context.fetch(fetchRequest)
                    if conclusions.count > 0 {
                        for conclusion in conclusions as! [NSManagedObject] {
                                // ID zaten bize attribute olarak geldiği için tekrardan çekmiyoruz
                            if let placeName = conclusion.value(forKey: "placeName") as? String {
                                annotationTitle = placeName
                                if let note = conclusion.value(forKey: "note") as? String {
                                    annotationSubtitle = note
                                    if let longitude = conclusion.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        if let latitude = conclusion.value(forKey: "latitude") as? Double {
                                            annotationLatitude = latitude
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            
                                            let annotationCoordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = annotationCoordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            placeText.text = annotationTitle
                                            noteText.text = annotationSubtitle
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("You've an error in mapsVC annotations!")
                }
            }
        } else {
            print("You've an error in mapsVC annotations else!")
        }
    }
    
    
        //  Yukarıdaki gestureRecognizer içerisine ulaşmak için alttaki fonk.a parametreler verdik.
    @objc func selectLocation (gestureRecognizer : UILongPressGestureRecognizer) {
            // State : Durum, Began : başlamak (begin)
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            
            // NOKTAYI KOORDİNATA ÇEVİRME
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom : mapView)
            
            selectedLatitude = touchCoordinate.latitude
            selectedLongitude = touchCoordinate.longitude
            
                // İşaretleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = placeText.text
            annotation.subtitle = noteText.text
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
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            // Haritadaki bölge
        let region = MKCoordinateRegion(center: locaiton, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        // CONTEXT'E ULAŞIYORUZ
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // VERİ SET'LİYORUZ
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
        newPlace.setValue(placeText.text, forKey: "placeName")
        newPlace.setValue(noteText.text, forKey: "note")
        newPlace.setValue(selectedLatitude, forKey: "latitude")
        newPlace.setValue(selectedLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("kayıt edildi")
        } catch {
            print("devam yeğenim")
        }
    }
}
