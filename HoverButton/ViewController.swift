//
//  ViewController.swift
//  HoverButton
//
//  Created by Ray on 2017/5/25.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let rect = CGRect(x: 20, y: 20, width: 50, height: 50)
        let hover = RHoverButton(frame: rect)
        hover.hoverModel.mainBtnColor = UIColor.brown
        hover.hoverModel.mainBtnSelectColor = UIColor.red
        hover.hoverModel.mainBtnTitle = "主"
        hover.hoverModel.mainBtnSelectTitle = "選"
        hover.hoverModel.subBtnTitles = ["1", "2", "3", "4", "5"]
        hover.hoverModel.subBtnColor = UIColor.brown
        hover.show()
        
        hover.subButtonAction { (index) in
            print("第\(index)顆按鈕")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

