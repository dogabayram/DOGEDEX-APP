//
//  ViewController.swift
//  DogeDex
//
//  Created by Doğa Bayram on 25.08.2018.
//  Copyright © 2018 Doğa Bayram. All rights reserved.
//

import UIKit
import CoreML
import Vision

class SecondViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textViewLifeSpan: UITextView!
    @IBOutlet weak var temperamentText: UITextView!
    @IBOutlet weak var weightText: UITextView!
    @IBOutlet weak var heightText: UITextView!
    
    
    var titleFVC: String?
    var imageViewFVC :UIImage?
    var lifeSpanLabelFVC : String?
    var temperamentLabelFVC : String?
    var weightLabelFVC : String?
    var heightLabelFVC : String?
    
   

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textViewLifeSpan.setContentOffset(CGPoint.zero, animated: false)
        temperamentText.setContentOffset(CGPoint.zero, animated: false)
        weightText.setContentOffset(CGPoint.zero, animated: false)
        heightText.setContentOffset(CGPoint.zero, animated: false)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleFVC ?? "Could not find title"
        imageView.image = imageViewFVC
        textViewLifeSpan.text = lifeSpanLabelFVC ?? "Could not find any information"
        temperamentText.text = temperamentLabelFVC
        weightText.text = weightLabelFVC
        heightText.text = heightLabelFVC
        
        //print(infoLabelFVC!)

        
    }
}
    
    
    class RoundedImageView: UIImageView {
        override func layoutSubviews() {
            super.layoutSubviews()
            let radius = self.frame.width / 2
            layer.cornerRadius = radius
            clipsToBounds = true
        }
        
    }

    
    
    



