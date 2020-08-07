//
//  NewsDetailController.swift
//  Study_1_NewsApp
//
//  Created by 김민호 on 2020/08/05.
//  Copyright © 2020 김민호. All rights reserved.
//

import UIKit

class NewsDetailController : UIViewController {
    
    @IBOutlet weak var ImageMain: UIImageView!
    @IBOutlet weak var LabelMain: UILabel!
    
    var imageUrl : String?
    var desc : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = imageUrl {
            if let data = try? Data(contentsOf: URL(string:"")!){
                DispatchQueue.main.async{
                    self.ImageMain.image = UIImage(data:data)
                }
            }
        }
        if let d = desc {
            self.LabelMain.text = d
        }
    }
}
