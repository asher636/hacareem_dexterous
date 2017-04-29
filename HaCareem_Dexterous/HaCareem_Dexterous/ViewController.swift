//
//  ViewController.swift
//  HaCareem_Dexterous
//
//  Created by Asher Ahsan on 29/04/2017.
//  Copyright © 2017 Asher Ahsan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentControl: RoundSegmentControl!
    @IBOutlet weak var checkImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkImage.setRounded()
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!, forKey: NSFontAttributeName as NSCopying)
        segmentControl.setTitleTextAttributes(attr as! [AnyHashable : Any], for: .normal)
    }

    


}

