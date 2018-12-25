//
//  FirstViewController.swift
//  DogeDex
//
//  Created by Doğa Bayram on 30.08.2018.
//  Copyright © 2018 Doğa Bayram. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SVProgressHUD
import MobileCoreServices
import GoogleMobileAds
import Firebase



class FirstViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate,GADBannerViewDelegate,GADInterstitialDelegate {
    
    
    struct Dogs {
        
        
        var name : String?
        var height : String?
        let weight : String?
        let temperament : String?
        let breed_group : String?
        let life_span : String?
        
    }

    let imagePicker = UIImagePickerController()
    var imageView : UIImage?
    var nameOfDog = ""
    let newURL = "https://api.thedogapi.com/v1/breeds?"
    var newDict : [String : Int] = [:]
    var dog = Dogs(name: nil, height: nil, weight: nil, temperament: nil, breed_group: nil, life_span: nil)
    var interstitial: GADInterstitial!
    var counter = 0
    var firstAttempt = false
   

    
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        

        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
          //self.interstitial = self.createAndLoadAd()
        
        self.interstitial = self.createAndLoadAd()

 
        
    }
    
   
    
    func createAndLoadAd() -> GADInterstitial {
        
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }

    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        if counter > 2 {
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    
            self.interstitial = createAndLoadAd()
            counter = 0
        
        }
    
        
      
        
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }

    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        if counter > 2 {
            
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            self.interstitial = createAndLoadAd()
            counter = 0
        }
     
        
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.delegate = self
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        SVProgressHUD.show()
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            imageView = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else  {
                
                fatalError("cannot convert")
                
            }
            
            detect(image: ciImage)
            
        }
        
    
    func imagePickerControllerDidCancel(_ picker :UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
        
    }
    
    
    func detect (image : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Cannot Import model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not classify image")
            }
            
            self.nameOfDog = classification.identifier.capitalized
            self.navigationItem.title = self.nameOfDog
            
            
            print(self.nameOfDog)
            
            }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error")
        }
        
        let firstWordNewName = self.nameOfDog.components(separatedBy: " ").first
        let secondWordNewName = firstWordNewName?.components(separatedBy: ",").first
        
             requestForID(dogName: secondWordNewName) { (success) in
                if success {
                    DispatchQueue.main.async {
                         self.imagePicker.dismiss(animated: true, completion: {
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "SecondVC", sender: self)
                        })
                    }
                   
                    
                }
            }
        
       
        
        
    }
    
    
    func requestForID(dogName : String? = nil ,completion : @escaping ( ( Bool ) -> Void)){
        
        guard let url = URL(string: newURL) else { return }
        
        //  guard let parameters = ["name" : ""] as? [String:Any] else {return}
        
        
        let requestTask = URLSession.shared.dataTask(with: url) { (data, response, error   ) in
            
            
            guard let data = data else {return}
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String : Any]] else { return}
                
                
                for dict in json  {
                    
                    guard let name = dict["name"] as? String else {return}
                    guard let id = dict["id"] as? Int else {return}
                    
                    self.newDict[name] = id
                    
                }
                
                guard let newDogName = dogName else { return}
                 let searchToSearch = newDogName
                let filteredStrings = self.newDict.keys.filter({ (item : String) -> Bool in
                    
                    let stringMatch = item.lowercased().range(of: searchToSearch.lowercased())
                    
                    return stringMatch != nil ? true : false
                    }
                )
                
         
                if filteredStrings.count > 0 {
                
                let id = self.newDict[filteredStrings[0]]
                
                    self.requestForInfo(secondID: id!, completion: { (success) in
                    if success {
                        completion(true)
                    }
                })
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.imagePicker.dismiss(animated: true, completion: {
                            let alert = UIAlertController(title: "Could not find information", message: "Take Picture Again", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                    print("error")
 
                }
                
            }catch {
                print("error")
            }
            
        };requestTask.resume()
        
    
    }

    
    func requestForInfo(secondID : Int,completion : @escaping ( ( Bool ) -> Void)) {
        let infoURL = "https://api.thedogapi.com/v1/breeds/\(secondID)"
        
        guard let url = URL(string: infoURL) else { return }
        
        _ = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            
            guard let data = data else {return}
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else { return}
                
                
                
                self.datasFromJSON(json: json, completion: { (success) in
                    if success {
                        completion(true)
                        
                    }
                })
                
                
            }catch {
                print("error")
            }
            
            }.resume()
        
        
    }
    
    
    
    func datasFromJSON (json : [String : Any]? = nil,completion : @escaping ( ( Bool ) -> Void)) {
        
            
            guard let unWrappedJSON = json else { return }
            guard let name = unWrappedJSON["name"] as? String else { return }
            let height = unWrappedJSON["height"] as! Dictionary<String, AnyObject>
            let firstHeight = height.description.replacingOccurrences(of: "[", with: "")
            let secondHeight = firstHeight.replacingOccurrences(of: "]", with: "")
            let thirdHeight = secondHeight.replacingOccurrences(of: "\"", with: "")
            let weight = unWrappedJSON["weight"] as! Dictionary<String, AnyObject>
            let firstWeight = weight.description.replacingOccurrences(of: "[", with: "")
            let secondWeight = firstWeight.replacingOccurrences(of: "]", with: "")
            let thirdWeight = secondWeight.replacingOccurrences(of: "\"", with: "")

            
            guard let temperament = unWrappedJSON["temperament"] as? String else { return }
            guard let breedGroup = unWrappedJSON["breed_group"] as? String else {return}
            guard let lifeSpan = unWrappedJSON["life_span"] as? String else { return }
            
            
            
        
            self.dog = Dogs(name: name, height: thirdHeight, weight: thirdWeight, temperament: temperament, breed_group: breedGroup, life_span: lifeSpan)
        
        
            
            completion(true)
        
        
        
        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
              if segue.identifier == "SecondVC" {
                let destinationVC = segue.destination as! SecondViewController
                destinationVC.imageViewFVC = imageView
                destinationVC.titleFVC = dog.name
                destinationVC.lifeSpanLabelFVC = dog.life_span
                destinationVC.temperamentLabelFVC = dog.temperament
                destinationVC.weightLabelFVC = dog.weight
                destinationVC.heightLabelFVC = dog.height
            }
        
      
    }
    
    @IBAction func unWind(_ sender: UIStoryboardSegue) {
        
        counter += 1
 
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        print(counter)
      
        
    }

}
